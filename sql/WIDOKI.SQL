-- KLIENCI --

-- PŁEĆ W MIEŚCIE + UDZIAŁ (%)
CREATE OR REPLACE VIEW klienci_widok_plec_miasto_udzial AS
SELECT
  k.adres_zamieszkania AS miasto,
  SUM(k.plec = 'K') AS kobiety,
  ROUND(100 * SUM(k.plec = 'K') / NULLIF(COUNT(*), 0), 2) AS kobiety_pct_w_miescie,
  ROUND(100 * SUM(k.plec = 'K') / NULLIF(t.total, 0), 2)  AS kobiety_pct_ogolnie,
  SUM(k.plec = 'M') AS mezczyzni,
  ROUND(100 * SUM(k.plec = 'M') / NULLIF(COUNT(*), 0), 2) AS mezczyzni_pct_w_miescie,
  ROUND(100 * SUM(k.plec = 'M') / NULLIF(t.total, 0), 2)  AS mezczyzni_pct_ogolnie
FROM klienci k
CROSS JOIN (SELECT COUNT(*) AS total FROM klienci) t
GROUP BY k.adres_zamieszkania;

-- SNAPSHOT GRUP WIEKOWYCH
CREATE OR REPLACE VIEW klienci_widok_grupy_wiekowe AS
SELECT
  SUM(wiek < 18)                  AS lt_18,
  SUM(wiek BETWEEN 18 AND 24)     AS g_18_24,
  SUM(wiek BETWEEN 25 AND 34)     AS g_25_34,
  SUM(wiek BETWEEN 35 AND 44)     AS g_35_44,
  SUM(wiek BETWEEN 45 AND 54)     AS g_45_54,
  SUM(wiek BETWEEN 55 AND 64)     AS g_55_64,
  SUM(wiek >= 65)                 AS g_65_plus
FROM (
  SELECT TIMESTAMPDIFF(YEAR, data_urodzenia, CURDATE()) AS wiek
  FROM klienci
) x;


-- KONTA --


-- SUMA SALD PER KLIENT
CREATE OR REPLACE VIEW konta_widok_suma_sald_na_klienta AS
SELECT
  k.id_klienta,
  k.imie,
  k.nazwisko,
  k.pesel,
  SUM(a.saldo) AS suma_sald
FROM konta a
JOIN klienci k ON a.id_klienta = k.id_klienta
GROUP BY k.id_klienta, k.imie, k.nazwisko, k.pesel;

-- RANKING KLIENTÓW WG SALDA (SUMY)
CREATE OR REPLACE VIEW konta_ranking_suma_sald_klient AS
SELECT
  RANK() OVER (ORDER BY suma_sald DESC) AS ranking,
  id_klienta, imie, nazwisko, pesel, suma_sald
FROM (
  SELECT
    k.id_klienta, k.imie, k.nazwisko, k.pesel,
    SUM(a.saldo) AS suma_sald
  FROM konta a
  JOIN klienci k ON a.id_klienta = k.id_klienta
  GROUP BY k.id_klienta, k.imie, k.nazwisko, k.pesel
) s;

-- STATUS/TYP KONTA + UDZIAŁ GLBOALNY (%)
CREATE OR REPLACE VIEW konta_widok_status_typ_udzial AS
SELECT
  a.status,
  SUM(a.typ_konta = 'Osobiste')        AS osobiste,
  ROUND(100 * SUM(a.typ_konta = 'Osobiste')     / NULLIF(t.total, 0), 2) AS osobiste_pct,
  SUM(a.typ_konta = 'Emerytalne')      AS emerytalne,
  ROUND(100 * SUM(a.typ_konta = 'Emerytalne')   / NULLIF(t.total, 0), 2) AS emerytalne_pct,
  SUM(a.typ_konta = 'Firmowe')         AS firmowe,
  ROUND(100 * SUM(a.typ_konta = 'Firmowe')      / NULLIF(t.total, 0), 2) AS firmowe_pct,
  SUM(a.typ_konta = 'Studenckie')      AS studenckie,
  ROUND(100 * SUM(a.typ_konta = 'Studenckie')   / NULLIF(t.total, 0), 2) AS studenckie_pct,
  SUM(a.typ_konta = 'Mlodziezowe')     AS mlodziezowe,
  ROUND(100 * SUM(a.typ_konta = 'Mlodziezowe')  / NULLIF(t.total, 0), 2) AS mlodziezowe_pct,
  SUM(a.typ_konta = 'Oszczednosciowe') AS oszczednosciowe,
  ROUND(100 * SUM(a.typ_konta = 'Oszczednosciowe') / NULLIF(t.total, 0), 2) AS oszczednosciowe_pct
FROM konta a
CROSS JOIN (SELECT COUNT(id_konta) AS total FROM konta) t
GROUP BY a.status;


-- KARTY --


