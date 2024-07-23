create table ZSS_t (
    x number(3) primary key,
    s varchar2(50)
);

insert into ZSS_t(x, s) values (1, 'Snezhana');
insert into ZSS_t(x, s) values (2, 'Liza');
insert into ZSS_t(x, s) values (3, 'Lera');
commit;
select * from ZSS_t;

update ZSS_t set x = 4, s = 'Nastya' where x = 2;
update ZSS_t set x = 5, s = 'Anya' where x = 3;
commit;
select * from ZSS_t;

select s from ZSS_t;
select avg(x) from ZSS_t;
select sum(x) from ZSS_t;
select min(x) from ZSS_t;
select max(x) from ZSS_t;
select count(*) from ZSS_t; 

delete ZSS_t where x = 1;
select * from ZSS_t;
rollback;

create table ZSS_t_child (
    id number(3),
    info varchar2(50),
    foreign key (id) references ZSS_t(x)
);

insert into ZSS_t_child(id, info) values (1, 'Belarus, Leonid Beda Street, 5, 20');
insert into ZSS_t_child(id, info) values (4, 'Belarus, Partizanskaya Street, 13, 65');
select * from ZSS_t_child;
commit;

select * from ZSS_t left join ZSS_t_child on ZSS_t.x = id;
select * from ZSS_t inner join ZSS_t_child on ZSS_t.x = id;

drop table ZSS_t_child;
drop table ZSS_t;