--ZSSCORE
-- 1. Создайте таблицу, имеющую несколько атрибутов, один из которых первичный ключ.
alter pluggable database ZSS_PDB open;
grant create trigger to ZSSCORE;
-----------------------------------------------
show con_name;
alter session set container = ZSS_PDB;
alter session set "_ORACLE_SCRIPT" = true;

create table STUDENT
(
  STUDENT      number primary key,
  STUDENT_NAME varchar(100),
  PULPIT       char(40) default 'ИСиТ'
);

-- 2. Заполните таблицу данными (10 шт.).
INSERT INTO STUDENT (STUDENT, STUDENT_NAME)
VALUES (1, 'Понизович Дмитрий');
INSERT INTO STUDENT (STUDENT, STUDENT_NAME)
VALUES (2, 'Иванов Петр');
INSERT INTO STUDENT (STUDENT, STUDENT_NAME, PULPIT)
VALUES (3, 'Сидр Валерий', 'ПОиСОИ');
INSERT INTO STUDENT (STUDENT, STUDENT_NAME, PULPIT)
VALUES (4, 'Рыбаченок Ксения', 'ЛВ');
INSERT INTO STUDENT (STUDENT, STUDENT_NAME, PULPIT)
VALUES (5, 'Бабак Анастасия','ОВ');
INSERT INTO STUDENT (STUDENT, STUDENT_NAME, PULPIT)
VALUES (6, 'Кузнецов Иван', 'ОВ');
INSERT INTO STUDENT (STUDENT, STUDENT_NAME, PULPIT)
VALUES (7, 'Павлов Арнольд', 'ЛУ');
INSERT INTO STUDENT (STUDENT, STUDENT_NAME, PULPIT)
VALUES (8, 'Соловьев Никита', 'ЛПиСПС');
INSERT INTO STUDENT (STUDENT, STUDENT_NAME, PULPIT)
VALUES (9, 'Якубенко Ксения', 'ТЛ');
INSERT INTO STUDENT (STUDENT, STUDENT_NAME, PULPIT)
VALUES (10, 'Шалак Никита', 'ЛМиЛЗ');

select * from STUDENT;
drop table STUDENT;

-- 3. Создайте BEFORE – триггер уровня оператора на события INSERT, DELETE и 
--UPDATE. Этот и все последующие триггеры должны выдавать сообщение на серверную 
--консоль (DMS_OUTPUT) со своим собственным именем.
create or replace trigger STUDENT_TRIGGER_OPERATORS_BEFORE
  before insert or delete or update
  on STUDENT
begin
  dbms_output.put_line('STUDENT_TRIGGER OPERATORS BEFORE');
end;

INSERT INTO STUDENT (STUDENT, STUDENT_NAME, PULPIT)
VALUES (11, 'Лешков Павел', 'ИСиТ');
update STUDENT set STUDENT = 12 WHERE STUDENT = 11; 
delete from STUDENT where STUDENT = 12;

drop trigger STUDENT_TRIGGER_OPERATORS_BEFORE;

-- 4. Создайте BEFORE-триггер уровня строки на события INSERT, DELETE и UPDATE.
create or replace trigger STUDENT_TRIGGER_ROW_BEFORE
  before insert or delete or update
  on STUDENT
  for each row
begin
  dbms_output.put_line('STUDENT_TRIGGER ROW BEFORE');
end;

update STUDENT set PULPIT = 'ИСиТ';

drop trigger STUDENT_TRIGGER_ROW_BEFORE;

-- 5. Примените предикаты INSERTING, UPDATING и DELETING.
create or replace trigger STUDENT_TRIGGER_ROW_BEFORE
  before insert or delete or update
  on STUDENT
  for each row
begin
  if inserting then
    dbms_output.put_line('STUDENT_TRIGGER ROW INSERTING BEFORE');
  elsif updating then
    dbms_output.put_line('STUDENT_TRIGGER ROW UPDATING BEFORE');
  elsif deleting then
    dbms_output.put_line('STUDENT_TRIGGER ROW DELETING BEFORE');
  end if;
end;

INSERT INTO STUDENT (STUDENT, STUDENT_NAME, PULPIT)
VALUES (11, 'Лешков Павел', 'ИСиТ');
update STUDENT set STUDENT = 12 WHERE STUDENT = 11; 
delete from STUDENT where STUDENT = 12;

drop trigger STUDENT_TRIGGER_ROW_BEFORE;

-- 6. Разработайте AFTER-триггеры уровня оператора на события INSERT, DELETE и UPDATE.
create or replace trigger STUDENT_TRIGGER_OPERATORS_AFTER
  after insert or delete or update
  on STUDENT
begin
  dbms_output.put_line('STUDENT_TRIGGER OPERATORS AFTER');
