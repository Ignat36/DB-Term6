drop table clients_history;
drop table products_history;
drop table orders_history;

CREATE TABLE clients_history (
  action_id number primary key,
  client_id NUMBER(10),
  first_name VARCHAR2(50),
  last_name VARCHAR2(50),
  email VARCHAR2(100),
  phone_number VARCHAR2(20),
  change_date DATE,
  change_type VARCHAR2(10)
);

CREATE TABLE products_history (
  action_id number primary key,
  product_id NUMBER(10),
  product_name VARCHAR2(100),
  description VARCHAR2(500),
  price NUMBER,
  change_date DATE,
  change_type VARCHAR2(10)
);

CREATE TABLE orders_history (
  action_id number primary key,
  order_id NUMBER(10),
  order_date DATE,
  client_id NUMBER(10),
  product_id NUMBER(10),
  quantity NUMBER(10),
  change_date DATE,
  change_type VARCHAR2(10)
);

create sequence history_seq start with 1;
