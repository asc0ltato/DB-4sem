--1. Разработайте АБ, демонстрирующий работу оператора SELECT с точной выборкой.
declare
    faculty_rec faculty%rowtype;
begin
    select * into faculty_rec from faculty where faculty = 'ХТиТ';
    dbms_output.put_line(faculty_rec.faculty ||' '||faculty_rec.faculty_name);
    exception
    when others
    then dbms_output.put_line(sqlcode||' '||sqlerrm);
end;

--2. Разработайте АБ, демонстрирующий работу оператора SELECT с неточной точной 
--выборкой. Используйте конструкцию WHEN OTHERS секции исключений и встроенную 
--функции SQLERRM, SQLCODE для диагностирования неточной выборки.
declare
    faculty_rec faculty%rowtype;
begin
    select * into faculty_rec from faculty;
    dbms_output.put_line(faculty_rec.faculty ||' '||faculty_rec.faculty_name);
    exception
    when others
    then dbms_output.put_line(sqlcode||' '||sqlerrm);
end;

--3. Разработайте АБ, демонстрирующий работу конструкции WHEN TO_MANY_ROWS 
--секции исключений для диагностирования неточной выборки.
declare
    faculty_rec faculty%rowtype;
begin
    select * into faculty_rec from faculty;
    dbms_output.put_line(faculty_rec.faculty ||' '||faculty_rec.faculty_name);
    exception
    when too_many_rows
    then dbms_output.put_line(sqlcode||' '||sqlerrm);
end;

--4. Разработайте АБ, демонстрирующий возникновение и обработку исключения 
--NO_DATA_FOUND. Разработайте АБ, демонстрирующий применение атрибутов неявного 
--курсора.
declare
    faculty_rec faculty%rowtype;
begin
    select * into faculty_rec from faculty where faculty = 'ФИТ';
    dbms_output.put_line(faculty_rec.faculty ||' '||faculty_rec.faculty_name);
    exception
    when no_data_found
    then dbms_output.put_line(sqlcode||' '||sqlerrm);
end;

declare
    faculty_rec FACULTY%rowtype;
    b1 boolean;
    b2 boolean;
    b3 boolean;
    n pls_integer;
begin
    select * into faculty_rec from FACULTY where faculty = 'ИДиП';
    b1:= sql%found;
    b2:= sql%isopen;
    b3:= sql%notfound;
    n:= sql%rowcount;
    dbms_output.put_line(faculty_rec.faculty ||' '|| faculty_rec.faculty_name);
    if b1 then dbms_output.put_line('b1 - true');
        else dbms_output.put_line('b1 - false');
    end if;
    if b2 then dbms_output.put_line('b2 - true');
        else dbms_output.put_line('b2 - false');
    end if;
    if b3 then dbms_output.put_line('b3 - true');
        else dbms_output.put_line('b3 - false');
    end if;
    dbms_output.put_line('n = ' || n);
end;

--5. Разработайте АБ, демонстрирующий применение операторов INSERT, UPDATE, 
--DELETE, вызывающие нарушение целостности в базе данных. Обработайте исключения.
declare
    auditorium_rec auditorium%rowtype;
begin
    insert into auditorium values ('211-4','211-4', 'ЛК', 'ЛК');
    exception
    when others
    then dbms_output.put_line(sqlcode||' '||sqlerrm);
    rollback;
end;

declare
    auditorium_rec auditorium%rowtype;
begin
    delete from auditorium_type where auditorium_type = 'ЛК';
    exception
    when others
    then dbms_output.put_line(sqlcode||' '||sqlerrm);
    rollback;
end;

declare
    auditorium_rec auditorium%rowtype;
begin
    update auditorium_type set auditorium_type = 'ЛКК' where auditorium_type = 'ЛК';
    exception
    when others
    then dbms_output.put_line(sqlcode||' '||sqlerrm);
    rollback;
end;

--6. Создайте анонимный блок, распечатывающий таблицу TEACHER с применением 
--явного курсора LOOP-цикла. Считанные данные должны быть записаны в переменные,
--объявленные с применением опции %TYPE.
declare
    cursor curs_teachers is select * from teacher;
    m_teacher teacher.teacher%type;
    m_teacher_name teacher.teacher_name%type;
    m_pulpit teacher.pulpit%type;
begin
    open curs_teachers;
    dbms_output.put_line('rowcount = ' || curs_teachers%rowcount);
    loop
        fetch curs_teachers into m_teacher, m_teacher_name, m_pulpit;
        exit when curs_teachers%notfound;
        dbms_output.put_line(' ' || curs_teachers%rowcount || ' ' || m_teacher 
        || ' ' || m_teacher_name || ' ' || m_pulpit);
    end loop;
    dbms_output.put_line('rowcount = ' || curs_teachers%rowcount);
    close curs_teachers;
    exception
    when others
    then dbms_output.put_line(sqlcode||' '||sqlerrm);
