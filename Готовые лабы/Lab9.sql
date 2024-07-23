-- Все задания, начиная со 2-го, необходимо выполнять в рамках соединения
--пользователя XXX (у каждого студента собственный пользователь и инфраструктура)
--в своей PDB.
alter pluggable database ZSS_PDB open;

alter session set container = ZSS_PDB;
alter session set "_ORACLE_SCRIPT" = true;

show con_name;

--tablespaces
create tablespace ZSS_PDB_TS
    datafile 'ZSS_PDB_TS.dbf'
    size 10M
    autoextend on next 5M
    maxsize 50M;
    
create temporary tablespace ZSS_PDB_TS_TEMP
    tempfile 'ZSS_PDB_TS_TEMP.dbf'
    size 5M
    autoextend on next 2M
    maxsize 40M;
    
select * from dba_tablespaces where tablespace_name like '%ZSS%';
drop tablespace ZSS_PDB_TS including contents and datafiles;
drop tablespace ZSS_PDB_TS_TEMP including contents and datafiles;

--role
create role ZSS_PDB_RL;

grant connect, create table, create view, create sequence, create cluster,
create synonym, create public synonym, create materialized view,
create database link to ZSS_PDB_RL;

select * from dba_roles where role like '%RL%';
drop role ZSS_PDB_RL;

--profile
create profile ZSS_PDB_PROFILE limit
    password_life_time 365
    sessions_per_user 3
    failed_login_attempts 7
    password_lock_time 1
    password_reuse_time 10
    connect_time 100;
    
alter session set "_ORACLE_SCRIPT" = false;
    
select * from dba_profiles where profile like '%ZSS_PDB_PROFILE%';
drop profile ZSS_PDB_PROFILE;

--user
create user ZSSCORE identified by 123
    default tablespace ZSS_PDB_TS
    quota unlimited on ZSS_PDB_TS
    temporary tablespace ZSS_PDB_TS_TEMP
    profile ZSS_PDB_PROFILE
    account unlock;
    
grant ZSS_PDB_RL to ZSSCORE;

select * from dba_users where username like 'ZSSCORE';
drop user ZSSCORE;

--1. Прочитайте задание полностью и выдайте своему пользователю необходимые права.

--2. Создайте временную таблицу, добавьте в нее данные и продемонстрируйте, 
--как долго они хранятся. Поясните особенности работы с временными таблицами.
create global temporary table temp_table (
    id NUMBER,
    name VARCHAR2(30)
);

insert into temp_table(id, name) values (1, 'test1');
insert into temp_table(id, name) values (2, 'test2');

select * from temp_table;
--3. Создайте последовательность S1 (SEQUENCE), со следующими характеристиками:
--начальное значение 1000; приращение 10; нет минимального значения;
--нет максимального значения; не циклическая; значения не кэшируются в памяти;
--хронология значений не гарантируется. Получите несколько значений 
--последовательности. Получите текущее значение последовательности.
create sequence S1
    start with 1000
    increment by 10
    nominvalue
    nomaxvalue
    nocycle
    nocache
    noorder;

select S1.NEXTVAL from DUAL;
select S1.CURRVAL from DUAL;

--4. Создайте последовательность S2 (SEQUENCE), со следующими характеристиками:
--начальное значение 10; приращение 10; максимальное значение 100;
--не циклическую. Получите все значения последовательности. Попытайтесь получить
--значение, выходящее за максимальное значение.
create sequence S2
    start with 10
    increment by 10
    maxvalue 100
    nocycle;

select S2.NEXTVAL from DUAL;

--5. Создайте последовательность S3 (SEQUENCE), со следующими характеристиками:
--начальное значение 10; приращение -10; минимальное значение -100;
--не циклическую; гарантирующую хронологию значений. Получите все значения
--последовательности.Попытайтесь получить значение, меньше минимального значения.
create sequence S3
    start with 10
    increment by -10
    maxvalue 11
    minvalue -100
    nocycle
    order;

select S3.NEXTVAL from DUAL;

--6. Создайте последовательность S4 (SEQUENCE), со следующими характеристиками:
--начальное значение 1; приращение 1; минимальное значение 10;
--циклическая; кэшируется в памяти 5 значений; хронология значений не гарантиру-
--ется. Продемонстрируйте цикличность генерации значений последовательностью S4.
create sequence S4
    start with 1
    increment by 1
    --minvalue 10
    maxvalue 10
    cycle
    cache 5
    noorder;

select S4.NEXTVAL from DUAL;

--7. Получите список всех последовательностей в словаре базы данных,
--владельцем которых является пользователь XXX.
SELECT * FROM ALL_SEQUENCES WHERE SEQUENCE_OWNER = 'ZSSCORE';
select * from user_sequences;

DROP SEQUENCE S1;
DROP SEQUENCE S2;
DROP SEQUENCE S3;
DROP SEQUENCE S4;

--8. Создайте таблицу T1, имеющую столбцы N1, N2, N3, N4, типа NUMBER (20),
--кэшируемую и расположенную в буферном пуле KEEP. С помощью оператора INSERT 
--добавьте 7 строк, вводимое значение для столбцов должно формироваться с 
--помощью последовательностей S1, S2, S3, S4.
CREATE TABLE TEST1 (
    N1 NUMBER(20),
    N2 NUMBER(20),
    N3 NUMBER(20),
    N4 NUMBER(20)
) CACHE STORAGE ( BUFFER_POOL KEEP ) tablespace ZSS_PDB_TS;

