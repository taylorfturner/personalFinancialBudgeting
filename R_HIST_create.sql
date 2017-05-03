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