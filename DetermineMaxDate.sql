DELIMITER $$
CREATE FUNCTION DetermineMaxDate(firstDate date, secondDate date) RETURNS date
BEGIN
/*
Created: 27 February 2019
Author: Al Ortega
Description: Returns the greater of two dates. 

Notes:
*/
   
	IF(firstDate >= secondDate ) THEN
		return firstDate;
	ELSE
        return secondDate;
	END IF;   
END$$
DELIMITER ;
