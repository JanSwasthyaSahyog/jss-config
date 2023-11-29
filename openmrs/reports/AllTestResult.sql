	Select date(sample.entered_date)as date,concat(person.first_name,' ',person.last_name) "Patient Name",patient.gender, (patient.birth_date), patient_identity.identity_data as registration_number,type_of_sample.description as sample, test.name as test_name,

                        (CASE

                                        WHEN (result.result_type='N'

                                                        AND result.value != ''

                                                        AND result.value IS NOT NULL

                                                        AND NOT (result.min_normal=0 and result.max_normal=0))

                        THEN result.value
                        WHEN (result.result_type='D')
                        THEN dictionary.dict_entry
                END) as result_value

        from test

        inner join analysis on analysis.test_id = test.id
        inner join result on result.analysis_id=analysis.id
        inner join sample_item on sample_item.id = analysis.sampitem_id
    inner join type_of_sample on sample_item.typeosamp_id = type_of_sample.id
        inner join sample on sample.id = sample_item.samp_id
        inner join sample_human on sample_human.samp_id = sample.id
        inner join patient on sample_human.patient_id = patient.id
        inner join patient_identity on patient_identity.patient_id = patient.id
        inner join patient_identity_type on (patient_identity.identity_type_id = patient_identity_type.id and patient_identity_type.identity_type = 'ST')
        left join person on patient.person_id = person.id
        left  join dictionary on result.result_type='D' and dictionary.id::varchar(255) = result.value
        inner join status_of_sample on status_of_sample.id = analysis.status_id
        WHERE status_of_sample.name = 'Finalized'
    AND status_of_sample.name <> 'Test Canceled'
        AND date(sample.entered_date) between '#startDate#' and '#endDate#'
        ORDER BY date, registration_number;