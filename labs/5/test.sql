select * from clients;
select * from CLIENTS_HISTORY;

select * from PRODUCTS;
select * from PRODUCTS_HISTORY;

select * from ORDERS;
select * from ORDERS_HISTORY;

call rollback_by_date(to_timestamp('2022-04-23 18:25:00', 'YYYY-MM-DD HH24:MI:SS'));
call rollback_by_date(to_timestamp('2023-04-24 19:25:00', 'YYYY-MM-DD HH24:MI:SS'));
call FUNC_PACKAGE.ROLL_BACK(60000);
call FUNC_PACKAGE.ROLL_BACK(to_timestamp('2023-04-24 19:25:00', 'YYYY-MM-DD HH24:MI:SS'));
call FUNC_PACKAGE.REPORT();
call FUNC_PACKAGE.REPORT(to_timestamp('2022-03-10 15:30:00', 'YYYY-MM-DD HH24:MI:SS'), to_timestamp('2024-03-10 15:30:00', 'YYYY-MM-DD HH24:MI:SS'))
call CREATE_REPORT(to_timestamp('2022-03-10 15:30:00', 'YYYY-MM-DD HH24:MI:SS'), to_timestamp('2024-03-10 15:30:00', 'YYYY-MM-DD HH24:MI:SS'))
