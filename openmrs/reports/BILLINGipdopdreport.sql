select r1.care_type as Care_Type,r1.no_of_patient,r1.no_of_bill,r1.Billed_amount,r2.No_Of_discount_patient,r2.no_of_discount_Bill,r2.To_Discount,
 r1.Tobe_Paid_by_patient,
 r3.Insurance_patient,r3.Insurance,r4.Count_Payment ,r4.Received_as_cash_amount,r5.Bankpayment_patient,r5.Recevied_in_Bank_and_Cheque,r6.Subcenter_Received_as_cash,r7.total_voucher,r7.Credit_amount
 from
 
(SELECT  (CASE WHEN so.care_setting = 'opd' THEN 'OPD'
            WHEN so.care_setting = 'ipd' THEN 'IPD'
            ELSE 'Other'
       END) as care_type,count(distinct(so.partner_id))as no_of_patient,
count(so.name) As No_of_Bill ,sum (so.amount_untaxed)AS untaxed,sum(so.round_off)AS round_off ,sum((so.amount_untaxed) + (so.round_off))AS Billed_amount, sum(so.discount_amount) AS To_Discount,
sum(so.amount_total) AS Tobe_Paid_by_patient
FROM sale_order so
left join res_partner rp on rp.id = so.partner_id
WHERE cast(so.create_date as DATE) BETWEEN '#startDate#' and '#endDate#' 
and (so.state!='cancel' and so.state!='draft')
Group by so.care_setting) r1
left join
(SELECT  (CASE WHEN so.care_setting = 'opd' THEN 'OPD'
            WHEN so.care_setting = 'ipd' THEN 'IPD'
            ELSE 'Other'
       END) as care_type,count(distinct(ai.partner_id))as No_Of_discount_patient,
count(ai.id) As no_of_discount_Bill ,sum(ai.discount) AS To_Discount
from account_invoice ai
left join res_partner rp on rp.id = ai.partner_id
left join account_account aa On ai.discount_acc_id = aa.id
left join sale_order so on ai.reference = so.name
where cast(ai.create_date as DATE) BETWEEN '#startDate#' and '#endDate#'
and ai.discount_acc_id IS NOT NULL and ai.state  not in ('draft')
Group by so.care_setting)r2
On (r1.care_type = r2.care_type)
left join
 
(SELECT  (CASE WHEN so.care_setting = 'opd' THEN 'OPD'
            WHEN so.care_setting = 'ipd' THEN 'IPD'
            ELSE 'Other'
       END) as care_type, sum(ai.amount_total) As Insurance,count(distinct(ai.origin_name))as Insurance_patient
FROM account_invoice ai
left join res_partner rp on rp.id = ai.partner_id
left join sale_order so on ai.reference = so.name
WHERE cast(ai.date_invoice as DATE) BETWEEN '#startDate#' and '#endDate#'
and ai.number is  null
group by  so.care_setting) r3
On (r1.care_type = r3.care_type)
LEft Join
  
(SELECT (CASE WHEN so.care_setting = 'opd' THEN 'OPD'
            WHEN so.care_setting = 'ipd' THEN 'IPD'
            ELSE 'Other'
       END) as care_type ,count(distinct(ac.partner_id))as cash_total_patient,count(ac.number)as Count_Payment,
sum(ac.amount) As Received_as_cash_amount
FROM account_voucher ac
left join res_partner rp on rp.id = ac.partner_id
left join account_invoice ai on ac.invoice_id = ai.id
left join sale_order so on ai.reference = so.name
WHERE cast(ac.date as DATE) BETWEEN '#startDate#' and '#endDate#'

and ac.journal_id ='8'
Group BY so.care_setting) r4
On (r1.care_type = r4.care_type)
 left join

(SELECT (CASE WHEN so.care_setting = 'opd' THEN 'OPD'
            WHEN so.care_setting = 'ipd' THEN 'IPD'
            ELSE 'Other'
       END) As care_type,count(distinct(ac.partner_id))as Bankpayment_patient,
sum(ac.amount) As Recevied_in_bank_and_Cheque
FROM account_voucher ac
left join res_partner rp on rp.id = ac.partner_id
inner join account_invoice ai on ac.invoice_id = ai.id
inner join sale_order so on ai.reference = so.name
WHERE cast(ac.create_date as DATE) BETWEEN '#startDate#' and '#endDate#'
AND ac.journal_id in ('9', '12')
Group BY so.care_setting ) r5
ON (r1.care_type = r5.care_type)
left join

(SELECT (CASE WHEN so.care_setting = 'opd' THEN 'OPD'
            WHEN so.care_setting = 'ipd' THEN 'IPD'
            ELSE 'Other'
       END) as care_type ,count(ac.partner_id)as cash_total_patient,sum(ac.amount) As Subcenter_Received_as_cash
FROM account_voucher ac
left join res_partner rp on rp.id = ac.partner_id
left join account_invoice ai on ac.invoice_id = ai.id
left join sale_order so on ai.reference = so.name
WHERE cast(ac.date as DATE) BETWEEN '#startDate#' and '#endDate#'
and ac.journal_id in ('15','16','17')
group by  so.care_setting) r6
On (r1.care_type = r6.care_type)
LEft Join
(SELECT (CASE WHEN so.care_setting = 'opd' THEN 'OPD'
            WHEN so.care_setting = 'ipd' THEN 'IPD'
            ELSE 'Other'
       END) as care_type ,count(ac.id)as total_voucher,count(distinct(ac.partner_id))as total_patient,
 sum(ac.balance_amount)AS Credit_amount
FROM account_voucher ac
left join res_partner rp on rp.id = ac.partner_id
left join account_invoice ai on ac.invoice_id = ai.id
left join sale_order so on ai.reference = so.name
WHERE  ac.balance_amount <> '0' AND ac.is_insurance_journal is False
And cast(ac.create_date as DATE) BETWEEN '#startDate#' and '#endDate#'
Group BY so.care_setting) r7
On (r1.care_type = r7.care_type);
