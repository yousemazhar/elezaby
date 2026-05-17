import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {logger} from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

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
