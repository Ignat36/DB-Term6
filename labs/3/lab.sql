CREATE OR REPLACE PROCEDURE compare_schemas (dev_schema_name IN VARCHAR2, prod_schema_name IN VARCHAR2)
AS
  /* Cursor to get a list of tables in Dev schema */
  CURSOR cur_dev_tables IS
    SELECT table_name
    FROM user_tables
    WHERE owner = dev_schema_name;

  /* Cursor to get a list of columns in Prod schema */
  CURSOR cur_prod_cols (p_table_name VARCHAR2) IS
    SELECT column_name, data_type, data_length, data_precision, data_scale, nullable
    FROM all_tab_columns
    WHERE owner = prod_schema_name
    AND table_name = p_table_name
    ORDER BY column_id;

  /* Type to store the column information */
  TYPE col_info_type IS
    RECORD (
      column_name  VARCHAR2(30),
      data_type    VARCHAR2(30),
      data_length  NUMBER,
      data_precision NUMBER,
      data_scale NUMBER,
      nullable VARCHAR2(1)
    );

  /* Variable to store the column information */
  dev_col_info col_info_type;

  /* Variable to store the table name */
  dev_table_name VARCHAR2(30);

  /* Variable to store the foreign key information */
  fk_info VARCHAR2(1000);

  /* Variable to keep track of the processed tables */
  processed BOOLEAN := FALSE;

BEGIN
  /* Loop through each table in the Dev schema */
  FOR dev_table IN cur_dev_tables
  LOOP
    /* Set the processed flag */
    processed := FALSE;

    /* Get the current Dev table name */
    dev_table_name := dev_table.table_name;

    /* Cursor to get the column information for the current Dev table */
    FOR dev_col IN (SELECT column_name, data_type, data_length, data_precision, data_scale, nullable
                    FROM all_tab_columns
                    WHERE owner = dev_schema_name
                    AND table_name = dev_table_name
                    ORDER BY column_id)
    LOOP
      /* Get the current Dev column information */
      dev_col_info := dev_col;

      /* Check if the current column exists in Prod schema */
      BEGIN
        /* Open the cursor to get the column information from Prod schema */
        OPEN cur_prod_cols (dev_table_name);

        /* Loop through each column in the current Dev table */
        LOOP
          /* Fetch the next Prod column */
          FETCH cur_prod_cols INTO col_info_type;

          /* If the current column exists in Prod schema */
          IF dev_col_info.column_name = col_info_type.column_name THEN
            /* Compare the column information between Dev and Prod */
            IF (dev_col_info.data_type != col_info_type.data_type OR
                dev_col_info.data_length != col_info_type.data_length OR
                dev_col_info.data_precision != col_info_type.data_precision OR
                dev_col_info.data_scale != col_info_type.data_scale OR
                dev_col_info.nullable != col_info_type.nullable) THEN
                /* Raise an exception if the column information does not match */
                RAISE_APPLICATION_ERROR(-20001, 'Column information for column "' || dev_col_info.column_name || '" in table "' || dev_table_name || '" does not match between Dev and Prod schemas');
            END IF;
        /* Set the processed flag */
        processed := TRUE;

        /* Exit the loop as the current column has been processed */
        EXIT;
      END IF;
    END LOOP;

    /* Close the cursor */
    CLOSE cur_prod_cols;

    /* If the current column doesn't exist in Prod schema, insert it */
    IF processed = FALSE THEN
      /* Build the SQL statement to add the column */
      fk_info := 'ALTER TABLE ' || prod_schema_name || '.' || dev_table_name || ' ADD ' || dev_col_info.column_name || ' ' || dev_col_info.data_type || '(' || dev_col_info.data_length || ')';

      /* Execute the SQL statement */
      EXECUTE IMMEDIATE fk_info;
    END IF;
  END;
  END LOOP;
 END LOOP;
END compare_schemas;