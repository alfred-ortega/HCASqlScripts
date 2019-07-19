DELIMITER $$
CREATE FUNCTION ComputeMinimumLEORetirementDate(employeeid varchar(12)) RETURNS date
BEGIN

    DECLARE minimumRetDate date DEFAULT NULL;
    DECLARE dob date DEFAULT NULL;
    DECLARE scdRetire date DEFAULT NULL;

	select P.BIRTHDATE
          ,HCA.DetermineMinDate(G.GVT_SCD_RETIRE,G.GVT_SCD_TSP) X
	into dob,scdRetire      
	from HRLINKS.PS_PERSON P 
        join HRLINKS.PS_GVT_JOB J ON  P.EMPLID = J.EMPLID
        join HRLINKS.PS_JOBCODE_TBL JC ON J.JOBCODE = JC.JOBCODE
        JOIN HRLINKS.PS_GVT_EMPLOYMENT G ON P.EMPLID = G.EMPLID
      AND JC.SETID = 'GSASH'
      AND JC.GVT_OCC_SERIES = '1811'
      AND P.EMPLID = employeeid;

		
	set minimumRetDate =  HCA.DetermineMaxDate(DATE_ADD(scdRetire, INTERVAL '25' YEAR) ,
									           HCA.DetermineMaxDate(DATE_ADD(scdRetire, INTERVAL '20' YEAR), 
												              	   DATE_ADD(dob, INTERVAL '50' YEAR)
													               ) 
											  );        
    return minimumRetDate;
END$$
DELIMITER ;



