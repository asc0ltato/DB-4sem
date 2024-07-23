--1)Список всех существующих PDB. Определить их текущее состояние
select * from DBA_PDBS;
select name, open_mode from v$pdbs;

--2)Создать собственный экземпляр PDB
--3)Список всех существующих PDB
select * from DBA_PDBS;
alter database ZSS_PDB open;
--4)Подключение к ZSS_PDB. Создать табл.пр., роль. профиль без., пользователя
--U1_ZSS_PDB
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

grant connect, create session, alter session,
create any table, drop any table, create any view, drop any view,
create any procedure, drop any procedure to ZSS_PDB_RL;

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
create user U1_ZSS_PDB identified by 111
    default tablespace ZSS_PDB_TS
    quota unlimited on ZSS_PDB_TS
    temporary tablespace ZSS_PDB_TS_TEMP
    profile ZSS_PDB_PROFILE
    account unlock
    password expire;
    
grant ZSS_PDB_RL, SYSDBA to U1_ZSS_PDB;

select * from dba_users where username like '%U1%';
drop user U1_ZSS_PDB;

--5)Подключиться к U1_ZSS_PDB, создать таблицу, добавить строки, select 
create table ZSS_TABLE (
    id int primary key,
    s varchar(50)
);

insert into ZSS_TABLE values (1, 'test1');
insert into ZSS_TABLE values (2, 'test2');
insert into ZSS_TABLE values (3, 'test3');

select * from ZSS_TABLE;
drop table ZSS_TABLE;

--6)Вывод (U1_ZSS_PDB)
select * from dba_tablespaces where tablespace_name like 'ZSS%';
select * from dba_data_files;
select * from dba_temp_files;
select * from dba_roles where ROLE like 'ZSS%';
select * from dba_sys_privs where GRANTEE like 'ZSS%';
select * from dba_profiles where PROFILE like 'ZSS%';
select * from dba_users where USERNAME like 'ZSS%';

--7,8)Подключиться к CDB (находимся в ZSS), пользователь C##ZSS, ему привилегию 
--для подключения к ZSS_PDB. Привилегия на создание таблицы.
alter session set container = CDB$ROOT;
show con_name;

create user C##ZSS identified by 111;
grant connect, create session, alter session, create any table, drop any table,
SYSDBA to C##ZSS container = all;

select * from dba_users where USERNAME like '%C##%';
DROP USER C##ZSS;
--9)2 подключения C##ZSS в Developer к CDB и ZSS_PDB.
--10)Подключиться пользователем C##ZSS, создать таблицу и добавить данные.
--ConnectToCDB
create table x (id int);
drop table x;

insert into x values (1);
insert into x values (2);
select * from x;
--ConnectToPDB
create table x (id int);
drop table x;

insert into x values (3);
insert into x values (4);
select * from x;

--11)Просмотреть все объекты, доступные пользователям(U1_ZSS_PDB)
select object_name from user_objects; 

--12)(ZSS)Назначить привелегию, разрещающему подключение к ZSS_PDB общему 
--пользователю C##YYY, созданному другим студентом. Проверить работоспособность
--этого пользователя в ZSS_PDB
alter session set container = CDB$ROOT;
show con_name;
create user C##ZSS2 identified by 111;
grant connect, create session, alter session, create any table, drop any table,
SYSDBA to C##ZSS2 container = all;

select * from dba_users where username like '%C##%';

drop user C##ZSS2;
alter session set container = ZSS_PDB;
show con_name;
--13)Подключиться к U1_ZSS_PDB тут, а к C##ZSS и C##ZSS2 с другого (к ZSS_PDB).
--Тут получить список всех текущих подключений к ZSS_PDB и к CDB
select SID, SERIAL#, USERNAME, PROGRAM, MACHINE, LOGON_TIME FROM V$SESSION WHERE
TYPE = 'USER';

--15)Удалить ZSS_PDB. Удалить C##ZSS.
alter pluggable database ZSS_PDB close;
drop pluggable database ZSS_PDB including datafiles;
drop user C##ZSS;
