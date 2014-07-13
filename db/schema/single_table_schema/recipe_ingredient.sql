-- Table to manage which ingredients compose a recipe
CREATE TABLE `recipe_ingredient` (
  `recipe_id` int(11) NOT NULL DEFAULT '0',
  `ingredient_id` int(11) NOT NULL DEFAULT '0',
  `quantity` decimal(11,3) NOT NULL DEFAULT '0.000',
  `units` enum('kg','lt','box','g') NOT NULL DEFAULT 'kg',
  PRIMARY KEY (`ingredient_id`,`recipe_id`)
);
