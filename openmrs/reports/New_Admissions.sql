

SELECT * FROM (
( SELECT COALESCE(a.identifier, b.identifier) identifier,
  COALESCE(a.age, b.age) age,
  COALESCE(a.name, b.name) NAME,
  COALESCE(a.Gender, b.Gender) gender,
  notes,
  bed,
  ward,
  Disposition_By  
  FROM (SELECT DISTINCT pi.identifier AS identifier,
                   round(DATEDIFF(now(), p.birthdate) / 365.25) AS age,
                   concat(pn.given_name, '',IFNULL(pn.family_name, '')) AS 'NAME',
                   IF(p.gender = "F", "Female", "Male") AS Gender,
                   dispositionNote.value_text notes,
                   person_name.given_name AS Disposition_By
   FROM visit v
     JOIN person_name pn ON v.patient_id = pn.person_id AND pn.voided = 0 AND v.voided = 0
     JOIN patient_identifier pi ON v.patient_id = pi.patient_id
     JOIN person p ON v.patient_id = p.person_id
     JOIN encounter e ON v.visit_id = e.visit_id
     JOIN obs o ON e.encounter_id = o.encounter_id AND o.voided = 0
     JOIN concept c ON o.value_coded = c.concept_id
     JOIN concept_name cn ON c.concept_id = cn.concept_id AND cn.name = 'Admit Patient'
     JOIN (SELECT person_id, max(obs_id) FROM obs WHERE obs.value_coded = 50 GROUP BY person_id) max_obs ON o.person_id = max_obs.person_id
     JOIN obs dispositionNote ON dispositionNote.concept_id = (SELECT concept_id
                                                                          FROM concept_name
                                                                          WHERE
                                                                            NAME = 'Disposition Note' AND concept_name_type = 'FULLY_SPECIFIED')
                                            AND dispositionNote.obs_group_id = o.obs_group_id AND dispositionNote.voided = 0                                            
                      LEFT OUTER JOIN encounter_provider ep ON dispositionNote.encounter_id = ep.encounter_id
                      LEFT OUTER JOIN provider disp_provider ON disp_provider.provider_id = ep.provider_id
                      LEFT OUTER JOIN person_name ON person_name.person_id = disp_provider.person_id
  WHERE DATE(o.date_created) between '#startDate#' and '#endDate#') AS a
  LEFT OUTER JOIN (SELECT
                     DISTINCT pi.identifier AS identifier,
                              round(DATEDIFF(now(), p.birthdate) / 365.25) AS age,
                              concat(pn.given_name," ", pn.family_name) AS NAME,
                              IF(p.gender = "F", "Female", "Male") AS Gender,
                              bed.bed_number bed,
                              plocation.name ward
                   FROM encounter encounters_in_visit_with_admission
                     JOIN visit visit_with_admission ON encounters_in_visit_with_admission.visit_id = visit_with_admission.visit_id
                                                        AND DATE(visit_with_admission.date_started) between '#startDate#' and '#endDate#'
                                                        AND encounter_type IN (3, 5)
                     JOIN visit_attribute va ON visit_with_admission.visit_id = va.visit_id AND va.value_reference = "Admitted" AND va.voided = 0
                     JOIN (SELECT patient_id, max(encounter_id) last_encounter_id
                           FROM encounter WHERE encounter_type IN (3,5) AND DATE(encounter_datetime) between '#startDate#' and '#endDate#'
                           GROUP BY patient_id) last_encounters ON last_encounter_id = encounters_in_visit_with_admission.encounter_id
                     JOIN person_name pn ON visit_with_admission.patient_id = pn.person_id AND pn.voided = 0 AND visit_with_admission.voided = 0
                     JOIN patient_identifier pi ON visit_with_admission.patient_id = pi.patient_id
                     JOIN person p ON visit_with_admission.patient_id = p.person_id
                     LEFT JOIN bed_patient_assignment_map bpam ON bpam.encounter_id = last_encounter_id
                     LEFT JOIN bed ON bpam.bed_id = bed.bed_id
                     LEFT JOIN bed_location_map bl ON bl.bed_id = bpam.bed_id
                     LEFT JOIN location clocation ON clocation.location_id = bl.location_id
                     LEFT JOIN location plocation ON clocation.parent_location = plocation.location_id
) AS b ON a.identifier = b.identifier)
UNION
(SELECT
 COALESCE(a.identifier, b.identifier) identifier,
 COALESCE(a.age, b.age) age,
 COALESCE(a.name, b.name) NAME,
 COALESCE(a.Gender, b.Gender) gender,
 notes,
 bed,
 ward,
 Disposition_By
 FROM (SELECT DISTINCT pi.identifier AS identifier,
                                round(DATEDIFF(now(), p.birthdate) / 365.25) AS age,
                                concat(pn.given_name, '',IFNULL(pn.family_name, '')) AS 'NAME',
                                IF(p.gender = "F", "Female", "Male") AS Gender,
                                dispositionNote.value_text notes,
                                person_name.given_name AS Disposition_By
                FROM visit v
                  JOIN person_name pn ON v.patient_id = pn.person_id AND pn.voided = 0 AND v.voided = 0
                  JOIN patient_identifier pi ON v.patient_id = pi.patient_id
                  JOIN person p ON v.patient_id = p.person_id
                  JOIN encounter e ON v.visit_id = e.visit_id
                  JOIN obs o ON e.encounter_id = o.encounter_id AND o.voided = 0
                  JOIN concept c ON o.value_coded = c.concept_id
                  JOIN concept_name cn ON c.concept_id = cn.concept_id AND cn.name = 'Admit Patient'
                  JOIN (SELECT person_id, max(obs_id) FROM obs WHERE obs.value_coded = 50 GROUP BY person_id) max_obs ON o.person_id = max_obs.person_id
                  JOIN obs dispositionNote ON dispositionNote.concept_id = (SELECT concept_id
                                                                            FROM concept_name
                                                                            WHERE
                                                                              NAME = 'Disposition Note' AND concept_name_type = 'FULLY_SPECIFIED')
                                              AND dispositionNote.obs_group_id = o.obs_group_id AND dispositionNote.voided = 0
					  LEFT OUTER JOIN encounter_provider ep ON dispositionNote.encounter_id = ep.encounter_id
                      LEFT OUTER JOIN provider disp_provider ON disp_provider.provider_id = ep.provider_id
                      LEFT OUTER JOIN person_name ON person_name.person_id = disp_provider.person_id                                           
					  WHERE DATE(o.date_created) between '#startDate#' and '#endDate#') AS a RIGHT OUTER JOIN (SELECT
                                                         DISTINCT pi.identifier AS identifier,
                                                                  round(DATEDIFF(now(), p.birthdate) / 365.25) AS age,
                                                                  concat(pn.given_name," ", pn.family_name ) AS NAME,
                                                                  IF(p.gender = "F", "Female", "Male") AS Gender,
                                                                  bed.bed_number Bed,
                                                                  plocation.name ward
                                        FROM encounter encounters_in_visit_with_admission
                                          JOIN visit visit_with_admission ON encounters_in_visit_with_admission.visit_id = visit_with_admission.visit_id
                                                                             AND DATE(visit_with_admission.date_started) between '#startDate#' and '#endDate#'
                                                                             AND encounter_type IN (3, 5)
                                          JOIN visit_attribute va ON visit_with_admission.visit_id = va.visit_id AND va.value_reference = "Admitted" AND va.voided = 0
                                          JOIN (SELECT patient_id, max(encounter_id) last_encounter_id
                                                FROM encounter WHERE encounter_type IN (3,5) AND DATE(encounter_datetime) between '#startDate#' and '#endDate#'
                                                GROUP BY patient_id) last_encounters ON last_encounter_id = encounters_in_visit_with_admission.encounter_id
                                          JOIN person_name pn ON visit_with_admission.patient_id = pn.person_id AND pn.voided = 0 AND visit_with_admission.voided = 0
                                          JOIN patient_identifier pi ON visit_with_admission.patient_id = pi.patient_id
                                          JOIN person p ON visit_with_admission.patient_id = p.person_id
                                          LEFT JOIN bed_patient_assignment_map bpam ON bpam.encounter_id = last_encounter_id
                                          LEFT JOIN bed ON bpam.bed_id = bed.bed_id
                                          LEFT JOIN bed_location_map bl ON bl.bed_id = bpam.bed_id
                                          LEFT JOIN location clocation ON clocation.location_id = bl.location_id
                                          LEFT JOIN location plocation ON clocation.parent_location = plocation.location_id
) AS b ON a.identifier = b.identifier)) AS ab ORDER BY ward;
