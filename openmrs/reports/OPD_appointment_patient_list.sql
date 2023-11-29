select date(pa.start_date_time) As Appoinment_Date,pi.identifier,concat(person_name.given_name," ", person_name.family_name) as name, p.gender,
aps.name AS Appointment_Service ,ast.name AS Appointment_Service_Type,pa.comments AS Appointment_comments,
(CASE WHEN vt.name = 'OPD' THEN 'OPD'
            WHEN vt.name = 'IPD' THEN 'IPD'
            WHEN vt.name = 'LAB VISIT' THEN 'LAB VISIT'
            WHEN vt.name = 'ANC' THEN 'ANC'      
            WHEN vt.name = 'EMERGENCY' THEN 'EMERGENCY' 
            ELSE 'MISSED'
       END) as Visit_Type,
v.date_started as visit_Date_Time
from patient_appointment pa
left join visit v on v.patient_id = pa.patient_id and date(v.date_started) = date(pa.start_date_time)
left join patient_identifier pi on pi.patient_id = pa.patient_id
left join person_name  ON pa.patient_id = person_name.person_id
inner join appointment_service aps on pa.appointment_service_id = aps.appointment_service_id
left join appointment_service_type ast on pa.appointment_service_type_id = ast.appointment_service_type_id
left join visit_type vt on vt.visit_type_id = v.visit_type_id
left join person p on pa.patient_id = p.person_id
where pa.appointment_service_id = 1 and date(pa.start_date_time) BETWEEN '#startDate#' and '#endDate#' 
group by pa.patient_appointment_id;