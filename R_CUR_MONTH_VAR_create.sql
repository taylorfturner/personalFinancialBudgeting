CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_cur_month_var`
AS SELECT
   `summary_view`.`TRID` AS `TRID`,sum(`summary_view`.`DEBIT`) AS `DEBIT`,sum(`summary_view`.`CREDIT`) AS `CREDIT`,sum(`summary_view`.`VAR`) AS `VAR`,(case when (sum(`summary_view`.`VAR`) <= 0) then 1 else 0 end) AS `FLAG`
FROM `summary_view` where (`summary_view`.`PERIOD` = date_format(now(),'%Y%m')) group by `summary_view`.`TRID`;