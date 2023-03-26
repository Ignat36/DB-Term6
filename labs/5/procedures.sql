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

create or replace procedure create_report(t_begin in timestamp, t_end in timestamp)
as
    v_result varchar2(4000);
    i_count number;
    u_count number;
    d_count number;
begin

    v_result :=    '<table>
                      <tr>
                        <th>Table</th>
                        <th>INSERT</th>
                        <th>UPDATE</th>
                        <th>DELETE</th>
                      </tr>
                      ';

    select count(*) into u_count
    from CLIENTS_HISTORY
    where CHANGE_DATE between t_begin and t_end
    and CHANGE_TYPE = 'UPDATE';

    select count(*) into i_count
    from CLIENTS_HISTORY
    where CHANGE_DATE between t_begin and t_end
    and CHANGE_TYPE = 'INSERT';

    select count(*) into d_count
    from CLIENTS_HISTORY
    where CHANGE_DATE between t_begin and t_end
    and CHANGE_TYPE = 'DELETE';

    i_count := i_count - u_count;
    d_count := d_count - u_count;

    v_result := v_result || '<tr>
                               <td>Clients</td>
                               <td>' || i_count || '</td>
                               <td>' || u_count || '</td>
                               <td>' || d_count ||'</td>
                             </tr>
                              ';

    select count(*) into u_count
    from PRODUCTS_HISTORY
    where CHANGE_DATE between t_begin and t_end
    and CHANGE_TYPE = 'UPDATE';

    select count(*) into i_count
    from PRODUCTS_HISTORY
    where CHANGE_DATE between t_begin and t_end
    and CHANGE_TYPE = 'INSERT';

    select count(*) into d_count
    from PRODUCTS_HISTORY
    where CHANGE_DATE between t_begin and t_end
    and CHANGE_TYPE = 'DELETE';

    i_count := i_count - u_count;
    d_count := d_count - u_count;

    v_result := v_result || '<tr>
                               <td>Products</td>
                               <td>' || i_count || '</td>
                               <td>' || u_count || '</td>
                               <td>' || d_count ||'</td>
                             </tr>
                              ';

    select count(*) into u_count
    from ORDERS_HISTORY
    where CHANGE_DATE between t_begin and t_end
    and CHANGE_TYPE = 'UPDATE';

    select count(*) into i_count
    from ORDERS_HISTORY
    where CHANGE_DATE between t_begin and t_end
    and CHANGE_TYPE = 'INSERT';

    select count(*) into d_count
    from ORDERS_HISTORY
    where CHANGE_DATE between t_begin and t_end
    and CHANGE_TYPE = 'DELETE';

    i_count := i_count - u_count;
    d_count := d_count - u_count;

    v_result := v_result || '<tr>
                               <td>Orders</td>
                               <td>' || i_count || '</td>
                               <td>' || u_count || '</td>
                               <td>' || d_count ||'</td>
                             </tr>
                              ';

    v_result := v_result || '</table>';
    DBMS_OUTPUT.PUT_LINE(v_result);

end;