DROP SCHEMA IF EXISTS staging_umls CASCADE;

CREATE SCHEMA staging_umls;

create table staging_umls.MRCONSO
(
    CUI      char(8)      not null,
    LAT      char(3)      not null,
    TS       char         not null,
    LUI      varchar(10)  not null,
    STT      varchar(3)   not null,
    SUI      varchar(10)  not null,
    ISPREF   char         not null,
    AUI      varchar(9)   not null
        primary key,
    SAUI     varchar(50)  null,
    SCUI     varchar(100) null,
    SDUI     varchar(100) null,
    SAB      varchar(40)  not null,
    TTY      varchar(40)  not null,
    CODE     varchar(100) not null,
    STR      text         not null,
    SRL      int          not null,
    SUPPRESS char         not null,
    CVF      int          null
);

