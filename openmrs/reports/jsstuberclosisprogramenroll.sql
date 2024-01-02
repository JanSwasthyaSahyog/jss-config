select DATE(person.date_created) AS RegistrationDate,pi.identifier, concat(pn.given_name," ", pn.family_name) as PatientName, pr.value FathersName,person.gender Gender,
program.name as ProgramName, DATE(pp.date_enrolled),ocname.name as OutCome,
prog_attr_result.programID, date(pp.date_completed) as ProgramCompleteDate,
  prog_attr_result.highRisk,
  prog_attr_result.highRiskReason,
  prog_attr_result.highRiskReasonText,
  GROUP_CONCAT(DISTINCT diagnosisname.name),GROUP_CONCAT(DISTINCT diagnosisnon.value_text),
  ac.value Aadharcard, ab.value AyushmanId, nikshay.value NikshayID, bankaccount.value BankAccountNumber, bankifsc.value BankIFSC
from obs
left join patient_identifier pi on obs.person_id = pi.patient_id
left join person_name pn ON obs.person_id = pn.person_id
left join person ON obs.person_id = person.person_id
left join patient_program pp ON obs.person_id = pp.patient_id
left join person_attribute pr ON ( person.person_id = pr.person_id AND pr.person_attribute_type_id = 14)
left join person_attribute ab ON ( person.person_id = ab.person_id AND ab.person_attribute_type_id = 39)
left join person_attribute ac ON ( person.person_id = ac.person_id AND ac.person_attribute_type_id = 40)    
left join person_attribute nikshay ON ( person.person_id = nikshay.person_id AND nikshay.person_attribute_type_id = 41)
left join person_attribute bankaccount ON ( person.person_id = bankaccount.person_id AND bankaccount.person_attribute_type_id = 42)
left join person_attribute bankifsc ON ( person.person_id = bankifsc.person_id AND bankifsc.person_attribute_type_id = 43)
 
left join concept_name ocname ON (ocname.concept_id = pp.outcome_concept_id AND ocname.concept_name_type = 'FULLY_SPECIFIED')
left join program on program.program_id = pp.program_id                    
left join obs diagnosis ON ( diagnosis.encounter_id = obs.encounter_id AND diagnosis.concept_id = 43 )
left join concept_name diagnosisname ON (diagnosis.value_coded = diagnosisname.concept_id AND diagnosisname.concept_name_type = 'FULLY_SPECIFIED')
left join obs diagnosisnon ON ( diagnosisnon.encounter_id = obs.encounter_id AND diagnosisnon.concept_id = 42 )
 
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

where pp.program_id = 10 and  pp.date_enrolled between '#startDate#' AND '#endDate#'
GROUP BY pi.identifier ; 