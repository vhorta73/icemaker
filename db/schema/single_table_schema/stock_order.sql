-- Table to record stock order
CREATE TABLE `stock_order` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(11) NOT NULL DEFAULT '0',
  `status` enum('Prepared', 'Open', 'Cancelled', 'Closed', 'Incomplete') NOT NULL DEFAULT 'Prepared',
  `user_id` int(11) NOT NULL DEFAULT '0',
  `creation_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `type_id` (`supplier_id`),
  KEY `status` (`status`),
  KEY `user_id` (`user_id`),
  KEY `creation_date` (`creation_date`)
);
