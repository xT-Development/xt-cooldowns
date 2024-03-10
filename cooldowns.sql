CREATE TABLE `cooldowns` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
    `length` INT(11) NULL DEFAULT '10',
    `active` INT(11) NULL DEFAULT '0',
    PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=0
;