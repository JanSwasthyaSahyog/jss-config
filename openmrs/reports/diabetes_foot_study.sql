SELECT
  GROUP_CONCAT(DISTINCT (IF(pit.name = 'Patient Identifier', pi.identifier, NULL)))                            AS "Patient Identifier",
  concat(pn.given_name, ' ',
         pn.family_name)                                                                                             AS "Patient Name",
  floor(DATEDIFF(DATE(o.obs_datetime), p.birthdate) /
        365)                                                                                                         AS "Age",
  DATE_FORMAT(p.birthdate,
              "%d-%b-%Y")                                                                                            AS "Birthdate",
  p.gender                                                                                                           AS "Gender",
  GROUP_CONCAT(DISTINCT
      (IF(pat.name = 'caste', IF(pat.format = 'org.openmrs.Concept', coalesce(scn.name, fscn.name), pa.value),
          NULL)))                                                                                           AS 'caste',
  GROUP_CONCAT(DISTINCT (IF(pat.name = 'occupation',
                            IF(pat.format = 'org.openmrs.Concept', coalesce(scn.name, fscn.name), pa.value),
                            NULL)))                                                                                  AS 'occupation',
  paddress.city_village,
  paddress.address3,
  paddress.county_District,

  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Height',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Height',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Weight',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Weight',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'BMI',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'BMI',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Total Leucocyte Count (Blood)',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Total Leucocyte Count (Blood)',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Polymorph',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Polymorph',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Lymphocyte',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Lymphocyte',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Eosinophil',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Eosinophil',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Monocyte',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Monocyte',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Basophil',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Basophil',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Fasting Blood Sugar',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Fasting Blood Sugar',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'PP2BS',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'PP2BS',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Hb1AC',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Hb1AC',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'ESR',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'ESR',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Creatinine',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Creatinine',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Diabetic Foot Study, Duration of DM',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Diabetic Foot Study, Duration of DM',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Use of Insulin',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Use of Insulin',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'History of Smoking',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'History of Smoking',
  GROUP_CONCAT(DISTINCT
      (IF(obs_fscn.name = 'Positive Symptoms(Burning/Tingling/Shooting /Sharp Sensation) Sensation in feet',
          coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL))
  ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Positive Symptoms(Burning/Tingling/Shooting /Sharp Sensation) Sensation in feet',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Negative Symptoms(Numbness/feels/feet dead)',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Negative Symptoms(Numbness/feels/feet dead)',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Use of MCR Sandals at present',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Use of MCR Sandals at present',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Diabetic Foot Study, Duration of Use of MCR Sandals',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Diabetic Foot Study, Duration of Use of MCR Sandals',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'No of Total Amputations',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'No of Total Amputations',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Left Foot',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Left Foot',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Right Foot',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Right Foot',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = '1st Metatarsal Head Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS '1st Metatarsal Head Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = '1st Metatarsal Head Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS '1st Metatarsal Head Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = '2nd Metatarsal Head Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS '2nd Metatarsal Head Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = '2nd Metatarsal Head Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS '2nd Metatarsal Head Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = '5th Metatarsal Head Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS '5th Metatarsal Head Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = '5th Metatarsal Head Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS '5th Metatarsal Head Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Plantar Surface of Distal Hallux Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Plantar Surface of Distal Hallux Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Plantar Surface of Distal Hallux Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Plantar Surface of Distal Hallux Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Vibration Sensation Status Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Vibration Sensation Status Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Vibration Sensation Status Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Vibration Sensation Status Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Pinprick Sensation Status Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Pinprick Sensation Status Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Pinprick Sensation Status Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Pinprick Sensation Status Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Ankle Reflex Status Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Ankle Reflex Status Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Ankle Reflex Status Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Ankle Reflex Status Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Dorsalis Pedis Artery Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Dorsalis Pedis Artery Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Dorsalis Pedis Artery Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Dorsalis Pedis Artery Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Ankle systolic pressure Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Ankle systolic pressure Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Ankle systolic pressure Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Ankle systolic pressure Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Brachial systolic pressure Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Brachial systolic pressure Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Brachial systolic pressure Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Brachial systolic pressure Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Skin Color / Cracking / Sweating Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Skin Color / Cracking / Sweating Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Skin Color / Cracking / Sweating Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Skin Color / Cracking / Sweating Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Claw Toes / Hammer Toes Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Claw Toes / Hammer Toes Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Claw Toes / Hammer Toes Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Claw Toes / Hammer Toes Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Charcoat Joint Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Charcoat Joint Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Charcoat Joint Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Charcoat Joint Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Muscle Wasting (guttering between muscles) left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Muscle Wasting (guttering between muscles) left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Muscle Wasting (guttering between muscles) right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Muscle Wasting (guttering between muscles) right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Calluses Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Calluses Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Calluses Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Calluses Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Blisters Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Blisters Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Blisters Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Blisters Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Nail Infection Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Nail Infection Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Nail Infection Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Nail Infection Right',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Prominent Metatarsal Head Left',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Prominent Metatarsal Head Left',
  GROUP_CONCAT(DISTINCT (IF(obs_fscn.name = 'Prominent Metatarsal Head Right',
                            coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name),
                            NULL)) ORDER BY o.obs_id
  DESC)                                                                                                 AS 'Prominent Metatarsal Head Right',

  l.name                                                                                                             AS "Location name",
  DATE_FORMAT(v.date_started,
              "%d-%b-%Y")                                                                                            AS "Visit Start Date",
  DATE_FORMAT(v.date_stopped,
              "%d-%b-%Y")                                                                                            AS "Visit Stop Date",
  vt.name                                                                                                            AS "Visit Type",
  o.person_id                                                                                                        AS "Patient Id",
  o.encounter_id                                                                                                     AS "Encounter Id",
  v.visit_id                                                                                                         AS "Visit Id",
  program.name                                                                                                       AS "Program Name",
  DATE_FORMAT(pp.date_enrolled,
              "%d-%b-%Y")                                                                                            AS "Program Enrollment Date",
  DATE_FORMAT(pp.date_completed,
              "%d-%b-%Y")                                                                                            AS "Program End Date",
  DATE_FORMAT(p.date_created,
              "%d-%b-%Y")                                                                                            AS "Patient Created Date",
  coalesce(pro.name, concat(provider_person.given_name, " ",
                            provider_person.family_name))                                                            AS "Provider"
