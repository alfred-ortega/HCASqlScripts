DELIMITER $$
CREATE FUNCTION GetNOACAndFamily(noac varchar(3)) RETURNS varchar(90)
BEGIN
/*
Created: 27 February 2019
Author: Al Ortega
Description: Returns the NOAC as well as its description in accordance with OPM standards.

Notes: Descriptions from 
https://www.opm.gov/policy-data-oversight/data-analysis-documentation/personnel-documentation/processing-personnel-actions/gppa01.pdf

*/
    declare noacDescription varchar(90);
	set noacDescription = CONCAT('NOAC ', noac, ' FAMILY ', GetNOACFamily(noac));
    RETURN noacDescription;
END$$
DELIMITER ;