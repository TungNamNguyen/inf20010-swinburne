SET SERVEROUTPUT ON;
-- DDL Statement
DROP TABLE SALE CASCADE CONSTRAINTS;
DROP TABLE PRODUCT CASCADE CONSTRAINTS;
DROP TABLE CUSTOMER CASCADE CONSTRAINTS;
DROP TABLE LOCATION CASCADE CONSTRAINTS;
/
CREATE TABLE CUSTOMER (
CUSTID	NUMBER
, CUSTNAME	VARCHAR2(100)
, SALES_YTD	NUMBER
, STATUS	VARCHAR2(7)
, PRIMARY KEY	(CUSTID) 
);
/
CREATE TABLE PRODUCT (
PRODID	NUMBER
, PRODNAME	VARCHAR2(100)
, SELLING_PRICE	NUMBER
, SALES_YTD	NUMBER
, PRIMARY KEY	(PRODID)
);

/

CREATE TABLE SALE (
SALEID	NUMBER
, CUSTID	NUMBER
, PRODID	NUMBER
, QTY	NUMBER
, PRICE	NUMBER
, SALEDATE	DATE
, PRIMARY KEY 	(SALEID)
, FOREIGN KEY 	(CUSTID) REFERENCES CUSTOMER
, FOREIGN KEY 	(PRODID) REFERENCES PRODUCT
);

/

CREATE TABLE LOCATION (
  LOCID	VARCHAR2(5)
, MINQTY	NUMBER
, MAXQTY	NUMBER
, PRIMARY KEY 	(LOCID)
, CONSTRAINT CHECK_LOCID_LENGTH CHECK (LENGTH(LOCID) = 5)
, CONSTRAINT CHECK_MINQTY_RANGE CHECK (MINQTY BETWEEN 0 AND 999)
, CONSTRAINT CHECK_MAXQTY_RANGE CHECK (MAXQTY BETWEEN 0 AND 999)
, CONSTRAINT CHECK_MAXQTY_GREATER_MIXQTY CHECK (MAXQTY >= MINQTY)
);
/

DROP SEQUENCE SALE_SEQ;
CREATE SEQUENCE SALE_SEQ;

-- Task 1: Pass
-- Part 1
-- Part 1.1

CREATE OR REPLACE PROCEDURE ADD_CUST_TO_DB (pcustid NUMBER, pcustname  VARCHAR2) AS 
    err_custid_out_of_range EXCEPTION;
BEGIN
    IF pcustid < 1 OR pcustid > 499 THEN
        RAISE err_custid_out_of_range;
    END IF;
    INSERT INTO CUSTOMER (CUSTID, CUSTNAME, SALES_YTD, STATUS) VALUES (pcustid, pcustname, 0, 'OK');
    EXCEPTION
        WHEN err_custid_out_of_range THEN 
            RAISE_APPLICATION_ERROR(-20023, 'Customer ID out of range');
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20011, 'Duplicate customer ID');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END ADD_CUST_TO_DB;
/

CREATE OR REPLACE PROCEDURE ADD_CUSTOMER_VIASQLDEV(pcustid NUMBER, pcustname VARCHAR2) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Adding Customer. ID: ' || pcustid || ' Name: ' || pcustname);
    ADD_CUST_TO_DB(pcustid, pcustname);
    DBMS_OUTPUT.PUT_LINE('Customer Added OK');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END ADD_CUSTOMER_VIASQLDEV;
/

-- Part 1.2
CREATE OR REPLACE FUNCTION DELETE_ALL_CUSTOMERS_FROM_DB RETURN NUMBER AS
    v_rows_deleted_count NUMBER;
BEGIN
    DELETE FROM CUSTOMER;
    v_rows_deleted_count := SQL%ROWCOUNT;
    RETURN v_rows_deleted_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END DELETE_ALL_CUSTOMERS_FROM_DB;
/

CREATE OR REPLACE PROCEDURE DELETE_ALL_CUSTOMERS_VIASQLDEV AS
    v_rows_deleted_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Deleting all Customer rows');
    v_rows_deleted_count := DELETE_ALL_CUSTOMERS_FROM_DB;
    DBMS_OUTPUT.PUT_LINE(v_rows_deleted_count || ' rows deleted');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END DELETE_ALL_CUSTOMERS_VIASQLDEV;
/

-- Part 1.3
CREATE OR REPLACE PROCEDURE ADD_PRODUCT_TO_DB(pprodid NUMBER, pprodname VARCHAR2, pprice NUMBER) AS
    err_prodid_out_of_range EXCEPTION;
    err_price_out_of_range EXCEPTION;
BEGIN
    IF pprodid < 1000 OR pprodid > 2500 THEN
        RAISE err_prodid_out_of_range;
    END IF;
    IF pprice < 0 OR pprice > 999.99 THEN
        RAISE err_price_out_of_range;
    END IF;
    INSERT INTO PRODUCT (PRODID, PRODNAME, SELLING_PRICE, SALES_YTD) VALUES (pprodid, pprodname, pprice, 0);
    EXCEPTION
        WHEN err_prodid_out_of_range THEN
            RAISE_APPLICATION_ERROR(-20043, 'Product ID out of range');
        WHEN err_price_out_of_range THEN
            RAISE_APPLICATION_ERROR(-20055, 'Price out of range');
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20031, 'Duplicate product ID');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, SQLERRM);

END ADD_PRODUCT_TO_DB;
/

CREATE OR REPLACE PROCEDURE ADD_PRODUCT_VIASQLDEV(pprodid NUMBER, pprodname VARCHAR2, pprice NUMBER) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Adding Product. ID: ' || pprodid || ' Name: ' || pprodname || ' Price: ' || pprice);
    ADD_PRODUCT_TO_DB(pprodid, pprodname, pprice);
    DBMS_OUTPUT.PUT_LINE('Product Added OK');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END ADD_PRODUCT_VIASQLDEV;
