DELIMITER $$
CREATE FUNCTION GetFiscalYear(dateToCheck date) RETURNS varchar(4)
BEGIN
/*
Created: 27 February 2019
Author: Al Ortega
Description: Calculates the year and quarter based on a fiscal year of Oct - Sept calendar year.  If the month is Oct (10) or later we 
add 1 to the current year. 

Notes:
*/
    declare dtMonth varchar(2);
    declare dtYear varchar(4);
	set dtMonth = MONTH(dateToCheck);
	set dtYear = YEAR(dateToCheck);
	IF(dtMonth >= 10) THEN
		return dtYear + 1;
	ELSE
        return dtYear;
	END IF;   
END$$
DELIMITER ;
