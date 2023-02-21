call compare_schemas('C##DEV_USER', 'C##PROD_USER');

call compare_procedures('C##DEV_USER', 'C##PROD_USER');
call compare_functions('C##DEV_USER', 'C##PROD_USER');
call compare_indexes('C##DEV_USER', 'C##PROD_USER');

call GET_ALL_TABLES_IN_SCHEMA('C##DEV_USER');
call DROP_ALL_TABLES_IN_SCHEMA('C##DEV_USER');
call DROP_ALL_TABLES_IN_SCHEMA('C##PROD_USER');

CREATE OR REPLACE EDITIONABLE PROCEDURE "C##PROD_USER"."WRITE_EMPLOYEES" (
employee_name_a in varchar2,
employee_name_b in varchar2
)
as
begin
dbms_output.put_line(employee_name_a || ' and ' || employee_name_b);
end;