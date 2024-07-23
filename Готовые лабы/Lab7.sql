--1. Определите общий размер области SGA.
SELECT SUM(VALUE) FROM V$SGA;

--2. Определите текущие размеры основных пулов SGA.
SELECT COMPONENT, CURRENT_SIZE FROM V$SGA_DYNAMIC_COMPONENTS WHERE COMPONENT 
LIKE '%pool';

--3. Определите размеры гранулы для каждого пула.
SELECT COMPONENT, GRANULE_SIZE FROM V$SGA_DYNAMIC_COMPONENTS WHERE COMPONENT 
LIKE '%pool';

--4. Определите объем доступной свободной памяти в SGA.
SELECT CURRENT_SIZE FROM V$SGA_DYNAMIC_FREE_MEMORY;

--5. Определите максимальный и целевой размер области SGA.
SELECT NAME, VALUE FROM V$PARAMETER WHERE NAME IN ('sga_max_size', 'sga_target');

--6. Определите размеры пулов КЕЕP, DEFAULT и RECYCLE буферного кэша.
SELECT COMPONENT, MAX_SIZE, MIN_SIZE, CURRENT_SIZE FROM V$SGA_DYNAMIC_COMPONENTS
WHERE COMPONENT IN ('KEEP buffer cache', 'DEFAULT buffer cache', 'RECYCLE buffer cache');

--7. Создайте таблицу, которая будет помещаться в пул КЕЕP. Продемонстрируйте 
--сегмент таблицы.
CREATE TABLE KEEP_TABLE (X INT) STORAGE(BUFFER_POOL KEEP) TABLESPACE USERS;

INSERT INTO KEEP_TABLE VALUES(1);

SELECT SEGMENT_NAME, SEGMENT_TYPE, TABLESPACE_NAME, BUFFER_POOL 
FROM USER_SEGMENTS WHERE SEGMENT_NAME = 'KEEP_TABLE';

DROP TABLE KEEP_TABLE;

--8. Создайте таблицу, которая будет кэшироваться в пуле DEFAULT. 
--Продемонстрируйте сегмент таблицы.
CREATE TABLE DEFAULT_TABLE (X INT) STORAGE(BUFFER_POOL DEFAULT) TABLESPACE USERS;

INSERT INTO DEFAULT_TABLE VALUES(1);

SELECT SEGMENT_NAME, SEGMENT_TYPE, TABLESPACE_NAME, BUFFER_POOL 
FROM USER_SEGMENTS WHERE SEGMENT_NAME = 'DEFAULT_TABLE';

DROP TABLE DEFAULT_TABLE;

--9. Найдите размер буфера журналов повтора.
SHOW PARAMETER LOG_BUFFER;

--10. Найдите размер свободной памяти в большом пуле.
SELECT POOL, NAME, BYTES FROM V$SGASTAT WHERE POOL = 'large pool' 
AND NAME = 'free memory';

--11. Определите режимы текущих соединений с инстансом (dedicated, shared).
SELECT PADDR, USERNAME, SERVICE_NAME, SERVER, PROGRAM FROM V$SESSION 
WHERE USERNAME IS NOT NULL;

--12. Получите полный список работающих в настоящее время фоновых процессов.
SELECT * FROM V$BGPROCESS;

--13. Получите список работающих в настоящее время серверных процессов.
SELECT ADDR, SPID, PNAME FROM V$PROCESS WHERE BACKGROUND IS NULL ORDER BY PNAME;

--14. Определите, сколько процессов DBWn работает в настоящий момент.
SELECT count(*) FROM V$BGPROCESS WHERE NAME LIKE 'DBW%';
SELECT * FROM V$BGPROCESS WHERE NAME LIKE 'DBW%';

--15. Определите сервисы (точки подключения экземпляра).
SELECT NAME, NETWORK_NAME, PDB FROM V$SERVICES;

--16. Получите известные вам параметры диспетчеров.
SELECT * FROM V$DISPATCHER;
SHOW PARAMETER DISPATCHER;

--17. Укажите в списке Windows-сервисов сервис, реализующий процесс LISTENER.
--OracleOraDB19Home1TNSListener
--services.msc => %listener%

--18. Продемонстрируйте и поясните содержимое файла LISTENER.ORA.
--C:\WINDOWS.X64_193000_db_home\network\admin

--19. Запустите утилиту lsnrctl и поясните ее основные команды.
--C:\WINDOWS.X64_193000_db_home\bin

--20. Получите список служб инстанса, обслуживаемых процессом LISTENER.
--в cmd написала lsnrct1 и там пишем services