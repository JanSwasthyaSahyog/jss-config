
/* Outer SELECT statement to filter out unvoided, old EDD obs */
SELECT * FROM
(SELECT 
  pi.identifier                                                 AS 'Patient Identifier',
  CONCAT(pn.given_name, " ", pn.family_name)                    AS 'Patient_Name',
  DATE_FORMAT(p.birthdate, "%d-%b-%Y")                          AS 'Birthdate',
  FLOOR(DATEDIFF(CURDATE(), p.birthdate) / 365)                 AS 'Age',
  pa.value                                                      AS 'Primary Relative',  
  paddress.city_village                                         AS 'Village',
  paddress.address3                                             AS 'Tehsil', 
  paddress.county_district                                      AS 'District',
  DATE_FORMAT(pi.date_created, "%d-%b-%Y")                      AS 'Registration Date',
  DATE_FORMAT(pp.date_enrolled, "%d-%b-%Y")                     AS 'Program Enrolment Date',
  prog_attr_result.programID                                    AS 'ANC ID',

  DATE_FORMAT(GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Last menstrual period', coalesce(o.value_numeric,  o.value_text, o.value_datetime, 
  coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC), "%d-%b-%Y") AS 'Last_Menstrual_Period',

  DATE_FORMAT(GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Estimated Date of Delivery', coalesce(o.value_numeric,  o.value_text, o.value_datetime, 
  coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC), "%d-%b-%Y") AS 'Estimated_Date_Of_Delivery',

  UPPER(prog_attr_result.highRisk)                              AS 'High Risk',
  prog_attr_result.highRiskReason                               AS 'High Risk Reason',
  prog_attr_result.highRiskReasonText                           AS 'High Risk Reason Text', 
  
  SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC,Cluster', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, 
  coded_fscn.name), NULL)) ORDER BY o.obs_id DESC), ',', 1) AS 'Cluster',

  SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Follow up visit', coalesce(o.value_numeric,  o.value_text, o.value_datetime, 
  coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC), ',', 1) AS 'Follow up visit',

  SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Fundal Height', REPLACE(coalesce(o.value_numeric,  o.value_text, o.value_datetime, 
  coded_scn.name, coded_fscn.name), ',','-'), NULL)) ORDER BY o.obs_id DESC), ',', 1) AS 'Fundal Height',

  SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Position', REPLACE(coalesce(o.value_numeric,  o.value_text, o.value_datetime, 
  coded_scn.name, coded_fscn.name), ',','-'), NULL)) ORDER BY o.obs_id DESC), ',', 1) AS 'Position',  

  SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'ANC, Fetal Heart Sound', coalesce(o.value_numeric,  o.value_text, o.value_datetime, 
  coded_scn.name, coded_fscn.name), NULL)) ORDER BY o.obs_id DESC), ',', 1) AS 'FHS',

  SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Height', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, 
  coded_fscn.name), NULL)) ORDER BY o.obs_id DESC), ',', 1) AS 'Height',

  SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Weight', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, 
  coded_fscn.name), NULL)) ORDER BY o.obs_id DESC), ',', 1) AS 'Weight',

  SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Haemoglobin', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, 
  coded_fscn.name), NULL)) ORDER BY o.obs_id DESC), ',', 1) AS 'Haemoglobin',

  SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Systolic', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, 
  coded_fscn.name), NULL)) ORDER BY o.obs_id DESC), ',', 1) AS 'Systolic',

  SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT(IF(obs_fscn.name = 'Diastolic', coalesce(o.value_numeric,  o.value_text, o.value_datetime, coded_scn.name, 
  coded_fscn.name), NULL)) ORDER BY o.obs_id DESC), ',', 1) AS 'Diastolic',  

  SUBSTRING_INDEX(GROUP_CONCAT(anc_location.name ORDER BY o.obs_datetime DESC), ',', 1) AS 'Last_ANC_Location'

FROM patient_program pp
LEFT JOIN patient_identifier pi ON pp.patient_id=pi.patient_id AND pp.voided IS FALSE
JOIN person_name pn ON pi.patient_id = pn.person_id 
JOIN person p ON pi.patient_id = p.person_id 
JOIN person_attribute pa ON pi.patient_id = pa.person_id AND pa.person_attribute_type_id=14 /* person_attribute_type_id=14 == "primaryReleative"[sic] */
JOIN person_address paddress ON pi.patient_id = paddress.person_id 
JOIN obs edd ON pp.patient_id = edd.person_id AND edd.concept_id = 5532 AND edd.voided IS FALSE /* concept_id = 5532 == "EDD" */
LEFT JOIN obs o ON pp.patient_id=o.person_id AND o.voided IS FALSE 
JOIN concept_name obs_fscn on o.concept_id=obs_fscn.concept_id AND obs_fscn.concept_name_type="FULLY_SPECIFIED" AND obs_fscn.voided IS FALSE
   AND obs_fscn.name IN ('ANC,Cluster',
     'ANC, Last menstrual period',
     'ANC, Estimated Date of Delivery',
     'ANC, Follow up visit',
     'Height',
     'Weight',
     'Haemoglobin',
     'Systolic',
     'Diastolic',
     'Posture',
     'ANC, Fundal Height',
     'ANC, Position',
     'ANC, Fetal Heart Sound')
LEFT JOIN concept_name obs_scn on o.concept_id=obs_scn.concept_id AND obs_scn.concept_name_type="SHORT" AND obs_scn.voided IS FALSE
LEFT JOIN concept_name coded_fscn on coded_fscn.concept_id = o.value_coded AND coded_fscn.concept_name_type="FULLY_SPECIFIED" AND coded_fscn.voided IS FALSE
LEFT JOIN concept_name coded_scn on coded_scn.concept_id = o.value_coded AND coded_fscn.concept_name_type="SHORT" AND coded_scn.voided IS FALSE
LEFT JOIN location anc_location ON o.location_id = anc_location.location_id and anc_location.name LIKE "ANC -%"    
LEFT JOIN (SELECT
             patient_program_id,
             GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'Program ID', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'programID' , 
             GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'High Risk', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'highRisk' , 
             GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'High Risk Reason', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'highRiskReason' , 
             GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'High Risk Reason Text', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'highRiskReasonText'
           FROM program_attribute_type pg_at
           LEFT JOIN patient_program_attribute pg_attr ON pg_attr.attribute_type_id = pg_at.program_attribute_type_id AND pg_attr.voided = false 
             AND pg_at.name in('Program ID','High Risk','High Risk Reason','High Risk Reason Text')
           LEFT JOIN concept_view pg_attr_cn ON pg_attr.value_reference = pg_attr_cn.concept_id AND pg_at.datatype LIKE "%Concept%"
           GROUP BY patient_program_id) prog_attr_result ON prog_attr_result.patient_program_id = pp.patient_program_id  


WHERE pp.program_id=2 AND edd.value_datetime BETWEEN '#startDate#' and '#endDate#'
GROUP BY pi.identifier) a 
WHERE STR_TO_DATE(a.Estimated_Date_Of_Delivery, '%d-%b-%Y') BETWEEN '#startDate#' and '#endDate#' ORDER BY STR_TO_DATE(a.Estimated_Date_Of_Delivery, '%d-%b-%Y');

