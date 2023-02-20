call compare_schemas('C##DEV_USER', 'C##PROD_USER');
call compare_procedures('C##DEV_USER', 'C##PROD_USER');
call compare_functions('C##DEV_USER', 'C##PROD_USER');
call compare_indexes('C##DEV_USER', 'C##PROD_USER');
call GET_ALL_TABLES_IN_SCHEMA('C##DEV_USER');
call DROP_ALL_TABLES_IN_SCHEMA('C##DEV_USER');
call DROP_ALL_TABLES_IN_SCHEMA('C##PROD_USER');
