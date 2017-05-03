CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_budget_view`
AS SELECT
   `budget_view`.`PERIOD` AS `PERIOD`,
   `budget_view`.`TRID` AS `TRID`,sum(`budget_view`.`CREDIT`) AS `CREDIT`
FROM `budget_view` group by `budget_view`.`PERIOD`,`budget_view`.`TRID`;