/

CREATE OR REPLACE FUNCTION DELETE_ALL_PRODUCTS_FROM_DB RETURN NUMBER AS
    v_rows_deleted_count NUMBER;
BEGIN
    DELETE FROM PRODUCT;
    v_rows_deleted_count := SQL%ROWCOUNT;
    RETURN v_rows_deleted_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END DELETE_ALL_PRODUCTS_FROM_DB;
/

CREATE OR REPLACE PROCEDURE DELETE_ALL_PRODUCTS_VIASQLDEV AS
    v_rows_deleted_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Deleting all Product rows');
    v_rows_deleted_count := DELETE_ALL_PRODUCTS_FROM_DB;
    DBMS_OUTPUT.PUT_LINE(v_rows_deleted_count || ' rows deleted');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END DELETE_ALL_PRODUCTS_VIASQLDEV;
/

--Part 1.4
CREATE OR REPLACE FUNCTION GET_CUST_STRING_FROM_DB(pcustid NUMBER) RETURN VARCHAR2 AS
    v_custid CUSTOMER.CUSTID%TYPE;
    v_custname CUSTOMER.CUSTNAME%TYPE;
    v_status CUSTOMER.STATUS%TYPE;
    v_sales_ytd CUSTOMER.SALES_YTD%TYPE;
    v_cust_details VARCHAR2(500);
BEGIN
    SELECT CUSTID, CUSTNAME, STATUS, SALES_YTD INTO v_custid, v_custname, v_status, v_sales_ytd FROM CUSTOMER WHERE CUSTID = pcustid;
    v_cust_details := 'Custid: ' || v_custid || ' Name:' || v_custname || ' Status ' || v_status || ' SalesYTD:' || v_sales_ytd;
    RETURN v_cust_details;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20061, 'Customer ID not found');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END GET_CUST_STRING_FROM_DB;
/

CREATE OR REPLACE PROCEDURE GET_CUST_STRING_VIASQLDEV(pcustid NUMBER) AS
    v_cust_details VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Getting Details for Custid ' || pcustid);
    v_cust_details := GET_CUST_STRING_FROM_DB(pcustid);
    DBMS_OUTPUT.PUT_LINE(v_cust_details);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END GET_CUST_STRING_VIASQLDEV;
/

CREATE OR REPLACE PROCEDURE UPD_CUST_SALESYTD_IN_DB (pcustid NUMBER, pamt NUMBER) AS
    err_amt_out_of_range EXCEPTION;
    err_custid_not_found EXCEPTION;
BEGIN
    IF pamt < -999.99 OR pamt > 999.99 THEN
        RAISE err_amt_out_of_range;
    END IF;
    UPDATE CUSTOMER SET SALES_YTD = SALES_YTD + pamt WHERE CUSTID = pcustid;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE err_custid_not_found;
    END IF;
EXCEPTION
     WHEN err_amt_out_of_range THEN
         RAISE_APPLICATION_ERROR(-20083, 'Amount out of range');
     WHEN err_custid_not_found THEN
        RAISE_APPLICATION_ERROR(-20071, 'Customer ID not found');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END UPD_CUST_SALESYTD_IN_DB;
/

CREATE OR REPLACE PROCEDURE UPD_CUST_SALESYTD_VIASQLDEV (pcustid NUMBER, pamt NUMBER) AS 
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Updating SalesYTD. Customer Id: ' || pcustid || ' Amount: ' || pamt);
    UPD_CUST_SALESYTD_IN_DB(pcustid, pamt);
    DBMS_OUTPUT.PUT_LINE('Update OK');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END UPD_CUST_SALESYTD_VIASQLDEV;
/

-- Part 1.5
CREATE OR REPLACE FUNCTION GET_PROD_STRING_FROM_DB (pprodid NUMBER) RETURN VARCHAR2 AS
    v_prodid PRODUCT.PRODID%TYPE;
    v_prodname PRODUCT.PRODNAME%TYPE;
    v_prod_selling_price PRODUCT.SELLING_PRICE%TYPE;
    v_prod_sales_ytd PRODUCT.SALES_YTD%TYPE;
    v_prod_details VARCHAR2(500);
BEGIN
    SELECT PRODID, PRODNAME, SELLING_PRICE, SALES_YTD INTO v_prodid, v_prodname, v_prod_selling_price, v_prod_sales_ytd FROM PRODUCT WHERE PRODID = pprodid;
    v_prod_details := 'Prodid: ' || v_prodid || ' Name:' || v_prodname || ' Price ' || v_prod_selling_price || ' SalesYTD:' || v_prod_sales_ytd;
    RETURN v_prod_details;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20091, 'Product ID not found');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END GET_PROD_STRING_FROM_DB;
/

CREATE OR REPLACE PROCEDURE GET_PROD_STRING_VIASQLDEV (pprodid NUMBER) AS
    v_prod_details VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Getting Details for Prod Id ' || pprodid);
    v_prod_details := GET_PROD_STRING_FROM_DB(pprodid);
    DBMS_OUTPUT.PUT_LINE(v_prod_details);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END GET_PROD_STRING_VIASQLDEV;
/

CREATE OR REPLACE PROCEDURE UPD_PROD_SALESYTD_IN_DB (pprodid NUMBER, pamt NUMBER) AS
    err_amt_out_of_range EXCEPTION;
    err_prodid_not_found EXCEPTION;
BEGIN
    IF pamt < -999.99 OR pamt > 999.99 THEN
        RAISE err_amt_out_of_range;
    END IF;
    UPDATE PRODUCT SET SALES_YTD = SALES_YTD + pamt WHERE PRODID = pprodid;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE err_prodid_not_found;
    END IF;
