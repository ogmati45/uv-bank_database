DROP DATABASE IF EXISTS UV_Bank_db;
CREATE DATABASE IF NOT EXISTS UV_Bank_db;
use UV_Bank_db;

CREATE TABLE Klienci (
    id_klienta INT PRIMARY KEY,
    imie VARCHAR(50),
    nazwisko VARCHAR(50),
    plec ENUM('K', 'M'),
    pesel CHAR(11),
    data_urodzenia DATE,
    adres_zamieszkania VARCHAR(100),
    email VARCHAR(100),
    telefon CHAR(9),
    status VARCHAR(15)
);

CREATE TABLE Konta (
    id_konta INT PRIMARY KEY,
    id_klienta INT,
    iban VARCHAR(2),
    numer_konta CHAR(26),
    data_otwarcia DATE,
    saldo DECIMAL(15,2),
    typ_konta VARCHAR(25),
    status VARCHAR(25),
    FOREIGN KEY (id_klienta) REFERENCES Klienci(id_klienta)
);

CREATE TABLE Konta_walutowe (
    id_konta_walutowego INT PRIMARY KEY,
    id_klienta INT,
    waluta VARCHAR(5),
    numer_konta CHAR(26),
    saldo DECIMAL(15,2),
    data_otwarcia DATE,
    status VARCHAR(25),
    FOREIGN KEY (id_klienta) REFERENCES Klienci(id_klienta)
);

CREATE TABLE Karty (
    id_karty INT PRIMARY KEY,
    id_konta INT,
    numer_karty CHAR(16),
    typ_karty VARCHAR(25),
    data_wydania DATE,
    data_waznosci DATE,
    cvv CHAR(4),
    limit_kredytowy INT,
    status VARCHAR(25),
    FOREIGN KEY (id_konta) REFERENCES Konta(id_konta)
);

CREATE TABLE Lokaty (
    id_lokaty INT PRIMARY KEY,
    id_klienta INT,
    kwota DECIMAL(15,2),
    oprocentowanie DECIMAL(4,2),
    data_rozpoczecia DATE,
    data_zakonczenia DATE,
    kapitalizacja VARCHAR(25),
    status VARCHAR(25),
    FOREIGN KEY (id_klienta) REFERENCES Klienci(id_klienta)
);

CREATE TABLE Pozyczki (
    id_pozyczki INT PRIMARY KEY,
    id_klienta INT,
    kwota_pozyczki DECIMAL(12,2),
    oprocentowanie DECIMAL(5,2),
    data_udzielenia DATE,
    okres_miesiecy INT,
    rata_miesieczna DECIMAL(12,2),
    saldo_pozostale DECIMAL(12,2),
    pozostalo_do_zaplaty DECIMAL(12,2),
    status VARCHAR(25),
    FOREIGN KEY (id_klienta) REFERENCES Klienci(id_klienta)
);

CREATE TABLE Pracownicy (
    id_pracownika INT PRIMARY KEY,
    imie VARCHAR(50),
    nazwisko VARCHAR(50),
    email_sluzbowy VARCHAR(100),
    plec VARCHAR(5),
    pesel CHAR(11),
    telefon_sluzbowy CHAR(9),
    stanowisko VARCHAR(30),
    dzial VARCHAR(30),
    data_urodzenia DATE,
    data_zatrudnienia DATE,
    status VARCHAR(25),
    haslo_hash CHAR(32),
    wynagrodzenie DECIMAL(10,2)
);

CREATE TABLE Transakcje (
    id_transakcji INT PRIMARY KEY,
    id_konta INT,
    data_transakcji DATE,
    kwota DECIMAL(15,2),
    waluta VARCHAR(5),
    typ_transakcji VARCHAR(25),
    odbiorca_nazwa VARCHAR(50),
    odbiorca_numer_konta CHAR(26),
    tytul VARCHAR(100),
    FOREIGN KEY (id_konta) REFERENCES Konta(id_konta)
);

CREATE TABLE Zlecenia_stale (
    id_zlecenia INT PRIMARY KEY,
    id_konta INT,
    odbiorca_nazwa VARCHAR(50),
    tytul VARCHAR(100),
    kwota DECIMAL(12,2),
    data_start DATE,
    data_koniec DATE,
    czestotliwosc VARCHAR(25),
    FOREIGN KEY (id_konta) REFERENCES Konta(id_konta)
);

CREATE TABLE Wnioski (
    id_wniosku INT PRIMARY KEY,
    id_klienta INT,
    typ_wniosku VARCHAR(35),
    data_zlozenia DATE,
    status VARCHAR(35),
    FOREIGN KEY (id_klienta) REFERENCES Klienci(id_klienta)
);


