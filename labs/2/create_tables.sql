drop table students;
drop table groups;

create table groups (
  id number,
  name varchar2(50),
  c_val number,
  constraint pk_groups primary key (id)
);

create table students (
  id number,
  name varchar2(50),
  group_id number,
  constraint pk_students primary key (id),
  constraint fk_group_id foreign key (group_id) references groups (id)
);

