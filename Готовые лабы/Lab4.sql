--1.Получить список всех табличных пространств
select tablespace_name, contents from dba_tablespaces;
--2.Получить список всех файлов табличных пространств
select tablespace_name, file_name, status, maxbytes, user_bytes 
from dba_data_files
union
select tablespace_name, file_name, status, maxbytes, user_bytes 
from dba_temp_files;

--3.Получить перечень всех групп журналов повтора.Определить текущую
--группу журналов повтора
select group#, status from v$log;
select group# from v$log where status = 'CURRENT';

--4.Получить перечень файлов всех журналов повтора
select member from v$logfile;

--5.С помощью переключения журналов повтора пройдите полный цикл
--переключений. Проследите последовательность SCN.
select group#, status from v$log;
--выполняем и следим, где CURRENT
alter system switch logfile;

--6.Создать доп. группу журналов повтора с тремся файлами журнала.
--Убедиться в наличии группы и файлов, а также работоспособности группы
--(переключением).Проследить последовательность SCN
alter database add logfile 
    group 4
    'C:\ORACLEDB\ORADATA\ORCL\REDO04.LOG'
    size 50M
    blocksize 512;
    
alter database add logfile 
    member 
    'C:\ORACLEDB\ORADATA\ORCL\REDO04_1.LOG'
    to group 4;
    
alter database add logfile 
    member 
    'C:\ORACLEDB\ORADATA\ORCL\REDO04_2.LOG'
    to group 4;
    
alter database add logfile 
    member 
    'C:\ORACLEDB\ORADATA\ORCL\REDO04_3.LOG'
    to group 4;
    
select group#, status from v$log;
select member from v$logfile;

alter system switch logfile;

--7.Удалить созданную группу журналов повтора.Удалите созданные вами файлы 
--журналов на сервере.
alter database drop logfile member 'C:\ORACLEDB\ORADATA\ORCL\REDO04_1.LOG';
alter database drop logfile member 'C:\ORACLEDB\ORADATA\ORCL\REDO04_2.LOG';
alter database drop logfile member 'C:\ORACLEDB\ORADATA\ORCL\REDO04_3.LOG';
alter database drop logfile group 4;

--8.Определите, выполняется или нет архивирование журналов повтора.
select name, log_mode from v$database;
select instance_name, archiver, active_state from v$instance;

--9.Определите номер последнего архива
select * from v$archived_log;

--10.Включить архивирование
select name, log_mode from v$database;
select instance_name, archiver, active_state from v$instance;

--11.Создать архивный файл. Определить его номер. Определить его местоположение
--и убедиться в его наличии. Проследить последовательность SCN в архивах и 
--журналах повтора (файлы архивации сами создаются при переключении между
--журналами повтора)
alter system switch logfile;

select group#, status from v$log;

select * from v$archived_log;
select * from v$log;

--12.Отключить архивирование. Убедиться, что оно отключено
select name, log_mode from v$database;
select instance_name, archiver, active_state from v$instance;

--13. Получить список управляющих файлов.
select * from v$controlfile;

--14.Получить и исследовать содержимое управляющего файла. Пояснить известные
--мне параметры в файле
--Путь: C:\ORACLEDB\ORADATA\ORCL\CONTROL01.CTL
show parameter control_files;
select * from v$controlfile_record_section;