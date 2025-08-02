-- NOTE:  THIS SCRIPT WILL ONLY WORK ON THE SWINBURNE DATABASE

CLEAR SCREEN;
SET SERVEROUTPUT ON;

exec A2M_CLEAN_UP;

@./Ass2_DW_Creation_Script.SQL;
 
CLEAR SCREEN;

-- changing the second parameter below from false to true 
-- will cause the marking script to give more verbose output.
exec A2M_Mark_Ds_Ass2( USER, FALSE );