end;

--7. Создайте АБ, распечатывающий таблицу SUBJECT с применением явного курсора и 
--WHILE-цикла. Считанные данные должны быть записаны в запись (RECORD), 
--объявленную с применением опции %ROWTYPE.
declare
    cursor curs_subject is select * from subject;
    rec_subject subject%rowtype;
begin
    open curs_subject;
    dbms_output.put_line('rowcount = ' || curs_subject%rowcount);
    fetch curs_subject into rec_subject;
    while curs_subject%found
    loop
        fetch curs_subject into rec_subject;
        dbms_output.put_line(' ' || curs_subject%rowcount || ' ' || rec_subject.subject || ' ' ||
        rec_subject.subject_name || ' ' || rec_subject.pulpit);
    end loop;
    dbms_output.put_line('rowcount = ' || curs_subject%rowcount);
    close curs_subject;
    exception
    when others
    then dbms_output.put_line(sqlcode||' '||sqlerrm);
end;


--8. Создайте АБ, распечатывающий следующие списки аудиторий: все аудитории 
--(таблица AUDITORIUM) с вместимостью меньше 20, от 21-30, от 31-60, от 61 до 80,
--от 81 и выше. Примените курсор с параметрами и три способа организации цикла 
--по строкам курсора.
declare
    cursor curs (capacity auditorium.auditorium_capacity%type, capacity1 auditorium.auditorium_capacity%type)
    is select auditorium, auditorium_capacity, auditorium_type from auditorium
    where auditorium_capacity >= capacity and auditorium_capacity <= capacity1;
    aud curs%rowtype;
begin
    dbms_output.put_line('capacity <= 20 :');
    for aud in curs(0,20)
    loop 
        dbms_output.put_line(aud.auditorium || ' ' || aud.auditorium_capacity);
    end loop;
    dbms_output.put_line('21 <= capacity <= 30 :');
    for aud in curs(21,30)
    loop 
        dbms_output.put_line(aud.auditorium || ' ' || aud.auditorium_capacity);
    end loop;
    dbms_output.put_line('31 <= capacity <= 60 :');
    for aud in curs(31,60)
    loop 
        dbms_output.put_line(aud.auditorium || ' ' || aud.auditorium_capacity);
    end loop;
    dbms_output.put_line('61 <= capacity <= 80 :');
    for aud in curs(61,80)
    loop 
        dbms_output.put_line(aud.auditorium || ' ' || aud.auditorium_capacity);
    end loop;
    dbms_output.put_line('81 <= capacity :');
    for aud in curs(81,100)
    loop 
        dbms_output.put_line(aud.auditorium || ' ' || aud.auditorium_capacity);
    end loop;
    exception
    when others
    then dbms_output.put_line(sqlcode||' '||sqlerrm);
end;
            
--9. Создайте AБ. Объявите курсорную переменную с помощью системного типа 
--refcursor. Продемонстрируйте ее применение для курсора c параметрами.
declare
    type auditorium_ref is ref cursor return auditorium%rowtype;
    xcurs auditorium_ref;
    xcurs_row xcurs%rowtype;
begin
    open xcurs for select * from auditorium;
    fetch xcurs into xcurs_row;
    loop
        exit when xcurs%notfound;
        dbms_output.put_line(' '||xcurs_row.auditorium||' '||xcurs_row.auditorium_capacity);
        fetch xcurs into xcurs_row;
    end loop;
    close xcurs;
    exception 
    when others 
    then dbms_output.put_line(sqlcode||' '||sqlerrm);
end;

--10. Создайте AБ. Уменьшите вместимость всех аудиторий (таблица AUDITORIUM)
--вместимостью от 40 до 80 на 10%. Используйте явный курсор с параметрами, 
--цикл FOR, конструкцию UPDATE CURRENT OF.
declare
    cursor curs_auditorium(capacity auditorium.auditorium_capacity%type, 
    capacity1 auditorium.auditorium_capacity%type) is select auditorium, auditorium_capacity from auditorium
    where auditorium_capacity >= capacity and auditorium_capacity <= capacity1 for update;
    aud auditorium.auditorium%type;
    cap auditorium.auditorium_capacity%type;
begin
    for aud_rec in curs_auditorium(40,80)
    loop
        aud := aud_rec.auditorium;
        cap := aud_rec.auditorium_capacity * 0.9;
        update auditorium set auditorium_capacity = cap
        where current of curs_auditorium;
        dbms_output.put_line('Аудитория ' || aud || ': новая вместимость ' || cap);
    end loop;
    rollback;
    exception
    when others
    then dbms_output.put_line(sqlcode||' '||sqlerrm);
end;

select auditorium_capacity from auditorium;