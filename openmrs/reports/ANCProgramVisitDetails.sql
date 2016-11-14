SELECT
                      pi.identifier,
                      concat(pat_name.given_name, ' ', pat_name.family_name) AS PatientName,
                      floor(DATEDIFF(DATE(o.date_created), person.birthdate) / 365)   AS Age,
                      person.gender,
                      pattr_result.primaryRelative,
                      address.city_village, 
                      address.county_district, 
                      address.state_province,
					            v.date_started as Visit_StartDate,
                      e.encounter_datetime as Encounter_Date,
                      prog_attr_result.programID as ProgramID,
                      pp.date_enrolled as ProgramEnrollmentDate,
                      prog.name as ProgramName,
                      prog_attr_result.highRisk,
                      prog_attr_result.highRiskReason,
                      prog_attr_result.highRiskReasonText, 
                      pp.date_completed as ProgramCompletionDate,
					            GROUP_CONCAT(DISTINCT(concat(pn.given_name, ' ', pn.family_name)) SEPARATOR ',') as ProviderName,
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'ANC Template, ANC ID', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'ANC ID', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'Gravida', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Gravida', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'Parity', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Parity', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'Abortion', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Abortion', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'Live Births', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Live Births', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'ANC, Last menstrual period', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Last menstrual period', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'ANC, Estimated Date of Delivery', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Estimated Date of Delivery', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'ANC, First Tetanus', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'First Tetanus', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'ANC, Second Tetanus', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Second Tetanus', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'ANC, Visit date', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Visit date', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'ANC, Follow up visit', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Follow up visit', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'Height', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Height', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'Weight', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Weight', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'Albumin (Routine Urine)', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Albumin (Routine Urine)', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'Sugar (Routine Urin)', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Sugar (Routine Urin)', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'ANC, Oedema', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Oedema', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'Haemoglobin', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Haemoglobin', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'Haemoglobin Range', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Haemoglobin Range', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'Systolic', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Systolic', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'Diastolic', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Diastolic', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'Posture', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Posture', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'ANC, Gestation', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Gestation', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'ANC, Fundal Height', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Fundal Height', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'ANC, Position', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Position', 
                      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'ANC, Fetal Heart Sound', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e.date_created, e.encounter_datetime), NULL)) SEPARATOR ',') AS 'Fetal Heart Sound'
                    FROM patient_program pp
                    JOIN program prog ON (pp.program_id = prog.program_id AND prog.name IN ('Ante Natal Care Program'))  AND pp.voided = 0
                    JOIN episode_patient_program epp ON epp.patient_program_id = pp.patient_program_id
                    JOIN episode_encounter ee ON ee.episode_id = epp.episode_id
                    JOIN encounter e ON e.encounter_id = ee.encounter_id
                    JOIN visit v ON v.visit_id=e.visit_id AND v.voided is false
                    AND cast(v.date_started AS DATE) BETWEEN '#startDate#' and '#endDate#'
                  	JOIN (SELECT child_obs.obs_id,child_obs.encounter_id, child_obs.obs_group_id,max(root_obs.obs_id) root_obs_id
                          FROM obs child_obs
                            JOIN obs root_obs on (child_obs.encounter_id = root_obs.encounter_id and
                                              child_obs.voided is FALSE AND
                                              root_obs.voided is FALSE and
                                              child_obs.obs_id > root_obs.obs_id and
                                              root_obs.obs_group_id is null AND
                                              child_obs.form_namespace_and_path = root_obs.form_namespace_and_path )
                            JOIN concept on ( concept.uuid =  TRIM(TRAILING '^' FROM root_obs.form_namespace_and_path ))
                            
                            JOIN concept_view template on ( concept.concept_id=template.concept_id and template.concept_full_name = 'ANC Template' )
                          GROUP BY child_obs.obs_id, child_obs.obs_group_id, child_obs.encounter_id) root_obs on (e.encounter_id = root_obs.encounter_id )
                    JOIN obs o ON o.obs_id = root_obs.obs_id AND o.voided IS FALSE
                    RIGHT JOIN concept_view cv ON cv.concept_id = o.concept_id
                    INNER JOIN person_name pat_name ON pat_name.person_id = o.person_id
                    INNER JOIN person ON person.person_id = o.person_id  LEFT JOIN person_address address ON person.person_id = address.person_id  LEFT JOIN (SELECT
                           person_id,
                           GROUP_CONCAT(DISTINCT(IF(pat.name = 'primaryRelative', coalesce(person_attribute_cn.concept_short_name, person_attribute_cn.concept_full_name, pattr.value), NULL))) AS 'primaryRelative'
                           FROM
                             person_attribute_type pat
                             LEFT JOIN person_attribute pattr ON pattr.person_attribute_type_id = pat.person_attribute_type_id AND pattr.voided = FALSE AND pat.name IN ('primaryRelative')
                             LEFT JOIN concept_view person_attribute_cn ON pattr.value = person_attribute_cn.concept_id AND pat.format LIKE "%Concept"
                           GROUP BY person_id) pattr_result ON pattr_result.person_id = person.person_id LEFT JOIN (SELECT
                           patient_program_id,
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'Program ID', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'programID' , 
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'High Risk', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'highRisk' , 
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'High Risk Reason', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'highRiskReason' , 
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'High Risk Reason Text', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'highRiskReasonText'
                           FROM program_attribute_type pg_at
                                       LEFT JOIN patient_program_attribute pg_attr ON pg_attr.attribute_type_id = pg_at.program_attribute_type_id AND pg_attr.voided = false AND pg_at.name in('Program ID','High Risk','High Risk Reason','High Risk Reason Text')
                                       LEFT JOIN concept_view pg_attr_cn ON pg_attr.value_reference = pg_attr_cn.concept_id AND pg_at.datatype LIKE "%Concept%"
                            GROUP BY patient_program_id ) prog_attr_result ON prog_attr_result.patient_program_id = pp.patient_program_id  INNER JOIN patient_identifier pi ON pi.patient_id = o.person_id and pi.preferred = 1
                  LEFT JOIN encounter_provider ON encounter_provider.encounter_id = o.encounter_id
                  LEFT JOIN provider ON provider.provider_id = encounter_provider.provider_id
                  LEFT JOIN person_name pn ON pn.person_id = provider.person_id
                  LEFT JOIN concept_view answer ON o.value_coded = answer.concept_id 
                  GROUP BY pi.identifier, e.encounter_id,root_obs.root_obs_id;