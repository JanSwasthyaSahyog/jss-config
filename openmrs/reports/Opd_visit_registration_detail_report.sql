
select v.visit_id,pi.identifier,concat(person_name.given_name," ", person_name.family_name) as name,pr.value PrimeryReleative,p.gender, round(DATEDIFF(now(), p.birthdate) / 365.25) as age,Date(p.birthdate), 
(case when date(p.date_created) between '#startDate#' and '#endDate#' then 'New' else 'Old' end) as Patient_Type, date(v.date_started) as VisitDate,DATE(p.date_created) Registrationdate,  
class.name,
             pa.city_village,pa.address3 Tehshil,
pa.county_district District, pa.state_province State,r.value_numeric,  pc.value PrimeryContact, sc.value SeconderyContact
 , tn.value Telephone, vt.name,u.username as username, location.name
From visit v
    inner join person p on v.patient_id = p.person_id
    inner join person_name  ON v.patient_id = person_name.person_id
    inner join visit_type vt on vt.visit_type_id = v.visit_type_id
    inner join person_address pa on p.person_id = pa.person_id
inner join patient_identifier pi on pi.patient_id = p.person_id
    left join person_attribute pr ON ( p.person_id = pr.person_id AND pr.person_attribute_type_id = 14)
    left join person_attribute pat ON ( p.person_id = pat.person_id AND pat.person_attribute_type_id = 15)
left join concept_name class ON (class.concept_id = pat.value AND class.concept_name_type = 'FULLY_SPECIFIED')  
     left join person_attribute pc ON ( p.person_id = pc.person_id AND pc.person_attribute_type_id = 11)
left join person_attribute sc ON ( p.person_id = sc.person_id AND sc.person_attribute_type_id = 12)
left join person_attribute tn ON ( p.person_id = tn.person_id AND tn.person_attribute_type_id = 34)          
left outer join encounter e on e.visit_id = v.visit_id
left outer join obs o on o.encounter_id = e.encounter_id and o.voided = 0
    left outer join obs r on o.encounter_id = r.encounter_id and r.concept_id = 4
left join concept_name as ans on o.value_coded=ans.concept_id and ans.concept_name_type='SHORT'
left join location on v.location_id = location.location_id
  left outer join users u on o.creator = u.user_id                 
    where date(v.date_started)  between '#startDate#' and '#endDate#'
    AND date(e.encounter_datetime) between '#startDate#' and '#endDate#'
    AND vt.visit_type_id = 12            
    GROUP By v.visit_id  
    Order by Patient_Type, p.gender ASC ;