EXCEPTION
    WHEN err_amt_out_of_range THEN
        RAISE_APPLICATION_ERROR(-20113, 'Amount out of range');
    WHEN err_prodid_not_found THEN
         RAISE_APPLICATION_ERROR(-20101, 'Product ID not found');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END UPD_PROD_SALESYTD_IN_DB;
/

CREATE OR REPLACE PROCEDURE UPD_PROD_SALESYTD_VIASQLDEV (pprodid NUMBER, pamt NUMBER) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Updating SalesYTD Product Id: ' || pprodid || ' Amount: ' || pamt);
    UPD_PROD_SALESYTD_IN_DB(pprodid, pamt);
    DBMS_OUTPUT.PUT_LINE('Update OK');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END UPD_PROD_SALESYTD_VIASQLDEV;
/

--Part 1.6
CREATE OR REPLACE PROCEDURE UPD_CUST_STATUS_IN_DB (pcustid NUMBER, pstatus VARCHAR2) AS
    err_invalid_status EXCEPTION;
    err_custid_not_found EXCEPTION;
BEGIN
    IF pstatus NOT IN ('OK', 'SUSPEND') THEN
        RAISE err_invalid_status;
    END IF;
    UPDATE CUSTOMER SET STATUS = pstatus WHERE CUSTID = pcustid;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE err_custid_not_found;
    END IF;

EXCEPTION
    WHEN err_invalid_status THEN
        RAISE_APPLICATION_ERROR(-20133, 'Invalid Status value');
    WHEN err_custid_not_found THEN
        RAISE_APPLICATION_ERROR(-20121, 'Customer ID not found');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END UPD_CUST_STATUS_IN_DB;
/

CREATE OR REPLACE PROCEDURE UPD_CUST_STATUS_VIASQLDEV (pcustid NUMBER, pstatus VARCHAR2) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('Updating Status. Id: ' || pcustid || ' New Status: ' || pstatus);
    UPD_CUST_STATUS_IN_DB(pcustid, pstatus);
    DBMS_OUTPUT.PUT_LINE('Update OK');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END UPD_CUST_STATUS_VIASQLDEV;
/

--Part 1.7
CREATE OR REPLACE PROCEDURE ADD_SIMPLE_SALE_TO_DB (pcustid NUMBER, pprodid NUMBER, pqty NUMBER) AS
    v_prod_price PRODUCT.SELLING_PRICE%TYPE;
    v_status CUSTOMER.STATUS%TYPE;
    v_cust_count NUMBER;
    v_prod_count NUMBER;
    v_total_sale NUMBER;
    err_sale_qty_out_of_range EXCEPTION;
    err_invalid_status EXCEPTION;
    err_custid_not_found EXCEPTION;
    err_prodid_not_found EXCEPTION;
BEGIN
    IF pqty < 1 OR pqty > 999 THEN
        RAISE err_sale_qty_out_of_range;
    END IF;
    
    SELECT COUNT(*) INTO v_cust_count FROM CUSTOMER WHERE CUSTID = pcustid;
    IF v_cust_count = 0 THEN
        RAISE err_custid_not_found;
    END IF;
    
    SELECT COUNT(*) INTO v_prod_count FROM PRODUCT WHERE PRODID = pprodid;
    IF v_prod_count = 0 THEN
        RAISE err_prodid_not_found;
    END IF; 
    
    SELECT STATUS INTO v_status FROM CUSTOMER WHERE CUSTID = pcustid;
    IF v_status != 'OK' THEN
        RAISE err_invalid_status;
    END IF;
    
    SELECT SELLING_PRICE INTO v_prod_price FROM PRODUCT WHERE PRODID = pprodid;
    v_total_sale := v_prod_price * pqty;
    UPD_CUST_SALESYTD_IN_DB(pcustid, v_total_sale);
    UPD_PROD_SALESYTD_IN_DB(pprodid, v_total_sale);
EXCEPTION
    WHEN err_sale_qty_out_of_range THEN
    RAISE_APPLICATION_ERROR(-20141, 'Sale Quantity outside valid range');
    WHEN err_invalid_status THEN
    RAISE_APPLICATION_ERROR(-20153, 'Customer status is not OK');
    WHEN  err_custid_not_found THEN
    RAISE_APPLICATION_ERROR(-20165, 'Customer ID not found');
    WHEN err_prodid_not_found THEN
    RAISE_APPLICATION_ERROR(-20177, 'Product ID not found');
    WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END ADD_SIMPLE_SALE_TO_DB;
/

CREATE OR REPLACE PROCEDURE ADD_SIMPLE_SALE_VIASQLDEV (pcustid NUMBER,pprodid NUMBER,pqty NUMBER) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Adding Simple Sale. Cust Id: ' || pcustid || ' Prod Id: ' || pprodid || ' Qty: ' || pqty);
    ADD_SIMPLE_SALE_TO_DB(pcustid, pprodid, pqty);
    DBMS_OUTPUT.PUT_LINE('Added Simple Sale OK');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        ROLLBACK;
END ADD_SIMPLE_SALE_VIASQLDEV;
/

-- Part 1.8
CREATE OR REPLACE FUNCTION SUM_CUST_SALESYTD RETURN NUMBER AS
    v_total_sales_ytd NUMBER;
BEGIN
    SELECT SUM(SALES_YTD) INTO v_total_sales_ytd FROM CUSTOMER;
    RETURN v_total_sales_ytd;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END SUM_CUST_SALESYTD;
/

CREATE OR REPLACE PROCEDURE SUM_CUST_SALES_VIASQLDEV AS
    v_total_sales_ytd NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Summing Customer SalesYTD');
    v_total_sales_ytd := SUM_CUST_SALESYTD;
    DBMS_OUTPUT.PUT_LINE('All Customer Total: ' || v_total_sales_ytd);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('All Customer Total: 0');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END SUM_CUST_SALES_VIASQLDEV;
