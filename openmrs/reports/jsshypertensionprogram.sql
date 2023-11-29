SELECT DATE(person.date_created) AS RegistrationDate, pi.identifier AS Registration_ID,concat(pn.given_name," ", pn.family_name) AS PatientName, pr.value FathersName, person.gender,program.name AS ProgramName,DATE(pp.date_enrolled)AS Program_Enroll_Date,
prog_attr_result.programID,
  prog_attr_result.highRisk,
  prog_attr_result.highRiskReason,
  prog_attr_result.highRiskReasonText
FROM obs
LEFT JOIN patient_identifier pi ON obs.person_id = pi.patient_id
LEFT JOIN person_name pn ON obs.person_id = pn.person_id
LEFT JOIN person ON obs.person_id = person.person_id
LEFT JOIN patient_program pp ON obs.person_id = pp.patient_id
LEFT JOIN person_attribute pr ON ( person.person_id = pr.person_id AND pr.person_attribute_type_id = 14)
 LEFT JOIN program ON program.program_id = pp.program_id                               
                         
 LEFT JOIN ( SELECT                       
 patient_program_id,
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'Program ID', COALESCE(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'programID' , 
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'High Risk', COALESCE(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'highRisk' , 
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'High Risk Reason', COALESCE(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'highRiskReason' , 
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'High Risk Reason Text', COALESCE(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'highRiskReasonText'
                           FROM program_attribute_type pg_at
                                       LEFT JOIN patient_program_attribute pg_attr ON pg_attr.attribute_type_id = pg_at.program_attribute_type_id AND pg_attr.voided = FALSE AND pg_at.name IN('Program ID','High Risk','High Risk Reason','High Risk Reason Text')
                                       LEFT JOIN concept_view pg_attr_cn ON pg_attr.value_reference = pg_attr_cn.concept_id AND pg_at.datatype LIKE "%Concept%"
                            GROUP BY patient_program_id ) prog_attr_result ON prog_attr_result.patient_program_id = pp.patient_program_id 

WHERE pp.program_id = 8 AND  pp.date_enrolled BETWEEN '#startDate#' AND '#endDate#'

GROUP BY pi.identifier ORDER BY Program_Enroll_Date, RegistrationDate ASC ;                        