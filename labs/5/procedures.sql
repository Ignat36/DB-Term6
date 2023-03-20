create or replace procedure rollback_clients_by_date (date_time in timestamp)
as
begin
  delete from clients;

  for i in (select * from clients_history where CHANGE_DATE <= date_time ORDER BY CHANGE_DATE) LOOP
      if i.CHANGE_TYPE = 'INSERT' then
        insert into clients values (i.CLIENT_ID, i.FIRST_NAME, i.LAST_NAME, i.EMAIL, i.PHONE_NUMBER);
      elsif i.CHANGE_TYPE = 'DELETE' then
        delete from clients where CLIENT_ID = i.CLIENT_ID;
      end if;
  end loop;

  delete from clients_history
  where CHANGE_DATE > date_time;

end;

create or replace procedure rollback_products_by_date (date_time in timestamp)
as
begin
  delete from products;

  for i in (select * from products_history where CHANGE_DATE <= date_time ORDER BY CHANGE_DATE) LOOP
      if i.CHANGE_TYPE = 'INSERT' then
        insert into products values (i.PRODUCT_ID, i.PRODUCT_NAME, i.DESCRIPTION, i.PRICE);
      elsif i.CHANGE_TYPE = 'DELETE' then
        delete from products where PRODUCT_ID = i.PRODUCT_ID;
      end if;
  end loop;

  delete from products_history
  where CHANGE_DATE > date_time;
end;

create or replace procedure rollback_orders_by_date (date_time in timestamp)
as
begin
  delete from orders;

  for i in (select * from orders_history where CHANGE_DATE <= date_time ORDER BY CHANGE_DATE) LOOP
      if i.CHANGE_TYPE = 'INSERT' then
        insert into orders values (i.ORDER_ID, i.ORDER_DATE, i.CLIENT_ID, i.PRODUCT_ID, i.QUANTITY);
      elsif i.CHANGE_TYPE = 'DELETE' then
        delete from orders where ORDER_ID = i.ORDER_ID;
      end if;
  end loop;

  delete from orders_history
  where CHANGE_DATE > date_time;
end;

create or replace procedure rollback_by_date (date_time in timestamp)
as
begin
    rollback_orders_by_date(date_time);
    rollback_clients_by_date(date_time);
    rollback_products_by_date(date_time);
end;