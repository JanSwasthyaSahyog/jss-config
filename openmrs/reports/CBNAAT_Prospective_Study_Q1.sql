select * from (
SELECT pi.identifier AS 'Identifier',DATE(pi.date_created)RegistrationDate,date(v.date_created) as Visit_Date,
  concat(pn.given_name, " ", pn.family_name)                        AS 'Patient Name',
  p.gender 															AS 'Gender',
  DATE_FORMAT(p.birthdate, "%d-%b-%Y")                              AS 'Birthdate',
  floor(DATEDIFF(DATE(o.obs_datetime), p.birthdate) / 365)          AS 'Age',  
  paddress.city_village                                             AS 'City_Village', 
  paddress.address3                                                 AS 'Tehsil', 
  paddress.county_district 											AS 'District',
  paddress.state_province 											AS 'State',
  hight.value_numeric 												AS 'Height',
  wieght.value_numeric 												AS 'Weight', 
  BMI.value_numeric 												AS 'BMI',  
 
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'CBNAAT Testing Centre', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Testing_Centre',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'CBNAAT Sample', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Sample',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'CBNAAT HIV Status', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'HIV_Status',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'CBNAAT Diabetes Status', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Diabetes_Status',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Has your patient previously been treated for TB', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Has_Your_Patient_Previously_Been_TreatedforTB',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'When are you requesting this CBNAAT', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'When_are_you_requesting_this_CBNAAT',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Are you also requesting smear-microscopy as well as this CBNAAT', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Are_you_also_requesting_smear-microscopy_aswellas_this_CBNAAT',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Purpose of CBNAAT,I am using this CBNAAT to', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Purpose_Of_CBNAAT_I_am_using_this_CBNAATto',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'CBNAAT, Are you', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Are_You',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'CBNAAT, Do you consider your patient', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Do_you_consider_your_patient',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'CBNAAT, Is your patient', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Is_your_patient',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'When was the sample for this CBNAAT taken', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'When_was_the_sample_for_this_CBNAAT_taken',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'When did this patient present to JSS with symptoms of possible TB', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'When_did_this_patient_present_to_JSS_with_symptoms_of_possible_TB'
   
  FROM obs o
  JOIN concept obs_concept ON obs_concept.concept_id=o.concept_id AND obs_concept.retired is false
  JOIN concept_name obs_fscn on o.concept_id=obs_fscn.concept_id AND obs_fscn.concept_name_type="FULLY_SPECIFIED" AND obs_fscn.voided is false
   AND obs_fscn.name IN ('CBNAAT Testing Centre',
   'CBNAAT Sample','CBNAAT HIV Status','CBNAAT Diabetes Status',
   'Has your patient previously been treated for TB',
   'When did this patient present to JSS with symptoms of possible TB',
   'When are you requesting this CBNAAT',
   'Are you also requesting smear-microscopy as well as this CBNAAT',
   'Purpose of CBNAAT,I am using this CBNAAT to','CBNAAT, Are you',
   'CBNAAT, Do you consider your patient','CBNAAT Diabetes Status',
   'CBNAAT, Is your patient','When was the sample for this CBNAAT taken',
   'When did this patient present to JSS with symptoms of possible TB')
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
  LEFT JOIN concept_name coded_scn on coded_scn.concept_id = o.value_coded AND coded_scn.concept_name_type="SHORT" AND coded_scn.voided is false
  LEFT JOIN concept_name coded_fscn on coded_fscn.concept_id = o.value_coded AND coded_fscn.concept_name_type="FULLY_SPECIFIED" AND coded_fscn.voided is false  
  LEFT OUTER JOIN person_attribute pa ON p.person_id = pa.person_id AND pa.voided is false
  LEFT OUTER JOIN person_attribute_type pat ON pa.person_attribute_type_id = pat.person_attribute_type_id AND pat.retired is false
  LEFT OUTER JOIN concept_name scn ON pat.format = "org.openmrs.Concept" AND pa.value = scn.concept_id AND scn.concept_name_type = "SHORT" AND scn.voided is false
  LEFT OUTER JOIN concept_name fscn ON pat.format = "org.openmrs.Concept" AND pa.value = fscn.concept_id AND fscn.concept_name_type = "FULLY_SPECIFIED" AND fscn.voided is false 
  LEFT OUTER JOIN person_address paddress ON p.person_id = paddress.person_id AND paddress.voided is false
  LEFT OUTER JOIN obs hight ON pi.patient_id = hight.person_id AND hight.concept_id = 5
  LEFT OUTER JOIN obs wieght ON pi.patient_id = wieght.person_id AND wieght.concept_id = 6
  LEFT OUTER JOIN obs BMI ON pi.patient_id = BMI.person_id AND BMI.concept_id = 7
  WHERE v.voided is false  AND cast(v.date_started AS DATE) BETWEEN '#startDate#' AND '#endDate#' GROUP BY e.encounter_id
  ) as result where Testing_Centre is not null ;