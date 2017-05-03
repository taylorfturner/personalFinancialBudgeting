CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_dy_hist`
AS SELECT
   year(`transaction`.`timestamp_key`) AS `year`,month(`transaction`.`timestamp_key`) AS `month`,dayofmonth(`transaction`.`timestamp_key`) AS `dynm`,
   `transaction`.`TRID` AS `TRID`,sum((`transaction`.`debit` * -(1))) AS `SUM`,avg(`transaction`.`debit`) AS `AVG`
FROM `transaction` where (`transaction`.`debit` < 0) group by `year`,`month`,`dynm`,`transaction`.`TRID`;