FROM obs o
  JOIN concept obs_concept ON obs_concept.concept_id = o.concept_id AND obs_concept.retired IS FALSE
  JOIN concept_name obs_fscn ON
                               o.concept_id = obs_fscn.concept_id AND obs_fscn.concept_name_type = "FULLY_SPECIFIED" AND
                               obs_fscn.voided IS FALSE
                               AND obs_fscn.name IN
                                   ("Height", "Weight", "BMI", "Total Leucocyte Count (Blood)", "Polymorph", "Lymphocyte", "Eosinophil", "Monocyte", "Basophil", "Fasting Blood Sugar", "PP2BS", "Hb1AC", "ESR", "Creatinine", "Diabetic Foot Study, Duration of DM", "Use of Insulin", "History of Smoking", "Positive Symptoms(Burning/Tingling/Shooting /Sharp Sensation) Sensation in feet", "Negative Symptoms(Numbness/feels/feet dead)", "Use of MCR Sandals at present", "Diabetic Foot Study, Duration of Use of MCR Sandals", "No of Total Amputations", "Left Foot", "Right Foot", "1st Metatarsal Head Left", "1st Metatarsal Head Right", "2nd Metatarsal Head Left", "2nd Metatarsal Head Right", "5th Metatarsal Head Left", "5th Metatarsal Head Right", "Plantar Surface of Distal Hallux Left", "Plantar Surface of Distal Hallux Right", "Vibration Sensation Status Left", "Vibration Sensation Status Right", "Pinprick Sensation Status Left", "Pinprick Sensation Status Right", "Ankle Reflex Status Left", "Ankle Reflex Status Right", "Dorsalis Pedis Artery Left", "Dorsalis Pedis Artery Right", "Ankle systolic pressure Left", "Ankle systolic pressure Right", "Brachial systolic pressure Left", "Brachial systolic pressure Right", "Skin Color / Cracking / Sweating Left", "Skin Color / Cracking / Sweating Right", "Claw Toes / Hammer Toes Left", "Claw Toes / Hammer Toes Right", "Charcoat Joint Left", "Charcoat Joint Right", "Muscle Wasting (guttering between muscles) left", "Muscle Wasting (guttering between muscles) right", "Calluses Left", "Calluses Right", "Blisters Left", "Blisters Right", "Nail Infection Left", "Nail Infection Right", "Prominent Metatarsal Head Left", "Prominent Metatarsal Head Right")
  LEFT JOIN concept_name obs_scn
    ON o.concept_id = obs_scn.concept_id AND obs_scn.concept_name_type = "SHORT" AND obs_scn.voided IS FALSE

  JOIN person p ON p.person_id = o.person_id AND p.voided IS FALSE
  JOIN patient_identifier pi ON p.person_id = pi.patient_id AND pi.voided IS FALSE
  JOIN patient_identifier_type pit ON pi.identifier_type = pit.patient_identifier_type_id AND pit.retired IS FALSE
  JOIN person_name pn ON pn.person_id = p.person_id AND pn.voided IS FALSE
  JOIN encounter e ON o.encounter_id = e.encounter_id AND e.voided IS FALSE
  JOIN encounter_provider ep ON ep.encounter_id = e.encounter_id
  JOIN provider pro ON pro.provider_id = ep.provider_id
  LEFT OUTER JOIN person_name provider_person ON provider_person.person_id = pro.person_id
  JOIN visit v ON v.visit_id = e.visit_id AND v.voided IS FALSE
  JOIN visit_type vt ON vt.visit_type_id = v.visit_type_id AND vt.retired IS FALSE

  LEFT JOIN location l ON e.location_id = l.location_id AND l.retired IS FALSE
  LEFT JOIN obs parent_obs ON parent_obs.obs_id = o.obs_group_id
  LEFT JOIN concept_name parent_cn
    ON parent_cn.concept_id = parent_obs.concept_id AND parent_cn.concept_name_type = "FULLY_SPECIFIED"
  LEFT JOIN concept_name coded_fscn
    ON coded_fscn.concept_id = o.value_coded AND coded_fscn.concept_name_type = "FULLY_SPECIFIED" AND
       coded_fscn.voided IS FALSE
  LEFT JOIN concept_name coded_scn
    ON coded_scn.concept_id = o.value_coded AND coded_fscn.concept_name_type = "SHORT" AND coded_scn.voided IS FALSE

  LEFT OUTER JOIN person_attribute pa ON p.person_id = pa.person_id AND pa.voided IS FALSE
  LEFT OUTER JOIN person_attribute_type pat
    ON pa.person_attribute_type_id = pat.person_attribute_type_id AND pat.retired IS FALSE
  LEFT OUTER JOIN concept_name scn
    ON pat.format = "org.openmrs.Concept" AND pa.value = scn.concept_id AND scn.concept_name_type = "SHORT" AND
       scn.voided IS FALSE
  LEFT OUTER JOIN concept_name fscn
    ON pat.format = "org.openmrs.Concept" AND pa.value = fscn.concept_id AND fscn.concept_name_type = "FULLY_SPECIFIED"
       AND fscn.voided IS FALSE
  LEFT OUTER JOIN person_address paddress ON p.person_id = paddress.person_id AND paddress.voided IS FALSE
  LEFT JOIN patient_program pp ON p.person_id = pp.patient_id
  LEFT JOIN program program ON pp.program_id = program.program_id

WHERE o.voided IS FALSE
      AND program.name = 'Diabetic Foot Study'
      AND pp.date_enrolled BETWEEN '2017-06-01' AND '2017-06-30'
      AND cast(o.obs_datetime AS DATE) BETWEEN pp.date_enrolled and now()
GROUP BY o.person_id, date(v.date_started);