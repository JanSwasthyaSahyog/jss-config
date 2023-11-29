Select (case when t0.location is null then 0 else t0.location end) as 'Location',
(case when t3.MaleNewOPD is null then 0 else MaleNewOPD end) as 'Male New',
(case when t1.FemaleNewOPD is null then 0 else FemaleNewOPD end) as 'Female New',
((case when t3.MaleNewOPD is null then 0 else MaleNewOPD end) + (case when t1.FemaleNewOPD is null then 0 else FemaleNewOPD end)) as 'Total New',
(case when t4.MaleOLDOPD is null then 0 else MaleOLDOPD end) as 'Male OLD',
(case when t2.FemaleOLDOPD is null then 0 else FemaleOLDOPD end) as 'Female OLD',
((case when t4.MaleOLDOPD is null then 0 else MaleOLDOPD end) + (case when t2.FemaleOLDOPD is null then 0 else FemaleOLDOPD end)) as 'Total OLD',
((case when t3.MaleNewOPD is null then 0 else MaleNewOPD end) + (case when t4.MaleOLDOPD is null then 0 else MaleOLDOPD end)) as 'Total Male',
((case when t1.FemaleNewOPD is null then 0 else FemaleNewOPD end) + (case when t2.FemaleOLDOPD is null then 0 else FemaleOLDOPD end)) as 'Total Female',
(((case when t3.MaleNewOPD is null then 0 else MaleNewOPD end) + (case when t1.FemaleNewOPD is null then 0 else FemaleNewOPD end)) + ((case when t4.MaleOLDOPD is null then 0 else MaleOLDOPD end) + (case when t2.FemaleOLDOPD is null then 0 else FemaleOLDOPD end))) as 'Total Patient'
from 
(select location.name as location,Count(pi.identifier),
date(v.date_started) from visit v
inner join person as p on v.patient_id = p.person_id
join person_name pn on v.patient_id = pn.person_id and pn.voided = 0
inner join patient_identifier pi on pi.patient_id = p.person_id
inner join visit_type vt on vt.visit_type_id = v.visit_type_id
left join location on v.location_id = location.location_id
left outer join users u on v.creator = u.user_id
left join person_name pnu on u.person_id = pnu.person_id
where vt.visit_type_id = 12
AND date(v.date_started) between '#startDate#' and '#endDate#'

group by location.name order by location.name ASC ) t0
left join
(select location.name as location, count(v.visit_id) as FemaleNewOPD
from visit v
inner join person as p on v.patient_id = p.person_id
inner join visit_type vt on vt.visit_type_id = v.visit_type_id
left join location on v.location_id = location.location_id
inner join patient_identifier pi on pi.patient_id = p.person_id
left outer join users u on v.creator = u.user_id
where vt.visit_type_id = 12
AND date(v.date_created)between '#startDate#' and '#endDate#' 
and Date (p.date_created)between '#startDate#' and '#endDate#' 
and p.gender ='F' 

group by location.name) t1
on (t0.location = t1.location)
left join
(select location.name as location, count(v.visit_id) as FemaleOLDOPD
from visit v
inner join person as p on v.patient_id = p.person_id
inner join visit_type vt on vt.visit_type_id = v.visit_type_id
left join location on v.location_id = location.location_id
left outer join users u on v.creator = u.user_id
where vt.visit_type_id = 12
AND date(v.date_created)between '#startDate#' and '#endDate#' 
And date(v.date_created)<>date(p.date_created)
and p.gender ='F' 

group by location.name) t2
ON (t0.location = t2.location)
left join
(select location.name as location, count(v.visit_id) as MaleNewOPD
from visit v
inner join person as p on v.patient_id = p.person_id
inner join visit_type vt on vt.visit_type_id = v.visit_type_id
left join location on v.location_id = location.location_id
inner join patient_identifier pi on pi.patient_id = p.person_id
left outer join users u on v.creator = u.user_id
where vt.visit_type_id = 12
AND date(v.date_created)between '#startDate#' and '#endDate#'  
and Date (p.date_created)between '#startDate#' and '#endDate#' 
and p.gender ='M' 

group by location.name) t3
on (t0.location = t3.location)
left join
(select location.name as location, count(v.visit_id) as MaleOLDOPD
from visit v
inner join person as p on v.patient_id = p.person_id
inner join visit_type vt on vt.visit_type_id = v.visit_type_id
left join location on v.location_id = location.location_id
left outer join users u on v.creator = u.user_id
where vt.visit_type_id = 12
AND date(v.date_created)between '#startDate#' and '#endDate#' 
And date(v.date_created)<>date(p.date_created)
and p.gender ='M' 

group by location.name) t4
ON (t0.location = t4.location);