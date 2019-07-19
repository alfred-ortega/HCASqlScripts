DELIMITER $$
CREATE FUNCTION GetNOACFamily(noac varchar(3)) RETURNS varchar(70)
BEGIN
/*
Created: 27 February 2019
Author: Al Ortega
Description: Returns the description of each NOAC in accordance with OPM standards.

Notes: Descriptions from 
https://www.opm.gov/policy-data-oversight/data-analysis-documentation/personnel-documentation/processing-personnel-actions/gppa01.pdf

*/
    declare noacDescription varchar(70);
	IF ((noac >= '100') and (noac < '200')) THEN
		SET noacDescription = 'Appointments';
	ELSEIF ((noac >= '200') and (noac < '300')) THEN
		SET noacDescription = 'Returns to Duty from non-pay Status';
	ELSEIF ((noac >= '300') and (noac < '400')) THEN
		SET noacDescription = 'Separations';
	ELSEIF ((noac >= '400') and (noac < '500')) THEN
		SET noacDescription = 'Placements in non-pay and/or non-duty status';
	ELSEIF ((noac >= '500') and (noac < '600')) THEN
		SET noacDescription = 'Conversions to appointment';
	ELSEIF ((noac >= '600') and (noac < '700')) THEN
		SET noacDescription = 'Reserved for OPM Use';
	ELSEIF ((noac >= '700') and (noac < '800')) THEN
		SET noacDescription = 'Position Changes, Extensions, and Miscellaneous Changes';
	ELSEIF ((noac >= '800') and (noac < '900')) THEN
		SET noacDescription = 'Pay Changes and Miscellaneous Changes';
	ELSEIF (noac >= '900') THEN
		SET noacDescription = 'Reserved for use by agencies';
	ELSE
		SET noacDescription = 'Unknown NOA Code';
	END IF;
    RETURN noacDescription;
END$$
DELIMITER ;