/

CREATE OR REPLACE FUNCTION SUM_PROD_SALESYTD_FROM_DB RETURN NUMBER AS
    v_total_sales_ytd NUMBER;
BEGIN
    SELECT SUM(SALES_YTD) INTO v_total_sales_ytd FROM PRODUCT;
    RETURN v_total_sales_ytd;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END SUM_PROD_SALESYTD_FROM_DB;
/

CREATE OR REPLACE PROCEDURE SUM_PROD_SALES_VIASQLDEV AS
    v_total_sales_ytd NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE( '--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Summing Product SalesYTD');
    v_total_sales_ytd := SUM_PROD_SALESYTD_FROM_DB;
    DBMS_OUTPUT.PUT_LINE('All Product Total: ' || v_total_sales_ytd);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('All Product Total: 0');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END SUM_PROD_SALES_VIASQLDEV;
/

--Part 1.10
begin
    dbms_output.put_line('Student ID: 103181157');
    DELETE_ALL_CUSTOMERS_VIASQLDEV;
    DELETE_ALL_PRODUCTS_VIASQLDEV;
    dbms_output.put_line('==========TEST ADD CUSTOMERS ==========================');
    ADD_CUSTOMER_VIASQLDEV(1,'Colin Smith');
    ADD_CUSTOMER_VIASQLDEV(2,'Jill Davis');
    ADD_CUSTOMER_VIASQLDEV(3,'Dave Brown');
    ADD_CUSTOMER_VIASQLDEV(4,'Kirsty Glass');
    ADD_CUSTOMER_VIASQLDEV(1,'Jenny Nighy');
    ADD_CUSTOMER_VIASQLDEV(-3,'Emma Jones');
    ADD_CUSTOMER_VIASQLDEV(666,'Peter White');
    dbms_output.put_line('==========TEST ADD PRODUCTS==========================');
    ADD_PRODUCT_VIASQLDEV(1001,'ProdA', 10);
    ADD_PRODUCT_VIASQLDEV(1002,'ProdB', 20);
    ADD_PRODUCT_VIASQLDEV(1003,'ProdC', 35);
    ADD_PRODUCT_VIASQLDEV(1001,'ProdD', 10);
    ADD_PRODUCT_VIASQLDEV(3333,'ProdD', 100);
    ADD_PRODUCT_VIASQLDEV(1004,'ProdD', 1234);
    dbms_output.put_line('===========TEST STATUS UPDATES ==========================');
    UPD_CUST_STATUS_VIASQLDEV(3,'SUSPEND');
    UPD_CUST_STATUS_VIASQLDEV(4,'QWERTY');
    dbms_output.put_line('===========TEST CUSTOMER RETREIVAL ==========================');
    GET_CUST_STRING_VIASQLDEV(1);
    GET_CUST_STRING_VIASQLDEV(2);
    GET_CUST_STRING_VIASQLDEV(22);
    dbms_output.put_line('===========TEST CUSTOMER RETREIVAL ==========================');
    GET_PROD_STRING_VIASQLDEV(1001);
    GET_PROD_STRING_VIASQLDEV(1002);
    GET_PROD_STRING_VIASQLDEV(2222);
    dbms_output.put_line('===========TEST SIMPLE SALES ==========================');
    ADD_SIMPLE_SALE_VIASQLDEV(1,1001,15);
    ADD_SIMPLE_SALE_VIASQLDEV(2,1002,37);
    ADD_SIMPLE_SALE_VIASQLDEV(3,1002,15);
    ADD_SIMPLE_SALE_VIASQLDEV(4,1001,100);
    SUM_CUST_SALES_VIASQLDEV;
    SUM_PROD_SALES_VIASQLDEV;
    dbms_output.put_line('===========MORE TESTING OF SIMPLE SALES ==========================');
    ADD_SIMPLE_SALE_VIASQLDEV(99,1002,60);
    ADD_SIMPLE_SALE_VIASQLDEV(2,5555,60);
    ADD_SIMPLE_SALE_VIASQLDEV(1,1002,6666);
    SUM_CUST_SALES_VIASQLDEV;
    SUM_PROD_SALES_VIASQLDEV;
    dbms_output.put_line('==========LIST ALL CUSTOMERS AND PRODUCTS==========================');
    GET_CUST_STRING_VIASQLDEV(1);
    GET_CUST_STRING_VIASQLDEV(2);
    GET_CUST_STRING_VIASQLDEV(3);
    GET_CUST_STRING_VIASQLDEV(4);
    GET_PROD_STRING_VIASQLDEV(1001);
    GET_PROD_STRING_VIASQLDEV(1002);
    GET_PROD_STRING_VIASQLDEV(1003);
end;
/

--Part 2
--Part 2.1
CREATE OR REPLACE FUNCTION GET_ALLCUST RETURN SYS_REFCURSOR AS
    cust_cursor SYS_REFCURSOR;
BEGIN
    OPEN cust_cursor FOR SELECT * FROM CUSTOMER;
    RETURN cust_cursor;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END GET_ALLCUST;
/

CREATE OR REPLACE PROCEDURE GET_ALLCUST_VIASQLDEV AS
    cust_cursor SYS_REFCURSOR;
    v_custid CUSTOMER.CUSTID%TYPE;
    v_custname CUSTOMER.CUSTNAME%TYPE;
    v_sales_ytd CUSTOMER.SALES_YTD%TYPE;
    v_status CUSTOMER.STATUS%TYPE;
    v_rows_found BOOLEAN := FALSE;

BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Listing All Customer Details');
    cust_cursor := GET_ALLCUST;
    LOOP FETCH cust_cursor INTO v_custid, v_custname, v_sales_ytd, v_status;
        EXIT WHEN cust_cursor%NOTFOUND;
        v_rows_found := TRUE;
        DBMS_OUTPUT.PUT_LINE('Custid: ' || v_custid || ' Name:' || v_custname || ' Status ' || v_status || ' SalesYTD:' || v_sales_ytd);
    END LOOP;
    CLOSE cust_cursor;
    IF NOT v_rows_found THEN
        DBMS_OUTPUT.PUT_LINE('No rows found');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END GET_ALLCUST_VIASQLDEV;
/

CREATE OR REPLACE FUNCTION GET_ALLPROD_FROM_DB RETURN SYS_REFCURSOR AS
    prod_cursor SYS_REFCURSOR;
BEGIN
    OPEN prod_cursor FOR SELECT * FROM PRODUCT;
    RETURN prod_cursor;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END GET_ALLPROD_FROM_DB;
/

CREATE OR REPLACE PROCEDURE GET_ALLPROD_VIASQLDEV AS
    prod_cursor SYS_REFCURSOR;
    v_prodid PRODUCT.PRODID%TYPE;
    v_prodname PRODUCT.PRODNAME%TYPE;
    v_selling_price PRODUCT.SELLING_PRICE%TYPE;
    v_sales_ytd PRODUCT.SALES_YTD%TYPE;
    v_rows_found BOOLEAN := FALSE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Listing All Product Details');
    prod_cursor := GET_ALLPROD_FROM_DB;
    LOOP FETCH prod_cursor INTO v_prodid, v_prodname, v_selling_price, v_sales_ytd;
        EXIT WHEN prod_cursor%NOTFOUND;
        v_rows_found := TRUE;
        DBMS_OUTPUT.PUT_LINE('Prodid: ' || v_prodid || ' Name:' || v_prodname || ' Price ' || v_selling_price || ' SalesYTD:' || v_sales_ytd);
    END LOOP;
    CLOSE prod_cursor;
    IF NOT v_rows_found THEN
        DBMS_OUTPUT.PUT_LINE('No rows found');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END GET_ALLPROD_VIASQLDEV;
/

--Part 2.3
begin
dbms_output.put_line('Student ID: 103181157');
dbms_output.put_line('==========PART 2 TEST CURSOR==========================');
GET_ALLCUST_VIASQLDEV;
GET_ALLPROD_VIASQLDEV;
end;
/

-- Part 3
-- Part 3.1
-- Here is the function to check constraint
CREATE OR REPLACE FUNCTION strip_constraint(pErrmsg VARCHAR2) RETURN VARCHAR2 AS
    rp_loc NUMBER;
    dot_loc NUMBER;
BEGIN
    dot_loc := INSTR(pErrmsg, '.');
    rp_loc := INSTR(pErrmsg, ')');
    IF (dot_loc = 0 OR rp_loc = 0) THEN
        RETURN NULL;
    ELSE
        RETURN UPPER(SUBSTR(pErrmsg, dot_loc + 1, rp_loc - dot_loc - 1));
    END IF;
END strip_constraint;
/

CREATE OR REPLACE PROCEDURE ADD_LOCATION_TO_DB (ploccode VARCHAR2,pminqty NUMBER,pmaxqty NUMBER) AS
    dbms_constraint_name VARCHAR2(500);
    err_invalid_locid EXCEPTION;
BEGIN
    IF LENGTH(ploccode) != 5 THEN
        RAISE err_invalid_locid;
    END IF;
    INSERT INTO LOCATION (LOCID, MINQTY, MAXQTY) VALUES (ploccode, pminqty, pmaxqty);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20181, 'Duplicate location ID');
    WHEN err_invalid_locid THEN
        RAISE_APPLICATION_ERROR(-20193, 'Location Code length invalid');
    WHEN OTHERS THEN
        dbms_constraint_name := strip_constraint(SQLERRM);
        --IF dbms_constraint_name = 'CHECK_LOCID_LENGTH' THEN
            --RAISE_APPLICATION_ERROR(-20193, 'Location Code length invalid'); -- I can not get the constraint CHECK_LOCID_LENGTH
        IF dbms_constraint_name = 'CHECK_MINQTY_RANGE' THEN
            RAISE_APPLICATION_ERROR(-20205, 'Minimum Qty out of range');
        ELSIF dbms_constraint_name = 'CHECK_MAXQTY_RANGE' THEN
            RAISE_APPLICATION_ERROR(-20217, 'Maximum Qty out of range');
        ELSIF dbms_constraint_name = 'CHECK_MAXQTY_GREATER_MIXQTY' THEN
            RAISE_APPLICATION_ERROR(-20229, 'Minimum Qty larger than Maximum Qty');
        ELSE
            RAISE_APPLICATION_ERROR(-20000, SQLERRM);
        END IF;
END ADD_LOCATION_TO_DB;
/


CREATE OR REPLACE PROCEDURE ADD_LOCATION_VIASQLDEV (plocode VARCHAR2, pminqty NUMBER, pmaxqty NUMBER) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Adding Location LocCode: ' || plocode || ' MinQty: ' || pminqty || ' MaxQty: ' || pmaxqty);
    ADD_LOCATION_TO_DB(plocode, pminqty, pmaxqty);
    DBMS_OUTPUT.PUT_LINE('Location Added OK');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END ADD_LOCATION_VIASQLDEV;
/

--Part 3.3
begin
    dbms_output.put_line('Student ID: 103181157');
    dbms_output.put_line('==========PART 3 TEST LOCATIONS==========================');
    ADD_LOCATION_VIASQLDEV ('AF201',1,2);
    ADD_LOCATION_VIASQLDEV ('AF202',-3,4);
    ADD_LOCATION_VIASQLDEV ('AF203',5,1);
    ADD_LOCATION_VIASQLDEV ('AF204',6,7000);
    ADD_LOCATION_VIASQLDEV ('AF20111',8,9);
