select coalesce(organization.name, 'Unassigned') as org_name,
 sample.accession_number,date(referral.referral_request_date),patient_identity.identity_data as registration_number,type_of_sample.description as sample,  test.description as test,
(case organization.name WHEN NULL THEN ''
                ELSE (case result.result_type WHEN NULL THEN ''
                                        WHEN 'N' then result.value
                                        WHEN 'R' then result.value
                                        WHEN 'D' then dictionary.dict_entry
                                        ELSE 'N/A'
                END)
END) as result
from referral
inner join analysis on referral.analysis_id = analysis.id
inner join test on analysis.test_id = test.id
inner join sample_item on sample_item.id = analysis.sampitem_id
inner join sample on sample.id = sample_item.samp_id
inner join type_of_sample on sample_item.typeosamp_id = type_of_sample.id
inner join sample_human on sample_human.samp_id = sample.id
inner join patient on sample_human.patient_id = patient.id
inner join patient_identity on patient_identity.patient_id = patient.id
inner join patient_identity_type on (patient_identity.identity_type_id = patient_identity_type.id and patient_identity_type.identity_type = 'ST')
left  join organization on referral.organization_id = organization.id
left  join result on result.analysis_id=analysis.id
left  join dictionary on result.result_type='D' and dictionary.id::varchar(255) = result.value
where date(referral.referral_request_date) between '#startDate#' and '#endDate#'
and referral.canceled = FALSE
order by org_name asc, sample.received_date desc, accession_number asc;
