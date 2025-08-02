
---------------------------------------------------------
-- MARKING PROCEDURE 
---------------------------------------------------------
SET SERVEROUTPUT ON;
-- 1. RESET THE DATABASE
Clear Screen;
--EXECUTE tbaird.A1M_DATABASE_RESET;
EXECUTE rtipping.A1M_DATABASE_RESET;
---------------------------------------------------------
-- 2. RUN THE ASSIGNMENT SCRIPT
---------------------------------------------------------
@./ASS1_SQLCODE.sql;

-- 3. MARK THE ASSIGNMENT

--Execute tbaird.A1m_Premark_Check;
Execute rtipping.A1m_Premark_Check;
clear screen;
--Execute tbaird.A1m_Mark_Dbsys_Ass1;
Execute rtipping.A1m_Mark_Dbsys_Ass1;
show errors;