end;
/

--Task 2: Credit
--Part 4
--Part 4.1
CREATE OR REPLACE PROCEDURE ADD_COMPLEX_SALE_TO_DB (pcustid NUMBER, pprodid NUMBER, pqty NUMBER, pdate VARCHAR2) AS
    v_status CUSTOMER.STATUS%TYPE;
    v_prod_price PRODUCT.SELLING_PRICE%TYPE;
    v_saleid NUMBER;
    v_cust_count NUMBER;
    v_prod_count NUMBER;
    v_date DATE;
    v_total_sale NUMBER;
    err_sale_qty_out_of_range EXCEPTION;
    err_invalid_status EXCEPTION;
    err_custid_not_found EXCEPTION;
    err_prodid_not_found EXCEPTION;
    err_invalid_date EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_cust_count FROM CUSTOMER WHERE CUSTID = pcustid;
    IF v_cust_count = 0 THEN
        RAISE err_custid_not_found;
    END IF;
    SELECT STATUS INTO v_status FROM CUSTOMER WHERE CUSTID = pcustid;
    IF v_status != 'OK' THEN
        RAISE err_invalid_status;
    END IF;
    IF pqty < 1 OR pqty > 999 THEN
        RAISE err_sale_qty_out_of_range;
    END IF;
    BEGIN
        v_date := TO_DATE(pdate, 'YYYYMMDD');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE err_invalid_date;
    END;
    SELECT COUNT(*) INTO v_prod_count FROM PRODUCT WHERE PRODID = pprodid;
    IF v_prod_count = 0 THEN
        RAISE err_prodid_not_found;
    END IF;
    SELECT SELLING_PRICE INTO v_prod_price FROM PRODUCT WHERE PRODID = pprodid;
    v_total_sale := pqty * v_prod_price;
    SELECT SALE_SEQ.NEXTVAL INTO v_saleid FROM DUAL;
    INSERT INTO SALE (SALEID, CUSTID, PRODID, QTY, PRICE, SALEDATE) VALUES (v_saleid, pcustid, pprodid, pqty, v_prod_price, v_date);
    UPD_CUST_SALESYTD_IN_DB(pcustid, v_total_sale);
    UPD_PROD_SALESYTD_IN_DB(pprodid, v_total_sale);
EXCEPTION
    WHEN err_sale_qty_out_of_range THEN
        RAISE_APPLICATION_ERROR(-20231, 'Sale Quantity outside valid range');
    WHEN err_invalid_status THEN
        RAISE_APPLICATION_ERROR(-20243, 'Customer status is not OK');
    WHEN err_custid_not_found THEN
        RAISE_APPLICATION_ERROR(-20267, 'Customer ID not found');
    WHEN err_prodid_not_found THEN
        RAISE_APPLICATION_ERROR(-20279, 'Product ID not found');
    WHEN err_invalid_date THEN
        RAISE_APPLICATION_ERROR(-20255, 'Invalid sale date');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END ADD_COMPLEX_SALE_TO_DB;
/

CREATE OR REPLACE PROCEDURE ADD_COMPLEX_SALE_VIASQLDEV (pcustid NUMBER,pprodid NUMBER,pqty NUMBER,pdate VARCHAR2) AS
    v_prod_price PRODUCT.SELLING_PRICE%TYPE;
    v_total_sale NUMBER;
BEGIN
    SELECT SELLING_PRICE INTO v_prod_price FROM PRODUCT WHERE PRODID = pprodid;
    v_total_sale:= pqty * v_prod_price;
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Adding Complex Sale. Cust Id: ' || pcustid ||' Prod Id: ' || pprodid || ' Date: ' || pdate || ' Amt: ' || v_total_sale);
    ADD_COMPLEX_SALE_TO_DB(pcustid, pprodid, pqty, pdate);
    DBMS_OUTPUT.PUT_LINE('Added Complex Sale OK');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        ROLLBACK;
END ADD_COMPLEX_SALE_VIASQLDEV;
/

CREATE OR REPLACE FUNCTION GET_ALLSALES_FROM_DB RETURN SYS_REFCURSOR AS
    sales_cursor SYS_REFCURSOR;
BEGIN
    OPEN sales_cursor FOR SELECT * FROM SALE;
    RETURN sales_cursor;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END GET_ALLSALES_FROM_DB;
/

CREATE OR REPLACE PROCEDURE GET_ALLSALES_VIASQLDEV AS
    sales_cursor SYS_REFCURSOR;
    v_saleid SALE.SALEID%TYPE;
    v_custid SALE.CUSTID%TYPE;
    v_prodid SALE.PRODID%TYPE;
    v_qty SALE.QTY%TYPE;
    v_price SALE.PRICE%TYPE;
    v_saledate SALE.SALEDATE%TYPE;
    v_rows_found BOOLEAN := FALSE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('Listing All Complex Sales Details');
    sales_cursor := GET_ALLSALES_FROM_DB;
    LOOP
        FETCH sales_cursor INTO v_saleid, v_custid, v_prodid, v_qty, v_price, v_saledate;
        EXIT WHEN sales_cursor%NOTFOUND;
        v_rows_found := TRUE;
        DBMS_OUTPUT.PUT_LINE('Saleid: ' || v_saleid || ' Custid: ' || v_custid || ' Prodid: ' || v_prodid || ' Date ' || TO_CHAR(v_saledate, 'DD MON YYYY') || ' Amount: ' || v_price);
    END LOOP;
    CLOSE sales_cursor;
    IF NOT v_rows_found THEN
        DBMS_OUTPUT.PUT_LINE('No rows found');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END GET_ALLSALES_VIASQLDEV;
/

