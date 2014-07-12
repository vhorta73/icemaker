-- Table to manage ingredient database
CREATE TABLE `ingredient` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `in_stock` int(11) NOT NULL DEFAULT '0',
  `creation_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `creation_date` (`creation_date`),
  KEY `last_updated_date` (`last_updated_date`),
  KEY `name` (`name`),
  KEY `in_stock` (`in_stock`)
);
