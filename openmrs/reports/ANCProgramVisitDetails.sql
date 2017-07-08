SELECT
  pi.identifier AS 'Patient_Identifier',
  concat(pn.given_name, " ", pn.family_name)                    AS 'Patient Name',
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'primaryRelative', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Primary_Relative', 
  floor(DATEDIFF(DATE(o.obs_datetime), p.birthdate) / 365)      AS 'Age',
  DATE_FORMAT(p.birthdate, "%d-%b-%Y")                          AS 'Birthdate',
  p.gender                                                      AS 'Gender',
  paddress.city_village                                            AS 'City_Village', 
  paddress.address3                                                AS 'Tehsil', 
  paddress.county_district                                        AS 'District',
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'caste', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Caste', 
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'class', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Class', 
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'smoking', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Smoking', 
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'alcohol', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Alcohol',
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'landHolding', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'land_Holding',
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'rationCard', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Ration_Card', 
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'familyIncome', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Family_Income',
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'foodSecurity', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Food_Security',
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'distanceFromCenter', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Distance_from_Home',
  DATE_FORMAT(v.date_started, "%d-%b-%Y")                       AS 'Visit Start Date',
  DATE_FORMAT(v.date_stopped, "%d-%b-%Y")                       AS 'Visit Stop Date',
  program.name                                                  AS 'Program Name',
  DATE_FORMAT(pp.date_enrolled, "%d-%b-%Y")                     AS 'Program Enrollment Date',
  DATE_FORMAT(pp.date_completed, "%d-%b-%Y")                    AS 'Program End Date',
  prog_attr_result.programID,
  prog_attr_result.highRisk,
  prog_attr_result.highRiskReason,
  prog_attr_result.highRiskReasonText, 
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC Template, ANC ID', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'ANC ID',
GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC,Cluster', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Cluster',
GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Gravida', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Gravida',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Parity', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Parity',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Abortion', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Abortion',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Live Births', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Live Births',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Last menstrual period', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'LMP',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Estimated Date of Delivery', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'EDD',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, First Tetanus', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'TT1',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Second Tetanus', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'TT2',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Visit date', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Visit date',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Follow up visit', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Follow up visit',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Height', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Height',  
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Weight', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Weight',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Albumin (Routine Urine)', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Albumin (Routine Urine)',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Sugar (Routine Urin)', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Sugar (Routine Urin)',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Oedema', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Oedema',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Haemoglobin', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Haemoglobin',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Haemoglobin Range', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Haemoglobin Range',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Systolic', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Systolic',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Diastolic', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Diastolic',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Posture', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Posture',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Gestation', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Gestation',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Fundal Height', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Fundal Height',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Position', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Position',  
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Fetal Heart Sound', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'FHS'
FROM obs o
  JOIN concept obs_concept ON obs_concept.concept_id=o.concept_id AND obs_concept.retired is false
  JOIN concept_name obs_fscn on o.concept_id=obs_fscn.concept_id AND obs_fscn.concept_name_type="FULLY_SPECIFIED" AND obs_fscn.voided is false
   AND obs_fscn.name IN ('ANC Template, ANC ID',
   'ANC,Cluster',
   'Gravida',
   'Parity',
   'Abortion',
   'Live Births',
   'ANC, Last menstrual period',
   'ANC, Estimated Date of Delivery',
   'ANC, First Tetanus',
   'ANC, Second Tetanus',
   'ANC, Visit date',
   'ANC, Follow up visit',
   'Height',
   'Weight',
   'Albumin (Routine Urine)',
   'Sugar (Routine Urin)',
   'ANC, Oedema',
   'Haemoglobin',
   'Haemoglobin Range',
   'Systolic',
   'Diastolic',
   'Posture',
   'ANC, Gestation',
   'ANC, Fundal Height',
   'ANC, Position',
   'ANC, Fetal Heart Sound')
  LEFT JOIN concept_name obs_scn on o.concept_id=obs_scn.concept_id AND obs_scn.concept_name_type="SHORT" AND obs_scn.voided is false
  JOIN person p ON p.person_id = o.person_id AND p.voided is false
  JOIN patient_identifier pi ON p.person_id = pi.patient_id AND pi.voided is false
  JOIN patient_identifier_type pit ON pi.identifier_type = pit.patient_identifier_type_id AND pit.retired is false  JOIN person_name pn ON pn.person_id = p.person_id AND pn.voided is false
  JOIN encounter e ON o.encounter_id=e.encounter_id AND e.voided is false
  JOIN encounter_provider ep ON ep.encounter_id=e.encounter_id
  JOIN provider pro ON pro.provider_id=ep.provider_id
  LEFT OUTER JOIN person_name provider_person ON provider_person.person_id = pro.person_id
  JOIN visit v ON v.visit_id=e.visit_id AND v.voided is false
  JOIN visit_type vt ON vt.visit_type_id=v.visit_type_id AND vt.retired is false
  LEFT JOIN location l ON e.location_id = l.location_id AND l.retired is false
  LEFT JOIN obs parent_obs ON parent_obs.obs_id=o.obs_group_id
  LEFT JOIN concept_name parent_cn ON parent_cn.concept_id=parent_obs.concept_id AND parent_cn.concept_name_type="FULLY_SPECIFIED"
  LEFT JOIN concept_name coded_fscn on coded_fscn.concept_id = o.value_coded AND coded_fscn.concept_name_type="FULLY_SPECIFIED" AND coded_fscn.voided is false
  LEFT JOIN concept_name coded_scn on coded_scn.concept_id = o.value_coded AND coded_fscn.concept_name_type="SHORT" AND coded_scn.voided is false
  LEFT OUTER JOIN person_attribute pa ON p.person_id = pa.person_id AND pa.voided is false
  LEFT OUTER JOIN person_attribute_type pat ON pa.person_attribute_type_id = pat.person_attribute_type_id AND pat.retired is false
  LEFT OUTER JOIN concept_name scn ON pat.format = "org.openmrs.Concept" AND pa.value = scn.concept_id AND scn.concept_name_type = "SHORT" AND scn.voided is false
  LEFT OUTER JOIN concept_name fscn ON pat.format = "org.openmrs.Concept" AND pa.value = fscn.concept_id AND fscn.concept_name_type = "FULLY_SPECIFIED" AND fscn.voided is false 
  LEFT OUTER JOIN person_address paddress ON p.person_id = paddress.person_id AND paddress.voided is false 
  JOIN episode_encounter ee ON e.encounter_id = ee.encounter_id
  JOIN episode_patient_program epp ON ee.episode_id=epp.episode_id
  JOIN patient_program pp ON epp.patient_program_id = pp.patient_program_id
  JOIN program program ON pp.program_id = program.program_id AND program.name IN ("Ante Natal Care Program")
  
  LEFT JOIN (SELECT
                           patient_program_id,
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'Program ID', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'programID' , 
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'High Risk', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'highRisk' , 
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'High Risk Reason', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'highRiskReason' , 
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'High Risk Reason Text', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'highRiskReasonText'
                           FROM program_attribute_type pg_at
                                       LEFT JOIN patient_program_attribute pg_attr ON pg_attr.attribute_type_id = pg_at.program_attribute_type_id AND pg_attr.voided = false AND pg_at.name in('Program ID','High Risk','High Risk Reason','High Risk Reason Text')
                                       LEFT JOIN concept_view pg_attr_cn ON pg_attr.value_reference = pg_attr_cn.concept_id AND pg_at.datatype LIKE "%Concept%"
                            GROUP BY patient_program_id ) prog_attr_result ON prog_attr_result.patient_program_id = pp.patient_program_id  

  WHERE o.voided is false 
  AND cast(v.date_started AS DATE) BETWEEN '#startDate#' and '#endDate#'
  GROUP BY e.encounter_id ;
