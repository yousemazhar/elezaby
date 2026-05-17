import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {logger} from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

const CART_ABANDON_SECONDS = 30;

export const onOrderCreated = onDocumentCreated(
  "orders/{orderId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const order = snap.data();
    const userId: string | undefined = order.userId;
    if (!userId) {
      logger.warn("Order missing userId", {orderId: event.params.orderId});
      return;
    }

    const isPrescription = order.type === "prescription";
    const title = isPrescription
      ? "Prescription received"
      : "Order confirmed";
    const body = isPrescription
      ? "We received your prescription. Our pharmacist will review it shortly."
      : `Your order has been placed successfully.` +
        (typeof order.total === "number"
          ? ` Total: EGP ${order.total.toFixed(2)}.`
          : "");

    const tokensSnap = await db
      .collection("users")
      .doc(userId)
      .collection("fcmTokens")
      .get();

    const tokens = tokensSnap.docs
      .map((d) => d.get("token") as string | undefined)
      .filter((t): t is string => typeof t === "string" && t.length > 0);

    if (tokens.length === 0) {
      logger.info("No FCM tokens for user", {userId});
      return;
    }

    const response = await messaging.sendEachForMulticast({
      tokens,
      notification: {title, body},
      data: {
        orderId: event.params.orderId,
        type: isPrescription ? "prescription" : "order",
      },
      android: {
        notification: {
          channelId: "elezaby_default_channel",
        },
      },
    });

    const stale: Promise<unknown>[] = [];
    response.responses.forEach((r, i) => {
      if (r.success) return;
      const code = r.error?.code;
      if (
        code === "messaging/invalid-registration-token" ||
        code === "messaging/registration-token-not-registered"
      ) {
        stale.push(
          db
            .collection("users")
            .doc(userId)
            .collection("fcmTokens")
            .doc(tokens[i])
            .delete()
            .catch(() => undefined),
        );
      }
    });
    await Promise.all(stale);

    logger.info("Order notification sent", {
      orderId: event.params.orderId,
      successCount: response.successCount,
      failureCount: response.failureCount,
    });
  },
);

export const cartAbandonmentScan = onSchedule(
  "every 1 minutes",
  async () => {
    const now = admin.firestore.Timestamp.now();
    const cutoff = admin.firestore.Timestamp.fromMillis(
      now.toMillis() - CART_ABANDON_SECONDS * 1000,
    );

    let itemsSnap: FirebaseFirestore.QuerySnapshot;
    try {
      itemsSnap = await db
        .collectionGroup("items")
        .where("addedAt", "<=", cutoff)
        .get();
    } catch (err) {
      const e = err as {message?: string; details?: string; code?: number};
      logger.error("Cart abandonment query failed", {
        code: e.code,
        message: e.message,
        details: e.details,
      });
      return;
    }

    const oldestByUser = new Map<string, FirebaseFirestore.Timestamp>();
    for (const doc of itemsSnap.docs) {
      const cartRef = doc.ref.parent.parent;
      if (!cartRef || cartRef.parent.id !== "carts") continue;
      const uid = cartRef.id;
      const addedAt = doc.get("addedAt") as
        | FirebaseFirestore.Timestamp
        | undefined;
      if (!addedAt) continue;
      const current = oldestByUser.get(uid);
      if (!current || addedAt.toMillis() < current.toMillis()) {
        oldestByUser.set(uid, addedAt);
      }
    }

    if (oldestByUser.size === 0) {
      logger.info("Cart abandonment scan: no abandoned carts");
      return;
    }

    let notified = 0;
    for (const [uid, oldestAddedAt] of oldestByUser) {
      try {
        const cartRef = db.collection("carts").doc(uid);
        const cartSnap = await cartRef.get();
        const lastNotified = cartSnap.get("lastAbandonNotifiedAt") as
          | FirebaseFirestore.Timestamp
          | undefined;
        if (
          lastNotified &&
          lastNotified.toMillis() >= oldestAddedAt.toMillis()
        ) {
          continue;
        }

        const tokensSnap = await db
          .collection("users")
          .doc(uid)
          .collection("fcmTokens")
          .get();

        const tokens = tokensSnap.docs
          .map((d) => d.get("token") as string | undefined)
          .filter(
            (t): t is string => typeof t === "string" && t.length > 0,
          );

        if (tokens.length === 0) {
          logger.info("No FCM tokens for abandoned cart user", {uid});
          await cartRef.set(
            {lastAbandonNotifiedAt: admin.firestore.FieldValue
              .serverTimestamp()},
            {merge: true},
          );
          continue;
        }

        const response = await messaging.sendEachForMulticast({
          tokens,
          notification: {
            title: "Items waiting in your cart",
            body:
              "You left items in your cart — come back and complete " +
              "your order.",
          },
          data: {type: "cart_abandoned"},
          android: {
            notification: {channelId: "elezaby_default_channel"},
          },
        });

        const stale: Promise<unknown>[] = [];
        response.responses.forEach((r, i) => {
          if (r.success) return;
          const code = r.error?.code;
          if (
            code === "messaging/invalid-registration-token" ||
            code === "messaging/registration-token-not-registered"
          ) {
            stale.push(
              db
                .collection("users")
                .doc(uid)
                .collection("fcmTokens")
                .doc(tokens[i])
                .delete()
                .catch(() => undefined),
            );
          }
        });
        await Promise.all(stale);

        await cartRef.set(
          {lastAbandonNotifiedAt: admin.firestore.FieldValue
            .serverTimestamp()},
          {merge: true},
        );

        notified += response.successCount;
      } catch (err) {
        logger.error("Cart abandonment send failed", {uid, err});
      }
    }

    logger.info("Cart abandonment scan complete", {
      candidateUsers: oldestByUser.size,
      notified,
    });
  },
);
