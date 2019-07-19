DELIMITER $$
CREATE FUNCTION DetermineRetirementType(employeeid varchar(12)) RETURNS varchar(4)
BEGIN
	declare retirementType varchar(4);
	declare retPlan varchar(4);
	declare jobSeries varchar(4);

 select R.BENEFIT_PLAN
       ,JC.GVT_OCC_SERIES
	into retPlan, jobSeries      
	from HRLINKS.PS_PERSON P 
		join HRLINKS.PS_RTRMNT_PLAN R ON P.EMPLID = R.EMPLID
        join HRLINKS.PS_GVT_JOB J ON  P.EMPLID = J.EMPLID
        join HRLINKS.PS_JOBCODE_TBL JC ON J.JOBCODE = JC.JOBCODE
        JOIN (SELECT MAX(EFFDT) EFFDT
						,BENEFIT_PLAN
 				     FROM HRLINKS.PS_RTRMNT_PLAN
					 WHERE EMPLID = employeeid
                       AND BENEFIT_PLAN NOT LIKE ('%TSP%')
					 GROUP BY BENEFIT_PLAN
              ) S on R.EFFDT = S.EFFDT AND R.BENEFIT_PLAN = S.BENEFIT_PLAN
	WHERE P.EMPLID = employeeid
      AND JC.SETID = 'GSASH'
      AND JC.GVT_OCC_SERIES > '0000';

	if jobSeries = '1811' then
		set retirementType = 'LEO';
    elseif retPlan in ('1', '6', 'C', 'E')  then  
		set retirementType = 'CSRS';
	elseif retPlan in ('K','KF','KR','L','M','MF','N') then
		set retirementType = 'FERS';
	else
		set retirementType = null;
	end if;

    return retirementType;
END$$
DELIMITER ;