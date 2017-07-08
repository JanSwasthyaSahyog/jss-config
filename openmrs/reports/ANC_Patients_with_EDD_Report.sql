
select pi.identifier,DATE(pi.date_created) RegistrationDate,DATE(pp.date_enrolled) DateOfProgramEnroll, pid.value_text ProgramID, pn.given_name, pn.family_name,pr.value PrimeryReleative,person.birthdate, DATEDIFF(curdate(),person.birthdate) /365 Age,hight.value_numeric Height, pa.city_village village, pa.address3 Tehshil, pa.county_district District, pa.state_province State,Date(lmp.value_datetime) LMPDate, Date(edd.value_datetime) EDDDate
from patient_program pp
left join patient_identifier pi on pp.patient_id = pi.patient_id 
left join person_name pn ON pp.patient_id = pn.person_id
left join person ON pi.patient_id = person.person_id
left join person_address pa ON (person.person_id = pa.person_id)
left join person_attribute pr ON ( person.person_id = pr.person_id AND pr.person_attribute_type_id = 14)
left join visit v on v.patient_id = pi.patient_id
inner join obs edd on pp.patient_id = edd.person_id and edd.concept_id = 5532
left join obs lmp on pp.patient_id = lmp.person_id and lmp.concept_id = 5531
left join obs pid on pp.patient_id = pid.person_id and pid.concept_id = 5530

left join obs hight ON pi.patient_id = hight.person_id AND hight.concept_id = 5 
and date(pi.date_created)

where pp.program_id = 2 and edd.value_datetime between '#startDate#' and '#endDate#' 
Group by pi.identifier ;
