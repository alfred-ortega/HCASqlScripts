DELIMITER $$
CREATE FUNCTION ComputeMinimumFERSRetirementDate(employeeid varchar(12)) RETURNS date
BEGIN


    DECLARE dob date;
    DECLARE retSCDTemp DATE DEFAULT NULL;
    DECLARE minRetDate DATE DEFAULT NULL;
    
    DECLARE minimumRetDate date DEFAULT NULL;
    
    
	select P.BIRTHDATE
          ,HCA.DetermineMinDate(G.GVT_SCD_RETIRE,G.GVT_SCD_TSP) 
   into dob, retSCDTemp      
	from HRLINKS.PS_PERSON P 
		join HRLINKS.PS_RTRMNT_PLAN R ON P.EMPLID = R.EMPLID
        join HRLINKS.PS_GVT_EMPLOYMENT G ON P.EMPLID = G.EMPLID
	WHERE P.EMPLID = employeeid
	  AND R.BENEFIT_PLAN IN ('K','KF','KR','L','M','MF','N')
	  AND R.EFFDT = (SELECT MAX(EFFDT)
		   FROM HRLINKS.PS_RTRMNT_PLAN
			WHERE EMPLID = employeeid 
			AND BENEFIT_PLAN IN ('K','KF','KR','L','M','MF','N'));
		
        set minimumRetDate = (
							  select min(D)
							  from (
								SELECT DetermineMaxDate(DATE_ADD(dob, INTERVAL '62' YEAR),DATE_ADD(retSCDTemp, INTERVAL '5' YEAR)) D -- FERSMaxOfAge62AndSCDplus5
								UNION ALL
								SELECT DetermineMaxDate(DATE_ADD(dob, INTERVAL '60' YEAR),DATE_ADD(retSCDTemp, INTERVAL '20' YEAR)) -- FERSAge60AndSCDplus20
								UNION ALL
								SELECT DetermineMaxDate(ComputeFERSMRA(employeeid), DATE_ADD(retSCDTemp, INTERVAL '10' YEAR)) -- FERSMaxOfMRAAndSCDplus10
								UNION ALL
								SELECT DetermineMaxDate(ComputeFERSMRA(employeeid), DATE_ADD(retSCDTemp, INTERVAL '30' YEAR))  -- FERSMaxOfMRAAndSCDplus30
							) x
        );
    return minimumRetDate;
END$$
DELIMITER ;

