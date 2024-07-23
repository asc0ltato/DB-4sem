--1. Разработайте простейший анонимный блок PL/SQL (АБ), не содержащий операторов.
DECLARE
BEGIN
NULL;
END;

--2. Разработайте АБ, выводящий «Hello World!». Выполните его в SQLDev и SQL+.
DECLARE
BEGIN
DBMS_OUTPUT.PUT_LINE('Hello World!');
END;

-- 3. Разработайте скрипт, позволяющий посмотреть все спецсимволы PL/SQL.
select keyword from V_$RESERVED_WORDS where LENGTH = 1 and KEYWORD <> 'A';

-- 4. Разработайте скрипт, позволяющий посмотреть все ключевые слова PL/SQL.
select keyword from V_$RESERVED_WORDS where LENGTH > 1 and keyword <> 'A' 
order by keyword;

-- 5. Разработайте анонимный блок, демонстрирующий (выводящий в выходной серверный 
--поток результаты):
-- 5.1. объявление и инициализацию целых number-переменных;
DECLARE
v_num1 NUMBER := 1;
v_num2 INTEGER := 2;
BEGIN
DBMS_OUTPUT.PUT_LINE(v_num1);
DBMS_OUTPUT.PUT_LINE(v_num2);
END;

-- 5.2. арифметические действия над двумя целыми number-переменных, включая деление с остатком;
DECLARE
v_num1 NUMBER := 1;
v_num2 NUMBER(3) := 2;
BEGIN
DBMS_OUTPUT.PUT_LINE(v_num1 + v_num2);
DBMS_OUTPUT.PUT_LINE(v_num1 - v_num2);
DBMS_OUTPUT.PUT_LINE(v_num1 * v_num2);
DBMS_OUTPUT.PUT_LINE(v_num1 / v_num2);
DBMS_OUTPUT.PUT_LINE(v_num1 mod v_num2);
END;

-- 5.3. объявление и инициализацию number-переменных с фиксированной точкой
DECLARE
v_num1 NUMBER := 1.1;
v_num2 NUMBER(3, 1) := 2.2;
BEGIN
DBMS_OUTPUT.PUT_LINE(v_num1);
DBMS_OUTPUT.PUT_LINE(v_num2);
END;

-- 5.4. объявление и инициализацию number-переменных с фиксированной точкой 
--и отрицательным масштабом (округление);
DECLARE
v_num1 NUMBER := 1.1;
v_num2 NUMBER(3, -1) := 2.2;
BEGIN
DBMS_OUTPUT.PUT_LINE(v_num1);
DBMS_OUTPUT.PUT_LINE(v_num2);
END;

-- 5.5. объявление number-переменных с точкой и применением символа E (степень 10)
--при инициализации/присвоении;
DECLARE
v_num1 NUMBER := 1.1E1;
v_num2 NUMBER := 1.1E-1;
BEGIN
DBMS_OUTPUT.PUT_LINE(v_num1);
DBMS_OUTPUT.PUT_LINE(v_num2);
END;

-- 5.6. объявление и инициализацию переменных типа даты;
-- 5.7. объявление и инициализацию символьных переменных различной семантики;

— 14. объявление и инициализацию BINARY_FLOAT-переменной;

DECLARE
v_num BINARY_FLOAT := 1.1;
BEGIN
DBMS_OUTPUT.PUT_LINE(v_num);
end;

— 15. объявление и инициализацию BINARY_DOUBLE-переменной;

DECLARE
v_num BINARY_DOUBLE := 1.1;
BEGIN
DBMS_OUTPUT.PUT_LINE(v_num);
END;

--5.8. объявление и инициализацию BOOLEAN-переменных
DECLARE
v_bool BOOLEAN := TRUE;
BEGIN
IF v_bool THEN
DBMS_OUTPUT.PUT_LINE('TRUE');
ELSE
DBMS_OUTPUT.PUT_LINE('FALSE');
END IF;
END;

-- 6. Разработайте анонимный блок PL/SQL содержащий объявление констант (VARCHAR2, CHAR, NUMBER).
--Продемонстрируйте возможные операции константами.

