CREATE TABLE `order_recipe_tub` (
  `order_recipe_id` int(11) NOT NULL,
  `package_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT '0',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_recipe_id`,`package_id`)
);
