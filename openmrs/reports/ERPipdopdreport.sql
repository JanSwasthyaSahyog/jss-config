

 SELECT  av.create_date, so.care_setting,so.create_date Sale_Order_Date,
rp.ref,rp.name,so.amount_untaxed,so.round_off,

 so.amount_untaxed + so.round_off As total ,so.discount_amount,

 so.amount_total, av.amount paid_amount,av.balance_amount,av.balance_before_pay

FROM sale_order so

Left join account_voucher  av on  so.partner_id = av.partner_id

and av.date = so.date_order

left join res_partner rp on rp.id = so.partner_id

left join account_account aa On so.discount_acc_id = aa.id

WHERE   so.create_date < '#startDate#'::date

AND    so.create_date > '#endDate#'::date ;
