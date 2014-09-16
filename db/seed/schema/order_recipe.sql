-- Table to manage the main customer order per ordered recipe
CREATE TABLE `order_recipe` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `recipe_id` int(11) NOT NULL,
  `status` enum('saved','cancelled','ready','in progress','pending','completed','closed') NOT NULL DEFAULT 'saved',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);
