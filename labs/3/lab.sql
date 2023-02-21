drop procedure COMPARE_PROCEDURES;

CREATE OR REPLACE PROCEDURE compare_procedures (
    dev_schema IN VARCHAR2,
    prod_schema IN VARCHAR2
)
AUTHID CURRENT_USER
AS
  v_script VARCHAR2(4000);
  v_count NUMBER;
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

    FOR dev_proc IN (SELECT object_name, dbms_metadata.get_ddl('PROCEDURE', object_name, dev_schema) AS proc_text FROM all_objects WHERE object_type = 'PROCEDURE' AND owner = dev_schema)
    LOOP
        v_count := 0;
        SELECT COUNT(*) INTO v_count FROM all_objects WHERE object_type = 'PROCEDURE' AND object_name = dev_proc.object_name AND owner = prod_schema;
        IF v_count = 0 THEN
            v_script := dev_proc.proc_text;
            v_script := REPLACE(v_script, dev_schema, prod_schema);
            dbms_output.put_line('CREATE ' || v_script);
        END IF;
    END LOOP;

    -- Drop unnecessary procedures from the prod schema
    FOR prod_proc IN (SELECT object_name FROM all_objects WHERE object_type = 'PROCEDURE' AND owner = prod_schema) LOOP
        v_count := 0;
        SELECT COUNT(*) INTO v_count FROM all_objects WHERE object_type = 'PROCEDURE' AND object_name = prod_proc.object_name AND owner = dev_schema;
        IF v_count = 0 THEN
            dbms_output.put_line('DROP PROCEDURE ' || prod_schema || '.' || prod_proc.object_name);
        END IF;
    END LOOP;
END;

CREATE OR REPLACE PROCEDURE compare_functions (
    dev_schema IN VARCHAR2,
    prod_schema IN VARCHAR2
)
AUTHID CURRENT_USER
AS
    v_script VARCHAR2(4000);
        v_count number;
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

    FOR dev_func IN (SELECT object_name, dbms_metadata.get_ddl('FUNCTION', object_name, dev_schema) AS func_text FROM all_objects WHERE object_type = 'FUNCTION' AND owner = dev_schema)
    LOOP
        v_count := 0;
        SELECT COUNT(*) INTO v_count
        FROM all_objects
        WHERE object_type = 'FUNCTION' AND object_name = dev_func.object_name AND owner = prod_schema;
        IF v_count = 0 THEN
            v_script := dev_func.func_text;
            v_script := REPLACE(v_script, dev_schema, prod_schema);
            dbms_output.put_line('CREATE ' || v_script);
        END IF;
    END LOOP;
    FOR prod_func IN (SELECT object_name FROM all_objects WHERE object_type = 'FUNCTION' AND owner = prod_schema) LOOP
        v_count := 0;
        SELECT COUNT(*) INTO v_count
        FROM all_objects
        WHERE object_type = 'FUNCTION' AND object_name = prod_func.object_name AND owner = dev_schema;
        IF v_count = 0 THEN
            dbms_output.put_line('DROP FUNCTION ' || prod_func.object_name);
        END IF;
    END LOOP;
END;

CREATE OR REPLACE PROCEDURE compare_indexes (dev_schema IN VARCHAR2, prod_schema IN VARCHAR2) AUTHID CURRENT_USER IS
    v_script VARCHAR2(32767);
    v_count PLS_INTEGER := 0;
BEGIN
  FOR i IN (SELECT index_name FROM all_indexes WHERE owner = dev_schema MINUS SELECT index_name FROM all_indexes WHERE owner = prod_schema) LOOP
    DBMS_OUTPUT.PUT_LINE('Index ' || i.index_name || ' exists in ' || dev_schema || ' but not in ' || prod_schema);
  END LOOP;

  FOR i IN (SELECT index_name FROM all_indexes WHERE owner = prod_schema MINUS SELECT index_name FROM all_indexes WHERE owner = dev_schema) LOOP
    DBMS_OUTPUT.PUT_LINE('Index ' || i.index_name || ' exists in ' || prod_schema || ' but not in ' || dev_schema);
  END LOOP;

    FOR dev_index IN (SELECT index_name, table_name, dbms_metadata.get_ddl('INDEX', index_name, dev_schema) AS index_text FROM all_indexes WHERE owner = dev_schema)
    LOOP
        v_script := '';
        SELECT COUNT(*) INTO v_count FROM all_indexes WHERE owner = prod_schema AND index_name = dev_index.index_name;
        IF v_count = 0 THEN
            v_script := 'CREATE ' || REPLACE(DBMS_LOB.SUBSTR(dev_index.index_text, 32767), dev_schema, prod_schema);
            dbms_output.put_line(v_script);
        END IF;
    END LOOP;
    FOR prod_index IN (SELECT index_name FROM all_indexes WHERE owner = prod_schema) LOOP
        SELECT COUNT(*) INTO v_count FROM all_indexes WHERE owner = dev_schema AND index_name = prod_index.index_name;
        IF v_count = 0 THEN
            dbms_output.put_line('DROP INDEX ' || prod_schema || '.' || prod_index.index_name);
        END IF;
    END LOOP;
