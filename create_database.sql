CREATE TABLE `CCNM` (
  `CODE` int(11) DEFAULT NULL,
  `CODEDSCRP` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `GACC` (
  `TRID` varchar(255) DEFAULT NULL,
  `TRID_CODE` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `BUDGET` (
  `DATE_TIME` varchar(255) DEFAULT NULL,
  `TRID_CODE` int(11) DEFAULT NULL,
  `CREDIT` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_budget_view`
AS SELECT
   `budget_view`.`PERIOD` AS `PERIOD`,
   `budget_view`.`TRID` AS `TRID`,sum(`budget_view`.`CREDIT`) AS `CREDIT`
FROM `budget_view` group by `budget_view`.`PERIOD`,`budget_view`.`TRID`;


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_cat_margin`
AS SELECT
   `func_inc_var_session`() AS `ROW_NUM`,
   `transaction_view`.`PERIOD` AS `PERIOD`,
   `transaction_view`.`TRID` AS `TRID`,sum((`transaction_view`.`DEBIT` * -(1))) AS `DEBIT`,sum(distinct `r_budget_view`.`CREDIT`) AS `CREDIT`,((sum((`transaction_view`.`DEBIT` * -(1))) - sum(distinct `r_budget_view`.`CREDIT`)) * -(1)) AS `MARGIN`
FROM (`transaction_view` left join `r_budget_view` on(((`transaction_view`.`PERIOD` = convert(`r_budget_view`.`PERIOD` using utf8)) and (`transaction_view`.`TRID` = `r_budget_view`.`TRID`)))) group by `transaction_view`.`PERIOD`,`transaction_view`.`TRID`;



CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_cur_month_var`
AS SELECT
   `summary_view`.`TRID` AS `TRID`,sum(`summary_view`.`DEBIT`) AS `DEBIT`,sum(`summary_view`.`CREDIT`) AS `CREDIT`,sum(`summary_view`.`VAR`) AS `VAR`,(case when (sum(`summary_view`.`VAR`) <= 0) then 1 else 0 end) AS `FLAG`
FROM `summary_view` where (`summary_view`.`PERIOD` = date_format(now(),'%Y%m')) group by `summary_view`.`TRID`;



CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_dy_hist`
AS SELECT
   year(`transaction`.`timestamp_key`) AS `year`,month(`transaction`.`timestamp_key`) AS `month`,dayofmonth(`transaction`.`timestamp_key`) AS `dynm`,
   `transaction`.`TRID` AS `TRID`,sum((`transaction`.`debit` * -(1))) AS `SUM`,avg(`transaction`.`debit`) AS `AVG`
FROM `transaction` where (`transaction`.`debit` < 0) group by `year`,`month`,`dynm`,`transaction`.`TRID`;


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_hist`
AS SELECT
   `func_inc_var_session`() AS `ROW_NUM`,month(`transaction`.`timestamp_key`) AS `MONTH`,if((length(month(`transaction`.`timestamp_key`)) = 1),convert(concat(year(`transaction`.`timestamp_key`),'0',month(`transaction`.`timestamp_key`)) using utf8),convert(concat(year(`transaction`.`timestamp_key`),month(`transaction`.`timestamp_key`)) using utf8)) AS `PERIOD`,dayofmonth(`transaction`.`timestamp_key`) AS `dynm`,
   `transaction`.`description` AS `description`,
   `transaction`.`TRID` AS `TRID`,
   `transaction`.`memo` AS `memo`,
   `transaction`.`debit` AS `debit`,
   `transaction`.`credit` AS `credit`,
   `transaction`.`transaction_number` AS `transaction_number`
FROM `transaction`;


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_margin_decay`
AS SELECT
   left(`r_temp_decay`.`PERIOD`,4) AS `YEAR`,
   `r_temp_decay`.`PERIOD` AS `PERIOD`,
   `r_temp_decay`.`PERIODKEY` AS `PERIODKEY`,
   `r_temp_decay`.`DAY` AS `DAY`,
   `r_temp_decay`.`DEBIT` AS `DEBIT`,
   `budget_sum_view`.`INCOME` AS `INCOME`
FROM (`r_temp_decay` left join `budget_sum_view` on((`r_temp_decay`.`PERIOD` = convert(`budget_sum_view`.`PERIOD` using utf8))));