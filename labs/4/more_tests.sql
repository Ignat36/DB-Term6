DECLARE
    json_string CLOB := '[{"id": 1, "name": "Alice", "hobbies": ["reading", "painting"]}, {"id": 2, "name": "Bob", "hobbies": ["hiking", {"name": "drawing", "type": "art"}]}]';
    json_data JSON_ARRAY_T := JSON_ARRAY_T.parse(json_string);
BEGIN
    FOR i IN 1..json_data.get_size() LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || treat (json_data.get(i) as JSON_OBJECT_T).get('id').get_number());
        DBMS_OUTPUT.PUT_LINE('Name: ' || treat (json_data.get(i) as JSON_OBJECT_T).get('name').get_string());

        -- loop through hobbies array
        DBMS_OUTPUT.PUT_LINE('Hobbies:');
        FOR j IN 1..treat (json_data.get(i) as JSON_OBJECT_T).get('hobbies').get_size() LOOP
            IF json_data.get(i).get('hobbies').get(j).is_string() THEN
                DBMS_OUTPUT.PUT_LINE('- ' || json_data.get(i).get('hobbies').get(j).get_string());
            ELSE
                DBMS_OUTPUT.PUT_LINE('- ' || json_data.get(i).get('hobbies').get(j).get('name').get_string() || ' (' || json_data.get(i).get('hobbies').get(j).get('type').get_string() || ')');
            END IF;
        END LOOP;
    END LOOP;
END;

DECLARE
  json_data CLOB := '{"name": "John", "age": 30, "hobbies": ["reading", "swimming"]}';
  j JSON_OBJECT_T := JSON_OBJECT_T(json_data);
  hobby_count PLS_INTEGER;
BEGIN
  -- Access scalar properties
  DBMS_OUTPUT.PUT_LINE('Name: ' || j.get_string('name'));
  DBMS_OUTPUT.PUT_LINE('Age: ' || j.get_number('age'));

  -- Access array properties
  hobby_count := j.get_array('hobbies').get_size();
  FOR i IN 1..hobby_count LOOP
    DBMS_OUTPUT.PUT_LINE('Hobby ' || i || ': ' || j.get_array('hobbies').get_string(i));
  END LOOP;
END;



DECLARE
  json_data CLOB := '{"names": ["John", "Jane", "Bob"]}';
  json_obj JSON_OBJECT_T;
  names_arr JSON_ARRAY_T;
  name_str VARCHAR2(100);
BEGIN
  json_obj := JSON_OBJECT_T.PARSE(json_data);
  names_arr := json_obj.get_array('names');

  FOR i IN 0..names_arr.get_size()-1 LOOP
    name_str := names_arr.get_string(i);
    DBMS_OUTPUT.PUT_LINE(name_str);
  END LOOP;
END;

DECLARE
  json_data CLOB := '{
                      "name": "John",
                      "age": 30,
                      "city": "New York"
                    }';
  json_obj JSON_OBJECT_T;
  name_val VARCHAR2(50);
  age_val NUMBER;
  city_val VARCHAR2(50);
BEGIN
  json_obj := JSON_OBJECT_T.PARSE(json_data);
  name_val := json_obj.get_string('name');
  age_val := json_obj.get_number('age');
  city_val := json_obj.get_string('city');
  DBMS_OUTPUT.PUT_LINE('Name: ' || name_val);
  DBMS_OUTPUT.PUT_LINE('Age: ' || age_val);
  DBMS_OUTPUT.PUT_LINE('City: ' || city_val);
END;