CREATE OR REPLACE FUNCTION COUNT_PRODUCT_SALES_FROM_DB (pdays NUMBER) RETURN NUMBER AS
    v_sale_count NUMBER;
BEGIN
    SELECT COUNT(*)INTO v_sale_count FROM SALE WHERE SALEDATE >= (SYSDATE - pdays);
    RETURN v_sale_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END COUNT_PRODUCT_SALES_FROM_DB;
/

CREATE OR REPLACE PROCEDURE COUNT_PRODUCT_SALES_VIASQLDEV (pdays NUMBER) AS
    v_sale_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Counting sales within ' || pdays || ' days');
    v_sale_count := COUNT_PRODUCT_SALES_FROM_DB(pdays);
    DBMS_OUTPUT.PUT_LINE('Total number of sales: ' || v_sale_count);
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END COUNT_PRODUCT_SALES_VIASQLDEV;
/

--Part 4.2
begin
    dbms_output.put_line('==========TEST DELETION OF EXISTING DATA==========================');
    DELETE FROM SALE;
    dbms_output.put_line('==========TEST PART 4==========================');
    ADD_CUSTOMER_VIASQLDEV(10,'Mieko Hayashi');
    ADD_CUSTOMER_VIASQLDEV(11,'John Kalia');
    ADD_CUSTOMER_VIASQLDEV(12,'Alex Kim');
    ADD_PRODUCT_VIASQLDEV(2001,'Chair', 10);
    ADD_PRODUCT_VIASQLDEV(2002,'Table', 45);
    ADD_PRODUCT_VIASQLDEV(2003,'Lamp', 22);
    ADD_COMPLEX_SALE_VIASQLDEV (10,2001,6,'20140301');
    ADD_COMPLEX_SALE_VIASQLDEV (10,2002,1,'20140320');
    ADD_COMPLEX_SALE_VIASQLDEV (11,2001,1,'20140301');
    ADD_COMPLEX_SALE_VIASQLDEV (11,2003,2,'20140215');
    ADD_COMPLEX_SALE_VIASQLDEV (12,2001,10,'20140131');
    COUNT_PRODUCT_SALES_VIASQLDEV( sysdate-to_date('01-Jan-2014'));
    COUNT_PRODUCT_SALES_VIASQLDEV( sysdate-to_date('01-Feb-2014'));
    GET_ALLSALES_VIASQLDEV;
    ADD_COMPLEX_SALE_VIASQLDEV (99,2001,10,'20140131');
    ADD_COMPLEX_SALE_VIASQLDEV (12,9999,10,'20140131');
    ADD_COMPLEX_SALE_VIASQLDEV (12,2001,9999,'20140131');
    ADD_COMPLEX_SALE_VIASQLDEV (12,2001,10,'99999999');
    ADD_COMPLEX_SALE_VIASQLDEV (12,2001,10, '20141331');
    ADD_COMPLEX_SALE_VIASQLDEV (12,2001,10,'20140132');
    ADD_COMPLEX_SALE_VIASQLDEV (12,2001,10, '20140');
    ADD_COMPLEX_SALE_VIASQLDEV (12,2001,10,'201401311');
    UPD_CUST_STATUS_VIASQLDEV(12,'SUSPEND');
    ADD_COMPLEX_SALE_VIASQLDEV (12,2002,10,'20140131');
end;
/


--Part 4.3
CREATE OR REPLACE FUNCTION DELETE_SALE_FROM_DB RETURN NUMBER AS
    v_saleid NUMBER;
    v_custid NUMBER;
    v_prodid NUMBER;
    v_qty NUMBER;
    v_price NUMBER;
    v_amount NUMBER;
    err_no_sale_row_found EXCEPTION;
BEGIN
    SELECT MIN(SALEID) INTO v_saleid FROM SALE;
    IF v_saleid IS NULL THEN
        RAISE err_no_sale_row_found;
    END IF;
    SELECT CUSTID, PRODID, QTY, PRICE INTO v_custid, v_prodid, v_qty, v_price FROM SALE WHERE SALEID = v_saleid;
    v_amount := v_price * v_qty;
    DELETE FROM SALE WHERE SALEID = v_saleid;
    UPD_CUST_SALESYTD_IN_DB(v_custid, -v_amount);
    UPD_PROD_SALESYTD_IN_DB(v_prodid, -v_amount);
    RETURN v_saleid;
EXCEPTION
    WHEN err_no_sale_row_found THEN
        RAISE_APPLICATION_ERROR(-20281, 'No Sale Rows Found');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END DELETE_SALE_FROM_DB;
/

CREATE OR REPLACE PROCEDURE DELETE_SALE_VIASQLDEV AS
    v_saleid NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Deleting Sale with smallest SaleId value');
    v_saleid := DELETE_SALE_FROM_DB;
    DBMS_OUTPUT.PUT_LINE('Deleted Sale OK. SaleID: ' || v_saleid);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END DELETE_SALE_VIASQLDEV;
/

CREATE OR REPLACE PROCEDURE DELETE_ALL_SALES_FROM_DB AS
BEGIN
    DELETE FROM SALE;
    UPDATE CUSTOMER SET SALES_YTD = 0;
    UPDATE PRODUCT SET SALES_YTD = 0;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END DELETE_ALL_SALES_FROM_DB;
/

CREATE OR REPLACE PROCEDURE DELETE_ALL_SALES_VIASQLDEV AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE('Deleting all Sales data in Sale, Customer, and Product tables');
    DELETE_ALL_SALES_FROM_DB;
    DBMS_OUTPUT.PUT_LINE('Deletion OK');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END DELETE_ALL_SALES_VIASQLDEV;
/

