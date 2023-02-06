drop table MyTable;

CREATE TABLE MyTable (id NUMBER, val NUMBER);

DECLARE
  i INT := 1;
BEGIN
  FOR i IN 1..10000 LOOP
    INSERT INTO MyTable (id, val) VALUES (i, TRUNC(DBMS_RANDOM.value(1, 1000000)));
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
      
      IF even > odd THEN
        return 'TRUE';
      ELSIF even < odd THEN
        return 'FALSE';
      ELSE
        RETURN 'EQUAL';
      END IF;
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
