select pi.identifier RegistrationNumber,DATE(pi.date_created) RegistrationDate,pn.given_name PatientName,pn.family_name LastName,pr.value FathersName,
person.Birthdate,DATEDIFF(curdate(),person.birthdate) /365 Age,person.Gender,pa.city_village Village,pa.address3 Tehshil,pa.county_district District,
pa.state_province State,mobile.value PhoneNumber,DATE(pp.date_enrolled) DateOfTBDiagnosis,cast.value Cast,class.name Class,hight.value_numeric Height,
wieght.value_numeric Weight,BMI.value_numeric BMI,DATE(pp.date_enrolled) ProgramEnrollDate, prog_attr_result.programID,totname.name TypeOfTuberclusis,pttname.name PatientType,bodname.name BasicOfDiagnosis,
tsname.name TreatmentPlan,DATE(doti.date_created) IntekTemplateEnterDate
from patient_program pp
left join patient_identifier pi on pp.patient_id = pi.patient_id
left join person_name pn ON pp.patient_id = pn.person_id
left join person ON pi.patient_id = person.person_id
left join person_address pa ON (person.person_id = pa.person_id)
left join person_attribute mobile ON ( person.person_id = mobile.person_id AND person_attribute_type_id = 11)
left join person_attribute pr ON ( person.person_id = pr.person_id AND pr.person_attribute_type_id = 14)
left join person_attribute cast ON ( person.person_id = cast.person_id AND cast.person_attribute_type_id = 8)
left join person_attribute cl ON ( person.person_id = cl.person_id AND cl.person_attribute_type_id = 15)
left join concept_name class ON (class.concept_id = cl.value AND class.concept_name_type = 'FULLY_SPECIFIED')
left join visit v on v.patient_id = pi.patient_id
left join encounter e on e.visit_id=v.visit_id
left join orders o on o.encounter_id=e.encounter_id and o.order_type_id=2
left join obs hight ON pi.patient_id = hight.person_id AND hight.concept_id = 5 and date(pi.date_created)
left join obs wieght ON wieght.encounter_id = e.encounter_id AND wieght.concept_id = 6
left join obs BMI ON BMI.person_id = pi.patient_id AND BMI.concept_id = 7
left join obs doti On ( pi.patient_id = doti.person_id AND doti.concept_id = 4257)
left join obs tot ON ( pi.patient_id = tot.person_id AND tot.concept_id = 4187)
left join concept_name totname ON (totname.concept_id = tot.value_coded AND totname.concept_name_type = 'FULLY_SPECIFIED')
left join obs ptt ON ( pi.patient_id = ptt.person_id AND ptt.concept_id = 4194)
left join concept_name pttname ON (pttname.concept_id = ptt.value_coded AND pttname.concept_name_type = 'FULLY_SPECIFIED')
left join obs bod ON ( pi.patient_id = bod.person_id AND bod.concept_id = 4197)
left join concept_name bodname ON (bodname.concept_id = bod.value_coded AND bodname.concept_name_type = 'FULLY_SPECIFIED')
left join obs ts ON ( pi.patient_id = ts.person_id AND ts.concept_id = 4198)
left join concept_name tsname ON (tsname.concept_id = ts.value_coded AND tsname.concept_name_type = 'FULLY_SPECIFIED')
LEFT JOIN ( SELECT                       
 patient_program_id,
                           GROUP_CONCAT(DISTINCT(IF(pg_at.name = 'Program ID', coalesce(pg_attr_cn.concept_short_name, pg_attr_cn.concept_full_name, pg_attr.value_reference), NULL))) AS 'programID'
                           FROM program_attribute_type pg_at
                                       LEFT JOIN patient_program_attribute pg_attr ON pg_attr.attribute_type_id = pg_at.program_attribute_type_id AND pg_attr.voided = false AND pg_at.name in('Program ID')
                                       LEFT JOIN concept_view pg_attr_cn ON pg_attr.value_reference = pg_attr_cn.concept_id AND pg_at.datatype LIKE "%Concept%"
                            GROUP BY patient_program_id ) prog_attr_result ON prog_attr_result.patient_program_id = pp.patient_program_id 
where pp.program_id = 10 and pp.date_enrolled between '#startDate#' and '#endDate#'
GROUP BY pi.identifier;

