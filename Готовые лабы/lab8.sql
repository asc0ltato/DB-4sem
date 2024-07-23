--1.Найти конфигурационные файлы SQLNET.RA и TNSNAMES.ORA и ознакомиться с
--их содержимым
--C:\WINDOWS.X64_193000_db_home\network\admin

--2.Настроить соединение при помощи SQL Developer с сервером Oracle.
--Убедиться, что оно работает
select * from dba_tablespaces;

--3.Настроить соединение при помощи SQLPLUS с сервером Oracle с помощью 
--стандартной строки соединения. Убедиться, что соединения работает
--connect system/Qwerty12345@//oracledb.mshome.net:1521/orcl.mshome.net

--4.Запустить утилиту Oracle Net Manager на клиенте и настроить TNS соединение

--5.Подключиться при помощи SQL Developer и SQLPLUS компьютером клиентом к
--серверу с использованием TNS соединения. Убедиться, что оба соединения работают
--connect system/Qwerty12345@test