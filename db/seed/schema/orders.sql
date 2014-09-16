-- Main orders table, linked to the customer ordering.
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL DEFAULT '0',
  `status` enum('saved','cancelled','queued','in progress','pending','completed','closed') NOT NULL DEFAULT 'saved',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY(`customer_id`),
  KEY(`status`),
  KEY(`creation_date`)
);
