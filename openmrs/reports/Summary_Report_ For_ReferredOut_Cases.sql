select organization.name as organization_name, type_of_sample.description as sample_type_name, count(distinct(sample.id)) number_of_samples, count(distinct(analysis.id)) as number_of_tests
from referral
inner join organization on referral.organization_id = organization.id
inner join analysis on referral.analysis_id = analysis.id
inner join test on analysis.test_id = test.id
inner join result on result.analysis_id=analysis.id
inner join sample_item on sample_item.id = analysis.sampitem_id
inner join sample on sample.id = sample_item.samp_id
inner join type_of_sample on sample_item.typeosamp_id = type_of_sample.id
where date(sample.entered_date) between '#startDate#' and '#endDate#'
and referral.canceled = FALSE
group by organization.name, sample_type_name;
