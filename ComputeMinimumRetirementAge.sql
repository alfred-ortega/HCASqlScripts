DELIMITER //
CREATE FUNCTION ComputeMinimumRetirementAge(employeeid varchar(12)) returns date
BEGIN
/*
Created: 27 February 2019
Author: Al Ortega
Description: Determines Retirement Eligibility in accordance with OPM guidance for 
FERS (https://www.opm.gov/retirement-services/fers-information/eligibility/)

Notes:
If the person isn't identified as FERS (BENEFIT_PLAN in ('K','KF','KR','L','M','MF','N')
then a null is returned.
Due to the conversion from CHRIS to HRLinks (May 2018) there are multiple retirement records in HRLINKS.PS_RTRMNT_PLAN
so the subquery determines the latest entry (EFFDT) to use.
*/
    DECLARE retType varchar(6);
    DECLARE dob date;
	DECLARE dobYear int;
    DECLARE minRetDate date DEFAULT NULL;
    
	select R.BENEFIT_PLAN
          ,P.BIRTHDATE
          ,YEAR(P.BIRTHDATE)
    into retType, dob, dobYear      
	from HRLINKS.PS_PERSON P 
		join HRLINKS.PS_RTRMNT_PLAN R ON P.EMPLID = R.EMPLID
	WHERE P.EMPLID = employeeid
	  AND R.BENEFIT_PLAN IN ('K','KF','KR','L','M','MF','N')
	  AND R.EFFDT = (SELECT MAX(EFFDT)
		   FROM HRLINKS.PS_RTRMNT_PLAN
			WHERE EMPLID = '00020689' 
			AND BENEFIT_PLAN IN ('K','KF','KR','L','M','MF','N'));

		IF dobYear <= 1947 THEN
			SET minRetDate = DATE_ADD(dob, INTERVAL 55 YEAR);
        ELSEIF dobYear = 1948 THEN
			SET minRetDate = DATE_ADD(dob, INTERVAL '55.2' YEAR_MONTH);
        ELSEIF dobYear = 1949 THEN
			SET minRetDate = DATE_ADD(dob, INTERVAL '55.4' YEAR_MONTH);
        ELSEIF dobYear = 1950 THEN
			SET minRetDate = DATE_ADD(dob, INTERVAL '55.6' YEAR_MONTH);
        ELSEIF dobYear = 1951 THEN
			SET minRetDate = DATE_ADD(dob, INTERVAL '55.8' YEAR_MONTH);
        ELSEIF dobYear = 1952 THEN
			SET minRetDate = DATE_ADD(dob, INTERVAL '55.10' YEAR_MONTH);
        ELSEIF (dobYear >= 1953 AND dobYear <= 1964) THEN
			SET minRetDate = DATE_ADD(dob, INTERVAL '56' YEAR);
        ELSEIF dobYear = 1965 THEN
			SET minRetDate = DATE_ADD(dob, INTERVAL '56.2' YEAR_MONTH);        
        ELSEIF dobYear = 1966 THEN
			SET minRetDate = DATE_ADD(dob, INTERVAL '56.4' YEAR_MONTH);
        ELSEIF dobYear = 1967 THEN
			SET minRetDate = DATE_ADD(dob, INTERVAL '56.6' YEAR_MONTH);        
        ELSEIF dobYear = 1968 THEN
			SET minRetDate = DATE_ADD(dob, INTERVAL '56.8' YEAR_MONTH);
        ELSEIF dobYear = 1969 THEN
			SET minRetDate = DATE_ADD(dob, INTERVAL '56.10' YEAR_MONTH);        
        ELSE
			SET minRetDate = DATE_ADD(dob, INTERVAL '57' YEAR);  
		END IF;
    return minRetDate;
END//
DELIMITER ;