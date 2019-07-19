DELIMITER //
CREATE FUNCTION CalculateOptionalRetirement(employeeid varchar(12)) returns DATE
BEGIN

    DECLARE retType varchar(6);
    DECLARE dob date;
	DECLARE dobYear int;
    DECLARE jobSeries varchar(4);
    DECLARE minimumRetDate date DEFAULT NULL;
    DECLARE scdRetire date DEFAULT NULL;
    DECLARE scdCivilian date DEFAULT NULL;

    DECLARE retSCDTemp date DEFAULT NULL;
    
    select R.BENEFIT_PLAN
          ,P.BIRTHDATE
          ,YEAR(P.BIRTHDATE)
          ,JC.GVT_OCC_SERIES
          ,G.GVT_SCD_RETIRE
          ,G.GVT_SCD_TSP
	into retType, dob, dobYear, jobSeries, scdRetire, scdCivilian      
	from HRLINKS.PS_PERSON P 
		join HRLINKS.PS_RTRMNT_PLAN R ON P.EMPLID = R.EMPLID
        join HRLINKS.PS_GVT_JOB J ON  P.EMPLID = J.EMPLID
        join HRLINKS.PS_JOBCODE_TBL JC ON J.JOBCODE = JC.JOBCODE
        JOIN HRLINKS.PS_GVT_EMPLOYMENT G ON P.EMPLID = G.EMPLID
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

	IF (scdRetire is null and scdCivilian is null) THEN
		set retSCDTemp = null;
	ELSEIF ((scdRetire is not null) and (scdCivilian is null)) OR (scdRetire <= scdCivilian) then
		set retSCDTemp = scdRetire;
	ELSE
		set retSCDTemp = scdCivilian;
	END IF;	

IF jobSeries = '1811' THEN
		/*
		LEO/Criminal Investigation RETIREMENT Calculation
		*/
		set minimumRetDate =  HCA.DetermineMaxDate(DATE_ADD(retSCDTemp, INTERVAL '25' YEAR) ,
                                          HCA.DetermineMaxDate(DATE_ADD(retSCDTemp, INTERVAL '20' YEAR), 
                                                           DATE_ADD(dob, INTERVAL '50' YEAR)
										            	   ) 
										 ) ;

	ELSEIF retType in ('1', '6', 'C', 'E') THEN 
		/*
		CSRS RETIREMENT Calculation
		*/
		set minimumRetDate = (SELECT MIN(D) 
					FROM (
						select DetermineMaxDate(DATE_add(dob, INTERVAL '62' YEAR), DATE_add(retSCDTemp, INTERVAL '5' YEAR)) D
						union all
						select DetermineMaxDate(DATE_add(dob, INTERVAL '55' YEAR), DATE_add(retSCDTemp, INTERVAL '20' YEAR))
						union all
						SELECT DetermineMaxDate(DATE_add(dob, INTERVAL '55' YEAR), DATE_add(retSCDTemp, INTERVAL '30' YEAR))
					 ) csrs);

	ELSEIF (retType in ('K','KF','KR','L','M','MF','N')) THEN
		/*
		FERS RETIREMENT Calculation
       */
		set minimumRetDate = (SELECT MIN(D) 
					FROM (
						SELECT DetermineMaxDate(DATE_ADD(dob, INTERVAL '62' YEAR),DATE_ADD(retSCDTemp, INTERVAL '5' YEAR)) D -- FERSMaxOfAge62AndSCDplus5
						UNION ALL
						SELECT DetermineMaxDate(DATE_ADD(dob, INTERVAL '60' YEAR),DATE_ADD(retSCDTemp, INTERVAL '20' YEAR)) -- FERSAge60AndSCDplus20
						UNION ALL
						SELECT DetermineMaxDate(ComputeMinimumRetirementAge(employeeid), DATE_ADD(retSCDTemp, INTERVAL '10' YEAR)) -- FERSMaxOfMRAAndSCDplus10
						UNION ALL
						SELECT DetermineMaxDate(ComputeMinimumRetirementAge(employeeid), DATE_ADD(retSCDTemp, INTERVAL '30' YEAR))  -- FERSMaxOfMRAAndSCDplus30
					) fers);
    ELSE
		set minimumRetDate = null;
    END IF;
	return minimumRetDate;
END//
DELIMITER ;



