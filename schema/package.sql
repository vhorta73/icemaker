CREATE TABLE `package` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(25) NOT NULL DEFAULT '',
  `size` decimal(5,2) NOT NULL DEFAULT '0.00',
  `units` enum('lt','ml') NOT NULL DEFAULT 'lt',
  `in_stock` int(11) NOT NULL DEFAULT '0',
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `creation_date` (`creation_date`),
  KEY `last_updated_date` (`last_updated_date`),
  KEY `status` (`status`)
);
