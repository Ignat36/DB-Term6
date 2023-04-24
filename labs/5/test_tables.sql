drop table orders;
drop table clients;
drop table products;


CREATE TABLE clients (
  client_id NUMBER(10) CONSTRAINT PK_clients PRIMARY KEY,
  first_name VARCHAR2(50),
  last_name VARCHAR2(50),
  email VARCHAR2(100) UNIQUE,
  phone_number VARCHAR2(20)
);

CREATE TABLE products (
  product_id NUMBER(10) CONSTRAINT PK_products PRIMARY KEY,
  product_name VARCHAR2(100),
  description VARCHAR2(500),
  price NUMBER
);

CREATE TABLE orders (
  order_id NUMBER(10) CONSTRAINT PK_orders PRIMARY KEY,
  order_date DATE,
  client_id NUMBER(10),
  product_id NUMBER(10),
  quantity NUMBER(10),
  CONSTRAINT fk_client FOREIGN KEY (client_id) REFERENCES clients(client_id),
  CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

delete from orders;
delete from clients;
delete from products;

INSERT INTO clients (client_id, first_name, last_name, email, phone_number)
VALUES (1, 'John', 'Doe', 'johndoe@example.com', '555-1234');

INSERT INTO clients (client_id, first_name, last_name, email, phone_number)
VALUES (2, 'Jane', 'Smith', 'janesmith@example.com', '555-5678');

UPDATE clients set phone_number = '123-1234' where client_id = 2;

INSERT INTO products (product_id, product_name, description, price)
VALUES (1, 'T-Shirt', 'A comfortable cotton t-shirt', 20.00);

INSERT INTO products (product_id, product_name, description, price)
VALUES (2, 'Hoodie', 'A warm and cozy hoodie', 40.00);

INSERT INTO orders (order_id, order_date, client_id, product_id, quantity)
VALUES (1, TO_DATE('2022-01-01', 'YYYY-MM-DD'), 1, 1, 3);

INSERT INTO orders (order_id, order_date, client_id, product_id, quantity)
VALUES (2, TO_DATE('2022-01-02', 'YYYY-MM-DD'), 2, 2, 1);

delete from orders where order_id = 2;

commit;