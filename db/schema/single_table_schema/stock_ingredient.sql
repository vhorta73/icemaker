-- Table to record stock ingredient
CREATE TABLE `stock_ingredient` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ingredient_id` int(11) NOT NULL DEFAULT '0',
  `quantity` decimal(5,2) NOT NULL DEFAULT '0.00',
  `creation_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ingredient_id` (`ingredient_id`),
  KEY `quantity` (`quantity`),
  KEY `creation_date` (`creation_date`)
);
