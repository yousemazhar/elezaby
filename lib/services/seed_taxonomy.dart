// Static taxonomy for pharma sub-categories and 2nd-level sub-categories.
// Tier definitions feed both the Firestore seed and the heuristic that
// assigns each product to a sub / sub-sub category based on its
// active ingredient and dosage form.

class SubcategoryDef {
  final String id;
  final String categoryId;
  final String name;
  final String emoji;
  final int sortOrder;
  const SubcategoryDef(
      this.id, this.categoryId, this.name, this.emoji, this.sortOrder);
}

class SubSubcategoryDef {
  final String id;
  final String categoryId;
  final String subcategoryId;
  final String name;
  final String emoji;
  final int sortOrder;
  const SubSubcategoryDef(this.id, this.categoryId, this.subcategoryId,
      this.name, this.emoji, this.sortOrder);
}

const kSubcategories = <SubcategoryDef>[
  // cardiovascular
  SubcategoryDef(
      'cv_antihypertensives', 'cardiovascular', 'Antihypertensives', '🩺', 1),
  SubcategoryDef('cv_anticoagulants', 'cardiovascular',
      'Anticoagulants & Antiplatelets', '🩸', 2),
  SubcategoryDef('cv_statins', 'cardiovascular', 'Statins', '📊', 3),
  SubcategoryDef('cv_diuretics', 'cardiovascular', 'Diuretics', '💧', 4),
  SubcategoryDef('cv_antianginals', 'cardiovascular', 'Antianginals', '💓', 5),
  SubcategoryDef(
      'cv_peripheral', 'cardiovascular', 'Peripheral Circulation', '🫀', 6),
  SubcategoryDef('cv_other', 'cardiovascular', 'Other Cardio', '❤️', 7),

  // psychiatric_neuro
  SubcategoryDef(
      'pn_antipsychotics', 'psychiatric_neuro', 'Antipsychotics', '🧠', 1),
  SubcategoryDef(
      'pn_antidepressants', 'psychiatric_neuro', 'Antidepressants', '💙', 2),
  SubcategoryDef(
      'pn_antiepileptics', 'psychiatric_neuro', 'Anti-epileptics', '⚡', 3),
  SubcategoryDef('pn_anxiolytics', 'psychiatric_neuro', 'Anxiolytics', '😴', 4),
  SubcategoryDef('pn_adhd', 'psychiatric_neuro', 'ADHD', '🎯', 5),
  SubcategoryDef('pn_neurology', 'psychiatric_neuro', 'Neurology', '🔬', 6),
  SubcategoryDef('pn_nootropics', 'psychiatric_neuro', 'Nootropics', '🧩', 7),

  // respiratory_allergy
  SubcategoryDef(
      'ra_antihistamines', 'respiratory_allergy', 'Antihistamines', '🌸', 1),
  SubcategoryDef(
      'ra_bronchodilators', 'respiratory_allergy', 'Bronchodilators', '🫁', 2),
  SubcategoryDef('ra_nasal', 'respiratory_allergy', 'Nasal Sprays', '💨', 3),
  SubcategoryDef('ra_coldflu', 'respiratory_allergy', 'Cold & Flu', '🤧', 4),
  SubcategoryDef(
      'ra_cough', 'respiratory_allergy', 'Cough & Expectorants', '🫧', 5),

  // diabetes_metabolism
  SubcategoryDef(
      'dm_antidiabetics', 'diabetes_metabolism', 'Antidiabetics', '🩺', 1),
  SubcategoryDef('dm_insulin', 'diabetes_metabolism', 'Insulin', '💉', 2),
  SubcategoryDef('dm_thyroid', 'diabetes_metabolism', 'Thyroid', '🦋', 3),
  SubcategoryDef(
      'dm_endocrine', 'diabetes_metabolism', 'Endocrine Therapy', '⚙️', 4),
  SubcategoryDef(
      'dm_other', 'diabetes_metabolism', 'Other Metabolism', '🧬', 5),

  // pain_inflammation
  SubcategoryDef('pi_analgesics', 'pain_inflammation', 'Analgesics', '💊', 1),
  SubcategoryDef('pi_nsaids', 'pain_inflammation', 'NSAIDs', '🌡️', 2),
  SubcategoryDef('pi_muscle', 'pain_inflammation', 'Muscle Relaxants', '💪', 3),
  SubcategoryDef('pi_local_anaesthetics', 'pain_inflammation',
      'Local Anaesthetics', '🩺', 4),
  SubcategoryDef(
      'pi_antirheumatic', 'pain_inflammation', 'Anti-Rheumatic', '🦴', 5),
  SubcategoryDef(
      'pi_topical_pain', 'pain_inflammation', 'Topical Pain Relief', '🤲', 6),
  SubcategoryDef('pi_opioid_related', 'pain_inflammation',
      'Opioid-Related Therapy', '🔒', 7),

  // antibiotics
  SubcategoryDef('ab_antibiotics', 'antibiotics', 'Antibiotics', '🦠', 1),
  SubcategoryDef('ab_antifungals', 'antibiotics', 'Antifungals', '🍄', 2),
  SubcategoryDef(
      'ab_topical', 'antibiotics', 'Topical Anti-infectives', '🧴', 3),
  SubcategoryDef(
      'ab_ophthalmic', 'antibiotics', 'Ophthalmic Anti-infectives', '👁️', 4),
  SubcategoryDef(
      'ab_derm_topicals', 'antibiotics', 'Dermatology Topicals', '🧴', 5),

  // gastrointestinal
  SubcategoryDef('gi_acid', 'gastrointestinal', 'Acid Relief', '🫀', 1),
  SubcategoryDef('gi_antiemetics', 'gastrointestinal', 'Antiemetics', '🤢', 2),
  SubcategoryDef('gi_bowel', 'gastrointestinal', 'Bowel Care', '🚽', 3),
  SubcategoryDef(
      'gi_haemorrhoids', 'gastrointestinal', 'Haemorrhoids', '💊', 4),
  SubcategoryDef('gi_bladder', 'gastrointestinal', 'Bladder Care', '💧', 5),
  SubcategoryDef('gi_renal', 'gastrointestinal', 'Renal Stones', '🪨', 6),

  // vitamins_supplements
  SubcategoryDef('vs_vitamins', 'vitamins_supplements', 'Vitamins', '🌟', 1),
  SubcategoryDef('vs_minerals', 'vitamins_supplements', 'Minerals', '💊', 2),
  SubcategoryDef(
      'vs_multivitamins', 'vitamins_supplements', 'Multivitamins', '🌈', 3),
  SubcategoryDef('vs_immunity', 'vitamins_supplements', 'Immunity', '🛡️', 4),
  SubcategoryDef('vs_joint', 'vitamins_supplements', 'Joint Support', '🦴', 5),

  // dermatology
  SubcategoryDef('dr_hair_care', 'dermatology', 'Hair Care', '💇', 1),
  SubcategoryDef('dr_skin_care', 'dermatology', 'Skin Care', '🧴', 2),
  SubcategoryDef('dr_shampoos', 'dermatology', 'Shampoos', '🚿', 3),
  SubcategoryDef('dr_antiseptics', 'dermatology', 'Antiseptics', '🧼', 4),
  SubcategoryDef(
      'dr_topical_antibiotics', 'dermatology', 'Topical Antibiotics', '🩹', 5),

  // oncology
  SubcategoryDef('on_hormonal', 'oncology', 'Hormonal Therapy', '🔬', 1),
  SubcategoryDef('on_cytotoxic', 'oncology', 'Cytotoxic', '💉', 2),
  SubcategoryDef('on_supportive', 'oncology', 'Supportive Care', '🎗️', 3),

  // other
  SubcategoryDef('ot_general', 'other', 'General', '🏥', 1),
];