-- Part 4.4
begin
    dbms_output.put_line('==========TEST DELETION OF EXISTING DATA==========================');
    DELETE_ALL_SALES_VIASQLDEV;
    dbms_output.put_line('==========TEST PART 5==========================');
    ADD_CUSTOMER_VIASQLDEV(10,'Mieko Hayashi');
    ADD_CUSTOMER_VIASQLDEV(11,'John Kalia');
    ADD_CUSTOMER_VIASQLDEV(12,'Alex Kim');
    ADD_PRODUCT_VIASQLDEV(2001,'Chair', 10);
    ADD_PRODUCT_VIASQLDEV(2002,'Table', 45);
    ADD_PRODUCT_VIASQLDEV(2003,'Lamp', 22);
    ADD_COMPLEX_SALE_VIASQLDEV (10,2001,6,'20140301');
    ADD_COMPLEX_SALE_VIASQLDEV (10,2002,1,'20140320');
    ADD_COMPLEX_SALE_VIASQLDEV (11,2001,1,'20140301');
    ADD_COMPLEX_SALE_VIASQLDEV (11,2003,2,'20140215');
    ADD_COMPLEX_SALE_VIASQLDEV (12,2001,10,'20140131');
    COUNT_PRODUCT_SALES_VIASQLDEV(sysdate-to_date('01-Feb-2000') );
    GET_ALLSALES_VIASQLDEV;
    DELETE_SALE_VIASQLDEV;
    GET_ALLSALES_VIASQLDEV;
    DELETE_SALE_VIASQLDEV;
    GET_ALLSALES_VIASQLDEV;
    DELETE_ALL_SALES_VIASQLDEV;
    GET_ALLSALES_VIASQLDEV;
end;
/
--Part 5
-- Part 5.1
CREATE OR REPLACE PROCEDURE DELETE_CUSTOMER(pCustid NUMBER) AS
    v_sale_count NUMBER;
    v_cust_count NUMBER;
    err_customer_not_found EXCEPTION;
    err_customer_has_sales EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_cust_count FROM CUSTOMER WHERE CUSTID = pCustid;
    IF v_cust_count = 0 THEN
        RAISE err_customer_not_found;
    END IF;
    SELECT COUNT(*) INTO v_sale_count FROM SALE WHERE CUSTID = pCustid;
    IF v_sale_count > 0 THEN
        RAISE err_customer_has_sales;
    END IF;
    DELETE FROM CUSTOMER WHERE CUSTID = pCustid;
EXCEPTION
    WHEN err_customer_not_found THEN
        RAISE_APPLICATION_ERROR(-20291, 'Customer ID not found');
    WHEN err_customer_has_sales THEN
        RAISE_APPLICATION_ERROR(-20303, 'Customer cannot be deleted as sales exist');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END DELETE_CUSTOMER;
/

CREATE OR REPLACE PROCEDURE DELETE_CUSTOMER_VIASQLDEV (pCustid NUMBER) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Deleting Customer. Cust Id: ' || pCustid);
    DELETE_CUSTOMER(pCustid);
    DBMS_OUTPUT.PUT_LINE('Deleted Customer OK.');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END DELETE_CUSTOMER_VIASQLDEV;
/

CREATE OR REPLACE PROCEDURE DELETE_PROD_FROM_DB(pProdid NUMBER) AS
    v_sale_count NUMBER;
    v_prod_count NUMBER;
    err_product_not_found EXCEPTION;
    err_product_has_sales EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_prod_count FROM PRODUCT WHERE PRODID = pProdid;
    IF v_prod_count = 0 THEN
        RAISE err_product_not_found;
    END IF;
    SELECT COUNT(*) INTO v_sale_count FROM SALE WHERE PRODID = pProdid;
    IF v_sale_count > 0 THEN
        RAISE err_product_has_sales;
    END IF;
    DELETE FROM PRODUCT WHERE PRODID = pProdid;
EXCEPTION
    WHEN err_product_not_found THEN
        RAISE_APPLICATION_ERROR(-20311, 'Product ID not found');
    WHEN err_product_has_sales THEN
        RAISE_APPLICATION_ERROR(-20323, 'Product cannot be deleted as sales exist');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END DELETE_PROD_FROM_DB;
/

CREATE OR REPLACE PROCEDURE DELETE_PROD_VIASQLDEV (pProdid NUMBER) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Deleting Product. Product Id: ' || pProdid);
    DELETE_PROD_FROM_DB(pProdid);
    DBMS_OUTPUT.PUT_LINE('Deleted Product OK.');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END DELETE_PROD_VIASQLDEV;
/

--Part 5.2
begin
    dbms_output.put_line('==========TEST DELETION OF EXISTING DATA==========================');
    DELETE_ALL_SALES_VIASQLDEV;
    dbms_output.put_line('==========TEST PART 6==========================');
    ADD_CUSTOMER_VIASQLDEV(17,'Stephen Ward');
    ADD_CUSTOMER_VIASQLDEV(18,'Lisa Church');
    ADD_CUSTOMER_VIASQLDEV(19,'Joel Pairman');
    ADD_PRODUCT_VIASQLDEV(2005,'Desk', 195);
    ADD_PRODUCT_VIASQLDEV(2006,'Footrest', 20);
    ADD_PRODUCT_VIASQLDEV(2007,'Bookcase', 85);
    ADD_COMPLEX_SALE_VIASQLDEV (17,2005,1,'20140302');
    ADD_COMPLEX_SALE_VIASQLDEV (17,2006,1,'20140303');
    ADD_COMPLEX_SALE_VIASQLDEV (19,2005,1,'20140304');
    DELETE_CUSTOMER_VIASQLDEV (17);
    DELETE_CUSTOMER_VIASQLDEV(18);
    DELETE_CUSTOMER_VIASQLDEV(19);
    DELETE_PROD_VIASQLDEV (2005);
    DELETE_PROD_VIASQLDEV(2006);
    DELETE_PROD_VIASQLDEV(2007);
end;
/