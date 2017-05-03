CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_margin_view`
AS SELECT
   `func_inc_var_session`() AS `ROW_NUM`,
   `expense_view`.`PERIOD` AS `PERIOD`,round(`budget_sum_view`.`INCOME`,1) AS `INCOME`,round((`expense_view`.`DEBIT` * -(1)),1) AS `EXPENSES`,round((`budget_sum_view`.`INCOME` + `expense_view`.`DEBIT`),1) AS `MARGIN`,((round((`budget_sum_view`.`INCOME` + `expense_view`.`DEBIT`),1) / round(`budget_sum_view`.`INCOME`,1)) * 100) AS `OP_MARGIN`,
   `htrid_count`.`HTRID_COUNT` AS `HTRID_COUNT`,
   `atrid_count`.`ATRID_COUNT` AS `ATRID_COUNT`,
   `digtrid_count`.`DIGTRID_COUNT` AS `DIGTRID_COUNT`,
   `ttrid_count`.`TTRID_COUNT` AS `TTRID_COUNT`,
   `prtrid_count`.`PRTRID_COUNT` AS `PRTRID_COUNT`,
   `phtrid_count`.`PHTRID_COUNT` AS `PHTRID_COUNT`,
   `svtrid_count`.`SVTRID_COUNT` AS `SVTRID_COUNT`,
   `ftrid_count`.`FTRID_COUNT` AS `FTRID_COUNT`
FROM (((((((((`expense_view` left join `budget_sum_view` on((`expense_view`.`PERIOD` = convert(`budget_sum_view`.`PERIOD` using utf8)))) left join `htrid_count` on((`expense_view`.`PERIOD` = convert(`htrid_count`.`PERIOD` using utf8)))) left join `atrid_count` on((`expense_view`.`PERIOD` = convert(`atrid_count`.`PERIOD` using utf8)))) left join `digtrid_count` on((`expense_view`.`PERIOD` = convert(`digtrid_count`.`PERIOD` using utf8)))) left join `prtrid_count` on((`expense_view`.`PERIOD` = convert(`prtrid_count`.`PERIOD` using utf8)))) left join `phtrid_count` on((`expense_view`.`PERIOD` = convert(`phtrid_count`.`PERIOD` using utf8)))) left join `ftrid_count` on((`expense_view`.`PERIOD` = convert(`ftrid_count`.`PERIOD` using utf8)))) left join `svtrid_count` on((`expense_view`.`PERIOD` = convert(`svtrid_count`.`PERIOD` using utf8)))) left join `ttrid_count` on((`expense_view`.`PERIOD` = convert(`ttrid_count`.`PERIOD` using utf8))));