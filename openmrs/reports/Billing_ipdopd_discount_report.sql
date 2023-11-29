SELECT date(so.date_confirm) ,rp.ref As Registration_Number,rp.name AS Patient_Name, so.care_setting As Care_visit,
 (so.amount_untaxed) + (so.round_off) As Total_Amount ,so.discount_amount As Discount, 
 so.amount_total As Amount_For_Payment, aa.name AS Discount_Head
FROM sale_order so
left join res_partner rp on rp.id = so.partner_id
left join account_account aa On so.discount_acc_id = aa.id
WHERE  Cast(so.date_confirm as DATE) BETWEEN '#startDate#' and '#endDate#' 
And (so.discount_amount <> 0.00) ORDER BY Patient_Name;