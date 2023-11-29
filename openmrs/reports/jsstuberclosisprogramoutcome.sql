select pi.identifier RegistrationNumber, concat(pn.given_name," ", pn.family_name) as PatientName, pr.value FathersName,person.gender Gender,
program.name as ProgramName, DATE(pp.date_enrolled) ProgramEnrollDate,ocname.name as OutCome,
prog_attr_result.programID, date(pp.date_completed) as ProgramCompleteDate,
  prog_attr_result.highRisk,
  prog_attr_result.highRiskReason,
  prog_attr_result.highRiskReasonText
from obs
left join patient_identifier pi on obs.person_id = pi.patient_id
left join person_name pn ON obs.person_id = pn.person_id
left join person ON obs.person_id = person.person_id
left join patient_program pp ON obs.person_id = pp.patient_id
left join person_attribute pr ON ( person.person_id = pr.person_id AND pr.person_attribute_type_id = 14)
left join concept_name ocname ON (ocname.concept_id = pp.outcome_concept_id AND ocname.concept_name_type = 'FULLY_SPECIFIED')
left join program on program.program_id = pp.program_id                    
                         
 LEFT JOIN ( SELECT                      
 patient_program_id,
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'Program ID', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'programID' ,
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'High Risk', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'highRisk' ,
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'High Risk Reason', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'highRiskReason' ,
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'High Risk Reason Text', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'highRiskReasonText'
                           FROM program_attribute_type pg_at
                                       LEFT JOIN patient_program_attribute pg_attr ON pg_attr.attribute_type_id = pg_at.program_attribute_type_id AND pg_attr.voided = false AND pg_at.name in('Program ID','High Risk','High Risk Reason','High Risk Reason Text')
                                       LEFT JOIN concept_view pg_attr_cn ON pg_attr.value_reference = pg_attr_cn.concept_id AND pg_at.datatype LIKE "%Concept%"
                            GROUP BY patient_program_id ) prog_attr_result ON prog_attr_result.patient_program_id = pp.patient_program_id

where pp.program_id = 10 and  pp.date_completed between '#startDate#' AND '#endDate#' and pp.date_completed is not null

GROUP BY pi.identifier;               