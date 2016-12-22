select pi.identifier,DATE(pi.date_created) RegistrationDate,DATE(pp.date_enrolled) DateOfDiagnosis,pn.given_name, 
pn.family_name,person.gender,person.birthdate,
DATEDIFF(curdate(),person.birthdate) /365 Age,pa.city_village village, 
pa.address3 Tehshil, pa.county_district District, 
pa.state_province State,mobile.value MobileNo, 
hight.value_numeric Height, wieght.value_numeric Weight, 
BMI.value_numeric BMI,waist.value_numeric Waist,hip.value_numeric Hip, 
GROUP_CONCAT(DISTINCT d.name) Drug, 
GROUP_CONCAT(DISTINCT cdvn.name) Diagnosis,
DATE(pp.date_completed) EndDate
from patient_program pp
left join patient_identifier pi on pp.patient_id = pi.patient_id
left join person_name pn  ON pp.patient_id = pn.person_id
left join person ON pi.patient_id = person.person_id
left join person_address pa ON (person.person_id = pa.person_id)
left join person_attribute mobile ON ( person.person_id = mobile.person_id AND person_attribute_type_id = 11)
left join visit v on v.patient_id = pi.patient_id
left join encounter e on e.visit_id=v.visit_id
left join orders o on o.encounter_id=e.encounter_id and o.order_type_id=2
left join drug_order do on o.order_id=do.order_id
left join drug d on d.drug_id=do.drug_inventory_id
left join confirmed_diagnosis_view_new cdvn on cdvn.visit_id=v.visit_id
left join obs hight ON pi.patient_id = hight.person_id AND hight.concept_id = 5 
left join obs wieght ON wieght.encounter_id = e.encounter_id AND wieght.concept_id = 6
left join obs BMI ON BMI.person_id = pi.patient_id AND BMI.concept_id = 7
left join obs waist on waist.person_id = pi.patient_id AND waist.concept_id = 3325
left join obs hip on hip.person_id = pi.patient_id AND hip.concept_id = 3326
where pp.program_id = 6 and pp.date_enrolled between '#startDate#' and '#endDate#'
Group by pi.patient_id;