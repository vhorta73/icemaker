-- Table to manage recipes and recipe attributes
CREATE TABLE `recipe` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `pasteurised` int(11) NOT NULL DEFAULT '0',
  `duration` time NOT NULL DEFAULT '00:00:00',
  `final_size` decimal(9,3) NOT NULL DEFAULT '0.000',
  `notes` longtext,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `creation_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `duration` (`duration`),
  KEY `name` (`name`),
  KEY `status` (`status`),
  KEY `creation_date` (`creation_date`)
);
