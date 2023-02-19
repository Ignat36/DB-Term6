-- Create the second schema
CREATE USER c##prod_user IDENTIFIED BY prod_password;
GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE PROCEDURE TO c##prod_user;

drop table C##PROD_USER.EMPLOYEE;

-- Create a table in the C##DEV_USER schema that does not exist in the C##PROD_USER schema
CREATE TABLE C##PROD_USER.departments (
  id NUMBER PRIMARY KEY
  -- name VARCHAR2(50)
);

-- Create a table in the C##PROD_USER schema
CREATE TABLE C##PROD_USER.employee (
  id NUMBER PRIMARY KEY,
  name VARCHAR2(50),
  department_id NUMBER(4),
  -- salary NUMBER,
  FOREIGN KEY (department_id) REFERENCES C##PROD_USER.departments(id)
);

-- In the C##PROD_USER schema:
CREATE TABLE C##PROD_USER.products (
  product_id   NUMBER PRIMARY KEY,
  product_name VARCHAR2(50) NOT NULL,
  price        NUMBER NOT NULL,
  quantity     NUMBER NOT NULL
);

CREATE TABLE C##PROD_USER.CUSTOMERS (
  CUSTOMER_ID NUMBER(10) PRIMARY KEY,
  CUSTOMER_NAME VARCHAR2(50) NOT NULL,
  CUSTOMER_ADDRESS VARCHAR2(100) NOT NULL,
  CUSTOMER_PHONE NUMBER(10) NOT NULL
);

CREATE TABLE C##PROD_USER.orders (
  order_id NUMBER PRIMARY KEY,
  customer_id NUMBER,
  order_date DATE,
  FOREIGN KEY (customer_id) REFERENCES C##PROD_USER.customers(customer_id)
);

CREATE TABLE C##PROD_USER.order_details (
  order_detail_id NUMBER PRIMARY KEY,
  order_id NUMBER,
  product_id NUMBER,
  quantity NUMBER,
  FOREIGN KEY (order_id) REFERENCES C##PROD_USER.orders(order_id),
  FOREIGN KEY (product_id) REFERENCES C##PROD_USER.products(product_id)
);




