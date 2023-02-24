delete from students;
delete from groups;
delete from students_log;

commit;
insert into groups (id, name, c_val) values (1, '053501', 0);
insert into groups (id, name, c_val) values (2, '053502', 0);
insert into groups (id, name, c_val) values (3, '053503', 0);
insert into groups (id, name, c_val) values (4, '053504', 0);
insert into groups (id, name, c_val) values (5, '053505', 0);
insert into groups (id, name, c_val) values (6, '053506', 0);
commit;

insert into students (id, name, group_id) values (1, 'Шаргородский Игнат Сергеевич', 2);
insert into students (id, name, group_id) values (2, 'Какой-то левый чел', 2);
insert into students (id, name, group_id) values (3, 'Леха', 2);
insert into students (id, name, group_id) values (4, 'Владик', 5);
insert into students (id, name, group_id) values (5, 'Спермач', 6);
commit;

select * from students;
select * from groups;
select * from students_log;

call restore_students_info_by_date(to_timestamp('2023-02-16 16:55:28', 'YYYY-MM-DD HH24:MI:SS'));

insert into groups  values (7, '053506', 0); /

delete from groups
    where id = 2;

commit;
insert into groups  values (8, '053502', 0);
insert into groups  values (9, '053502', 0);
insert into groups  values (10, '053502', 0);

insert into students (id, name, group_id) values (6, 'Шаргородский Игнат Сергеевич', 2);