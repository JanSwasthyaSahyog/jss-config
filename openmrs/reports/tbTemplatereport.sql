Select ProgDetails.*,
LabDetails.Haemoglobin_Blood,
LabDetails.FBS,
LabDetails.RBS,
LabDetails.PP2BS,
LabDetails.HIV_ELISA_Blood,
LabDetails.HIV_ELISA_Serum,
LabDetails.S_ALT,
LabDetails.GGT,
LabDetails.ZN_Stain_Sputum,
LabDetails.Gram_Stain_Sputum,
LabDetails.CBNAAT_Sputum,
LabDetails.Creatinine,
LabDetails.Albumin_Serum
 from (SELECT
  pi.identifier AS 'Patient_Identifier',
  concat(pn.given_name, " ", pn.family_name)                    AS 'Patient Name',
  floor(DATEDIFF(DATE(o.obs_datetime), p.birthdate) / 365)      AS 'Age',
  DATE_FORMAT(p.birthdate, "%d-%b-%Y")                          AS 'Birthdate',
  p.gender                                                      AS 'Gender',
  paddress.city_village											AS 'City_Village', 
  paddress.address3												AS 'Tehsil', 
  paddress.county_district										AS 'District',
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'caste', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Caste', 
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'class', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Class', 
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'primaryRelative', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Primary_Relative', 
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'smoking', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Smoking', 
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'alcohol', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Alcohol',
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'landHolding', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'land_Holding',
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'rationCard', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Ration_Card', 
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'familyIncome', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Family_Income',
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'foodSecurity', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Food_Security',
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'distanceFromCenter', IF(pat.format = 'org.openmrs.Concept',coalesce(scn.name, fscn.name),pa.value), NULL))) AS 'Distance_from_Home',    
  v.visit_id,
  DATE_FORMAT(v.date_started, "%d-%b-%Y")                       AS 'Visit Start Date',
  DATE_FORMAT(v.date_stopped, "%d-%b-%Y")                       AS 'Visit Stop Date',
  program.name                                                  AS 'Program Name',
  DATE_FORMAT(pp.date_enrolled, "%d-%b-%Y")                     AS 'Program Enrollment Date',
  DATE_FORMAT(pp.date_completed, "%d-%b-%Y")                    AS 'Program End Date',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'WEIGHT', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'WEIGHT',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'HEIGHT', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'HEIGHT',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'BMI', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'BMI',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'BMI STATUS', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'BMI STATUS',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Symptoms', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Symptoms',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Symptoms Duration', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Symptoms Duration',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Symptoms  duration', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Symptoms  duration',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Next Followup Visit', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Next Followup Visit',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Plan for next visit', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Plan for next visit',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Need of Admission', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Need of Admission',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Indication for Admission', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Indication for Admission',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Output of Treatment', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Output of Treatment',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Followup Visit', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Followup Visit',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Family Screened', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Family Screened',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Fever', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Fever',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Cough', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Cough',	GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Anorexia', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Anorexia',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Chest Pain', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Chest Pain',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Breathlessness', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Breathlessness',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis Followup, Lymph Node Size', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis Followup, Lymph Node Size',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Examination', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Examination',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Treatment Compliance', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Treatment Compliance',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Adverse Effects', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Adverse Effects',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Treatment for adverse effects', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Treatment for adverse effects',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Tuberculosis, Visit Impression', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Tuberculosis, Visit Impression'
FROM obs o
  JOIN concept obs_concept ON obs_concept.concept_id=o.concept_id AND obs_concept.retired is false
  JOIN concept_name obs_fscn on o.concept_id=obs_fscn.concept_id AND obs_fscn.concept_name_type="FULLY_SPECIFIED" AND obs_fscn.voided is false
   AND obs_fscn.name IN ("WEIGHT","HEIGHT","BMI","BMI STATUS","Tuberculosis, Symptoms","Tuberculosis, Symptoms Duration","Tuberculosis, Symptoms  duration","Tuberculosis, Next Followup Visit","Tuberculosis, Plan for next visit","Tuberculosis, Need of Admission","Tuberculosis, Indication for Admission","Tuberculosis, Output of Treatment","Tuberculosis, Followup Visit","Tuberculosis, Family Screened","Tuberculosis, Fever","Tuberculosis, Cough","Tuberculosis, Anorexia","Tuberculosis, Chest Pain","Tuberculosis, Breathlessness","Tuberculosis Followup, Lymph Node Size","Tuberculosis, Examination","Tuberculosis, Treatment Compliance","Tuberculosis, Adverse Effects","Tuberculosis, Treatment for adverse effects","Tuberculosis, Visit Impression")
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
  JOIN program program ON pp.program_id = program.program_id AND program.name IN ("TB Program")
  WHERE o.voided is false AND cast(v.date_started AS DATE) BETWEEN "2016-11-17" AND "2016-11-22"
  GROUP BY e.encounter_id
) as ProgDetails
Left Join 
(
SELECT
pi.identifier,
v.visit_id,
GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Haemoglobin (Blood)', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Haemoglobin_Blood',
GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'FBS', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'FBS',
GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'RBS', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'RBS',
GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'PP2BS', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'PP2BS',
GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'HIV ELISA (Blood)', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'HIV_ELISA_Blood',
GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'HIV ELISA (Serum)', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'HIV_ELISA_Serum',
GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'S. ALT', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'S_ALT',
GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'GGT', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'GGT',
GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ZN Stain (Sputum)', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'ZN_Stain_Sputum',
GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Gram Stain (Sputum)', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Gram_Stain_Sputum',
GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'CBNAAT (Sputum)', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'CBNAAT_Sputum',
GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Creatinine', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Creatinine',
GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Albumin (Serum)', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Albumin_Serum'            
FROM obs o
  JOIN concept obs_concept ON obs_concept.concept_id=o.concept_id AND obs_concept.retired is false
  JOIN concept_name obs_fscn on o.concept_id=obs_fscn.concept_id AND obs_fscn.concept_name_type="FULLY_SPECIFIED" AND obs_fscn.voided is false
   AND obs_fscn.name IN ("Haemoglobin (Blood)","FBS","RBS","PP2BS","HIV ELISA (Blood)","HIV ELISA (Serum)","S. ALT","GGT","ZN Stain (Sputum)","Gram Stain (Sputum)",
   "CBNAAT (Sputum)","Creatinine")
  LEFT JOIN concept_name obs_scn on o.concept_id=obs_scn.concept_id AND obs_scn.concept_name_type="SHORT" AND obs_scn.voided is false
  JOIN person p ON p.person_id = o.person_id AND p.voided is false
  JOIN patient_identifier pi ON p.person_id = pi.patient_id AND pi.voided is false
  JOIN patient_identifier_type pit ON pi.identifier_type = pit.patient_identifier_type_id AND pit.retired is false  
  JOIN person_name pn ON pn.person_id = p.person_id AND pn.voided is false
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
  WHERE o.voided is false 
  AND cast(v.date_started AS DATE) BETWEEN "2016-11-17" AND "2016-11-22"
GROUP BY e.encounter_id
) as LabDetails
On LabDetails.identifier=ProgDetails.Patient_Identifier and LabDetails.visit_id=ProgDetails.visit_id ;

