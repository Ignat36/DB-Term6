DECLARE
    json_data CLOB := '{"query_type": "SELECT", "columns": ["table1.column1", "table2.column2"], "tables": ["table1", "table2"], "join_conditions": ["table1.column3 = table2.column1"], "filter_conditions": ["table1.column3 > 10"]}';
    result SYS_REFCURSOR;
BEGIN
    result := json_orm(json_data);
END;

SELECT table1.column1, table2.column2 FROM table1, table2 WHERE table1.column3 = table2.column1 AND table1.column3 > 10;