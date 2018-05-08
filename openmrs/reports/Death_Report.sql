


select patient_identifier.identifier RegistrationNumber,person_name.given_name PatientName, person_name.family_name LastName, person.gender ,DATEDIFF(curdate(), 
person.birthdate) /365 Age, person_address.city_village village, person_address.address3 Tehsil, person_address.county_district District,
 person_address.state_province State, class.name Cast, date(person.date_created) RegistrationDate, GROUP_CONCAT(DISTINCT diagnosisname.name) Diagnosis, 
 GROUP_CONCAT(DISTINCT formname.name) Template, person.death_date DeathDate, codname.name CauseOfDeath
from  patient_identifier
  inner join person ON (patient_identifier.patient_id = person.person_id and date(person.death_date) between '#startDate#' and '#endDate#')
      inner join person_name  ON person.person_id = person_name.person_id
      inner join person_address ON (person.person_id = person_address.person_id)
      left join person_attribute ON ( person.person_id = person_attribute.person_id AND person_attribute_type_id = 15)
      left join concept_name class ON (class.concept_id = person_attribute.value AND class.concept_name_type = 'FULLY_SPECIFIED')
      left join obs diagnosis ON ( diagnosis.person_id = person.person_id AND diagnosis.concept_id = 43 )
      left join concept_name diagnosisname ON (diagnosis.value_coded = diagnosisname.concept_id AND diagnosisname.concept_name_type = 'FULLY_SPECIFIED')
      left join obs form ON form.person_id = person.person_id
      left join concept_set ON (form.concept_id = concept_set.concept_id AND concept_set.concept_set = 2122)
      left join concept_name formname ON (formname.concept_id = concept_set.concept_id AND formname.concept_name_type = 'FULLY_SPECIFIED')
      inner join concept_name codname ON (person.cause_of_death = codname.concept_id AND codname.concept_name_type = 'FULLY_SPECIFIED')
      GROUP BY patient_identifier.identifier;
