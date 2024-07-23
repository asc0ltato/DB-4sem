--ZSS
alter pluggable database ZSS_PDB open;
ALTER SESSION SET nls_date_format='dd-mm-yyyy hh24:mi:ss';
SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE = 'ZSS_PDB_RL';
GRANT CREATE TABLESPACE TO ZSSCORE;
GRANT ALTER TABLESPACE TO ZSSCORE;

--ZSSCORE
create tablespace data01
    datafile 't1_zss.dbf'
    size 7 m
    autoextend on
    maxsize unlimited;

create tablespace data02
    datafile 't2_zss.dbf'
    size 7 m
    autoextend on
    maxsize unlimited;

create tablespace data03
    datafile 't3_zss.dbf'
    size 7 m
    autoextend on
    maxsize unlimited;

--ZSS
alter user ZSSCORE quota unlimited on data01;
alter user ZSSCORE quota unlimited on data02;
alter user ZSSCORE quota unlimited on data03;

--drop tablespace data01 including contents and datafiles;
--drop tablespace data02 including contents and datafiles;
--drop tablespace data03 including contents and datafiles;

-- 1. Создайте таблицу T_RANGE c диапазонным секционированием. Используйте ключ
--секционирования типа NUMBER.
drop table T_RANGE;
create table T_RANGE (
    id number,
    price number
)
partition by range (id)
(
    partition T_RANGE_q1 values less than (100) tablespace data01,
    partition T_RANGE_q2 values less than (200) tablespace data02,
    partition T_RANGE_max values less than (maxvalue) tablespace data03
);
-- 2. Создайте таблицу T_INTERVAL c интервальным секционированием. Используйте 
--ключ секционирования типа DATE.
drop table T_INTERVAL;
create table T_INTERVAL (
    id number,
    time_id date
)
    partition by range (time_id)
    interval (numtoyminterval(1, 'YEAR'))
(
    partition p0 values less than ('01-01-2010') tablespace data01
);
-- 3. Создайте таблицу T_HASH c хэш-секционированием. Используйте ключ 
--секционирования типа VARCHAR2.
drop table T_HASH;
create table T_HASH
(
    str varchar2(50),
    id number
)
partition by hash (id)
    partitions 3
    store in (data01 , data02 , data03);
-- 4. Создайте таблицу T_LIST со списочным секционированием. Используйте ключ 
--секционирования типа CHAR.
drop table T_LIST;
create table T_LIST (
    type char(250)
)
partition by list(type)
(
    partition T_LIST_q1 values ('BIG') tablespace data01,
    partition T_LIST_q2 values ('MEDIUM') tablespace data02,
    partition T_LIST_q3 values ('SMALL') tablespace data03,
    partition T_LIST_OTHER values (default)
);
-- 5. Введите с помощью операторов INSERT данные в таблицы T_RANGE, T_INTERVAL, 
--T_HASH, T_LIST. Данные должны быть такими, чтобы они разместились по всем 
--секциям. Продемонстрируйте это с помощью SELECT запроса.
begin
    for i in 1..300
    loop
        insert into T_RANGE(id, price) values (i, i);
    end loop;
end;
        
select * from T_RANGE partition(T_RANGE_q1);
select * from T_RANGE partition(T_RANGE_q2);
select * from T_RANGE partition(T_RANGE_max);

select TABLE_NAME, PARTITION_NAME, HIGH_VALUE, TABLESPACE_NAME
from USER_TAB_PARTITIONS
where table_name = 'T_RANGE';
--------------------------------------------------------------------------------
insert into T_INTERVAL(id, time_id) values (50, '01-02-2008');
insert into T_INTERVAL(id, time_id) values (105, '01-01-2009');
insert into T_INTERVAL(id, time_id) values (205, '01-01-2019');
insert into T_INTERVAL(id, time_id) values (405, '01-01-2017');
insert into T_INTERVAL(id, time_id) values (505, '01-01-2026');
commit;

select * from T_INTERVAL partition (p0);
select * from T_INTERVAL partition (SYS_P381);
select * from T_INTERVAL partition (SYS_P382);
select * from T_INTERVAL partition (SYS_P383);

