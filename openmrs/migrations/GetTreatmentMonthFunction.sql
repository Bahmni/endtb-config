CREATE FUNCTION `getTreatmentMonth`(days int) RETURNS varchar(12) CHARSET utf8
BEGIN
	DECLARE month VARCHAR(12);
	DECLARE monthDiv int;
	DECLARE monthMod int;

	SET month = "NA";


	SET monthDiv = 0;
	SET monthMod = 0;

	set monthDiv =  days DIV 30;
	set monthMod =  MOD(days ,30);

	IF (monthMod > 14 ) then
		set monthDiv = monthDiv + 1;
	END IF;

	if (monthDiv < 0) then
		set month = "-M";
	else
		set month = "M";
	end if;
	set month = concat(month, cast(abs(monthDiv) as CHAR) );

RETURN month;
END;