const kSubSubcategories = <SubSubcategoryDef>[
  // cv_antihypertensives
  SubSubcategoryDef('cv_ace', 'cardiovascular', 'cv_antihypertensives',
      'ACE Inhibitors', '🩺', 1),
  SubSubcategoryDef(
      'cv_arb', 'cardiovascular', 'cv_antihypertensives', 'ARBs', '🩺', 2),
  SubSubcategoryDef('cv_ccb', 'cardiovascular', 'cv_antihypertensives',
      'Calcium Channel Blockers', '🩺', 3),
  SubSubcategoryDef('cv_bb', 'cardiovascular', 'cv_antihypertensives',
      'Beta Blockers', '❤️‍🩹', 4),
  SubSubcategoryDef('cv_combo', 'cardiovascular', 'cv_antihypertensives',
      'Combination', '⚗️', 5),

  // cv_anticoagulants
  SubSubcategoryDef(
      'cv_doac', 'cardiovascular', 'cv_anticoagulants', 'DOACs', '🩸', 1),
  SubSubcategoryDef('cv_antiplatelet', 'cardiovascular', 'cv_anticoagulants',
      'Antiplatelets', '🩸', 2),
  SubSubcategoryDef('cv_vk', 'cardiovascular', 'cv_anticoagulants',
      'Vitamin K Antag.', '🩸', 3),

  // cv_statins
  SubSubcategoryDef(
      'cv_statin_only', 'cardiovascular', 'cv_statins', 'Statins', '📊', 1),

  // cv_diuretics
  SubSubcategoryDef(
      'cv_diu_thiazide', 'cardiovascular', 'cv_diuretics', 'Thiazide', '💧', 1),
  SubSubcategoryDef(
      'cv_diu_loop', 'cardiovascular', 'cv_diuretics', 'Loop', '💧', 2),
  SubSubcategoryDef(
      'cv_diu_kspare', 'cardiovascular', 'cv_diuretics', 'K-Sparing', '💧', 3),

  // cv_antianginals
  SubSubcategoryDef('cv_ang_nitrate', 'cardiovascular', 'cv_antianginals',
      'Nitrates', '💓', 1),
  SubSubcategoryDef('cv_ang_other', 'cardiovascular', 'cv_antianginals',
      'Other Antianginals', '💓', 2),

  // cv_peripheral
  SubSubcategoryDef('cv_periph_vasodilator', 'cardiovascular', 'cv_peripheral',
      'Peripheral Vasodilators', '🫀', 1),

  // cv_other
  SubSubcategoryDef(
      'cv_other_general', 'cardiovascular', 'cv_other', 'General', '❤️', 1),

  // psychiatric_neuro
  SubSubcategoryDef('pn_typical', 'psychiatric_neuro', 'pn_antipsychotics',
      'Typical', '🧠', 1),
  SubSubcategoryDef('pn_atypical', 'psychiatric_neuro', 'pn_antipsychotics',
      'Atypical', '🧠', 2),
  SubSubcategoryDef(
      'pn_ssri', 'psychiatric_neuro', 'pn_antidepressants', 'SSRIs', '💙', 1),
  SubSubcategoryDef(
      'pn_snri', 'psychiatric_neuro', 'pn_antidepressants', 'SNRIs', '💙', 2),
  SubSubcategoryDef('pn_tca', 'psychiatric_neuro', 'pn_antidepressants',
      'Tricyclics', '💙', 3),
  SubSubcategoryDef('pn_ae', 'psychiatric_neuro', 'pn_antiepileptics',
      'Anti-epileptics', '⚡', 1),
  SubSubcategoryDef(
      'pn_anx', 'psychiatric_neuro', 'pn_anxiolytics', 'Anxiolytics', '😴', 1),
  SubSubcategoryDef(
      'pn_adhd_gen', 'psychiatric_neuro', 'pn_adhd', 'ADHD', '🎯', 1),
  SubSubcategoryDef('pn_neuro_gen', 'psychiatric_neuro', 'pn_neurology',
      'General Neuro', '🔬', 1),
  SubSubcategoryDef('pn_noot_gen', 'psychiatric_neuro', 'pn_nootropics',
      'Nootropics', '🧩', 1),

  // respiratory_allergy
  SubSubcategoryDef('ra_anti_h1', 'respiratory_allergy', 'ra_antihistamines',
      '1st Gen', '🌸', 1),
  SubSubcategoryDef('ra_anti_h2', 'respiratory_allergy', 'ra_antihistamines',
      '2nd Gen', '🌸', 2),
  SubSubcategoryDef('ra_bronch_inh', 'respiratory_allergy',
      'ra_bronchodilators', 'Inhalers', '🫁', 1),
  SubSubcategoryDef('ra_bronch_tab', 'respiratory_allergy',
      'ra_bronchodilators', 'Tablets', '🫁', 2),
  SubSubcategoryDef('ra_nasal_decongestant', 'respiratory_allergy', 'ra_nasal',
      'Nasal Decongestants', '💨', 1),
  SubSubcategoryDef('ra_nasal_steroid', 'respiratory_allergy', 'ra_nasal',
      'Nasal Corticosteroids', '💨', 2),
  SubSubcategoryDef('ra_nasal_gen', 'respiratory_allergy', 'ra_nasal',
      'Other Nasal Sprays', '💨', 3),
  SubSubcategoryDef(
      'ra_cf_gen', 'respiratory_allergy', 'ra_coldflu', 'Cold & Flu', '🤧', 1),
  SubSubcategoryDef('ra_cf_throat', 'respiratory_allergy', 'ra_coldflu',
      'Throat Lozenges', '🍬', 2),
  SubSubcategoryDef('ra_cough_mucolytic', 'respiratory_allergy', 'ra_cough',
      'Mucolytics', '🫧', 1),
  SubSubcategoryDef('ra_cough_expect', 'respiratory_allergy', 'ra_cough',
      'Expectorants', '🫧', 2),

  // diabetes_metabolism
  SubSubcategoryDef('dm_sglt2', 'diabetes_metabolism', 'dm_antidiabetics',
      'SGLT2 Inhibitors', '💉', 1),
  SubSubcategoryDef('dm_dpp4', 'diabetes_metabolism', 'dm_antidiabetics',
      'DPP-4 Inhibitors', '🔬', 2),
  SubSubcategoryDef('dm_glinide', 'diabetes_metabolism', 'dm_antidiabetics',
      'Glinides', '🔬', 3),
  SubSubcategoryDef('dm_biguanide', 'diabetes_metabolism', 'dm_antidiabetics',
      'Biguanides', '🧬', 4),
  SubSubcategoryDef(
      'dm_ins_gen', 'diabetes_metabolism', 'dm_insulin', 'Insulin', '💉', 1),
  SubSubcategoryDef(
      'dm_thy_gen', 'diabetes_metabolism', 'dm_thyroid', 'Thyroid', '🦋', 1),
  SubSubcategoryDef('dm_dopamine_agonist', 'diabetes_metabolism',
      'dm_endocrine', 'Dopamine Agonists', '⚙️', 1),
  SubSubcategoryDef('dm_other_gen', 'diabetes_metabolism', 'dm_other',
      'Vitamin D & Calcium', '🦴', 1),

  // pain_inflammation
  SubSubcategoryDef('pi_anal_gen', 'pain_inflammation', 'pi_analgesics',
      'Analgesics', '💊', 1),
  SubSubcategoryDef('pi_nsaid_oral', 'pain_inflammation', 'pi_nsaids',
      'Oral NSAIDs', '🌡️', 1),
  SubSubcategoryDef('pi_nsaid_topical', 'pain_inflammation', 'pi_nsaids',
      'Topical NSAIDs', '🌡️', 2),
  SubSubcategoryDef('pi_mr_gen', 'pain_inflammation', 'pi_muscle',
      'Muscle Relaxants', '💪', 1),
  SubSubcategoryDef('pi_la_gen', 'pain_inflammation', 'pi_local_anaesthetics',
      'Local Anaesthetics', '🩺', 1),
  SubSubcategoryDef('pi_ar_dmard', 'pain_inflammation', 'pi_antirheumatic',
      'DMARDs', '🦴', 1),
  SubSubcategoryDef('pi_ar_joint', 'pain_inflammation', 'pi_antirheumatic',
      'Joint Support', '🦴', 2),
  SubSubcategoryDef(
      'pi_top_gen', 'pain_inflammation', 'pi_topical_pain', 'Topical', '🤲', 1),
  SubSubcategoryDef('pi_opioid_antagonist', 'pain_inflammation',
      'pi_opioid_related', 'Opioid Antagonists', '🔒', 1),

  // antibiotics
  SubSubcategoryDef(
      'ab_pen', 'antibiotics', 'ab_antibiotics', 'Penicillins', '🦠', 1),
  SubSubcategoryDef(
      'ab_ceph', 'antibiotics', 'ab_antibiotics', 'Cephalosporins', '🦠', 2),
  SubSubcategoryDef(
      'ab_macro', 'antibiotics', 'ab_antibiotics', 'Macrolides', '🦠', 3),
  SubSubcategoryDef('ab_fluoro', 'antibiotics', 'ab_antibiotics',
      'Fluoroquinolones', '🦠', 4),
  SubSubcategoryDef('ab_other', 'antibiotics', 'ab_antibiotics',
      'Other Antibacterial', '🦠', 5),
  SubSubcategoryDef(
      'ab_af_gen', 'antibiotics', 'ab_antifungals', 'Antifungals', '🍄', 1),
  SubSubcategoryDef(
      'ab_top_gen', 'antibiotics', 'ab_topical', 'Topical', '🧴', 1),
  SubSubcategoryDef('ab_eye_fluoro', 'antibiotics', 'ab_ophthalmic',
      'Fluoroquinolone Eye Drops', '👁️', 1),
  SubSubcategoryDef('ab_derm_hair_inhibitor', 'antibiotics', 'ab_derm_topicals',
      'Hair Growth Inhibitors', '💇', 1),

  // gastrointestinal
  SubSubcategoryDef('gi_ppi', 'gastrointestinal', 'gi_acid', 'PPIs', '🫀', 1),
  SubSubcategoryDef(
      'gi_h2', 'gastrointestinal', 'gi_acid', 'H2 Blockers', '🫀', 2),
  SubSubcategoryDef(
      'gi_antacid', 'gastrointestinal', 'gi_acid', 'Antacids', '🫀', 3),
  SubSubcategoryDef('gi_anti_em', 'gastrointestinal', 'gi_antiemetics',
      'Antiemetics', '🤢', 1),
  SubSubcategoryDef(
      'gi_bowel_gen', 'gastrointestinal', 'gi_bowel', 'Bowel Care', '🚽', 1),
  SubSubcategoryDef('gi_haem_gen', 'gastrointestinal', 'gi_haemorrhoids',
      'Haemorrhoids', '💊', 1),
  SubSubcategoryDef('gi_bladder_gen', 'gastrointestinal', 'gi_bladder',
      'Bladder Care', '💧', 1),
  SubSubcategoryDef(
      'gi_renal_gen', 'gastrointestinal', 'gi_renal', 'Renal Stones', '🪨', 1),

  // vitamins_supplements
  SubSubcategoryDef('vs_vit_gen', 'vitamins_supplements', 'vs_vitamins',
      'Single Vitamins', '🌟', 1),
  SubSubcategoryDef(
      'vs_min_gen', 'vitamins_supplements', 'vs_minerals', 'Minerals', '💊', 1),
  SubSubcategoryDef('vs_mvi_gen', 'vitamins_supplements', 'vs_multivitamins',
      'Multivitamins', '🌈', 1),
  SubSubcategoryDef('vs_imm_gen', 'vitamins_supplements', 'vs_immunity',
      'Immunity', '🛡️', 1),
  SubSubcategoryDef('vs_joint_gen', 'vitamins_supplements', 'vs_joint',
      'Joint Support', '🦴', 1),

  // dermatology
  SubSubcategoryDef(
      'dr_hl', 'dermatology', 'dr_hair_care', 'Hair Loss', '💇', 1),
  SubSubcategoryDef(
      'dr_hair_color', 'dermatology', 'dr_hair_care', 'Hair Coloring', '🎨', 2),
  SubSubcategoryDef('dr_sk_general', 'dermatology', 'dr_skin_care',
      'General Skin Care', '🧴', 1),
  SubSubcategoryDef(
      'dr_sk_acne', 'dermatology', 'dr_skin_care', 'Acne', '🧼', 2),
  SubSubcategoryDef(
      'dr_sh_gen', 'dermatology', 'dr_shampoos', 'Shampoos', '🚿', 1),
  SubSubcategoryDef('dr_antiseptic_gen', 'dermatology', 'dr_antiseptics',
      'Skin Antiseptics', '🧼', 1),
  SubSubcategoryDef('dr_top_ab_gen', 'dermatology', 'dr_topical_antibiotics',
      'Topical Antibiotics', '🩹', 1),

  // oncology
  SubSubcategoryDef(
      'on_anti_estrogen', 'oncology', 'on_hormonal', 'Anti-Estrogen', '🔬', 1),
  SubSubcategoryDef('on_aromatase', 'oncology', 'on_hormonal',
      'Aromatase Inhibitors', '💉', 2),
  SubSubcategoryDef(
      'on_anti_androgen', 'oncology', 'on_hormonal', 'Anti-Androgen', '🔬', 3),
  SubSubcategoryDef(
      'on_cyto_gen', 'oncology', 'on_cytotoxic', 'Cytotoxic', '💉', 1),
  SubSubcategoryDef(
      'on_sup_gen', 'oncology', 'on_supportive', 'Supportive Care', '🎗️', 1),

  // other
  SubSubcategoryDef('ot_gen_gen', 'other', 'ot_general', 'General', '🏥', 1),
];

