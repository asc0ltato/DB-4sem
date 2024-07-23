Вариант 1
1. Получить список всех временных табличных пространств
 select * from dba_tablespaces where contents='TEMPORARY'
2. Получить список привилегий для роли sys
 select * from dba_sys_privs where grantee='SYS' 
select * from USER_sys_privs//если войти по sys 
3. Получить список всех объектов, принадлежащих пользователю
select * from user_OBJECTS
4. Получить список файлов текущих журналов повтора
select * from v$log where status = 'CURRENT';
5. Получить последний архив журналов повтора
select * from v$archived_log;
6. Получить месторасположение файла параметров
select * from v$patameter(?)
7. Для всех таблиц. пользователя найти, в каком пуле буферного кэша
select segment_name, segment_type, tablespace_name, buffer_pool 
from dba_segments 
8. Получить список пользователей, имеющих привилегию sysdba из файла паролей
select * from v$pwfile_users where sysdba='TRUE'
9. Получить размер гранулы в буферном кэше
select * from v$sgainfo where name = 'Granule Size'
select component,
      current_size,
      max_size,
      granule_size from v$sga_dynamic_components where current_size>0 and component like '%buffer%';
10. Получить список работающих в настоящее время фоновых процедур
SELECT * FROM v$BGPROCESS where paddr != hextoraw('00');


Вариант 2
1. Показать все представления словаря, относящиеся к процессам
SELECT * FROM dict where table_name like '%PROCESS%';
2. Получить список файлов табличных пространств отката
select * from dba_tablespaces where contents='UNDO'
3. Получить список всех ролей
select * from DBA_ROLES ;
4. Получить размер данных в наибольшей таблице пользователя
select pool, name, bytes 
from v$sgastat 
order by bytes desc fetch first 1 rows only;
5. Получить размер блока данных двумя способами
show parameter db_block_size;
select distinct bytes/blocks from user_segments;
6. Получить список параметров экземпляра
select * from v$instance;
7. Получить месторасположение файла журнала
select * from v$logfile;
8. Получить объем памяти, выделенный под объекты пользовательской корзины
select component, current_size 
from v$sga_dynamic_components 
where component like '%RECYCLE%'
9. Получить список действительных сервисов
SELECT * FROM V$SERVICES;
10. Получить список работающих в настоящее время серверных процессов.
select * from v$process;
select * from v$session s join v$process p on p.addr=s.paddr where s.username is not null;


3 вариант
1)SELECT INSTANCE_NAME,ARCHIVER FROM V$INSTANCE;+
2)select * from dba_profiles where profile = 'DEFAULT';+
3)select * from user_segments;+
4)SELECT SUM(BYTES) FROM USER_EXTENTS;+
5)select name from dba_pdbs;+
6)select * from v$logfile;+
7)select USERNAME from v$psfile_users; +
8)SELECT COMPONENT, SURRENT_SIZE FROM V$SGA_DYNAMIC_COMPONENTS;+
9)SELECT COMPONENT,GRANULE_SIZE FROM V$SGA_DYNAMIC_COMPONENTS WHERE
COMPONENT LIKE '%shared pool%';+
10)select * from v$session where STATUS = 'ACTIVE';+



— 3.1
select LOG_MODE from V$DATABASE;
select ARCHIVER from v$instance;
— 3.2
select * from dba_profiles where PROFILE = 'DEFAULT'
--3.3
select distinct SEGMENT_TYPE, COUNT(*) from USER_SEGMENTS group by SEGMENT_TYPE
--3.4
select SEGMENT_NAME, SEGMENT_TYPE,
ROUND((BYTES/extents)*8192/1024/1024) EXTENT_SIZE_MB
from USER_SEGMENTS
order by EXTENT_SIZE_MB desc;
--3.5
select * from DBA_PDBS;
--3.6
select MEMBER from v$logfile;
--3.7
select * from v$pwfile_users
--3.8
select COMPONENT, CURRENT_SIZE from V$SGA_DYNAMIC_COMPONENTS;
--3.9
select granule_size from V$SGA_DYNAMIC_COMPONENTS where component like 'shared%';
--3.10
select * from v$session where status = 'ACTIVE';