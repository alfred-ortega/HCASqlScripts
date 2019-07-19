DELIMITER $$
CREATE FUNCTION CalculateRIF(employeeid varchar(12)) RETURNS int
BEGIN
/*
-- ============ Maintenance Log ================================================
-- Author:      James McConville
-- Date:        2017-05-15  
-- Description: Function to calculate the # of years to adjust an employees SCD.
--              The average of the last 3 performance ratings (or the average of 
--              the most recent ratings if less than 3) using the following 
--              formula for each performance rating:
--				* Performance Rating = 5 ==> 20 years
--				* Performance Rating = 4 ==> 16 years
--				* Performance Rating = 3 ==> 12 years
--				* Performance Rating = 2 ==> 0 years
--				* Performance Rating = 1 ==> 0 years
--              
--              If an employee has no Performance Rating, their SCD is adjusted
--              by 12 years.
-- =============================================================================
*/
	declare currentFY varchar(4) DEFAULT HCA.GetFiscalYear(now());
	declare currentCY varchar(4) DEFAULT YEAR(now());
    declare evalCount int default 0;
	declare startDate date default null;
	declare ratingStartDate date default null;
    declare avgRating int default 1;
    declare avgRatingTemp int default 0;

    DECLARE PERF_PLANS_CURSOR CURSOR FOR
			select EP_APPRAISAL_ID
			FROM HRLINKS.PS_EP_APPR
			WHERE EMPLID = employeeid
			  AND PERIOD_BEGIN_DT >= ratingStartDate
			ORDER BY PERIOD_BEGIN_DT DESC; 

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
 
	IF currentCY = currentFY THEN  -- FY Q2-Q4 Where the previous years ratings are completed
		SET startDate = STR_TO_DATE(CONTACT((currentCY -1),'-10-01'),'%Y-%m-%d');
	ELSE-- FY Q1 Where the previous years ratings are in progress
		SET startDate = STR_TO_DATE(CONTACT(currentCY,'-10-01'),'%Y-%m-%d');
	END IF;
    set ratingStartDate = DATE_ADD(startDate, INTERVAL '-3' YEAR);

	OPEN PERF_PLANS_CURSOR;
	
	read_loop: LOOP
    fetch PERF_PLANS_CURSOR INTO V_PERF_PLANS;
    
    IF done THEN
		LEAVE read_loop;
        END IF;
        

	END LOOP;
	CLOSE PERF_PLANS_CURSOR;    
    
	if avgRatingTemp > 1 then
		set avgRating = avgRatingTemp;
    end if;
    
    set startingSCD = HCA.CalculateOptionalRetirement(employeeid);
    
    

END$$
DELIMITER ;
-- mY emplid 00013663
    SELECT ROUND(AVG(EP_RATING)) AVG_RATING
    FROM HRLINKS.PS_Z_EP_APPR_C_ITM
    WHERE EP_APPRAISAL_ID IN (select EP_APPRAISAL_ID
							 FROM HRLINKS.PS_EP_APPR
							 WHERE EMPLID = '00013663'
							   AND PERIOD_BEGIN_DT >= '2016-10-01'
							 ORDER BY PERIOD_BEGIN_DT DESC
						 	 );
                            
select *
FROM HRLINKS.PS_EP_APPR
WHERE EMPLID = '00013663'
AND PERIOD_BEGIN_DT >= '2016-10-01'
ORDER BY PERIOD_BEGIN_DT DESC
