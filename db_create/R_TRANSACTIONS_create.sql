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