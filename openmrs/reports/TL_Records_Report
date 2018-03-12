
select pi.identifier,DATE(pi.date_created)RegistrationDate,concat(pn.given_name, " ", pn.family_name) AS 'Patient Name',pr.value PrimeryReleative,person.gender,person.birthdate,
DATEDIFF(curdate(),person.birthdate) /365 Age,pa.city_village village, pa.address3 Tehshil, pa.county_district District, pa.state_province State,
mobile.value MobileNo, DATE(dos.value_datetime),
sp.value_coded SurgicalProcedure, spnc.value_text, osname.name OperatingSurgeon
from patient_identifier pi
left join person_name pn  ON pi.patient_id = pn.person_id
left join person ON pi.patient_id = person.person_id
left join person_address pa ON (person.person_id = pa.person_id)
left join person_attribute mobile ON ( person.person_id = mobile.person_id AND person_attribute_type_id = 11)
inner join obs dos ON (dos.person_id = person.person_id AND dos.concept_id = 3343)
left join person_attribute pr ON ( person.person_id = pr.person_id AND pr.person_attribute_type_id = 14)
left join obs sp ON ( sp.person_id = person.person_id AND sp.concept_id = 3344)
left join obs spnc  ON (spnc.person_id = person.person_id AND spnc.concept_id = 3345)
left join obs os ON (os.person_id = person.person_id AND os.concept_id = 3985)
left join concept_name osname ON (os.value_coded = osname.concept_id AND osname.concept_name_type = 'SHORT')     
where  DATE(dos.value_datetime) between '#startDate#' and '#endDate# '
Group By pi.identifier ;