END;

CREATE OR REPLACE PROCEDURE compare_tables (
    p_dev_schema IN VARCHAR2,
    p_prod_schema IN VARCHAR2
) AUTHID CURRENT_USER IS
    v_dev_table_name all_tables.table_name%TYPE;
    v_table_count INTEGER;
    v_dev_col_count INTEGER;
    v_prod_col_count INTEGER;

    v_script VARCHAR2(4000);
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

    FOR dev_tab_rec IN (SELECT table_name FROM all_tables WHERE owner = p_dev_schema) LOOP
            v_dev_table_name := dev_tab_rec.table_name;

            SELECT COUNT(*) INTO v_table_count
            FROM all_tables
            WHERE owner = p_prod_schema
            AND table_name = v_dev_table_name;

            IF v_table_count = 0 THEN
                -- Table does not exist in production schema, so generate CREATE TABLE statement
                SELECT dbms_metadata.get_ddl('TABLE', v_dev_table_name, p_dev_schema) INTO v_script
                FROM dual;
                v_script := REPLACE(v_script, p_dev_schema, p_prod_schema);
                dbms_output.put_line(v_script);
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
                    -- Table has more columns in development schema, so generate ALTER TABLE statement to add missing columns
                    v_script := 'ALTER TABLE ' || p_prod_schema || '.' || v_dev_table_name || ' ADD (';
                    FOR dev_col_rec IN (SELECT column_name, data_type, data_length, data_precision, data_scale
                                        FROM all_tab_cols WHERE owner = p_dev_schema AND table_name = v_dev_table_name) LOOP
                        SELECT COUNT(*) INTO v_table_count
                        FROM all_tab_cols
                        WHERE owner = p_prod_schema
                        AND table_name = v_dev_table_name
                        AND column_name = dev_col_rec.column_name;

                        IF v_table_count = 0 THEN
                            v_script := v_script || dev_col_rec.column_name || ' ' || dev_col_rec.data_type;
                            IF dev_col_rec.data_type IN ('VARCHAR2', 'NVARCHAR2', 'RAW') THEN
                                v_script := v_script || '(' || dev_col_rec.data_length || ')';
                            ELSIF dev_col_rec.data_type IN ('NUMBER') THEN
                                v_script := v_script || '(' || dev_col_rec.data_precision || ', ' || dev_col_rec.data_scale || ')';
                            END IF;
                            v_script := v_script || ', ';
                        END IF;
                    END LOOP;
                    v_script := RTRIM(v_script, ', ') || ')';
                    dbms_output.put_line(v_script);
                END IF;
            END IF;
        END LOOP;

        -- Check for tables that exist in the production schema but not in the development schema
        FOR prod_tab_rec IN (SELECT table_name FROM all_tables WHERE owner = p_prod_schema) LOOP
            SELECT COUNT(*) INTO v_table_count
            FROM all_tables
            WHERE owner = p_dev_schema
            AND table_name = prod_tab_rec.table_name;

            IF v_table_count = 0 THEN
                -- Table does not exist in development schema, so generate DROP TABLE statement
                dbms_output.put_line('DROP TABLE ' || p_prod_schema || '.' || prod_tab_rec.table_name);
            END IF;
        END LOOP;
END;

CREATE OR REPLACE PROCEDURE search_for_circular_foreign_key_references(
    schema_name IN VARCHAR2
) AUTHID CURRENT_USER IS
    nothing number;
BEGIN
    select count(*) into nothing from (SELECT a.table_name,
           b.table_name parent_table
    FROM all_constraints a, all_constraints b
    WHERE a.constraint_type = 'R'
    AND   b.constraint_type = 'P'
    AND   a.owner = schema_name
    AND   b.owner = schema_name
    AND   a.r_owner = b.owner
    AND   a.r_constraint_name = b.constraint_name
    START WITH a.table_name = b.table_name
    CONNECT BY PRIOR a.table_name = b.table_name);

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1436 THEN
      DBMS_OUTPUT.PUT_LINE('Circular foreign key reference detected in ' || schema_name ||' schema.');
    ELSE
      RAISE;
    END IF;
END;

CREATE OR REPLACE PROCEDURE compare_schemas (
    p_dev_schema VARCHAR2,
    p_prod_schema VARCHAR2
)
    AUTHID CURRENT_USER
IS
BEGIN

    compare_procedures(p_dev_schema, p_prod_schema);
    compare_functions(p_dev_schema, p_prod_schema);
    compare_indexes(p_dev_schema, p_prod_schema);
    compare_tables(p_dev_schema, p_prod_schema);
    search_for_circular_foreign_key_references(p_dev_schema);
    search_for_circular_foreign_key_references(p_prod_schema);
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