-- TYP KARTY + UDZIAŁ GLOBALNY (%)
CREATE OR REPLACE VIEW karty_widok_typ_udzial AS
SELECT
  typ_karty,
  COUNT(*) AS liczba_kart,
  ROUND(100 * COUNT(*) / NULLIF(t.total, 0), 2) AS udzial_pct
FROM karty
CROSS JOIN (SELECT COUNT(*) AS total FROM karty) t
GROUP BY typ_karty;


-- LOKATY --


-- STATYSTYKI ROCZNE LOKAT + UDZIAŁY GLOBALNE (%)
CREATE OR REPLACE VIEW lokaty_widok_rok_statystyki AS
SELECT
  YEAR(data_rozpoczecia)                           AS rok,
  COUNT(id_lokaty)                                 AS liczba_lokat,
  ROUND(AVG(oprocentowanie), 4)                    AS oprocentowanie_avg,
  ROUND(AVG(kwota), 2)                             AS kwota_avg,
  SUM(kwota)                                       AS kwota_suma,
  SUM(kapitalizacja = 'Roczna')                    AS roczna,
  SUM(kapitalizacja = 'Kwartalna')                 AS kwartalna,
  SUM(kapitalizacja = 'Miesieczna')                AS miesieczna,
  SUM(`status` = 'Aktywna')                        AS aktywna,
  ROUND(100 * SUM(`status` = 'Aktywna')    / NULLIF(t.total, 0), 2) AS aktywna_pct,
  SUM(`status` = 'Zakonczona')                     AS zakonczona,
  ROUND(100 * SUM(`status` = 'Zakonczona') / NULLIF(t.total, 0), 2) AS zakonczona_pct
FROM lokaty
CROSS JOIN (SELECT COUNT(id_lokaty) AS total FROM lokaty) t
GROUP BY YEAR(data_rozpoczecia);


-- POŻYCZKI --


-- STATYSTYKI WG STATUSU POŻYCZEK
CREATE OR REPLACE VIEW pozyczki_widok_status_statystyki AS
SELECT
  `status`,
  COUNT(id_pozyczki) AS liczba_pozyczek,
  ROUND(100 * COUNT(id_pozyczki) / NULLIF(t.total, 0), 2) AS udzial_pct,
  ROUND(AVG(kwota_pozyczki), 2) AS kwota_avg,
  SUM(kwota_pozyczki) AS kwota_suma,
  ROUND(AVG(oprocentowanie) * 100, 2) AS oprocentowanie_avg_pct,
  ROUND(AVG(okres_miesiecy), 2) AS okres_kredytowania_avg,
  ROUND(AVG(rata_miesieczna), 2) AS rata_miesieczna_avg,
  ROUND(AVG(saldo_pozostale), 2) AS saldo_pozostale_avg,
  SUM(saldo_pozostale) AS saldo_pozostale_suma,
  ROUND(AVG(pozostalo_do_zaplaty), 2)  AS pozostalo_do_zaplaty_avg,
  SUM(pozostalo_do_zaplaty) AS pozostalo_do_zaplaty_suma
FROM pozyczki
CROSS JOIN (SELECT COUNT(id_pozyczki) AS total FROM pozyczki) t
GROUP BY `status`;


-- TRANSAKCJE --


-- WALUTA TRANSAKCJI + UDZIAŁ + STATYSTYKI KWOT
CREATE OR REPLACE VIEW transakcje_widok_waluta_udzial AS
SELECT
  waluta,
  COUNT(id_transakcji) AS liczba_transakcji,
  ROUND(100 * COUNT(id_transakcji) / NULLIF(t.total, 0), 2) AS udzial_pct,
  ROUND(AVG(kwota), 2) AS kwota_avg,
  SUM(kwota) AS kwota_suma
FROM transakcje
CROSS JOIN (SELECT COUNT(id_transakcji) AS total FROM transakcje) t
GROUP BY waluta;

-- LICZBA I SUMA TRANSAKCJI NA KONTO
CREATE OR REPLACE VIEW transakcje_widok_liczba_na_konto AS
SELECT
  id_konta,
  COUNT(id_transakcji) AS liczba_transakcji,
  ROUND(AVG(kwota), 2) AS kwota_avg,
  SUM(kwota)           AS kwota_suma
FROM transakcje
GROUP BY id_konta;


-- ZLECENIA STAŁE --


-- CZĘSTOTLIWOŚĆ ZLECEŃ + UDZIAŁ GLOBALNY (%)
CREATE OR REPLACE VIEW zlecenia_stale_widok_czestotliwosc_udzial AS
SELECT
  czestotliwosc,
  COUNT(id_zlecenia)                                   AS liczba_zlecen,
  ROUND(100 * COUNT(id_zlecenia) / NULLIF(t.total, 0), 2) AS udzial_pct
