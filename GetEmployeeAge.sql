drop function GetEmployeeAge;
DELIMITER $$
CREATE FUNCTION GetEmployeeAge(dateOfBirth date) RETURNS int(11)
BEGIN
/*
Created: 27 February 2019
Author: Al Ortega
Description: Determines the age of an individual
Notes:

*/
	RETURN DATE_FORMAT(NOW(), '%Y') - DATE_FORMAT(dateOfBirth, '%Y') - (DATE_FORMAT(NOW(), '00-%m-%d') < DATE_FORMAT(dateOfBirth, '00-%m-%d')); 
END$$
DELIMITER ;
