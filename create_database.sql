CREATE TABLE `TRANSACTION` (
  `transaction_number` int(11) DEFAULT NULL,
  `timestamp_key` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `TRID` varchar(255) DEFAULT NULL,
  `memo` varchar(255) DEFAULT NULL,
  `debit` varchar(255) DEFAULT NULL,
  `credit` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `budget_view`
AS SELECT
   if((length(month(`budget`.`DATE_TIME`)) = 1),convert(concat(year(`budget`.`DATE_TIME`),'0',month(`budget`.`DATE_TIME`)) using utf8),concat(year(`budget`.`DATE_TIME`),month(`budget`.`DATE_TIME`))) AS `PERIOD`,
   `gacc`.`TRID` AS `TRID`,
   `budget`.`TRID_CODE` AS `TRID_CODE`,sum(`budget`.`CREDIT`) AS `CREDIT`
FROM (`budget` left join `gacc` on((left(`budget`.`TRID_CODE`,1) = `gacc`.`TRID_CODE`))) where (length(`budget`.`TRID_CODE`) > 1) group by if((length(month(`budget`.`DATE_TIME`)) = 1),convert(concat(year(`budget`.`DATE_TIME`),'0',month(`budget`.`DATE_TIME`)) using utf8),concat(year(`budget`.`DATE_TIME`),month(`budget`.`DATE_TIME`))),`gacc`.`TRID`,`budget`.`TRID_CODE`;


delimiter // 
CREATE FUNCTION `func_inc_var_session`() RETURNS int
    NO SQL
    NOT DETERMINISTIC
     begin
      SET @var := @var + 1;
      return @var;
     end
     // 
delimiter ;


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_trans`
AS SELECT
   `func_inc_var_session`() AS `ROW_NUM`,if((length(month(`transaction`.`timestamp_key`)) = 1),convert(concat(year(`transaction`.`timestamp_key`),'0',month(`transaction`.`timestamp_key`)) using utf8),convert(concat(year(`transaction`.`timestamp_key`),month(`transaction`.`timestamp_key`)) using utf8)) AS `PERIOD`,sum(1) AS `COUNT`,sum(`transaction`.`debit`) AS `SUM`
FROM `transaction` group by `PERIOD`;


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_budget_view`
AS SELECT
   `budget_view`.`PERIOD` AS `PERIOD`,
   `budget_view`.`TRID` AS `TRID`,sum(`budget_view`.`CREDIT`) AS `CREDIT`
FROM `budget_view` group by `budget_view`.`PERIOD`,`budget_view`.`TRID`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `transaction_view`
AS SELECT
   if((length(month(`transaction`.`timestamp_key`)) = 1),convert(concat(year(`transaction`.`timestamp_key`),'0',month(`transaction`.`timestamp_key`)) using utf8),convert(concat(year(`transaction`.`timestamp_key`),month(`transaction`.`timestamp_key`)) using utf8)) AS `PERIOD`,
   `transaction`.`TRID` AS `TRID`,
   `transaction`.`transaction_number` AS `TRID_CODE`,round(sum(`transaction`.`debit`),2) AS `DEBIT`
FROM `transaction` where (length(`transaction`.`TRID`) > 1) group by if((length(month(`transaction`.`timestamp_key`)) = 1),convert(concat(year(`transaction`.`timestamp_key`),'0',month(`transaction`.`timestamp_key`)) using utf8),convert(concat(year(`transaction`.`timestamp_key`),month(`transaction`.`timestamp_key`)) using utf8)),`transaction`.`TRID`,`transaction`.`transaction_number` order by if((length(month(`transaction`.`timestamp_key`)) = 1),convert(concat(year(`transaction`.`timestamp_key`),'0',month(`transaction`.`timestamp_key`)) using utf8),convert(concat(year(`transaction`.`timestamp_key`),month(`transaction`.`timestamp_key`)) using utf8)),`transaction`.`transaction_number`;


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_cat_margin`
AS SELECT
   `func_inc_var_session`() AS `ROW_NUM`,
   `transaction_view`.`PERIOD` AS `PERIOD`,
   `transaction_view`.`TRID` AS `TRID`,sum((`transaction_view`.`DEBIT` * -(1))) AS `DEBIT`,sum(distinct `r_budget_view`.`CREDIT`) AS `CREDIT`,((sum((`transaction_view`.`DEBIT` * -(1))) - sum(distinct `r_budget_view`.`CREDIT`)) * -(1)) AS `MARGIN`
FROM (`transaction_view` left join `r_budget_view` on(((`transaction_view`.`PERIOD` = convert(`r_budget_view`.`PERIOD` using utf8)) and (`transaction_view`.`TRID` = `r_budget_view`.`TRID`)))) group by `transaction_view`.`PERIOD`,`transaction_view`.`TRID`;


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `summary_view` AS (select `budget_view`.`PERIOD` AS `PERIOD`,`budget_view`.`TRID` AS `TRID`,`budget_view`.`TRID_CODE` AS `TRID_CODE`,(case when isnull(`transaction_view`.`DEBIT`) then 0.000 else `transaction_view`.`DEBIT` end) AS `DEBIT`,`budget_view`.`CREDIT` AS `CREDIT`,round(((((case when isnull(`transaction_view`.`DEBIT`) then 0.0000 else `transaction_view`.`DEBIT` end) * -(1)) - `budget_view`.`CREDIT`) * -(1)),2) AS `VAR`,if((((((case when isnull(`transaction_view`.`DEBIT`) then 0.000 else `transaction_view`.`DEBIT` end) * -(1)) - `budget_view`.`CREDIT`) * -(1)) < -(0)),1,0) AS `VAR_FLG` from (`budget_view` left join `transaction_view` on(((convert(`budget_view`.`PERIOD` using utf8) = `transaction_view`.`PERIOD`) and (`budget_view`.`TRID` = `transaction_view`.`TRID`) and (`budget_view`.`TRID_CODE` = `transaction_view`.`TRID_CODE`)))) order by `transaction_view`.`PERIOD` desc);


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


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_temp_decay`
AS SELECT
   if((length(month(`transaction`.`timestamp_key`)) = 1),convert(concat(year(`transaction`.`timestamp_key`),'0',month(`transaction`.`timestamp_key`)) using utf8),convert(concat(year(`transaction`.`timestamp_key`),month(`transaction`.`timestamp_key`)) using utf8)) AS `PERIOD`,concat(if((length(month(`transaction`.`timestamp_key`)) = 1),convert(concat(year(`transaction`.`timestamp_key`),'0',month(`transaction`.`timestamp_key`)) using utf8),convert(concat(year(`transaction`.`timestamp_key`),month(`transaction`.`timestamp_key`)) using utf8)),dayofmonth(`transaction`.`timestamp_key`)) AS `PERIODKEY`,dayofmonth(`transaction`.`timestamp_key`) AS `DAY`,(sum(`transaction`.`debit`) * -(1)) AS `DEBIT`
FROM `transaction` where ((`transaction`.`debit` * -(1)) > 0) group by `PERIOD`,`PERIODKEY`,`DAY`;


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `budget_sum_view`
AS SELECT
   `budget_view`.`PERIOD` AS `PERIOD`,sum(`budget_view`.`CREDIT`) AS `INCOME`
FROM `budget_view` group by `budget_view`.`PERIOD`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_margin_decay`
AS SELECT
   left(`r_temp_decay`.`PERIOD`,4) AS `YEAR`,
   `r_temp_decay`.`PERIOD` AS `PERIOD`,
   `r_temp_decay`.`PERIODKEY` AS `PERIODKEY`,
   `r_temp_decay`.`DAY` AS `DAY`,
   `r_temp_decay`.`DEBIT` AS `DEBIT`,
   `budget_sum_view`.`INCOME` AS `INCOME`
FROM (`r_temp_decay` left join `budget_sum_view` on((`r_temp_decay`.`PERIOD` = convert(`budget_sum_view`.`PERIOD` using utf8))));


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_temp_daydecay`
AS SELECT
   if((length(month(`transaction`.`timestamp_key`)) = 1),convert(concat(year(`transaction`.`timestamp_key`),'0',month(`transaction`.`timestamp_key`)) using utf8),convert(concat(year(`transaction`.`timestamp_key`),month(`transaction`.`timestamp_key`)) using utf8)) AS `PERIOD`,concat(if((length(month(`transaction`.`timestamp_key`)) = 1),convert(concat(year(`transaction`.`timestamp_key`),'0',month(`transaction`.`timestamp_key`)) using utf8),convert(concat(year(`transaction`.`timestamp_key`),month(`transaction`.`timestamp_key`)) using utf8)),dayofmonth(`transaction`.`timestamp_key`)) AS `PERIODKEY`,dayofmonth(`transaction`.`timestamp_key`) AS `DAY`,
   `transaction`.`TRID` AS `TRID`,(sum(`transaction`.`debit`) * -(1)) AS `DEBIT`
FROM `transaction` where ((`transaction`.`debit` * -(1)) > 0) group by `PERIOD`,`PERIODKEY`,`DAY`,`transaction`.`TRID`

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

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `expense_view`
AS SELECT
   `transaction_view`.`PERIOD` AS `PERIOD`,sum(`transaction_view`.`DEBIT`) AS `DEBIT`
FROM `transaction_view` group by `transaction_view`.`PERIOD`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `htrid_count`
AS SELECT
   `summary_view`.`PERIOD` AS `PERIOD`,
   `summary_view`.`TRID` AS `TRID`,sum(`summary_view`.`VAR_FLG`) AS `HTRID_COUNT`
FROM `summary_view` where ((`summary_view`.`VAR_FLG` = 1) and (`summary_view`.`TRID` = 'HTRID')) group by `summary_view`.`PERIOD`,`summary_view`.`TRID`;



CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `atrid_count`
AS SELECT
   `summary_view`.`PERIOD` AS `PERIOD`,
   `summary_view`.`TRID` AS `TRID`,sum(`summary_view`.`VAR_FLG`) AS `ATRID_COUNT`
FROM `summary_view` where ((`summary_view`.`VAR_FLG` = 1) and (`summary_view`.`TRID` = 'ATRID')) group by `summary_view`.`PERIOD`,`summary_view`.`TRID`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `digtrid_count`
AS SELECT
   `summary_view`.`PERIOD` AS `PERIOD`,
   `summary_view`.`TRID` AS `TRID`,sum(`summary_view`.`VAR_FLG`) AS `DIGTRID_COUNT`
FROM `summary_view` where ((`summary_view`.`VAR_FLG` = 1) and (`summary_view`.`TRID` = 'DIGTRID')) group by `summary_view`.`PERIOD`,`summary_view`.`TRID`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ttrid_count`
AS SELECT
   `summary_view`.`PERIOD` AS `PERIOD`,
   `summary_view`.`TRID` AS `TRID`,sum(`summary_view`.`VAR_FLG`) AS `TTRID_COUNT`
FROM `summary_view` where ((`summary_view`.`VAR_FLG` = 1) and (`summary_view`.`TRID` = 'TTRID')) group by `summary_view`.`PERIOD`,`summary_view`.`TRID`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `prtrid_count`
AS SELECT
   `summary_view`.`PERIOD` AS `PERIOD`,
   `summary_view`.`TRID` AS `TRID`,sum(`summary_view`.`VAR_FLG`) AS `PRTRID_COUNT`
FROM `summary_view` where ((`summary_view`.`VAR_FLG` = 1) and (`summary_view`.`TRID` = 'PRTRID')) group by `summary_view`.`PERIOD`,`summary_view`.`TRID`;


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `phtrid_count`
AS SELECT
   `summary_view`.`PERIOD` AS `PERIOD`,
   `summary_view`.`TRID` AS `TRID`,sum(`summary_view`.`VAR_FLG`) AS `PHTRID_COUNT`
FROM `summary_view` where ((`summary_view`.`VAR_FLG` = 1) and (`summary_view`.`TRID` = 'PHTRID')) group by `summary_view`.`PERIOD`,`summary_view`.`TRID`;


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `svtrid_count`
AS SELECT
   `summary_view`.`PERIOD` AS `PERIOD`,
   `summary_view`.`TRID` AS `TRID`,sum(`summary_view`.`VAR_FLG`) AS `SVTRID_COUNT`
FROM `summary_view` where ((`summary_view`.`VAR_FLG` = 1) and (`summary_view`.`TRID` = 'SVTRID')) group by `summary_view`.`PERIOD`,`summary_view`.`TRID`;


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ftrid_count`
AS SELECT
   `summary_view`.`PERIOD` AS `PERIOD`,
   `summary_view`.`TRID` AS `TRID`,sum(`summary_view`.`VAR_FLG`) AS `FTRID_COUNT`
FROM `summary_view` where ((`summary_view`.`VAR_FLG` = 1) and (`summary_view`.`TRID` = 'FTRID')) group by `summary_view`.`PERIOD`,`summary_view`.`TRID`;

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



CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_savings`
AS SELECT
   if((length(month(`budget`.`DATE_TIME`)) = 1),convert(concat(year(`budget`.`DATE_TIME`),'0',month(`budget`.`DATE_TIME`)) using utf8),convert(concat(year(`budget`.`DATE_TIME`),month(`budget`.`DATE_TIME`)) using utf8)) AS `PERIOD`,
   `budget`.`TRID_CODE` AS `TRID_CODE`,
   `budget`.`CREDIT` AS `CREDIT`
FROM (`budget` left join `transaction` on(((if((length(month(`budget`.`DATE_TIME`)) = 1),convert(concat(year(`budget`.`DATE_TIME`),'0',month(`budget`.`DATE_TIME`)) using utf8),convert(concat(year(`budget`.`DATE_TIME`),month(`budget`.`DATE_TIME`)) using utf8)) = if((length(month(`transaction`.`timestamp_key`)) = 1),convert(concat(year(`transaction`.`timestamp_key`),'0',month(`transaction`.`timestamp_key`)) using utf8),convert(concat(year(`transaction`.`timestamp_key`),month(`transaction`.`timestamp_key`)) using utf8))) and (`budget`.`TRID_CODE` = `transaction`.`transaction_number`)))) where (`budget`.`TRID_CODE` = '801');


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_summary_view` AS (select `budget_view`.`PERIOD` AS `PERIOD`,`budget_view`.`TRID` AS `TRID`,`budget_view`.`TRID_CODE` AS `TRID_CODE`,(case when isnull(`transaction_view`.`DEBIT`) then 0.000 else `transaction_view`.`DEBIT` end) AS `DEBIT`,`budget_view`.`CREDIT` AS `CREDIT`,round(((((case when isnull(`transaction_view`.`DEBIT`) then 0.0000 else `transaction_view`.`DEBIT` end) * -(1)) - `budget_view`.`CREDIT`) * -(1)),2) AS `VAR`,if((((((case when isnull(`transaction_view`.`DEBIT`) then 0.000 else `transaction_view`.`DEBIT` end) * -(1)) - `budget_view`.`CREDIT`) * -(1)) < -(0)),1,0) AS `VAR_FLG` from (`budget_view` left join `transaction_view` on(((convert(`budget_view`.`PERIOD` using utf8) = `transaction_view`.`PERIOD`) and (`budget_view`.`TRID` = `transaction_view`.`TRID`) and (`budget_view`.`TRID_CODE` = `transaction_view`.`TRID_CODE`)))) order by `transaction_view`.`PERIOD` desc);


CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_transactions`
AS SELECT
   `transaction`.`transaction_number` AS `transaction_number`,
   `transaction`.`timestamp_key` AS `timestamp_key`,
   `transaction`.`description` AS `description`,
   `transaction`.`TRID` AS `TRID`,
   `transaction`.`memo` AS `memo`,
   `transaction`.`debit` AS `debit`,
   `transaction`.`credit` AS `credit`
FROM `transaction`;
