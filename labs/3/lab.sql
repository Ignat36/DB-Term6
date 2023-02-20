CREATE OR REPLACE PROCEDURE compare_procedures (
    dev_schema IN VARCHAR2,
    prod_schema IN VARCHAR2
)
AUTHID CURRENT_USER
AS
BEGIN
  FOR proc IN (SELECT object_name
               FROM all_procedures
               WHERE owner = dev_schema
               MINUS
               SELECT object_name
               FROM all_procedures
               WHERE owner = prod_schema)
  LOOP
    dbms_output.put_line('Procedure ' || proc.object_name || ' is in ' || dev_schema || ' but not in ' || prod_schema);
  END LOOP;
END;

CREATE OR REPLACE PROCEDURE compare_functions (
    dev_schema IN VARCHAR2,
    prod_schema IN VARCHAR2
)
AUTHID CURRENT_USER
AS
BEGIN
  FOR func IN (SELECT distinct name
               FROM all_source
               WHERE all_source.type = 'FUNCTION'
               AND owner = dev_schema
               MINUS
               SELECT distinct name
               FROM all_source
               WHERE all_source.type = 'FUNCTION'
               AND owner = prod_schema)
  LOOP
    dbms_output.put_line('Function ' || func.name || ' is in ' || dev_schema || ' but not in ' || prod_schema);
  END LOOP;
END;

CREATE OR REPLACE PROCEDURE compare_indexes (dev_schema IN VARCHAR2, prod_schema IN VARCHAR2) AUTHID CURRENT_USER IS
BEGIN
  FOR i IN (SELECT index_name FROM all_indexes WHERE owner = dev_schema MINUS SELECT index_name FROM all_indexes WHERE owner = prod_schema) LOOP
    DBMS_OUTPUT.PUT_LINE('Index ' || i.index_name || ' exists in ' || dev_schema || ' but not in ' || prod_schema);
  END LOOP;

  FOR i IN (SELECT index_name FROM all_indexes WHERE owner = prod_schema MINUS SELECT index_name FROM all_indexes WHERE owner = dev_schema) LOOP
    DBMS_OUTPUT.PUT_LINE('Index ' || i.index_name || ' exists in ' || prod_schema || ' but not in ' || dev_schema);
  END LOOP;
END;


CREATE OR REPLACE PROCEDURE compare_schemas (
    p_dev_schema VARCHAR2,
    p_prod_schema VARCHAR2
)
IS
    v_dev_table_name VARCHAR2(30);
    v_prod_table_name VARCHAR2(30);
    v_table_count NUMBER := 0;
    v_dev_col_count NUMBER := 0;
    v_prod_col_count NUMBER := 0;

    dev_circ_flag BOOLEAN := true;
    prod_circ_flag BOOLEAN := true;
    nothing number := 0;
BEGIN
    FOR dev_tab_rec IN (SELECT table_name FROM all_tables WHERE owner = p_dev_schema) LOOP
        v_dev_table_name := dev_tab_rec.table_name;

        SELECT COUNT(*) INTO v_table_count
        FROM all_tables
        WHERE owner = p_prod_schema
        AND table_name = v_dev_table_name;

        IF v_table_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Table ' || v_dev_table_name || ' is present in development schema but not in production schema.');
        ELSE
            -- Compare table structure
            SELECT COUNT(*) INTO v_dev_col_count
            FROM all_tab_cols
            WHERE owner = p_dev_schema
            AND table_name = v_dev_table_name;

            SELECT COUNT(*) INTO v_prod_col_count
            FROM all_tab_cols
            WHERE owner = p_prod_schema
            AND table_name = v_dev_table_name;

            IF v_dev_col_count > v_prod_col_count THEN
                DBMS_OUTPUT.PUT_LINE('Table ' || v_dev_table_name || ' has ' || (v_dev_col_count - v_prod_col_count) || ' more columns in development schema.');
            END IF;

            FOR dev_col_rec IN (SELECT column_name FROM all_tab_cols WHERE owner = p_dev_schema AND table_name = v_dev_table_name) LOOP
                SELECT COUNT(*) INTO v_table_count
                FROM all_tab_cols
                WHERE owner = p_prod_schema
                AND table_name = v_dev_table_name
                AND column_name = dev_col_rec.column_name;

                IF v_table_count = 0 THEN
                    DBMS_OUTPUT.PUT_LINE('Column ' || dev_col_rec.column_name || ' in table ' || v_dev_table_name || ' is present in development schema but not in production schema.');
                END IF;
            END LOOP;
        END IF;
    END LOOP;

    select count(*) into nothing from (SELECT a.table_name,
           b.table_name parent_table
    FROM all_constraints a, all_constraints b
    WHERE a.constraint_type = 'R'
    AND   b.constraint_type = 'P'
    AND   a.owner = p_dev_schema
    AND   b.owner = p_dev_schema
    AND   a.r_owner = b.owner
    AND   a.r_constraint_name = b.constraint_name
    START WITH a.table_name = b.table_name
    CONNECT BY PRIOR a.table_name = b.table_name);
    dev_circ_flag := false;

    select count(*) into nothing from (SELECT a.table_name,
           b.table_name parent_table
    FROM all_constraints a, all_constraints b
    WHERE a.constraint_type = 'R'
    AND   b.constraint_type = 'P'
    AND   a.owner = p_prod_schema
    AND   b.owner = p_prod_schema
    AND   a.r_owner = b.owner
    AND   a.r_constraint_name = b.constraint_name
    START WITH a.table_name = b.table_name
    CONNECT BY PRIOR a.table_name = b.table_name);
    prod_circ_flag := false;

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1436 and dev_circ_flag THEN
      DBMS_OUTPUT.PUT_LINE('Circular foreign key reference detected in dev schema.');
    elsif SQLCODE = -1436 and prod_circ_flag THEN
      DBMS_OUTPUT.PUT_LINE('Circular foreign key reference detected in prod schema.');
    ELSE
      RAISE;
    END IF;
END;

CREATE OR REPLACE PROCEDURE drop_all_tables_in_schema (
    p_schema_name VARCHAR2
)
    AUTHID CURRENT_USER
IS
BEGIN
    FOR tab_rec IN (SELECT table_name FROM all_tables WHERE owner = p_schema_name) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || p_schema_name || '.' || tab_rec.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;

CREATE OR REPLACE PROCEDURE get_all_tables_in_schema(schema_name IN VARCHAR2) IS
  table_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO table_count FROM all_tables WHERE owner = schema_name;

  IF table_count > 0 THEN
    FOR t IN (SELECT table_name FROM all_tables WHERE owner = schema_name) LOOP
      DBMS_OUTPUT.PUT_LINE(t.table_name);
    END LOOP;
  ELSE
    DBMS_OUTPUT.PUT_LINE('No tables found in schema ' || schema_name);
  END IF;
END;