/// Assign a (subcategoryId, subSubcategoryId) for a product based on its
/// active ingredient, dosage form and category. Returns sensible defaults
/// when the heuristic can't identify a more specific bucket.
({String sub, String subSub}) classifyProduct({
  required String categoryId,
  required String activeIngredient,
  required String dosageForm,
}) {
  final ai = activeIngredient.toLowerCase();
  final df = dosageForm.toLowerCase();

  bool has(List<String> needles) => needles.any(ai.contains);

  switch (categoryId) {
    case 'cardiovascular':
      // Combo antihypertensives first.
      if (has([
        'olmesartan',
        'candesartan',
        'valsartan',
        'losartan',
        'telmisartan',
        'irbesartan'
      ])) {
        if (has(['amlodipine', 'hydrochlorothiazide', 'felodipine'])) {
          return (sub: 'cv_antihypertensives', subSub: 'cv_combo');
        }
        return (sub: 'cv_antihypertensives', subSub: 'cv_arb');
      }
      if (has([
        'lisinopril',
        'enalapril',
        'captopril',
        'ramipril',
        'perindopril'
      ])) {
        return (sub: 'cv_antihypertensives', subSub: 'cv_ace');
      }
      if (has(['amlodipine', 'felodipine', 'nifedipine', 'lercanidipine'])) {
        return (sub: 'cv_antihypertensives', subSub: 'cv_ccb');
      }
      if (has([
        'metoprolol',
        'propranolol',
        'carvedilol',
        'bisoprolol',
        'nebivolol',
        'sotalol',
        'atenolol'
      ])) {
        return (sub: 'cv_antihypertensives', subSub: 'cv_bb');
      }
      if (has(['hydrochlorothiazide']) && !has(['olmesartan', 'candesartan'])) {
        return (sub: 'cv_diuretics', subSub: 'cv_diu_thiazide');
      }
      if (has(['torsemide', 'furosemide', 'bumetanide'])) {
        return (sub: 'cv_diuretics', subSub: 'cv_diu_loop');
      }
      if (has(['eplerenone', 'spironolactone'])) {
        return (sub: 'cv_diuretics', subSub: 'cv_diu_kspare');
      }
      if (has(['apixaban', 'rivaroxaban', 'dabigatran', 'edoxaban'])) {
        return (sub: 'cv_anticoagulants', subSub: 'cv_doac');
      }
      if (has([
        'clopidogrel',
        'ticagrelor',
        'prasugrel',
        'aspirin',
        'acetylsalicylic'
      ])) {
        return (sub: 'cv_anticoagulants', subSub: 'cv_antiplatelet');
      }
      if (has(['warfarin', 'acenocoumarol'])) {
        return (sub: 'cv_anticoagulants', subSub: 'cv_vk');
      }
      if (has([
        'rosuvastatin',
        'atorvastatin',
        'simvastatin',
        'pravastatin',
        'pitavastatin'
      ])) {
        return (sub: 'cv_statins', subSub: 'cv_statin_only');
      }
      if (has(['isosorbide', 'nitroglycerin', 'glyceryl trinitrate'])) {
        return (sub: 'cv_antianginals', subSub: 'cv_ang_nitrate');
      }
      if (has(['naftidrofuryl'])) {
        return (sub: 'cv_peripheral', subSub: 'cv_periph_vasodilator');
      }
      if (has(['ivabradine', 'ranolazine', 'trimetazidine'])) {
        return (sub: 'cv_antianginals', subSub: 'cv_ang_other');
      }
      return (sub: 'cv_other', subSub: 'cv_other_general');

    case 'psychiatric_neuro':
      if (has([
        'olanzapine',
        'risperidone',
        'quetiapine',
        'aripiprazole',
        'clozapine',
        'lurasidone',
        'paliperidone',
        'ziprasidone'
      ])) {
        return (sub: 'pn_antipsychotics', subSub: 'pn_atypical');
      }
      if (has(['haloperidol', 'chlorpromazine', 'fluphenazine'])) {
        return (sub: 'pn_antipsychotics', subSub: 'pn_typical');
      }
      if (has([
        'sertraline',
        'citalopram',
        'escitalopram',
        'paroxetine',
        'fluoxetine',
        'fluvoxamine'
      ])) {
        return (sub: 'pn_antidepressants', subSub: 'pn_ssri');
      }
      if (has(['venlafaxine', 'duloxetine', 'desvenlafaxine'])) {
        return (sub: 'pn_antidepressants', subSub: 'pn_snri');
      }
      if (has(
          ['amitriptyline', 'imipramine', 'nortriptyline', 'clomipramine'])) {
        return (sub: 'pn_antidepressants', subSub: 'pn_tca');
      }
      if (has([
        'carbamazepine',
        'levetiracetam',
        'brivaracetam',
        'pregabalin',
        'gabapentin',
        'lamotrigine',
        'topiramate',
        'valproate',
        'oxcarbazepine',
        'phenytoin'
      ])) {
        return (sub: 'pn_antiepileptics', subSub: 'pn_ae');
      }
      if (has([
        'oxazepam',
        'diazepam',
        'alprazolam',
        'clonazepam',
        'lorazepam',
        'bromazepam',
        'buspirone'
      ])) {
        return (sub: 'pn_anxiolytics', subSub: 'pn_anx');
      }
      if (has(['atomoxetine', 'methylphenidate', 'lisdexamfetamine'])) {
        return (sub: 'pn_adhd', subSub: 'pn_adhd_gen');
      }
      if (has(['piracetam'])) {
        return (sub: 'pn_nootropics', subSub: 'pn_noot_gen');
      }
      return (sub: 'pn_neurology', subSub: 'pn_neuro_gen');

    case 'respiratory_allergy':
      if (has([
        'cetirizine',
        'levocetirizine',
        'loratadine',
        'desloratadine',
        'fexofenadine',
        'bilastine',
        'rupatadine',
        'ketotifen'
      ])) {
        if (has(['pseudoephedrine'])) {
          return (sub: 'ra_coldflu', subSub: 'ra_cf_gen');
        }
        return (sub: 'ra_antihistamines', subSub: 'ra_anti_h2');
      }
      if (has(['chlorpheniramine', 'diphenhydramine', 'promethazine'])) {
        return (sub: 'ra_antihistamines', subSub: 'ra_anti_h1');
      }
      if (has([
        'bambuterol',
        'salbutamol',
        'formoterol',
        'salmeterol',
        'tiotropium',
        'ipratropium',
        'budesonide',
        'fluticasone',
        'theophylline'
      ])) {
        if (df.contains('nasal') || df.contains('spray')) {
          return (sub: 'ra_nasal', subSub: 'ra_nasal_steroid');
        }
        if (df.contains('inhal') ||
            df.contains('aerosol') ||
            df.contains('nebul')) {
          return (sub: 'ra_bronchodilators', subSub: 'ra_bronch_inh');
        }
        return (sub: 'ra_bronchodilators', subSub: 'ra_bronch_tab');
      }
      if (has(['xylometazoline', 'oxymetazoline'])) {
        return (sub: 'ra_nasal', subSub: 'ra_nasal_decongestant');
      }
      if (has(['dichlorobenzyl', 'amylmetacresol'])) {
        return (sub: 'ra_coldflu', subSub: 'ra_cf_throat');
      }
      if (has([
        'bromhexine',
        'ambroxol',
        'guaifenesin',
        'acetylcysteine',
        'carbocysteine'
      ])) {
        return (sub: 'ra_cough', subSub: 'ra_cough_mucolytic');
      }
      return (sub: 'ra_coldflu', subSub: 'ra_cf_gen');

    case 'diabetes_metabolism':
      if (has(['empagliflozin', 'dapagliflozin', 'canagliflozin'])) {
        return (sub: 'dm_antidiabetics', subSub: 'dm_sglt2');
      }
      if (has(['linagliptin', 'sitagliptin', 'vildagliptin', 'saxagliptin'])) {
        return (sub: 'dm_antidiabetics', subSub: 'dm_dpp4');
      }
      if (has(['repaglinide', 'nateglinide'])) {
        return (sub: 'dm_antidiabetics', subSub: 'dm_glinide');
      }
      if (has(['metformin'])) {
        return (sub: 'dm_antidiabetics', subSub: 'dm_biguanide');
      }
      if (has(['insulin'])) {
        return (sub: 'dm_insulin', subSub: 'dm_ins_gen');
      }
      if (has(['levothyroxine', 'thyroid'])) {
        return (sub: 'dm_thyroid', subSub: 'dm_thy_gen');
      }
      if (has(['quinagolide', 'cabergoline', 'bromocriptine'])) {
        return (sub: 'dm_endocrine', subSub: 'dm_dopamine_agonist');
      }
      if (has(['alfacalcidol', 'calcitriol', 'cholecalciferol'])) {
        return (sub: 'dm_other', subSub: 'dm_other_gen');
      }
      return (sub: 'dm_antidiabetics', subSub: 'dm_biguanide');

    case 'pain_inflammation':
      if (has([
        'ibuprofen',
        'diclofenac',
        'naproxen',
        'meloxicam',
        'celecoxib',
        'etoricoxib',
        'ketoprofen',
        'piroxicam',
        'acemetacin'
      ])) {
        if (df.contains('gel') ||
            df.contains('cream') ||
            df.contains('patch') ||
            df.contains('ointment') ||
            df.contains('topical')) {
          return (sub: 'pi_nsaids', subSub: 'pi_nsaid_topical');
        }
        return (sub: 'pi_nsaids', subSub: 'pi_nsaid_oral');
      }
      if (has([
        'leflunomide',
        'methotrexate',
        'sulfasalazine',
        'hydroxychloroquine'
      ])) {
        return (sub: 'pi_antirheumatic', subSub: 'pi_ar_dmard');
      }
      if (has(['glucose amine', 'chondroitin'])) {
        return (sub: 'pi_antirheumatic', subSub: 'pi_ar_joint');
      }
      if (has(['cyclobenzaprine', 'tizanidine', 'baclofen', 'orphenadrine'])) {
        return (sub: 'pi_muscle', subSub: 'pi_mr_gen');
      }
      if (has([
        'lidocaine',
        'prilocaine',
        'benzocaine',
        'cinchocaine',
        'policresulen'
      ])) {
        return (sub: 'pi_local_anaesthetics', subSub: 'pi_la_gen');
      }
      if (has(['capsaicin', 'menthol'])) {
        return (sub: 'pi_topical_pain', subSub: 'pi_top_gen');
      }
      if (has(['naltrexone'])) {
        return (sub: 'pi_opioid_related', subSub: 'pi_opioid_antagonist');
      }
      if (has([
        'paracetamol',
        'acetaminophen',
        'naltrexone',
        'tramadol',
        'codeine'
      ])) {
        return (sub: 'pi_analgesics', subSub: 'pi_anal_gen');
      }
      return (sub: 'pi_analgesics', subSub: 'pi_anal_gen');

    case 'antibiotics':
      if (has(['amoxicillin', 'ampicillin', 'penicillin', 'flucloxacillin'])) {
        return (sub: 'ab_antibiotics', subSub: 'ab_pen');
      }
      if (has([
        'cefuroxime',
        'cefdinir',
        'cefixime',
        'ceftriaxone',
        'cephalexin',
        'cefaclor',
        'cefpodoxime'
      ])) {
        return (sub: 'ab_antibiotics', subSub: 'ab_ceph');
      }
      if (has([
        'azithromycin',
        'clarithromycin',
        'erythromycin',
        'roxithromycin'
      ])) {
        return (sub: 'ab_antibiotics', subSub: 'ab_macro');
      }
      if (has([
        'moxifloxacin',
        'ciprofloxacin',
        'levofloxacin',
        'ofloxacin',
        'norfloxacin'
      ])) {
        if (df.contains('eye')) {
          return (sub: 'ab_ophthalmic', subSub: 'ab_eye_fluoro');
        }
        return (sub: 'ab_antibiotics', subSub: 'ab_fluoro');
      }
      if (has([
        'itraconazole',
        'ketoconazole',
        'fluconazole',
        'terbinafine',
        'terconazole',
        'clotrimazole',
        'miconazole',
        'nystatin'
      ])) {
        return (sub: 'ab_antifungals', subSub: 'ab_af_gen');
      }
      if (has(['fusidic', 'povidone', 'mupirocin', 'chlorhexidine'])) {
        return (sub: 'ab_topical', subSub: 'ab_top_gen');
      }
      if (has(['eflornithine'])) {
        return (sub: 'ab_derm_topicals', subSub: 'ab_derm_hair_inhibitor');
      }
      if (has(['metronidazole', 'nifuroxazide', 'tinidazole'])) {
        return (sub: 'ab_antibiotics', subSub: 'ab_other');
      }
      return (sub: 'ab_antibiotics', subSub: 'ab_other');

    case 'gastrointestinal':
      if (has([
        'omeprazole',
        'esomeprazole',
        'pantoprazole',
        'lansoprazole',
        'rabeprazole',
        'vonoprazan'
      ])) {
        return (sub: 'gi_acid', subSub: 'gi_ppi');
      }
      if (has(['ranitidine', 'famotidine', 'nizatidine'])) {
        return (sub: 'gi_acid', subSub: 'gi_h2');
      }
      if (has([
        'aluminum hydroxide',
        'magnesium hydroxide',
        'sodium alginate',
        'sodium bicarbonate',
        'calcium carbonate'
      ])) {
        return (sub: 'gi_acid', subSub: 'gi_antacid');
      }
      if (has([
        'meclizine',
        'ondansetron',
        'domperidone',
        'metoclopramide',
        'granisetron'
      ])) {
        return (sub: 'gi_antiemetics', subSub: 'gi_anti_em');
      }
      if (has(['mirabegron', 'solifenacin', 'oxybutynin', 'tolterodine'])) {
        return (sub: 'gi_bladder', subSub: 'gi_bladder_gen');
      }
      if (has(['potassium citrate', 'tamsulosin'])) {
        return (sub: 'gi_renal', subSub: 'gi_renal_gen');
      }
      if (has(['cinchocaine', 'policresulen'])) {
        return (sub: 'gi_haemorrhoids', subSub: 'gi_haem_gen');
      }
      if (has(
          ['nifuroxazide', 'loperamide', 'bisacodyl', 'lactulose', 'senna'])) {
        return (sub: 'gi_bowel', subSub: 'gi_bowel_gen');
      }
      return (sub: 'gi_acid', subSub: 'gi_antacid');

    case 'vitamins_supplements':
      if (has([
        'multivitamins',
        'vitamins+iron',
        'vitamins+minerals',
        'minerals+vitamins'
      ])) {
        return (sub: 'vs_multivitamins', subSub: 'vs_mvi_gen');
      }
      if (has(['lactoferrin', 'echinacea', 'zinc'])) {
        return (sub: 'vs_immunity', subSub: 'vs_imm_gen');
      }
      if (has(['glucose amine', 'chondroitin'])) {
        return (sub: 'vs_joint', subSub: 'vs_joint_gen');
      }
      if (has(['minerals']) && !ai.contains('vitamin')) {
        return (sub: 'vs_minerals', subSub: 'vs_min_gen');
      }
      if (has(['vitamin'])) {
        return (sub: 'vs_vitamins', subSub: 'vs_vit_gen');
      }
      if (has(['wheat germ'])) {
        return (sub: 'vs_multivitamins', subSub: 'vs_mvi_gen');
      }
      return (sub: 'vs_vitamins', subSub: 'vs_vit_gen');

    case 'dermatology':
      if (df.contains('shampoo') || ai.contains('shampoo')) {
        return (sub: 'dr_shampoos', subSub: 'dr_sh_gen');
      }
      if (has(['povidone', 'chlorhexidine'])) {
        return (sub: 'dr_antiseptics', subSub: 'dr_antiseptic_gen');
      }
      if (has(['fusidic', 'mupirocin'])) {
        return (sub: 'dr_topical_antibiotics', subSub: 'dr_top_ab_gen');
      }
      if (has([
        'biotin',
        'minoxidil',
        'caffeine+green coffee',
        'saw palmetto',
        'rosemary'
      ])) {
        return (sub: 'dr_hair_care', subSub: 'dr_hl');
      }
      if (has([
        'eflornithine',
        'azelaic acid',
        'tretinoin',
        'adapalene',
        'benzoyl peroxide'
      ])) {
        return (sub: 'dr_skin_care', subSub: 'dr_sk_acne');
      }
      return (sub: 'dr_skin_care', subSub: 'dr_sk_general');

    case 'oncology':
      if (has(['tamoxifen', 'fulvestrant'])) {
        return (sub: 'on_hormonal', subSub: 'on_anti_estrogen');
      }
      if (has(['anastrozole', 'letrozole', 'exemestane'])) {
        return (sub: 'on_hormonal', subSub: 'on_aromatase');
      }
      if (has(['bicalutamide', 'flutamide', 'enzalutamide'])) {
        return (sub: 'on_hormonal', subSub: 'on_anti_androgen');
      }
      return (sub: 'on_supportive', subSub: 'on_sup_gen');

    default:
      return (sub: 'ot_general', subSub: 'ot_gen_gen');
  }
}
