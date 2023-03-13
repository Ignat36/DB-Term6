drop table table2;
drop table table1;

CREATE TABLE table1 (
  column1 NUMBER,
  column2 VARCHAR2(100),
  column3 NUMBER
);

CREATE TABLE table2 (
  column1 NUMBER,
  column2 VARCHAR2(100),
  column3 VARCHAR2(100)
);

INSERT INTO table1 VALUES (1, 'foo', 12);
INSERT INTO table1 VALUES (2, 'bar', 8);
INSERT INTO table1 VALUES (3, 'baz', 20);

INSERT INTO table2 VALUES (12, 'foo', 'abc');
INSERT INTO table2 VALUES (8, 'bar', 'def');
INSERT INTO table2 VALUES (20, 'baz', 'ghi');

INSERT INTO table1 VALUES (1, 'Row 1, Table 1', 5);
INSERT INTO table1 VALUES (2, 'Row 2, Table 1', 15);
INSERT INTO table1 VALUES (3, 'Row 3, Table 1', 25);

INSERT INTO table2  VALUES (1, 'Row 1, Table 2', 'Value A');
INSERT INTO table2 VALUES (2, 'Row 2, Table 2', 'Value B');
INSERT INTO table2 VALUES (3, 'Row 3, Table 2', 'Value C');