end;

INSERT INTO STUDENT (STUDENT, STUDENT_NAME, PULPIT)
VALUES (11, 'Лешков Павел', 'ИСиТ');
update STUDENT set STUDENT = 12 WHERE STUDENT = 11; 
delete from STUDENT where STUDENT = 12;

drop trigger STUDENT_TRIGGER_OPERATORS_AFTER;

--7. Разработайте AFTER-триггеры уровня строки на события INSERT, DELETE и UPDATE.
create or replace trigger STUDENT_TRIGGER_ROW_AFTER
  after insert or delete or update
  on STUDENT
  for each row
begin
  dbms_output.put_line('STUDENT_TRIGGER ROW AFTER');
end;

update STUDENT set PULPIT = 'ИСиТ';

drop trigger STUDENT_TRIGGER_ROW_AFTER;

--8. Создайте таблицу с именем AUDIT. Таблица должна содержать поля: OperationDate, 
--OperationType (операция вставки, обновления и удаления), TriggerName(имя триггера), 
--Data (строка со значениями полей до и после операции).
create table AUDITS
(
  OperationDate date,
  OperationType varchar(255),
  TriggerName   varchar(255),
  Data varchar(255)
);

DROP TABLE AUDITS;

--9. Измените все триггеры таким образом, чтобы они регистрировали все 
--операции с исходной таблицей в таблице AUDIT.
create or replace trigger INSERT_INTO_STUDENT
    before insert 
    on STUDENT 
begin
    dbms_output.put_line('INSERT INTO STUDENT');
end;

create or replace trigger UPDATE_INTO_STUDENT
    before update
    on STUDENT 
begin
    dbms_output.put_line('UPDATE INTO STUDENT');
end;

create or replace trigger DELETE_INTO_STUDENT
    before delete
    on STUDENT 
begin
    dbms_output.put_line('DELETE INTO STUDENT');
end;

create or replace trigger GET_AUDITS
  before insert or delete or update
  on STUDENT
  for each row
begin
    if inserting then
        insert into AUDITS values (sysdate, 'INSERT', 'INSERT_INTO_STUDENT', 
        :NEW.STUDENT || ' : ' || :NEW.STUDENT_NAME || ' : ' || :NEW.PULPIT);
    elsif updating then
        insert into AUDITS values (sysdate, 'UPDATE', 'UPDATE_INTO_STUDENT', 
        :OLD.STUDENT || ' - ' || :NEW.STUDENT || ' : ' || :OLD.STUDENT_NAME || ' - '  || :NEW.STUDENT_NAME || ' : ' || :OLD.PULPIT || ' - '  || :NEW.PULPIT);
    elsif deleting then
        insert into AUDITS values (sysdate, 'DELETE', 'DELETE_INTO_STUDENT', 
        :OLD.STUDENT || ' : ' || :OLD.STUDENT_NAME || ' : ' || :OLD.PULPIT);
    end if;
end;

INSERT INTO STUDENT (STUDENT, STUDENT_NAME, PULPIT)
VALUES (11, 'Лешков Павел', 'ИСиТ');
update STUDENT set STUDENT = 12 WHERE STUDENT = 11; 
delete from STUDENT where STUDENT = 12;

select * from AUDITS;
truncate table AUDITS; 

drop trigger INSERT_INTO_STUDENT;
drop trigger UPDATE_INTO_STUDENT;
drop trigger DELETE_INTO_STUDENT;
drop trigger GET_AUDITS;
--10. Выполните операцию, нарушающую целостность таблицы по первичному ключу.
--Выясните, зарегистрировал ли триггер это событие. Объясните результат.
INSERT INTO STUDENT (STUDENT, STUDENT_NAME, PULPIT)
VALUES (1, 'Иван Иваныч', 'ИСиТ');
 
select * from AUDITS;

--11. Удалите (drop) исходную таблицу. Объясните результат. 
--Добавьте триггер, запрещающий удаление исходной таблицы.
drop table STUDENT;

flashback table STUDENT to before drop;

select * from STUDENT;

create or replace trigger BEFORE_DROP
  before drop on ZSSCORE.SCHEMA
begin
  if ORA_DICT_OBJ_NAME <> 'STUDENT' then
    return;
  end if;
  raise_application_error(-20001, 'Нельзя удалять таблицу STUDENT');
end;

drop trigger BEFORE_DROP;
--12. Удалите (drop) таблицу AUDIT. Просмотрите состояние триггеров с помощью 
--SQL-DEVELOPER. Объясните результат. Измените триггеры.
drop table AUDITS;
flashback table AUDITS to before drop;
select TRIGGER_NAME, STATUS from USER_TRIGGERS;

