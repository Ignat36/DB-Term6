create or replace FUNCTION json_orm(json_data CLOB) RETURN SYS_REFCURSOR IS
  v_query_type VARCHAR2(100);
  v_columns VARCHAR2(4000);
  v_tables VARCHAR2(4000);
  v_join_conditions VARCHAR2(4000);
  v_filter_conditions VARCHAR2(4000);
  v_set_clause VARCHAR2(4000);
  v_values VARCHAR2(4000);
  v_pks VARCHAR2(4000);
  v_sql VARCHAR2(8000);
  v_cursor SYS_REFCURSOR;

  FUNCTION process_select_condition(json_select CLOB) RETURN VARCHAR2
  IS
    v_type_check varchar2(100);
    v_col VARCHAR2(4000);
    v_tab VARCHAR2(4000);
    v_filter_cond VARCHAR2(4000);
    v_inclusion_operator VARCHAR2(4000);
    v_search_column VARCHAR2(4000);
    v_res_sql VARCHAR2(4000);
  BEGIN

      select JSON_VALUE(json_select, '$.query_type') into v_type_check from DUAL;

      if v_type_check = 'SELECT' then

        select LISTAGG(table_name, ', ')
            into v_tab
            from JSON_TABLE(json_select, '$.tables[*]' COLUMNS (table_name VARCHAR2(1000) PATH '$')) j;

        select JSON_VALUE(json_select, '$.column') into v_col from DUAL;
        select JSON_VALUE(json_select, '$.operator') into v_inclusion_operator from DUAL;
        select JSON_VALUE(json_select, '$.search_col') into v_search_column from DUAL;

        v_filter_cond := '';
        for i in (select f_q_type, f_cond, f_operator from JSON_TABLE (json_select,
                           '$.filter_conditions[*]' COLUMNS (
                              f_q_type VARCHAR2(100) PATH '$.condition_type',
                              f_cond VARCHAR2(4000) PATH '$.condition',
                              f_operator VARCHAR2(100) PATH '$.operator')
                           ) j)
        loop

            if i.f_q_type = 'plain' then

                if v_filter_cond is null then
                    v_filter_cond := i.f_cond;
                else
                    v_filter_cond := v_filter_cond || ' ' || i.f_operator || ' ' || i.f_cond;
                end if;

            elsif i.f_q_type = 'included' then

                if v_filter_cond is null then
                    v_filter_cond := process_select_condition(replace(i.f_cond, 'ё', '"'));
                else
                    v_filter_cond := v_filter_cond || ' ' || i.f_operator || ' (' || process_select_condition(replace(i.f_cond, 'ё', '"')) || ')';
                end if;

            end if;

        end loop;

        -- Build the dynamic SQL statement
        v_res_sql := 'SELECT ' || v_col || ' FROM ' || v_tab;
        v_res_sql := v_res_sql || ' WHERE ' || v_filter_cond;
        v_res_sql := v_search_column || ' ' || v_inclusion_operator || ' (' || v_res_sql || ')';

      end if;

      return v_res_sql;
  END;

