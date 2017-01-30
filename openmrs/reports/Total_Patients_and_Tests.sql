Select sample_source.name as Sample_Source,count(distinct(sample_human.patient_id)) as total_patient,count(distinct(analysis.id)) as total_test
from sample
        inner join sample_human on sample_human.samp_id=sample.id
        inner join sample_item on sample_item.samp_id = sample.id
        inner join analysis on analysis.sampitem_id = sample_item.id
        inner join sample_source on sample.sample_source_id=sample_source.id
        inner join status_of_sample on analysis.status_id = status_of_sample.id
        WHERE status_of_sample.name = 'Finalized'
        AND status_of_sample.name <> 'Test Canceled'
        AND  date(sample.entered_date) between '#startDate#'AND '#endDate#'
    group by sample_source.name
        order by sample_source.name;
