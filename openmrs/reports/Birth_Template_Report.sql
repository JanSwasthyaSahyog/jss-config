

select * from (
SELECT  pi.identifier AS 'Identifier',DATE(pi.date_created)RegistrationDate,date(v.date_created) as Visit_Date,
  concat(pn.given_name, " ", pn.family_name)                        AS 'Patient Name',
  p.gender 							    AS 'Gender',
  DATE_FORMAT(p.birthdate, "%d-%b-%Y")                              AS 'Birthdate',
  floor(DATEDIFF(DATE(o.obs_datetime), p.birthdate) / 365)          AS 'Age',  
  paddress.city_village                                             AS 'Village', 
  paddress.address3                                                 AS 'Tehsil', 
  paddress.county_district                                          AS 'District', 
  hight.value_numeric 						    AS 'Height',
  wieght.value_numeric 						    AS 'Weight', 
  BMI.value_numeric 						    AS 'BMI',  
    
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Birth Booked/ Unbooked', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Birth_Booked_Unbooked',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Birth Date of Delivery', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Birth Date of Delivery',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Birth Village program (Yes / No)', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Birth Village program (Yes / No)',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Birth Gravida', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Birth Gravida',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Birth Gestational Age (Week/Month)', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Birth Gestational Age (Week/Month)',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Birth Type of Delivery', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Birth Type of Delivery',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Risk Factors (Complication/Prenatal Diagnosis)', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Risk Factors (Complication/Prenatal Diagnosis)',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Birth Number of Babies', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Birth Number of Babies',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Birth Sex of Baby', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Birth Sex of Baby',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Birth Time', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Birth Time',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Birth Weight', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Birth Weight',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Birth Alive/ Dead', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Birth Alive/ Dead',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Apgar - Score (X/10)', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Apgar - Score (X/10)',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Birth Any Congenital Abnormallities', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Birth Any Congenital Abnormallities',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Birth Condition of Baby at Birth', coalesce(o.value_numeric, o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Birth Condition of Baby at Birth',
  GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Conducted By', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC) AS 'Conducted By'

  FROM obs o
  JOIN concept obs_concept ON obs_concept.concept_id=o.concept_id AND obs_concept.retired is false
  JOIN concept_name obs_fscn on o.concept_id=obs_fscn.concept_id AND obs_fscn.concept_name_type="FULLY_SPECIFIED" AND obs_fscn.voided is false
   AND obs_fscn.name IN ('Birth Booked/ Unbooked',
	'Birth Date of Delivery',
	'Birth Village program (Yes / No)',
	'Birth Gravida',
	'Birth Gestational Age (Week/Month)',
	'Birth Type of Delivery',
	'Risk Factors (Complication/Prenatal Diagnosis)',
	'Birth Number of Babies',
	'Birth Sex of Baby',
	'Birth Time',
    	'Birth Weight',
	'Birth Alive/ Dead',
	'Apgar - Score (X/10)',
    	'Birth Any Congenital Abnormallities',
	'Birth Condition of Baby at Birth',
	'Conducted By'
	)
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
  WHERE o.voided is false AND cast(o.obs_datetime AS DATE) BETWEEN '#startDate#' and '#endDate#' GROUP BY e.encounter_id
  ) as result where Birth_Booked_Unbooked is not null ;
