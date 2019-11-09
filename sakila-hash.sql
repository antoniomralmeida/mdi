USE `sakila`;
DROP function IF EXISTS `rental_hash`;

DELIMITER $$
USE `sakila`$$
CREATE FUNCTION `rental_hash` (k1 int, k2 int, k3 int, k4 int, k5 int, k6 int)
RETURNS INTEGER
BEGIN
RETURN k1+k2+k3+k4+k5+k6;
END$$

DELIMITER ;