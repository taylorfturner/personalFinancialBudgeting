CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_cat_margin`
AS SELECT
   `func_inc_var_session`() AS `ROW_NUM`,
   `transaction_view`.`PERIOD` AS `PERIOD`,
   `transaction_view`.`TRID` AS `TRID`,sum((`transaction_view`.`DEBIT` * -(1))) AS `DEBIT`,sum(distinct `r_budget_view`.`CREDIT`) AS `CREDIT`,((sum((`transaction_view`.`DEBIT` * -(1))) - sum(distinct `r_budget_view`.`CREDIT`)) * -(1)) AS `MARGIN`
FROM (`transaction_view` left join `r_budget_view` on(((`transaction_view`.`PERIOD` = convert(`r_budget_view`.`PERIOD` using utf8)) and (`transaction_view`.`TRID` = `r_budget_view`.`TRID`)))) group by `transaction_view`.`PERIOD`,`transaction_view`.`TRID`;