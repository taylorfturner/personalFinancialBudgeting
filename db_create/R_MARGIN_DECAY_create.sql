CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_margin_decay`
AS SELECT
   left(`r_temp_decay`.`PERIOD`,4) AS `YEAR`,
   `r_temp_decay`.`PERIOD` AS `PERIOD`,
   `r_temp_decay`.`PERIODKEY` AS `PERIODKEY`,
   `r_temp_decay`.`DAY` AS `DAY`,
   `r_temp_decay`.`DEBIT` AS `DEBIT`,
   `budget_sum_view`.`INCOME` AS `INCOME`
FROM (`r_temp_decay` left join `budget_sum_view` on((`r_temp_decay`.`PERIOD` = convert(`budget_sum_view`.`PERIOD` using utf8))));