select TABLE_NAME, PARTITION_NAME, HIGH_VALUE, TABLESPACE_NAME
from USER_TAB_PARTITIONS
where table_name = 'T_INTERVAL';
--------------------------------------------------------------------------------
insert into T_HASH (str, id) values ('papap', 1);
insert into T_HASH (str, id) values ('mamamamama', 2);
insert into T_HASH (str, id) values ('waaaaaaaaaaaaaaay', 3);
insert into T_HASH (str, id) values ('blob', 4);
insert into T_HASH (str, id) values ('xx', 5);
commit;

select * from T_HASH partition (SYS_P421);
select * from T_HASH partition (SYS_P423);
select * from T_HASH partition (SYS_P403);

select TABLE_NAME, PARTITION_NAME, HIGH_VALUE, TABLESPACE_NAME
from USER_TAB_PARTITIONS
where table_name = 'T_HASH';
--------------------------------------------------------------------------------
insert into T_list(type) values('BIG');
insert into T_list(type) values('MEDIUM');
insert into T_list(type) values('SMALL');
insert into T_list(type) values('LALA');
insert into T_list(type) values('MAMA');
commit;

select * from T_list partition (T_LIST_q1);
select * from T_list partition (T_LIST_q2);
select * from T_list partition (T_LIST_q3);
select * from T_list partition (T_LIST_OTHER);

select TABLE_NAME, PARTITION_NAME, HIGH_VALUE, TABLESPACE_NAME
from USER_TAB_PARTITIONS
where table_name = 'T_LIST';
-- 6. Продемонстрируйте для всех таблиц процесс перемещения строк между секциями,
--при изменении (оператор UPDATE) ключа секционирования.
alter table T_RANGE enable row movement;
select * from T_RANGE partition(T_RANGE_q1);
select * from T_RANGE partition(T_RANGE_max);
update T_RANGE set id=0 where id=300;
select * from T_RANGE partition(T_RANGE_q1) order by id;

alter table T_INTERVAL enable row movement;
select * from T_INTERVAL partition(p0);
update T_INTERVAL set time_id='01-12-2012' where id=50;
select * from T_INTERVAL partition(SYS_P441);

alter table T_HASH enable row movement;
select * from T_HASH partition (SYS_P401);
select * from T_HASH partition (SYS_P402);
update T_HASH set str='la' where id=5;
select * from T_HASH partition (SYS_P403);

alter table T_LIST enable row movement;
select * from T_list partition (T_LIST_q1);
update T_LIST set type ='SMALL' where type ='BIG';
select * from T_list partition (T_LIST_q2);
select * from T_list partition (T_LIST_q3);

-- 7. Для одной из таблиц продемонстрируйте действие оператора ALTER TABLE MERGE.
alter table T_RANGE merge partitions T_RANGE_q1, T_RANGE_q2 into partition T_RANGE_q5
tablespace data03;
select * from T_RANGE partition(T_RANGE_q5);

-- 8. Для одной из таблиц продемонстрируйте действие оператора ALTER TABLE SPLIT.
alter table T_RANGE split partition T_RANGE_q5 at (100)
into (partition T_RANGE_q1 tablespace data01, partition T_RANGE_q2 tablespace data02);
select * from T_RANGE partition(T_RANGE_q5);
select * from T_RANGE partition(T_RANGE_q1);
select * from T_RANGE partition(T_RANGE_q2);

-- 9. Для одной из таблиц продемонстрируйте действие оператора ALTER TABLE EXCHANGE.
drop table T_RANGE1;
create table T_RANGE1
(
    id number,
    price number
);
alter table T_RANGE exchange partition T_RANGE_q1 with table T_RANGE1;
select * from T_RANGE partition (T_RANGE_q1);
select * from T_RANGE1;

-- 10. Выведите при помощи SELECT запросов:
-- •	список всех секционированных таблиц;
    SELECT * FROM USER_TABLES WHERE PARTITIONED = 'YES';
-- •	список всех секций какой-либо таблицы;
    select * from user_tab_partitions where table_name = 'T_RANGE';
-- •	список всех значений из какой-либо секции по имени секции;W
    select * from T_RANGE  partition(T_RANGE_q2);
-- •	список всех значений из какой-либо секции по ссылке.
    select * from T_RANGE  partition for (100); 