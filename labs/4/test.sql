DECLARE
    v_address VARCHAR2(100);
    v_name VARCHAR2(100);
    json_data CLOB := '{"query_type": "SELECT",
                      "columns": ["name", "address"],
                      "tables": ["table1", "table2"],
                      "join_conditions": ["table1.id = table2.id", "table1.age > 25"],
                      "filter_conditions": ["name IN (SELECT name FROM table1 WHERE age > 30)"]}';    result SYS_REFCURSOR;
BEGIN
    result := json_orm(json_data);

    LOOP
        FETCH result INTO v_address, v_name;
        EXIT WHEN result%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Address: ' || v_address || ', Name: ' || v_name);
    END LOOP;

END;

DECLARE
    json_data CLOB := '{
      "query_type": "SELECT",
      "columns": ["table1.name", "table2.address"],
      "tables": ["table1", "table2"],
      "join_conditions": ["table1.id = table2.id"],
      "filter_conditions": ["table1.age > 25"]
    }';
    result SYS_REFCURSOR;
BEGIN
    result := json_orm(json_data);
END;

DECLARE
    json_data CLOB := '{
      "query_type": "UPDATE",
      "table": "table1",
      "set": [ ["age", "100"], ["name", "''Ignat''"]],
      "filter_conditions": ["id = 1"]
    }';
    result SYS_REFCURSOR;
BEGIN
    result := json_orm(json_data);
END;

DECLARE
    json_data CLOB := '{
      "query_type": "INSERT",
      "table": "table1",
      "columns": ["id", "name", "age"],
      "values": ["1", "''John''", "30"]
    }';
    result SYS_REFCURSOR;
BEGIN
    result := json_orm(json_data);
END;

DECLARE
    json_data CLOB := '{
      "query_type": "DELETE",
      "table": "table1",
      "filter_conditions": ["id = 1"]
    }';
    result SYS_REFCURSOR;
BEGIN
    result := json_orm(json_data);
END;


SELECT address, name FROM table1, table2 WHERE table1.age > 25 AND table1.id = table2.id AND name IN (SELECT name FROM table1 WHERE age > 30)