FROM zlecenia_stale
CROSS JOIN (SELECT COUNT(id_zlecenia) AS total FROM zlecenia_stale) t
GROUP BY czestotliwosc;


-- WNIOSKI --


-- STATUS/TYP WNIOSKU + UDZIAŁY W RAMACH STATUSU
CREATE OR REPLACE VIEW wnioski_widok_status_typ_udzial AS
SELECT
  `status`,
  /* liczniki */
  SUM(typ_wniosku = 'inne')                  AS inne,
  SUM(typ_wniosku = 'zmiana_hasla')          AS zmiana_hasla,
  SUM(typ_wniosku = 'karta')                 AS karta,
  SUM(typ_wniosku = 'przeniesienie_konta')   AS przeniesienie_konta,
  SUM(typ_wniosku = 'modyfikacja_umowy')     AS modyfikacja_umowy,
  SUM(typ_wniosku = 'klauzula')              AS klauzula,
  SUM(typ_wniosku = 'odblokowanie_dostepu')  AS odblokowanie_dostepu,
  SUM(typ_wniosku = 'wydanie_zaswiadczenia') AS wydanie_zaswiadczenia,
  SUM(typ_wniosku = 'cesja_kredytu')         AS cesja_kredytu,
  SUM(typ_wniosku = 'aktualizacja_danych')   AS aktualizacja_danych,
  SUM(typ_wniosku = 'zawieszenie_splaty')    AS zawieszenie_splaty,
  SUM(typ_wniosku = 'limit')                 AS limit_,
  SUM(typ_wniosku = 'wyciag')                AS wyciag,
  SUM(typ_wniosku = 'reklamacja')            AS reklamacja,
  SUM(typ_wniosku = 'kredyt')                AS kredyt,
  SUM(typ_wniosku = 'raty')                  AS raty,
  SUM(typ_wniosku = 'wniosek_o_karencje')    AS wniosek_o_karencje,
  SUM(typ_wniosku = 'pozyczka')              AS pozyczka,
  SUM(typ_wniosku = 'zamkniecie_konta')      AS zamkniecie_konta,

  /* udziały w ramach statusu */
  ROUND(100 * SUM(typ_wniosku = 'inne')                  / COUNT(*), 2) AS inne_pct,
  ROUND(100 * SUM(typ_wniosku = 'zmiana_hasla')          / COUNT(*), 2) AS zmiana_hasla_pct,
  ROUND(100 * SUM(typ_wniosku = 'karta')                 / COUNT(*), 2) AS karta_pct,
  ROUND(100 * SUM(typ_wniosku = 'przeniesienie_konta')   / COUNT(*), 2) AS przeniesienie_konta_pct,
  ROUND(100 * SUM(typ_wniosku = 'modyfikacja_umowy')     / COUNT(*), 2) AS modyfikacja_umowy_pct,
  ROUND(100 * SUM(typ_wniosku = 'klauzula')              / COUNT(*), 2) AS klauzula_pct,
  ROUND(100 * SUM(typ_wniosku = 'odblokowanie_dostepu')  / COUNT(*), 2) AS odblokowanie_dostepu_pct,
  ROUND(100 * SUM(typ_wniosku = 'wydanie_zaswiadczenia') / COUNT(*), 2) AS wydanie_zaswiadczenia_pct,
  ROUND(100 * SUM(typ_wniosku = 'cesja_kredytu')         / COUNT(*), 2) AS cesja_kredytu_pct,
  ROUND(100 * SUM(typ_wniosku = 'aktualizacja_danych')   / COUNT(*), 2) AS aktualizacja_danych_pct,
  ROUND(100 * SUM(typ_wniosku = 'zawieszenie_splaty')    / COUNT(*), 2) AS zawieszenie_splaty_pct,
  ROUND(100 * SUM(typ_wniosku = 'limit')                 / COUNT(*), 2) AS limit_pct,
  ROUND(100 * SUM(typ_wniosku = 'wyciag')                / COUNT(*), 2) AS wyciag_pct,
  ROUND(100 * SUM(typ_wniosku = 'reklamacja')            / COUNT(*), 2) AS reklamacja_pct,
  ROUND(100 * SUM(typ_wniosku = 'kredyt')                / COUNT(*), 2) AS kredyt_pct,
  ROUND(100 * SUM(typ_wniosku = 'raty')                  / COUNT(*), 2) AS raty_pct,
  ROUND(100 * SUM(typ_wniosku = 'wniosek_o_karencje')    / COUNT(*), 2) AS wniosek_o_karencje_pct,
  ROUND(100 * SUM(typ_wniosku = 'pozyczka')              / COUNT(*), 2) AS pozyczka_pct,
  ROUND(100 * SUM(typ_wniosku = 'zamkniecie_konta')      / COUNT(*), 2) AS zamkniecie_konta_pct
FROM wnioski
GROUP BY `status`;
