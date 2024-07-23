--1. Определите местоположение файла параметров инстанса.
select value from v$parameter where name = 'spfile';

--2. Убедитесь в наличии этого файла в операционной системе.
--C:\WINDOWS.X64_193000_DB_HOME\DATABASE\SPFILEORCL.ORA

--3. Сформируйте PFILE с именем XXX_PFILE.ORA. Исследуйте его содержимое. 
--Поясните известные вам параметры в файле.
create pfile = 'ZSS_PFILE.ora' from spfile;

--4. Измените какой-либо параметр в файле PFILE.
--вручную изменяю параметр

--5. Создайте новый SPFILE.
create spfile = 'SPFILEORCL1.ora' from pfile = 'ZSS_PFILE.ora';

--6. Запустите инстанс с новыми параметрами.
ALTER SYSTEM SET SPFILE='C:\WINDOWS.X64_193000_DB_HOME\DATABASE\SPFILEORCL1.ORA';
show parameter spfile;

--7. Вернитесь к прежним значениям параметров другим способом.
select name, value from v$parameter where name = 'open_cursors';
alter system set open_cursors = 300 scope = spfile;

--8. Получите список управляющих файлов.
select * from v$controlfile;

--9. Создайте скрипт для изменения управляющего файла.
ALTER DATABASE BACKUP CONTROLFILE TO TRACE;

--10. Определите местоположение файла паролей инстанса.
select * from v$pwfile_users; -- пользователи и их роли здесь
show parameter remote_login_passwordfile; --exclusive/shared/none

--11. Убедитесь в наличии этого файла в операционной системе.
--C:\WINDOWS.X64_193000_db_home\database

--12. Получите перечень директориев для файлов сообщений
--(протоколы работы, трассировки, дампы) и диагностики.
select * from v$diag_info;

--13. Найдите и исследуйте содержимое протокола работы инстанса (LOG.XML), 
--найдите в нем команды переключения журналов которые вы выполняли.
--C:\OracleDB\diag\rdbms\orcl\orcl\alert

--14. Найдите и исследуйте содержимое трейса, в который вы сбросили управляющий файл.
--C:\ORACLEDB\diag\rdbms\orcl\orcl\trace
select value from v$diag_info where name = 'Default Trace File';