DECLARE
VCHAR_CONST CONSTANT VARCHAR2(20) := 'VCHAR_CONST';
CHAR_CONST CONSTANT CHAR(20) := 'CHAR_CONST';
NUMBER_CONST CONSTANT NUMBER := 1;
BEGIN
DBMS_OUTPUT.PUT_LINE(VCHAR_CONST);
DBMS_OUTPUT.PUT_LINE(CHAR_CONST);
DBMS_OUTPUT.PUT_LINE(NUMBER_CONST);
END;

-- 7. Разработайте АБ, содержащий объявления с опцией %TYPE. Продемонстрируйте действие опции.

DECLARE
VCHAR_CONST CONSTANT VARCHAR2(20) := 'VCHAR_CONST';
CHAR_CONST CONSTANT CHAR(20) := 'CHAR_CONST';
NUMBER_CONST CONSTANT NUMBER := 1;
VCHAR_CONST2 VCHAR_CONST%TYPE := 'VCHAR_CONST2';
CHAR_CONST2 CHAR_CONST%TYPE := 'CHAR_CONST2';
NUMBER_CONST2 NUMBER_CONST%TYPE := 2;
BEGIN
DBMS_OUTPUT.PUT_LINE(VCHAR_CONST2);
DBMS_OUTPUT.PUT_LINE(CHAR_CONST2);
DBMS_OUTPUT.PUT_LINE(NUMBER_CONST2);
END;

-- 8. Разработайте АБ, содержащий объявления с опцией %ROWTYPE. Продемонстрируйте действие опции.
DECLARE
AUDITORIUM_TYPE_ROW AUDITORIUM_TYPE%ROWTYPE;
BEGIN
AUDITORIUM_TYPE_ROW.AUDIOTRIUM_TYPENAME := 'Аудитория';
AUDITORIUM_TYPE_ROW.AUDITORIUM_TYPE := 'Auditorium';

DBMS_OUTPUT.PUT_LINE(AUDITORIUM_TYPE_ROW.AUDITORIUM_TYPE);
DBMS_OUTPUT.PUT_LINE(AUDITORIUM_TYPE_ROW.AUDIOTRIUM_TYPENAME);
end;

-- 9. Разработайте АБ, демонстрирующий все возможные конструкции оператора IF.
DECLARE
v_num NUMBER := 1;
BEGIN
IF v_num = 1 THEN
DBMS_OUTPUT.PUT_LINE('v_num = 1');
ELSIF v_num = 2 THEN
DBMS_OUTPUT.PUT_LINE('v_num = 2');
ELSIF v_num is null THEN
DBMS_OUTPUT.PUT_LINE('v_num is null');
ELSE
DBMS_OUTPUT.PUT_LINE('v_num = 3');
END IF;
END;

-- 10. Разработайте АБ, демонстрирующий работу оператора CASE.
DECLARE
v_num NUMBER := 1;
BEGIN
CASE v_num
WHEN 1 THEN
DBMS_OUTPUT.PUT_LINE('v_num = 1');
WHEN 2 THEN
DBMS_OUTPUT.PUT_LINE('v_num = 2');
WHEN 3 THEN
DBMS_OUTPUT.PUT_LINE('v_num = 3');
ELSE
DBMS_OUTPUT.PUT_LINE('v_num is null');
END CASE;
END;

-- 11. Разработайте АБ, демонстрирующий работу оператора LOOP.
DECLARE
v_num NUMBER := 1;
BEGIN
LOOP
DBMS_OUTPUT.PUT_LINE(v_num);
v_num := v_num + 1;
EXIT WHEN v_num > 10;
END LOOP;
END;

-- 12. Разработайте АБ, демонстрирующий работу оператора WHILE.
DECLARE
v_num NUMBER := 1;
BEGIN
WHILE v_num <= 10 LOOP
DBMS_OUTPUT.PUT_LINE(v_num);
v_num := v_num + 1;
END LOOP;
END;

-- 13. Разработайте АБ, демонстрирующий работу оператора FOR.
DECLARE
v_num NUMBER := 1;
BEGIN
FOR i IN 1..10 LOOP
DBMS_OUTPUT.PUT_LINE(i);
END LOOP;
END;
