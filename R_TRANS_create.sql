CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `r_trans`
AS SELECT
   `func_inc_var_session`() AS `ROW_NUM`,if((length(month(`transaction`.`timestamp_key`)) = 1),convert(concat(year(`transaction`.`timestamp_key`),'0',month(`transaction`.`timestamp_key`)) using utf8),convert(concat(year(`transaction`.`timestamp_key`),month(`transaction`.`timestamp_key`)) using utf8)) AS `PERIOD`,sum(1) AS `COUNT`,sum(`transaction`.`debit`) AS `SUM`
FROM `transaction` group by `PERIOD`;