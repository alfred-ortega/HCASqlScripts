DELIMITER $$
CREATE FUNCTION GetFiscalYearAndQuarter(dateToCheck date) RETURNS varchar(7)
BEGIN
/*
Created: 27 February 2019
Author: Al Ortega
Description: Calculates the year and quarter based on a fiscal year of Oct - Sept.

Notes:

*/
    declare dtMonth varchar(2);
    declare dtYear varchar(4);
    declare dtQuarter varchar(7);
	set dtMonth = MONTH(dateToCheck);
	set dtYear = YEAR(dateToCheck);
	IF(dtMonth >= 10) THEN
		
		SET dtQuarter = concat(dtYear + 1, ".Q1");
	ELSE
        IF (dtMonth <= '3') THEN
			SET dtQuarter = concat(dtYear, ".Q2");
        ELSEIF (dtMonth <= '6') THEN
			SET dtQuarter = concat(dtYear, ".Q3");
        ELSE
			SET dtQuarter = concat(dtYear, ".Q4");
        END IF;
	END IF;   
    RETURN dtQuarter;
END$$
DELIMITER ;
