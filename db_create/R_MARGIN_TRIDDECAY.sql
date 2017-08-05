CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_margin_triddecay`
AS SELECT
   left(`r_temp_daydecay`.`PERIOD`,4) AS `YEAR`,
   `r_temp_daydecay`.`PERIOD` AS `PERIOD`,
   `r_temp_daydecay`.`PERIODKEY` AS `PERIODKEY`,
   `r_temp_daydecay`.`DAY` AS `DAY`,
   `r_temp_daydecay`.`TRID` AS `TRID`,
   `r_temp_daydecay`.`DEBIT` AS `DEBIT`,
   `budget_sum_tridview`.`INCOME` AS `INCOME`
FROM (`r_temp_daydecay` left join `budget_sum_tridview` on(((`r_temp_daydecay`.`PERIOD` = convert(`budget_sum_tridview`.`PERIOD` using utf8)) and (`r_temp_daydecay`.`TRID` = `budget_sum_tridview`.`TRID`))));