ALTER TABLE AUDITS ENABLE ALL TRIGGERS;
--13. Создайте представление над исходной таблицей. Разработайте 
--INSTEAD OF UPDATE-триггер. Триггер должен добавлять новую строку в таблицу, 
--а старую помечать как недействительную.
drop trigger STUDENT_VIEW_TRIGGER;

create or replace view STUDENT_VIEW
as
select * from STUDENT;

create or replace trigger STUDENT_VIEW_TRIGGER
  instead of update on STUDENT_VIEW
  for each row
begin
  insert into STUDENT(STUDENT, STUDENT_NAME, PULPIT) values (:old.STUDENT + 10, :old.STUDENT_NAME, :old.PULPIT);
  update STUDENT set STUDENT_NAME = 'UNNABLE', PULPIT = 'UNNABLE' where STUDENT = :old.STUDENT;
  dbms_output.put_line('STUDENT_VIEW_INSTEAD_OF');
end;

update STUDENT_VIEW set STUDENT_NAME = 'Шалак Никита', PULPIT = 'ИСиТ' WHERE STUDENT = 10;

select * from STUDENT_VIEW;
select * from STUDENT;
select * from AUDITS;
truncate table AUDITS;
DROP TRIGGER STUDENT_VIEW_TRIGGER;
--14. Продемонстрируйте, в каком порядке выполняются триггеры.
CREATE OR REPLACE TRIGGER INSERT_INTO_STUDENT_BEFORE
    BEFORE INSERT ON STUDENT
BEGIN
    DBMS_OUTPUT.PUT_LINE('1. INSERT_INTO_STUDENT_BEFORE');
END;

CREATE OR REPLACE TRIGGER INSERT_INTO_STUDENT_ROW_BEFORE
    BEFORE INSERT ON STUDENT
    FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('2. INSERT_INTO_STUDENT_ROW_BEFORE');
END;

CREATE OR REPLACE TRIGGER INSERT_INTO_STUDENT_ROW_AFTER
    AFTER INSERT ON STUDENT
    FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('3. INSERT_INTO_STUDENT_ROW_AFTER');
END;

CREATE OR REPLACE TRIGGER INSERT_INTO_STUDENT_AFTER
    AFTER INSERT ON STUDENT
BEGIN
    DBMS_OUTPUT.PUT_LINE('4. INSERT_INTO_STUDENT_AFTER');
END;

INSERT INTO STUDENT (STUDENT, STUDENT_NAME, PULPIT)
VALUES (11, 'Лешков Павел', 'ИСиТ');
delete from STUDENT where STUDENT = 11;

DROP TRIGGER INSERT_INTO_STUDENT_BEFORE;
DROP TRIGGER INSERT_INTO_STUDENT_ROW_BEFORE;
DROP TRIGGER INSERT_INTO_STUDENT_ROW_AFTER;
DROP TRIGGER INSERT_INTO_STUDENT_AFTER;
--15. Создайте несколько триггеров одного типа, реагирующих на одно и то же 
--событие, и покажите, в каком порядке они выполняются. Измените порядок 
--выполнения этих триггеров.
CREATE OR REPLACE TRIGGER INSERT_INTO_STUDENT_AFTER_1
    AFTER INSERT ON STUDENT
    FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('1. INSERT_INTO_STUDENT_AFTER_1');
END;

CREATE OR REPLACE TRIGGER INSERT_INTO_STUDENT_AFTER_2
    AFTER INSERT ON STUDENT
    FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('2. INSERT_INTO_STUDENT_AFTER_2');
END;

CREATE OR REPLACE TRIGGER INSERT_INTO_STUDENT_AFTER_3
    AFTER INSERT ON STUDENT
    FOR EACH ROW
    FOLLOWS INSERT_INTO_STUDENT_AFTER_1
BEGIN
    DBMS_OUTPUT.PUT_LINE('3. INSERT_INTO_STUDENT_AFTER_3');
END;

CREATE OR REPLACE TRIGGER INSERT_INTO_STUDENT_AFTER_4
    AFTER INSERT ON STUDENT
    FOR EACH ROW
    FOLLOWS INSERT_INTO_STUDENT_AFTER_2
BEGIN
    DBMS_OUTPUT.PUT_LINE('4. INSERT_INTO_STUDENT_AFTER_4');
END;

INSERT INTO STUDENT (STUDENT, STUDENT_NAME, PULPIT)
VALUES (11, 'Лешков Павел', 'ИСиТ');
delete from STUDENT where STUDENT = 11;

DROP TRIGGER INSERT_INTO_STUDENT_AFTER_1;
DROP TRIGGER INSERT_INTO_STUDENT_AFTER_2;
DROP TRIGGER INSERT_INTO_STUDENT_AFTER_3;
DROP TRIGGER INSERT_INTO_STUDENT_AFTER_4;