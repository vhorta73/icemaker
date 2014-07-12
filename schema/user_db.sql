CREATE TABLE `user_access` (
    `user_id` INT(11) NOT NULL DEFAULT 0,
    `label` VARCHAR(255) NOT NULL DEFAULT '',
    `authorized` CHAR(1) NOT NULL DEFAULT 'Y',
    `level` TINYINT NOT NULL DEFAULT 1,
    `creation_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_updated_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY (`user_id`,`label`)
);

CREATE TABLE `user` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL DEFAULT '',
    `username` VARCHAR(25) NOT NULL DEFAULT '',
    `password` VARCHAR(255) NOT NULL DEFAULT '',
    `status` CHAR(1) NOT NULL DEFAULT 'Y',
    `creation_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_updated_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY(`username`), 
    KEY(`name`), 
    KEY(`status`),
    KEY(`creation_date`), 
    KEY (`last_updated_date`)
);
