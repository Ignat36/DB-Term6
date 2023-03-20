select * from clients;
select * from CLIENTS_HISTORY;

select * from PRODUCTS;
select * from PRODUCTS_HISTORY;

select * from ORDERS;
select * from ORDERS_HISTORY;

call rollback_by_date(to_timestamp('2023-03-10 15:30:00', 'YYYY-MM-DD HH24:MI:SS'));