create or replace trigger tr_students_unique_id
    before insert or update on students
    for each row
declare
    v_count int;
begin
    select count(*) into v_count
    from students
    where id = :new.id;

    if v_count > 0 then
        raise_application_error(-20001, 'ID должен быть уникальным');
    end if;
end;

create sequence students_seq start with 1;

create or replace trigger tr_students_auto_increment_id
    before insert on students
    for each row
begin
    select students_seq.nextval into :new.id
    from dual;
end;

create or replace trigger tr_groups_unique_name
    before insert or update on groups
    for each row
declare
    v_count int;
begin
    select count(*) into v_count
    from groups
    where name = :new.name;

    if v_count > 0 then
        raise_application_error(-20001, 'NAME должен быть уникальным');
    end if;
end;

create or replace trigger tr_delete_group_fk
    before delete on groups
    for each row
begin
    delete from students where group_id = :old.id;
end;

create or replace trigger tr_insert_student_fk
    before insert on students
    for each row
declare
    v_count int;
begin
    select count(*) into v_count
    from groups
    where groups.id = :new.group_id;

    if v_count = 0 then
        raise_application_error(-20000, 'Group ID does not exist');
    end if;
end;

create or replace trigger students_log
    after insert or update or delete on students
    for each row
declare
    v_username varchar2(30) := USER;
    v_date date := SYSDATE;
    v_operation varchar2(20);
begin
    if inserting then
        v_operation := 'INSERT';
        insert into students_log (username, date_of_action, operation, stud_id, stud_name, stud_group_id)
        values (v_username, v_date, v_operation, :new.id, :new.name, :new.group_id);
    elsif updating then
        v_operation := 'UPDATE';
        insert into students_log (username, date_of_action, operation, stud_id, stud_name, stud_group_id)
        values (v_username, v_date, v_operation, :new.id, :new.name, :new.group_id);
    elsif deleting then
        v_operation := 'DELETE';
        insert into students_log (username, date_of_action, operation, stud_id, stud_name, stud_group_id)
        values (v_username, v_date, v_operation, :old.id, :old.name, :old.group_id);
    end if;
end;

