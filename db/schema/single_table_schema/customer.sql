-- Table to manage customer database
CREATE TABLE `customer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `name` varchar(255) NOT NULL DEFAULT '',
  `phone` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(255) NOT NULL DEFAULT '',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);
