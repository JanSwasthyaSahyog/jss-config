select t1.program_name,t1.enrollpatient,t2.completedpatient
from
(select pp.program_id as programid, program.name as program_name,count(patient_id) as enrollpatient
from patient_program pp
left join program on program.program_id = pp.program_id  
where  pp.date_enrolled between '#startDate#' AND '#endDate#'
group by programid )t1
left join
(select pp.program_id as programid, program.name,count(patient_id)as completedpatient
from patient_program pp
left join program on program.program_id = pp.program_id  
where  pp.date_completed between '#startDate#' AND '#endDate#' 
and pp.date_completed is not null
group by programid)t2
ON (t1.programid = t2.programid) 
order by t1.program_name asc; 