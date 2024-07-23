--1.Получить список всех табличных пространств
SELECT * FROM DBA_TABLESPACES;

--2.Создать табл.пр. с именем ZSS_QDATA(10 M). При создании установить в offline.
--Затем перевести его в состояние online. Выделить пользователю ZSS квоту 2 M в
--ZSS_QDATA. От ZSS В ZSS_QDATA создать таблицу ZSS_T1 из двух столбцов, один из
--которых будет первичным ключом. Добавить в таблицу 3 строки.
CREATE TABLESPACE ZSS_QDATA
    DATAFILE 'ZSS_QDATA.dbf'
    SIZE 10 M
    OFFLINE;

ALTER TABLESPACE ZSS_QDATA ONLINE;

alter session set "_ORACLE_SCRIPT" = true;

--role
create role ZSS_RL;

grant connect, create session, alter session,
create any table, drop any table, create any view, drop any view,
create any procedure, drop any procedure to ZSS_RL;

select * from dba_roles where role like '%RL%';
drop role ZSS_RL;
--profile
create profile ZSS_PROFILE limit
    password_life_time 365
    sessions_per_user 3
    failed_login_attempts 7
    password_lock_time 1
    password_reuse_time 10
    connect_time 100;
    
alter session set "_ORACLE_SCRIPT" = false;
    
select * from dba_profiles where profile like '%ZSS_PROFILE%';
drop profile ZSS_PROFILE;
--user
create user C##ZSS identified by 111
    profile ZSS_PROFILE
    account unlock
    password expire;
    
grant ZSS_RL, SYSDBA to C##ZSS;

select * from dba_users where username like 'C##ZSS';
drop user C##ZSS;
----
ALTER USER C##ZSS QUOTA 2M ON ZSS_QDATA;

SELECT TABLESPACE_NAME, BYTES, MAX_BYTES FROM DBA_TS_QUOTAS 
WHERE TABLESPACE_NAME = 'ZSS_QDATA' AND USERNAME = 'C##ZSS';

CREATE TABLE ZSS_T1 (
    x int primary key,
    y int
) TABLESPACE ZSS_QDATA;

insert into ZSS_T1(x,y) values (1,2);
insert into ZSS_T1(x,y) values (3,4);
insert into ZSS_T1(x,y) values (5,6);

select * from ZSS_T1;

drop table ZSS_T1;

--3.Получить список сегментов ZSS_QDATA
SELECT SEGMENT_NAME, SEGMENT_TYPE FROM DBA_SEGMENTS WHERE TABLESPACE_NAME = 'ZSS_QDATA';

--4.Определить сегмент таблицы ZSS_T1
SELECT SEGMENT_NAME, SEGMENT_TYPE FROM DBA_SEGMENTS WHERE SEGMENT_NAME = 'ZSS_T1';

--5.Определить остальные сегменты.
SELECT SEGMENT_NAME, SEGMENT_TYPE FROM DBA_SEGMENTS;

--6.Удалить(drop) таблицу ZSS_T1
DROP TABLE ZSS_T1;

--7.Получить список сегментов ZSS_QDATA. Определить сегмент таблицы ZSS_T1.
--Выполнить select к представлению USER_RECYCLEBIN, пояснить результат
SELECT SEGMENT_NAME FROM DBA_SEGMENTS WHERE TABLESPACE_NAME = 'ZSS_QDATA';
SELECT SEGMENT_NAME, SEGMENT_TYPE FROM DBA_SEGMENTS WHERE SEGMENT_NAME = 'ZSS_T1';
SELECT * FROM USER_RECYCLEBIN;

--8.Восстановить(flashback) удаленную таблицу
FLASHBACK TABLE ZSS_T1 TO BEFORE DROP;

--9.Выполнить PL/SQL-скрипт, заполняющий таблицу ZSS_T1 данными(10000 строк) 
DECLARE 
    i int := 6;
BEGIN
    WHILE i < 10006 LOOP
        INSERT INTO ZSS_T1(x,y) values (i, i);
        i := i + 1;
    END LOOP;
END;

SELECT COUNT(*) FROM ZSS_T1;

--10.Определить сколько в сегменте таблицы ZSS_T1 экстентов, их размер в блоках
--и байтах
SELECT EXTENT_ID, BYTES, BLOCKS FROM DBA_EXTENTS WHERE SEGMENT_NAME = 'ZSS_T1';

--11.Получить перечень всех экстентов в бд
SELECT EXTENT_ID, FILE_ID, BLOCK_ID, BLOCKS FROM DBA_EXTENTS;

--12.Исследовать значения псевдостолбца RowId в таблице ZSS_T1 и других
--таблицах.Пояснить формат и использование RowId
CREATE TABLE TEST (
    x NUMBER(5) PRIMARY KEY,
    ora_rowscn number
) TABLESPACE ZSS_QDATA;

SELECT x, y, RowId FROM ZSS_T1;
SELECT x, RowId FROM TEST;

DROP TABLE TEST;
--13.Исследовать значения псевдостолбца RowSCN в таблице ZSS_T1 и других таблицах
SELECT x, y, ORA_ROWSCN FROM ZSS_T1;

--14.Изменить таблицу так, чтобы для каждой строки RowSCN выставлялся индивидуально
DROP TABLE ZSS_T1;

CREATE TABLE ZSS_T1 (
    x int primary key,
    y int
) ROWDEPENDECIES;

BEGIN 
    FOR i in 6 .. 10000 loop
    insert into ZSS_T1 (x,y) values (i,i);
    commit;
    end loop;
END;

select x,y, ORA_ROWSCN FROM ZSS_T1;
--16.Удалить ZSS_QDATA и его файл
DROP TABLESPACE ZSS_QDATA INCLUDING CONTENTS AND DATAFILES;
DROP TABLE ZSS_T1 PURGE;