BEGIN
  -- Extract values from JSON data
  select JSON_VALUE(json_data, '$.query_type') into v_query_type from DUAL;

  if v_query_type = 'SELECT' then

      select LISTAGG(column_name, ', ')
        into v_columns
        from JSON_TABLE(json_data, '$.columns[*]' COLUMNS (column_name VARCHAR2(1000) PATH '$')) j;

        select LISTAGG(table_name, ', ')
            into v_tables
            from JSON_TABLE(json_data, '$.tables[*]' COLUMNS (table_name VARCHAR2(1000) PATH '$')) j;

        select LISTAGG(table_name, ' AND ')
            into v_join_conditions
            from JSON_TABLE(json_data, '$.join_conditions[*]' COLUMNS (table_name VARCHAR2(1000) PATH '$')) j;


        for i in (select f_q_type, f_cond, f_operator from JSON_TABLE (json_data,
                           '$.filter_conditions[*]' COLUMNS (
                              f_q_type VARCHAR2(100) PATH '$.condition_type',
                              f_cond VARCHAR2(4000) PATH '$.condition',
                              f_operator VARCHAR2(100) PATH '$.operator')
                           ) j)
        loop

            if i.f_q_type = 'plain' then

                if v_filter_conditions is null then
                    v_filter_conditions := i.f_cond;
                else
                    v_filter_conditions := v_filter_conditions || ' ' || i.f_operator || ' ' || i.f_cond;
                end if;

            elsif i.f_q_type = 'included' then

                if v_filter_conditions is null then
                    v_filter_conditions := process_select_condition(replace(i.f_cond, 'ё', '"'));
                else
                    v_filter_conditions := v_filter_conditions || ' ' || i.f_operator || ' (' || process_select_condition(replace(i.f_cond, 'ё', '"')) || ')';
                end if;

            end if;
        end loop;

        -- Build the dynamic SQL statement
        v_sql := 'SELECT ' || v_columns || ' FROM ' || v_tables;
        if v_join_conditions is not null then
            v_sql := v_sql || ' WHERE ' || v_join_conditions;
        end if;
        if v_filter_conditions is not null then
            if v_join_conditions is null then
                v_sql := v_sql || ' WHERE ' || v_filter_conditions;
            else
                v_sql := v_sql || ' AND ' || v_filter_conditions;
            end if;
        end if;

        open v_cursor for v_sql;

    elsif v_query_type = 'INSERT' then

        select JSON_VALUE(json_data, '$.table') into v_tables from DUAL;

        select LISTAGG (column_name, ', ')
        into v_columns
        from JSON_TABLE (json_data,
                       '$.columns[*]' COLUMNS (column_name VARCHAR2 (1000) PATH '$')) j;

        select LISTAGG (val, ', ')
         into v_values
         from JSON_TABLE (json_data, '$.values[*]' COLUMNS (val VARCHAR2 (4000) PATH '$')) j;

      v_sql := 'INSERT INTO ' || v_tables || ' (' || v_columns || ') VALUES (' || v_values || ')';

    elsif v_query_type = 'DELETE' then

        select JSON_VALUE(json_data, '$.table') into v_tables from DUAL;

        select LISTAGG (condition, ' AND ')
          into v_filter_conditions
          from JSON_TABLE (json_data,
                           '$.filter_conditions[*]' COLUMNS (condition VARCHAR2 (4000) PATH '$')) j;

        v_sql := 'DELETE FROM ' || v_tables || ' WHERE ' || v_filter_conditions;

    elsif v_query_type = 'UPDATE' then

        select JSON_VALUE(json_data, '$.table') into v_tables from DUAL;

        select LISTAGG (column_name || ' = ' || val, ', ')
         into v_set_clause
         from JSON_TABLE (json_data,
                          '$.set[*]' COLUMNS (column_name VARCHAR2 (1000) PATH '$[0]',
                                              val VARCHAR2 (1000) PATH '$[1]')) j;

        select LISTAGG (condition, ' AND ') WITHIN GROUP (ORDER BY condition)
          into v_filter_conditions
          from JSON_TABLE (json_data,
                           '$.filter_conditions[*]' COLUMNS (condition VARCHAR2 (4000) PATH '$')) j;

        v_sql := 'UPDATE ' || v_tables || ' SET ' || v_set_clause || ' WHERE ' || v_filter_conditions;

    elsif v_query_type = 'CREATE TABLE' then

        SELECT JSON_VALUE(json_data, '$.table') INTO v_tables FROM DUAL;

        SELECT LISTAGG(column_name || ' ' || data_type, ', ')
          INTO v_columns
          FROM JSON_TABLE (json_data,
                           '$.columns[*]' COLUMNS (
                              column_name VARCHAR2(100) PATH '$.name',
                              data_type VARCHAR2(100) PATH '$.type')
                           ) j;

        SELECT LISTAGG ('constraint pk_' || v_tables || '_' || col_name || ' primary_key (' || col_name || ')', ', ')
          INTO v_pks
          FROM JSON_TABLE (json_data,
                           '$.primary_keys[*]' COLUMNS (col_name VARCHAR2 (4000) PATH '$')) j;

        v_sql := 'CREATE TABLE ' || v_tables || ' (' || v_columns || ', ' || v_pks || ');';

        SELECT JSON_VALUE(json_data, '$.primary_keys[0]') INTO v_pks FROM DUAL;

        v_sql := v_sql || ' ' || '

            create sequence ' || v_tables || '_seq start with 1;' ||
                 '
            CREATE OR REPLACE TRIGGER tr_' || v_tables || '_pk_autoincrement
            BEFORE INSERT ON ' || v_tables || '
            FOR EACH ROW
            BEGIN
            SELECT ' || v_tables || '_seq' || '.NEXTVAL
            INTO :NEW.' || v_pks || '
            FROM DUAL;
            END;';

    elsif v_query_type = 'DROP TABLE' then

        SELECT JSON_VALUE(json_data, '$.table') INTO v_tables FROM DUAL;
        v_sql := 'DROP TABLE ' || v_tables;

    else
        raise_application_error(-20005, 'Incorrect query type ');
        null;
    end if;

    DBMS_OUTPUT.PUT_LINE(v_sql);

    RETURN v_cursor;

END json_orm;