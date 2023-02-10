drop table MyTable;

CREATE TABLE MyTable (id NUMBER, val NUMBER);

DECLARE
  i INT := 1;
BEGIN
  FOR i IN 1..100 LOOP
    INSERT INTO MyTable (id, val) VALUES (i, trunc(DBMS_RANDOM.value(1, 1000000)));
  END LOOP;
END;

select * from MyTable;

create or replace function comp_odd_even return VARCHAR2 IS
    even INT;
    odd INT;
begin
      select count(*) into even
      from   MyTable
      where  MOD(val, 2) = 0;
      
      select count(*) into odd
      from   MyTable
      where  MOD(val, 2) != 0;
      
      if even > odd then
        return 'TRUE';
      elsif even < odd then
        return 'FALSE';
      else
        return 'EQUAL';
      end if;
end comp_odd_even;

select comp_odd_even() from dual;

create or replace function generate_insert_command (
  in_id in number,
  in_val in number
) return VARCHAR2 is
begin
  return 'INSERT INTO MyTable (id, val) VALUES (' || in_id || ', ' || in_val || ');';
end;

select generate_insert_command(10, 666) from dual;

create or replace procedure insert_into_mytable (
  p_id in number,
  p_val in number
) as
begin
  insert into MyTable (id, val) values (p_id, p_val);
end;

create or replace procedure update_mytable (
  p_id in number,
  p_val in number
) as
begin
  update MyTable
  set val = p_val
  where id = p_id;
end;

create or replace procedure delete_from_mytable (
  p_id in number
) as
begin
  delete from MyTable
  where id = p_id;
end;

create or replace function calculate_annual_compensation (monthly_salary number, annual_bonus_percentage number)
return number
is
begin
  if monthly_salary <= 0 then
    raise_application_error(-20000, 'Invalid monthly salary');
  end if;

  if annual_bonus_percentage <= 0 then
    raise_application_error(-20000, 'Invalid annual bonus percentage');
  end if;

  return (1 + annual_bonus_percentage / 100) * 12 * monthly_salary;
end;

select calculate_annual_compensation(1500, 50) from dual;