BEGIN
    FOR i IN 1..7 LOOP
    INSERT INTO TEST1 VALUES (S1.NEXTVAL, S2.NEXTVAL, S3.NEXTVAL, S4.NEXTVAL);
    END LOOP;
END;

SELECT * FROM TEST1;

--9. Создайте кластер ABC, имеющий hash-тип (размер 200) и
--содержащий 2 поля: X (NUMBER (10)), V (VARCHAR2(12)).
CREATE CLUSTER ABC (
    X NUMBER(10),
    V VARCHAR2(12)
) HASHKEYS 200;

--10. Создайте таблицу A, имеющую столбцы XA (NUMBER (10)) и VA (VARCHAR2(12)),
--принадлежащие кластеру ABC, а также еще один произвольный столбец.
CREATE TABLE A (
    XA NUMBER(10),
    VA VARCHAR2(12),
    Y NUMBER(10)
) CLUSTER ABC(XA, VA);

--11. Создайте таблицу B, имеющую столбцы XB (NUMBER (10)) и VB (VARCHAR2(12)),
--принадлежащие кластеру ABC, а также еще один произвольный столбец.
CREATE TABLE B (
    XB NUMBER(10),
    VB VARCHAR2(12),
    Z NUMBER(10)
) CLUSTER ABC(XB, VB);

insert into B values (1, 'test', 1);
--12. Создайте таблицу С, имеющую столбцы XС (NUMBER (10)) и VС (VARCHAR2(12)),
--принадлежащие кластеру ABC, а также еще один произвольный столбец.
CREATE TABLE C (
    XC NUMBER(10),
    VC VARCHAR2(12),
    W NUMBER(10)
) CLUSTER ABC(XC, VC);

insert into C values (2, 'test2', 2);
--13. Найдите созданные таблицы и кластер в представлениях словаря Oracle.
SELECT TABLE_NAME FROM USER_TABLES;
SELECT CLUSTER_NAME FROM USER_CLUSTERS;

--14. Создайте частный синоним для таблицы XXX.С и продемонстрируйте его применение.
CREATE SYNONYM SN FOR ZSSCORE.C;
SELECT * FROM C;
SELECT * FROM SN;

SELECT * FROM USER_SYNONYMS;
DROP SYNONYM SN;
--15. Создайте публичный синоним для таблицы XXX.B и продемонстрируйте его применение.
CREATE PUBLIC SYNONYM SB FOR ZSSCORE.B;
SELECT * FROM B;
SELECT * FROM SB;

--16. Создайте две произвольные таблицы A и B (с первичным и внешним ключами),
--заполните их данными, создайте представление V1, основанное на SELECT... FOR A
--inner join B. Продемонстрируйте его работоспособность.
CREATE TABLE A1 (
    X NUMBER(10),
    Y VARCHAR2(12),
    CONSTRAINT PK_A1 PRIMARY KEY (X)
);

CREATE TABLE B1 (
    X NUMBER(10),
    Y VARCHAR2(12),
    CONSTRAINT FK_B1 FOREIGN KEY (X) REFERENCES A1(X)
);

INSERT INTO A1 VALUES (1, 'test1');
INSERT INTO A1 VALUES (2, 'test2');
INSERT INTO B1 VALUES (1, 'test3');
INSERT INTO B1 VALUES (2, 'test4');

CREATE VIEW V1 AS SELECT A1.Y AS AandY, B1.Y AS BandY  FROM A1
INNER JOIN B1 ON A1.X = B1.X;

SELECT * FROM V1;

--17. На основе таблиц A и B создайте материализованное представление MV,
--которое имеет периодичность обновления 2 минуты. Продемонстрируйте его 
--работоспособность.
CREATE MATERIALIZED VIEW MV
REFRESH FORCE START WITH SYSDATE
NEXT SYSDATE + INTERVAL '2' MINUTE ENABLE QUERY REWRITE
as select * from A1 inner join B1 on A1.X = B1.X;

select * from MV;

INSERT INTO A1 VALUES (4, 'test5');
INSERT INTO B1 VALUES (4, 'test6');
COMMIT;

DROP MATERIALIZED VIEW MV;
--18. Создайте DBlink по схеме USER1-USER2 для подключения к другой базе данных
--(если ваша БД находится на сервере ORA12W, то надо подключаться к БД на 
--сервере ORA12D, если вы работаете на своем сервере, то договоритесь 
--с кем-то из группы).
CREATE DATABASE LINK LVO
CONNECT TO LVO
IDENTIFIED BY "2025"
USING '192.168.0.123:1521/PDB_LVO';

DROP DATABASE LINK LVO;
--19. Продемонстрируйте выполнение операторов SELECT, INSERT, UPDATE, DELETE, 
--вызов процедур и функций с объектами удаленного сервера.
SELECT * FROM USER_TABLES@LVO;
SELECT * FROM LVO_TB@LVO;
INSERT INTO LVO_TB@LVO(ID) VALUES (1);
UPDATE LVO_TB@LVO SET ID = 2 WHERE ID = 1;
DELETE FROM LVO_TB@LVO WHERE ID = 2;