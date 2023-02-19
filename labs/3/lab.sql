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

CREATE OR REPLACE PROCEDURE compare_schemas (
    p_dev_schema VARCHAR2,
    p_prod_schema VARCHAR2
)
IS
    v_dev_table_name VARCHAR2(30);
    v_prod_table_name VARCHAR2(30);
    v_table_count NUMBER := 0;
BEGIN
    FOR dev_tab_rec IN (SELECT table_name FROM all_tables WHERE owner = p_dev_schema) LOOP
        v_dev_table_name := dev_tab_rec.table_name;

        SELECT COUNT(*) INTO v_table_count
        FROM all_tables
        WHERE owner = p_prod_schema
        AND table_name = v_dev_table_name;

        IF v_table_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Table ' || v_dev_table_name || ' is present in development schema but not in production schema.');
        END IF;
    END LOOP;
END;
