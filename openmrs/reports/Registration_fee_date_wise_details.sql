select date(o.obs_datetime) As Obs_Date,date(pi.date_created) as RegistrationDate, pi.identifier, concat(pn.given_name, ' ', pn.family_name) as patient_name, 
p.gender,o.location_id, o.value_numeric, o.date_created,u.username as username,
(case when date(pi.date_created) between '#startDate#' and '#endDate#' then 'New' else 'Old' end) as Patient_Type
from obs o
inner join patient_identifier pi on o.person_id = pi.patient_id
inner join person_name pn on o.person_id = pn.person_id
left join person p on pi.patient_id = p.person_id
left outer join encounter e on e.encounter_id = o.encounter_id and o.voided = 0 and e.encounter_type in (select encounter_type_id from encounter_type where name ="REG")
left outer join users u on o.creator = u.user_id
where o.concept_id = 4 and o.location_id = 2 and o.value_numeric <> 0
and date(o.obs_datetime) between '#startDate#' and '#endDate#' and o.voided = 0 ;