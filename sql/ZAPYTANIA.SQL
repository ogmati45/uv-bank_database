--  KLIENCI --

-- LICZBA KLIENTÓW DANEJ PŁCI W MIEŚCIE + UDZIAŁ (%) W MIEŚCIE + UDZIAŁ (%) OGÓLNY
SELECT
  k.adres_zamieszkania,
  SUM(CASE WHEN k.plec = 'K' THEN 1 ELSE 0 END) AS `Kobiety`,
  CONCAT(ROUND(100 * SUM(CASE WHEN k.plec = 'K' THEN 1 ELSE 0 END) / COUNT(*), 2), ' %') AS `Udzial_k (%)`,
  CONCAT(ROUND(100 * SUM(CASE WHEN k.plec = 'K' THEN 1 ELSE 0 END) / t.total, 2), ' %') AS `Udzial_k_ogo (%)`,
  SUM(CASE WHEN k.plec = 'M' THEN 1 ELSE 0 END) AS `Mezczyzni`,
  CONCAT(ROUND(100 * SUM(CASE WHEN k.plec = 'M' THEN 1 ELSE 0 END) / COUNT(*), 2), ' %') AS `Udzial_m (%)`,
  CONCAT(ROUND(100 * SUM(CASE WHEN k.plec = 'M' THEN 1 ELSE 0 END) / t.total, 2), ' %') AS `Udzial_m_ogo (%)`
FROM klienci k
CROSS JOIN (SELECT COUNT(*) AS total FROM klienci) t
GROUP BY k.adres_zamieszkania
ORDER BY k.adres_zamieszkania;

-- DOMENY EMIAL KLIENTÓW
SELECT 
    SUBSTRING_INDEX(k.email, '@', -1) AS domena,
    COUNT(*) AS liczba,
    CONCAT(ROUND(100 * COUNT(*) / t.total, 2), ' %') AS udzial
FROM klienci k
CROSS JOIN (SELECT COUNT(*) AS total FROM klienci) t
GROUP BY domena, t.total
ORDER BY liczba DESC;

-- WIEK KLIENTÓW
SELECT 
    id_klienta,
    imie,
    nazwisko,
    pesel,
    email, 
    TIMESTAMPDIFF(YEAR, data_urodzenia, CURDATE()) AS `Wiek`
FROM klienci
ORDER BY Wiek ASC;

-- GRUPY WIEKOWE KLIENTÓW
SELECT
    COUNT(CASE WHEN `Wiek` < 18 THEN 1 ELSE 0 END) AS '< 18',
    COUNT(CASE WHEN `Wiek` >= 18 AND `Wiek` < 25 THEN 1 ELSE 0 END) AS '18-24',
    COUNT(CASE WHEN `Wiek` >= 25 AND `Wiek` < 35 THEN 1 ELSE 0 END) AS '25-34',
    COUNT(CASE WHEN `Wiek` >= 35 AND `Wiek` < 45 THEN 1 ELSE 0 END) AS '35-44',
    COUNT(CASE WHEN `Wiek` >= 45 AND `Wiek` < 55 THEN 1 ELSE 0 END) AS '45-54',
    COUNT(CASE WHEN `Wiek` >= 55 AND `Wiek` < 65 THEN 1 ELSE 0 END) AS '55-64',
    COUNT(CASE WHEN `Wiek` > 65 THEN 1 ELSE 0 END) AS '65+'
FROM (
    SELECT
        TIMESTAMPDIFF(YEAR, data_urodzenia, CURDATE()) AS `Wiek`
    FROM Klienci
) x;

-- GRUPOWANIE KLIENTÓW WG PŁCI + UDZIAŁ (%)
SELECT 
    plec, 
    COUNT(id_klienta) AS 'Liczba_klientow',
    CONCAT(ROUND(COUNT(id_klienta) / (SELECT COUNT(id_klienta) FROM Klienci) * 100, 2), ' %') AS 'Udzial (%)'
FROM klienci 
GROUP BY plec;

-- GRUPOWANIE KLIENTÓW WG ADRESU ZAMIESZKANIA (MIASTA) + UDZIAŁ (%)
SELECT
    adres_zamieszkania,
    COUNT(id_klienta) AS 'Liczba_klientow',
    CONCAT(ROUND(COUNT(id_klienta) / (SELECT COUNT(id_klienta) FROM klienci) * 100, 2), ' %') AS 'Udzial (%)'
FROM klienci
GROUP BY adres_zamieszkania;

-- LICZBA KLIENTÓW WG STATUSU KLIENTA + UDZIAŁ (%)
SELECT
    `status`,
    COUNT(id_klienta) AS 'Liczba_klientow',
    CONCAT(ROUND(COUNT(id_klienta) / (SELECT COUNT(id_klienta) FROM klienci) * 100, 2), ' %') AS 'Udzial (%)'
FROM klienci
GROUP BY `status`;


-- KONTA --


-- LICZBA KONT WG KLIENTA
SELECT
    x2.id_klienta,
    x2.Imie,
    x2.Nazwisko,
    x2.Pesel,
    COUNT(x1.id_konta) AS 'Liczba_kont'
FROM konta x1
JOIN klienci x2 ON x1.id_klienta = x2.id_klienta
GROUP BY x2.id_klienta, x2.Imie, x2.Nazwisko, x2.Pesel
ORDER BY COUNT(x1.id_konta) DESC;

-- SUMA SALD WG KLIENTA
SELECT
    x2.id_klienta,
    x2.Imie,
    x2.Nazwisko,
    x2.Pesel,
    SUM(x1.saldo) AS 'Suma_sald'
FROM konta x1
JOIN klienci x2 ON x1.id_klienta = x2.id_klienta
GROUP BY x2.id_klienta, x2.imie, x2.nazwisko, x2.pesel
ORDER BY SUM(x1.saldo) DESC;

-- TOP 10 NAJBOGATSZYCH OSOB (POJEDYNCZE KONTO)
SELECT 
    RANK() OVER (ORDER BY x1.saldo DESC) AS `Ranking`,
    x1.id_konta,
    x2.imie,
    x2.nazwisko,
    x2.pesel
FROM konta x1
JOIN klienci x2 ON x1.id_klienta = x2.id_klienta
ORDER BY x1.saldo DESC
LIMIT 10;

-- TOP 10 NAJBOGATSZYCH OSOB (WSZYSTKIE KONTA DANEGO KLIENTA)
SELECT
    RANK() OVER (ORDER BY SUM(x1.saldo) DESC) AS `Ranking`,
    SUM(x1.saldo) AS 'Suma_sald',
    x2.imie,
    x2.nazwisko,
    x2.pesel
FROM konta x1
JOIN klienci x2 ON x1.id_klienta = x2.id_klienta
GROUP BY x2.imie, x2.nazwisko, x2.pesel
ORDER BY SUM(x1.saldo) DESC
LIMIT 10;

-- LICZBA KONT WG STATUSU KONTA
SELECT 
    `status`,
    COUNT(id_konta) AS `Liczba_kont`
FROM konta
GROUP BY `status`;

-- LICZBA KONT WG TYPU KONTA
SELECT
    typ_konta,
    COUNT(id_konta) AS `Liczba_kont`
FROM konta
GROUP BY typ_konta;

-- LICZBA KONT WG STATUSU KONTA/TYPU KONTA
SELECT 
    k.status,
    SUM(CASE WHEN k.typ_konta = 'Osobiste' THEN 1 ELSE 0 END) AS `Osobiste`,
    CONCAT(ROUND(100 * SUM(CASE WHEN k.typ_konta = 'Osobiste' THEN 1 ELSE 0 END) / t.total, 2), ' %') AS `Udzial (%)`,
    SUM(CASE WHEN k.typ_konta = 'Emerytalne' THEN 1 ELSE 0 END) AS `Emerytalne`,
    CONCAT(ROUND(100 * SUM(CASE WHEN k.typ_konta = 'Emerytalne' THEN 1 ELSE 0 END) / t.total, 2), ' %') AS `Udzial (%)`,
    SUM(CASE WHEN k.typ_konta = 'Firmowe' THEN 1 ELSE 0 END) AS `Firmowe`,
    CONCAT(ROUND(100 * SUM(CASE WHEN k.typ_konta = 'Firmowe' THEN 1 ELSE 0 END) / t.total, 2), ' %') AS `Udzial (%)`,
    SUM(CASE WHEN k.typ_konta = 'Studenckie' THEN 1 ELSE 0 END) AS `Studencie`,
    CONCAT(ROUND(100 * SUM(CASE WHEN k.typ_konta = 'Studenckie' THEN 1 ELSE 0 END) / t.total, 2), ' %') AS `Udzial (%)`,
    SUM(CASE WHEN k.typ_konta = 'Mlodziezowe' THEN 1 ELSE 0 END) AS `Mlodziezowe`,
    CONCAT(ROUND(100 * SUM(CASE WHEN k.typ_konta = 'Mlodziezowe' THEN 1 ELSE 0 END) / t.total, 2), ' %') AS `Udzial (%)`,
    SUM(CASE WHEN k.typ_konta = 'Oszczednosciowe' THEN 1 ELSE 0 END) AS `Oszczednosciowe`,
    CONCAT(ROUND(100 * SUM(CASE WHEN k.typ_konta = 'Oszczednosciowe' THEN 1 ELSE 0 END) / t.total, 2), ' %') AS `Udzial (%)`
FROM konta k
CROSS JOIN (SELECT COUNT(id_konta) AS total FROM konta) t
GROUP BY k.status;

-- LICZBA KONT WG KLIENTA (PODZIAŁ NA STATUS)
SELECT
    x2.imie,
    x2.nazwisko,
    x2.pesel,
    COUNT(x1.id_konta) AS `Liczba_kont`,
    SUM(CASE WHEN x1.status = 'Aktywne' THEN 1 ELSE 0 END) AS `Aktywne`,
    SUM(CASE WHEN x1.status = 'Zablokowane' THEN 1 ELSE 0 END) AS `Zablokowane`,
    SUM(CASE WHEN x1.status = 'Zamkniete' THEN 1 ELSE 0 END) AS `Zamkniete`
FROM konta x1
JOIN klienci x2 ON x1.id_klienta = x2.id_klienta
GROUP BY x2.imie, x2.nazwisko, x2.pesel
ORDER BY COUNT(x1.id_konta) DESC;

-- LICZBA KONT WG KLIENTA (PODZIAL NA TYP KONTA)
SELECT
    x2.id_klienta,
    x2.imie,
    x2.nazwisko,
    x2.pesel
    COUNT(x1.id_konta) AS `Liczba_kont`,
    SUM(CASE WHEN x1.status = 'Osobiste' THEN 1 ELSE 0 END) AS `Osobiste`,
    SUM(CASE WHEN x1.status = 'Emerytalne' THEN 1 ELSE 0 END) AS `Emerytalne`,
    SUM(CASE WHEN x1.status = 'Firmowe' THEN 1 ELSE 0 END) AS `Firmowe`,
    SUM(CASE WHEN x1.status = 'Studenckie' THEN 1 ELSE 0 END) AS `Studenckie`,
    SUM(CASE WHEN x1.status = 'Mlodziezowe' THEN 1 ELSE 0 END) AS `Mlodziezowe`,
    SUM(CASE WHEN x1.status = 'Oszczednosciowe' THEN 1 ELSE 0 END) AS `Oszczednosciowe`
FROM konta x1
JOIN klienci x2 ON x1.id_klienta = x2.id_klienta
GROUP BY x2.id_klienta, x2.imie, x2.nazwisko, x2.pesel
ORDER BY COUNT(x1.id_konta) DESC;

-- LICZBA KONT WG IBANU
SELECT
    iban,
    COUNT(id_konta) AS `Liczba_kont`,
    CONCAT(ROUND(COUNT(id_konta) / (SELECT COUNT(id_konta) FROM konta) * 100, 2), ' %') AS 'Udzial (%)'
FROM konta
GROUP BY iban

-- KONTA POSORTOWANE WG DLUGOSCI ICH TRWANIA (TYLKO AKTYWNE I ZABLOKOWANE)
SELECT 
    x1.id_konta,
    x2.imie,
    x2.nazwisko,
    x2.pesel,
    TIMESTAMPDIFF(MONTH, x1.data_otwarcia, CURDATE()) AS `Miesiace`
FROM konta x1
JOIN klienci x2 ON x1.id_klienta = x2.id_klienta
ORDER BY TIMESTAMPDIFF(MONTH, x1.data_otwarcia, CURDATE()) DESC;


-- KONTA WALUTOWE --


-- LICZBA KONT WALUTOWYCH WG KLIENTA
SELECT 
    x2.id_klienta,
    x2.imie,
    x2.nazwisko,
    x2.pesel,
    COUNT(x1.id_konta_walutowego) AS `Liczba kont`
FROM konta_walutowe x1
JOIN klienci x2 ON x1.id_klienata = x2.id_klienta
GROUP BY x2.id_klienta, x2.imie, x2.nazwisko, x2.pesel
ORDER BY COUNT(x1.id_konta_walutowego) DESC

-- LICZBA KONT O DANEJ WALUCIE + UDZIAŁ (%)
SELECT 
    waluta,
    COUNT(id_konta_walutowego) AS `Liczba kont`,
    CONCAT(ROUND(COUNT(id_konta_walutowego) / (SELECT COUNT(id_konta_walutowego) FROM konta_walutowe) * 100, 2), ' %') AS `Udzial (%)`
FROM konta_walutowe
GROUP BY waluta

-- LICZBA KONT O DANYM STATUSIE + UDZIAŁ (%)
SELECT
    `status`
    COUNT(id_konta_walutowego) AS `Liczba kont`,
    CONCAT(ROUND(COUNT(id_konta_walutowego) / (SELECT COUNT(id_konta_walutowego) FROM konta_walutowe) * 100, 2), ' %') AS 'Udzial (%)'
FROM konta_walutowe
GROUP BY `status`

-- LICZBA KONT O DANYM STATUSIE / WALUTA + UDZIAŁ (%)
SELECT
    x1.status,
    SUM(CASE WHEN x1.waluta = 'SEK' THEN 1 ELSE 0 END) AS `SEK`,
    CONCAT(ROUND(SUM(CASE WHEN x1.waluta = 'SEK' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_SEK (%)`,
    SUM(CASE WHEN x1.waluta = 'USD' THEN 1 ELSE 0 END) AS `USD`,
    CONCAT(ROUND(SUM(CASE WHEN x1.waluta = 'USD' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_USD (%)`,
    SUM(CASE WHEN x1.waluta = 'GBP' THEN 1 ELSE 0 END) AS `GBP`,
    CONCAT(ROUND(SUM(CASE WHEN x1.waluta = 'GBP' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_GBP (%)`,
    SUM(CASE WHEN x1.waluta = 'DKK' THEN 1 ELSE 0 END) AS `DKK`,
    CONCAT(ROUND(SUM(CASE WHEN x1.waluta = 'DKK' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_DKK (%)`,
    SUM(CASE WHEN x1.waluta = 'JPY' THEN 1 ELSE 0 END) AS `JPY`,
    CONCAT(ROUND(SUM(CASE WHEN x1.waluta = 'JPY' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_JPY (%)`,
    SUM(CASE WHEN x1.waluta = 'EUR' THEN 1 ELSE 0 END) AS `EUR`,
    CONCAT(ROUND(SUM(CASE WHEN x1.waluta = 'EUR' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_EUR (%)`,
    SUM(CASE WHEN x1.waluta = 'NOK' THEN 1 ELSE 0 END) AS `NOK`,
    CONCAT(ROUND(SUM(CASE WHEN x1.waluta = 'NOK' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_NOK (%)`,
    SUM(CASE WHEN x1.waluta = 'CHF' THEN 1 ELSE 0 END) AS `CHF`,
    CONCAT(ROUND(SUM(CASE WHEN x1.waluta = 'CHF' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_CHF (%)`,
    SUM(CASE WHEN x1.waluta = 'CZK' THEN 1 ELSE 0 END) AS `CZK`,
    CONCAT(ROUND(SUM(CASE WHEN x1.waluta = 'CZK' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_CZK (%)`
FROM konta_walutowe x1
CROSS JOIN (SELECT COUNT(id_konta_walutowego) AS total FROM konta_walutowe) t
GROUP BY x1.status;

-- KONTA POSORTOWANE WG DLUGOSCI ICH TRWANIA (TYLKO AKTYWNE I ZABLOKOWANE)
SELECT 
    x1.id_konta_walutowego,
    x2.imie,
    x2.nazwisko,
    x2.pesel,
    TIMESTAMPDIFF(MONTH, x1.data_otwarcia, CURDATE()) AS `Miesiace`
FROM konta_walutowe x1
JOIN klienci x2 ON x1.id_klienta = x2.id_klienta
WHERE x1.status IN ('aktywne', 'zablokowane')
ORDER BY TIMESTAMPDIFF(MONTH, x1.data_otwarcia, CURDATE()) DESC;

-- SUMA SALD KONT WALUTOWYCH DLA KLIENTA
SELECT
    x2.imie,
    x2.nazwisko,
    x2.pesel,
    SUM(CASE WHEN x1.waluta = 'CZK' THEN 1 ELSE 0 END) AS `Liczba kont (CZK)`,
    SUM(CASE WHEN x1.waluta = 'CZK' THEN x1.saldo ELSE 0 END) AS `Suma (CZK)`,
    SUM(CASE WHEN x1.waluta = 'USD' THEN 1 ELSE 0 END) AS `Liczba kont (USD)`,
    SUM(CASE WHEN x1.waluta = 'USD' THEN x1.saldo ELSE 0 END) AS `Suma (USD)`,
    SUM(CASE WHEN x1.waluta = 'GBP' THEN 1 ELSE 0 END) AS `Liczba kont (GBP)`,
    SUM(CASE WHEN x1.waluta = 'GBP' THEN x1.saldo ELSE 0 END) AS `Suma (GBP)`,
    SUM(CASE WHEN x1.waluta = 'JPY' THEN 1 ELSE 0 END) AS `Liczba kont (JPY)`,
    SUM(CASE WHEN x1.waluta = 'JPY' THEN x1.saldo ELSE 0 END) AS `Suma (JPY)`,
    SUM(CASE WHEN x1.waluta = 'EUR' THEN 1 ELSE 0 END) AS `Liczba kont (EUR)`,
    SUM(CASE WHEN x1.waluta = 'EUR' THEN x1.saldo ELSE 0 END) AS `Suma (EUR)`,
    SUM(CASE WHEN x1.waluta = 'CHF' THEN 1 ELSE 0 END) AS `Liczba kont (CHF)`,
    SUM(CASE WHEN x1.waluta = 'CHF' THEN x1.saldo ELSE 0 END) AS `Suma (CHF)`,
    SUM(CASE WHEN x1.waluta = 'DKK' THEN 1 ELSE 0 END) AS `Liczba kont (DKK)`,
    SUM(CASE WHEN x1.waluta = 'DKK' THEN x1.saldo ELSE 0 END) AS `Suma (DKK)`,
    SUM(CASE WHEN x1.waluta = 'NOK' THEN 1 ELSE 0 END) AS `Liczba kont (NOK)`,
    SUM(CASE WHEN x1.waluta = 'NOK' THEN x1.saldo ELSE 0 END) AS `Suma (NOK)`,
    SUM(CASE WHEN x1.waluta = 'SEK' THEN 1 ELSE 0 END) AS `Liczba kont (SEK)`,
    SUM(CASE WHEN x1.waluta = 'SEK' THEN x1.saldo ELSE 0 END) AS `Suma (SEK)`
FROM konta_walutowe x1
JOIN klienci x2 ON x1.id_klienta = x2.id_klienta
GROUP BY x2.imie, x2.nazwisko, x2.pesel


-- KARTY --


-- LICZBA KART NA DANEGO KLIENTA
SELECT
    x3.id_klienta,
    x3.imie,
    x3.nazwisko,
    x3.pesel,
    COUNT(x1.id_karty) AS `Liczba kart`
FROM karty x1
JOIN konta x2 ON x1.id_konta = x2.id_konta
JOIN klienci x3 ON x2.id_klienta = x3.id_klienta
GROUP BY x3.id_klienta, x3.imie, x3.nazwisko, x3.pesel
ORDER BY COUNT(x1.id_karty) DESC;

-- LICZBA KART WG TYPU KARTY + UDZIAŁ (%)
SELECT
    typ_karty,
    COUNT(id_karty) AS `Liczba kart`,
    CONCAT(ROUND(COUNT(id_karty) / (SELECT COUNT(id_karty) FROM karty) * 100, 2), ' %') AS `Udzial (%)`
FROM karty
GROUP BY typ_karty;

-- LICZBA KART WG STATUSU KARTY + UDZIAŁ (%)
SELECT
    `status`,
    COUNT(id_karty) AS `Liczba kart`,
    CONCAT(ROUND(COUNT(id_karty) / (SELECT COUNT(id_karty) FROM karty) * 100, 2), ' %') AS `Udzial (%)`
FROM karty
GROUP BY `status`;

-- LICZBA KART WG STATUSU/TYP KARTY + UDZIAŁ (%)
SELECT
    `status`,
    SUM(CASE WHEN typ_karty = 'Debetowa' THEN 1 ELSE 0 END) AS `Debetowa`,
    CONCAT(ROUND(SUM(CASE WHEN typ_karty = 'Debetowa' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_deb (%)`,
    SUM(CASE WHEN typ_karty = 'Kredytowa' THEN 1 ELSE 0 END) AS `Kredytowa`,
    CONCAT(ROUND(SUM(CASE WHEN typ_karty = 'Kredytowa' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_kre (%)`,
    SUM(CASE WHEN typ_karty = 'Przedplacona' THEN 1 ELSE 0 END) AS `Przedplacona`,
    CONCAT(ROUND(SUM(CASE WHEN typ_karty = 'Przedplacona' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_prze (%)`,
    SUM(CASE WHEN typ_karty = 'Wirtualna' THEN 1 ELSE 0 END) AS `Wirtualna`,
    CONCAT(ROUND(SUM(CASE WHEN typ_karty = 'Wirtualna' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_wir (%)`
FROM karty
CROSS JOIN (SELECT COUNT(id_karty) AS total FROM karty) t
GROUP BY `status`;

-- LIMITY KREDYTOWE I LICZBA KART + UDZIAŁ (%)
SELECT
    IFNULL(limit_kredytowy, 'Brak limitu') AS limit_kredytowy,
    COUNT(id_karty) AS `Liczba kart`,
    CONCAT(ROUND(COUNT(id_karty) / (SELECT COUNT(id_karty) FROM karty) * 100, 2), ' %') AS `Udzial (%)`
FROM karty
GROUP BY limit_kredytowy;

-- NAJCZĘŚCIEJ WYSTĘPUJĄCE CVV
SELECT
    RANK() OVER (ORDER BY `Liczba_wystapien` DESC) AS `Ranking`,
    cvv,
    `Liczba_wystapien`
FROM (
    SELECT
        cvv,
        COUNT(id_karty) AS `Liczba_wystapien`
    FROM karty
    GROUP BY cvv
) AS subquery
ORDER BY `Liczba_wystapien` DESC;

-- LICZBA WYDANYCH KART - LATA + UDZIAŁ (%)
SELECT
    YEAR(data_wydania) AS `ROK`,
    COUNT(id_karty) AS `Liczba_kart`,
    CONCAT(ROUND(COUNT(id_karty) / (SELECT COUNT(id_karty) FROM karty) * 100, 2), ' %') AS `Udzial (%)`
FROM karty
GROUP BY YEAR(data_wydania)
ORDER BY YEAR(data_wydania) ASC;

-- TOP 10 NAJSTARSZE KARTY
SELECT
    id_karty,
    id_konta,
    numer_karty,
    typ_karty,
    data_wydania,
    `status`,
    TIMESTAMPDIFF(MONTH, data_wydania, CURDATE()) AS `Miesiace`
FROM karty
ORDER BY TIMESTAMPDIFF(MONTH, data_wydania, CURDATE()) DESC
LIMIT 10;


-- LOKATY --


-- OGOLNE INFORMACJE
SELECT
    YEAR(data_rozpoczecia) AS `Rok`,
    COUNT(id_lokaty) `Liczba lokat`,
    AVG(oprocentowanie) `Oprocentowanie (AVG)`,
    AVG(kwota) `Kwota (AVG)`,
    SUM(kwota) `Kwota (SUMA)`,
    SUM(CASE WHEN kapitalizacja = 'Roczna' THEN 1 ELSE 0 END) AS `Roczna`,
    SUM(CASE WHEN kapitalizacja = 'Kwartalna' THEN 1 ELSE 0 END) AS `Kwartalna`,
    SUM(CASE WHEN kapitalizacja = 'Miesieczna' THEN 1 ELSE 0 END) AS `Miesieczna`,
    SUM(CASE WHEN status = 'Aktywna' THEN 1 ELSE 0 END) AS `Aktywna`,
    CONCAT(ROUND(SUM(CASE WHEN status = 'Aktywna' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_akt (%)`,
    SUM(CASE WHEN status = 'Zakonczona' THEN 1 ELSE 0 END) AS `Zakonczona`,
    CONCAT(ROUND(SUM(CASE WHEN status = 'Zakonczona' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_zak (%)`
FROM lokaty
CROSS JOIN (SELECT COUNT(id_lokaty) AS total FROM lokaty) t
GROUP BY YEAR(data_rozpoczecia)
ORDER BY YEAR(data_rozpoczecia) ASC

-- LICZBA LOKAT DLA DANEGO KLIENTA
SELECT
    x2.id_klienta,
    x2.imie,
    x2.nazwisko,
    x2.pesel,
    COUNT(x1.id_lokaty) AS `Liczba lokat`
FROM lokaty x1
JOIN klienci x2 ON x1.id_klienta = x2.id_klienta
GROUP BY x2.id_klienta, x2.imie, x2.nazwisko, x2.pesel
ORDER BY `Liczba lokat` DESC;

-- LICZBA LOKAT WG KAPITALIZACJI + UDZIAŁ (%)
SELECT
    kapitalizacja,
    COUNT(id_lokaty) AS `Liczba lokat`,
    CONCAT(ROUND(COUNT(id_lokaty) / (SELECT COUNT(id_lokaty) FROM lokaty) * 100, 2), ' %') AS `Udzial (%)`
FROM lokaty
GROUP BY kapitalizacja;

-- LICZBA LOKAT WG STATUSU/KAPITALIZACJI + UDZIAŁ (%)
SELECT
    `status`,
    SUM(CASE WHEN kapitalizacja = 'Roczna' THEN 1 ELSE 0 END) AS `Roczna`,
    CONCAT(ROUND(SUM(CASE WHEN kapitalizacja = 'Roczna' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_roc (%)`,
    SUM(CASE WHEN kapitalizacja = 'Kwartalna' THEN 1 ELSE 0 END) AS `Kwartalna`,
    CONCAT(ROUND(SUM(CASE WHEN kapitalizacja = 'Kwartalna' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_kwr (%)`,
    SUM(CASE WHEN kapitalizacja = 'Miesieczna' THEN 1 ELSE 0 END) AS `Miesieczna`,
    CONCAT(ROUND(SUM(CASE WHEN kapitalizacja = 'Miesieczna' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_mie (%)`,
FROM lokaty
CROSS JOIN (SELECT COUNT(id_lokaty) AS total FROM lokaty) t
GROUP BY `status`;


-- PRACOWNICY --


-- INFORMACJE O DZIALE
SELECT
    dzial,
    COUNT(id_pracownika) AS `Liczba_pracownikow`,
    CONCAT(ROUND(COUNT(id_pracownika) / (SELECT COUNT(id_pracownika) FROM pracownicy) * 100, 2), ' %') AS `Udzial (%)`,
    SUM(CASE WHEN plec = 'K' THEN 1 ELSE 0 END) AS `Kobiety`,
    CONCAT(ROUND(SUM(CASE WHEN plec = 'K' THEN 1 ELSE 0 END) / COUNT(id_pracownika) * 100, 2), ' %') AS `Udzial_kob (%)`,
    SUM(CASE WHEN plec = 'M' THEN 1 ELSE 0 END) AS `Mezczyzni`,
    CONCAT(ROUND(SUM(CASE WHEN plec = 'M' THEN 1 ELSE 0 END) / COUNT(id_pracownika) * 100, 2), ' %') AS `Udzial_mez (%)`,
    AVG(wynagrodzenie) AS `Wynagrodzenie (AVG)`,
    SUM(wynagrodzenie) AS `Wynagrodzenie (SUMA)`
FROM pracownicy
GROUP BY dzial

-- INFORMACJE WG STATUSU ZATRUDNIENIA
SELECT
    `status`,
    COUNT(id_pracownika) AS `Liczba_pracownikow`,
    CONCAT(ROUND(COUNT(id_pracownika) / (SELECT COUNT(id_pracownika) FROM pracownicy) * 100, 2), ' %') AS `Udzial (%)`,
    SUM(CASE WHEN plec = 'K' THEN 1 ELSE 0 END) AS `Kobiety`,
    CONCAT(ROUND(SUM(CASE WHEN plec = 'K' THEN 1 ELSE 0 END) / COUNT(id_pracownika) * 100, 2), ' %') AS `Udzial_kob (%)`,
    SUM(CASE WHEN plec = 'M' THEN 1 ELSE 0 END) AS `Mezczyzni`,
    CONCAT(ROUND(SUM(CASE WHEN plec = 'M' THEN 1 ELSE 0 END) / COUNT(id_pracownika) * 100, 2), ' %') AS `Udzial_mez (%)`,
    SUM(CASE WHEN stanowisko = 'Prezes' THEN 1 ELSE 0 END) AS `Prezes`,
    CONCAT(ROUND(SUM(CASE WHEN stanowisko = 'Prezes' THEN 1 ELSE 0 END) / COUNT(id_pracownika) * 100, 2), ' %') AS `Udzial_pre (%)`,    
    SUM(CASE WHEN stanowisko = 'Doradca' THEN 1 ELSE 0 END) AS `Doradca`,
    CONCAT(ROUND(SUM(CASE WHEN stanowisko = 'Doradca' THEN 1 ELSE 0 END) / COUNT(id_pracownika) * 100, 2), ' %') AS `Udzial_dor (%)`,
    SUM(CASE WHEN stanowisko = 'Specjalista' THEN 1 ELSE 0 END) AS `Specjalista`,
    CONCAT(ROUND(SUM(CASE WHEN stanowisko = 'Specjalista' THEN 1 ELSE 0 END) / COUNT(id_pracownika) * 100, 2), ' %') AS `Udzial_spe (%)`,
    SUM(CASE WHEN stanowisko = 'Informatyk' THEN 1 ELSE 0 END) AS `Informatyk`,
    CONCAT(ROUND(SUM(CASE WHEN stanowisko = 'Informatyk' THEN 1 ELSE 0 END) / COUNT(id_pracownika) * 100, 2), ' %') AS `Udzial_inf (%)`,
    SUM(CASE WHEN stanowisko = 'Menedzer' THEN 1 ELSE 0 END) AS `Menedzer`,
    CONCAT(ROUND(SUM(CASE WHEN stanowisko = 'Menedzer' THEN 1 ELSE 0 END) / COUNT(id_pracownika) * 100, 2), ' %') AS `Udzial_men (%)`,
    SUM(CASE WHEN stanowisko = 'Analityk' THEN 1 ELSE 0 END) AS `Analityk`,
    CONCAT(ROUND(SUM(CASE WHEN stanowisko = 'Analityk' THEN 1 ELSE 0 END) / COUNT(id_pracownika) * 100, 2), ' %') AS `Udzial_ana (%)`,
    SUM(CASE WHEN stanowisko = 'Kasjer' THEN 1 ELSE 0 END) AS `Kasjer`,
    CONCAT(ROUND(SUM(CASE WHEN stanowisko = 'Kasjer' THEN 1 ELSE 0 END) / COUNT(id_pracownika) * 100, 2), ' %') AS `Udzial_kas (%)`,
    AVG(wynagrodzenie) AS `Wynagrodzenie (AVG)`,
    SUM(wynagrodzenie) AS `Wynagrodzenie (SUMA)`
FROM pracownicy
GROUP BY `status`;

-- WYNAGRODZNEIE WG PLCI --
SELECT
    plec,
    AVG(wynagrodzenie) AS `Wynagrodzenie (AVG)`,
    SUM(wynagrodzenie) AS `Wynagrodzenie (SUMA)`
FROM pracownicy
WHERE `status` IN ('aktywny', 'zawieszony')
GROUP BY plec;

-- RANKING WYNAGRODZENIA
SELECT
    RANK() OVER (ORDER BY wynagrodzenie DESC) AS `Ranking`,
    Imie,
    Nazwisko,
    Pesel,
    Dzial,
    Stanowisko,
    Wynagrodzenie
FROM pracownicy
ORDER BY wynagrodzenie DESC;

-- NAJSTARSI PRACOWNICY
SELECT
    id_pracownika,
    imie,
    nazwisko,
    email_sluzbowy,
    data_urodzenia,
    TIMESTAMPDIFF(YEAR, data_urodzenia, CURDATE()) AS `Wiek_pracownikow`
FROM pracownicy
WHERE `status` IN ('aktywny', 'zawieszony')
ORDER BY data_urodzenia ASC;

-- INFORMACJE O STANOWISKACH + UDZIAŁ (%)
SELECT
    stanowisko,
    COUNT(id_pracownika) AS `Liczba_pracownikow`,
    CONCAT(ROUND(COUNT(id_pracownika) / (SELECT COUNT(id_pracownika) FROM pracownicy) * 100, 2), ' %') AS `Udzial (%)`,
    SUM(CASE WHEN plec = 'K' THEN 1 ELSE 0 END) AS `Kobiety`,
    CONCAT(ROUND(SUM(CASE WHEN plec = 'K' THEN 1 ELSE 0 END) / COUNT(id_pracownika) * 100, 2), ' %') AS `Udzial_kob (%)`,
    SUM(CASE WHEN plec = 'M' THEN 1 ELSE 0 END) AS `Mezczyzni`,
    CONCAT(ROUND(SUM(CASE WHEN plec = 'M' THEN 1 ELSE 0 END) / COUNT(id_pracownika) * 100, 2), ' %') AS `Udzial_mez (%)`,
    AVG(wynagrodzenie) AS `Wynagrodzenie (AVG)`,
    SUM(wynagrodzenie) AS `Wynagrodzenie (SUMA)`
FROM pracownicy
WHERE `status` IN ('aktywny', 'zawieszony')
GROUP BY stanowisko;

-- NAJWCZEŚNIEJ ZATRUDNIENI PRACOWNICY
SELECT
    id_pracownika,
    imie,
    nazwisko,
    email_sluzbowy,
    data_zatrudnienia,
    TIMESTAMPDIFF(MONTH, data_zatrudnienia, CURDATE()) AS `Miesiace_zatrudnienia`
FROM pracownicy
WHERE `status` IN ('aktywny', 'zawieszony')
ORDER BY data_zatrudnienia ASC;


-- POŻYCZKI --


-- LICZBA POŻYCZEK DLA DANEGO KLIENTA
SELECT
    x2.id_klienta,
    x2.imie,
    x2.nazwisko,
    x2.pesel,
    COUNT(x1.id_pozyczki) AS `Liczba_pozyczek`
FROM pozyczki x1
JOIN klienci x2 ON x1.id_klienta = x2.id_klienta
GROUP BY x2.id_klienta, x2.imie, x2.nazwisko, x2.pesel
ORDER BY COUNT(x1.id_pozyczki) DESC;

-- LICZBA UDZIELONYCH POŻYCZEK W ROKU + UDZIAŁ (%)
SELECT
    YEAR(data_udzielenia) AS `Rok`,
    COUNT(id_pozyczki) AS `Liczba_pozyczek`,
    CONCAT(ROUND(COUNT(id_pozyczki) / (SELECT COUNT(id_pozyczki) FROM pozyczki) * 100, 2), ' %') AS `Udzial (%)`
FROM pozyczki
GROUP BY YEAR(data_udzielenia)
ORDER BY YEAR(data_udzielenia) ASC;

-- OGOLNE INFORMAJCE O POZYCZKACH + UDZIAŁ (%)
SELECT
    `status`,
    COUNT(id_pozyczki) AS `Liczba_pozyczek`,
    CONCAT(ROUND(COUNT(id_pozyczki) / (SELECT COUNT(id_pozyczki) FROM pozyczki) * 100, 2), ' %') AS `Udzial (%)`,
    AVG(kwota_pozyczki) AS `Kwota_pozyczki (AVG)`,
    SUM(kwota_pozyczki) AS `Kwota_pozyczki (SUMA)`,
    ROUND(AVG(oprocentowanie) * 100, 2) AS `Oprocentowanie (AVG)`,
    AVG(okres_miesiecy) AS `Okres_kredytowania (AVG)`,
    AVG(rata_miesieczna) AS `Rata_miesieczna (AVG)`,
    AVG(saldo_pozostale) AS `Saldo_pozostale (AVG)`,
    SUM(saldo_pozostale) AS `Saldo_pozostale (SUMA)`,
    AVG(pozostalo_do_zaplaty) AS `Pozostalo_do_zaplaty (AVG)`,
    SUM(Pozostalo_do_zaplaty) AS `Pozostalo_do_zaplaty (SUMA)`
FROM pozyczki
GROUP BY `status`;


-- TRANSAKCJE --


-- LICZBA TRANSAKCJI
SELECT
    id_konta,
    COUNT(id_transakcji) AS `Liczba_transakcji`,
    AVG(kwota) AS `Kwota (AVG)`,
    SUM(kwota) AS `Kwota (SUMA)`
FROM transakcje
GROUP BY id_konta
ORDER BY COUNT(id_transakcji) DESC;

-- LICZBA TRANSKACJI W DANEJ WALUCIE + UDZIAŁ (%)
SELECT
    waluta,
    COUNT(id_transakcji) AS `Liczba_transakcji`,
    CONCAT(ROUND(COUNT(id_transakcji) / (SELECT COUNT(id_transakcji) FROM transakcje) * 100, 2), ' %') AS `Udzial (%)`,
    AVG(kwota) AS `Kwota_transakcji (AVG)`,
    SUM(kwota) AS `Kwota_transakcji (SUMA)`
FROM transakcje
GROUP BY waluta;

-- LICZBA TRANSAKCJI WG DATY TRANSAKCJI/WALUTY TRANSAKCJI + UDZIAŁ (%)
SELECT
    YEAR(data_transakcji) AS `Rok`,
    COUNT(id_transakcji) AS `Liczba_transkacji`,
    CONCAT(ROUND(COUNT(id_transakcji) / (SELECT COUNT(id_transakcji) FROM transakcje) * 100, 2), ' %') AS `Udzial (%)`,
    AVG(kwota) AS `Kwota_transakcji (AVG)`,
    SUM(kwota) AS `Kwota_transakcji (SUMA)`,
    SUM(CASE WHEN waluta = 'SEK' THEN 1 ELSE 0 END) AS `SEK`,
    CONCAT(ROUND(SUM(CASE WHEN waluta = 'SEK' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_SEK (%)`,
    SUM(CASE WHEN waluta = 'USD' THEN 1 ELSE 0 END) AS `USD`,
    CONCAT(ROUND(SUM(CASE WHEN waluta = 'USD' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_USD (%)`,
    SUM(CASE WHEN waluta = 'GBP' THEN 1 ELSE 0 END) AS `GBP`,
    CONCAT(ROUND(SUM(CASE WHEN waluta = 'GBP' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_GBP (%)`,
    SUM(CASE WHEN waluta = 'DKK' THEN 1 ELSE 0 END) AS `DKK`,
    CONCAT(ROUND(SUM(CASE WHEN waluta = 'DKK' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_DKK (%)`,
    SUM(CASE WHEN waluta = 'JPY' THEN 1 ELSE 0 END) AS `JPY`,
    CONCAT(ROUND(SUM(CASE WHEN waluta = 'JPY' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_JPY (%)`,
    SUM(CASE WHEN waluta = 'EUR' THEN 1 ELSE 0 END) AS `EUR`,
    CONCAT(ROUND(SUM(CASE WHEN waluta = 'EUR' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_EUR (%)`,
    SUM(CASE WHEN waluta = 'NOK' THEN 1 ELSE 0 END) AS `NOK`,
    CONCAT(ROUND(SUM(CASE WHEN waluta = 'NOK' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_NOK (%)`,
    SUM(CASE WHEN waluta = 'CHF' THEN 1 ELSE 0 END) AS `CHF`,
    CONCAT(ROUND(SUM(CASE WHEN waluta = 'CHF' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_CHF (%)`,
    SUM(CASE WHEN waluta = 'CZK' THEN 1 ELSE 0 END) AS `CZK`,
    CONCAT(ROUND(SUM(CASE WHEN waluta = 'CZK' THEN 1 ELSE 0 END) / t.total * 100, 2), ' %') AS `Udzial_CZK (%)`
FROM transakcje
CROSS JOIN (SELECT COUNT(id_transakcji) AS total FROM transakcje) t
GROUP BY YEAR(data_transakcji);

-- LICZBA TRANSAKCJI W DANYM ROKU + UDZIAŁ (%)
SELECT
    YEAR(data_transakcji) AS `Rok`,
    COUNT(id_transakcji) AS `Liczba_transkacji`,
    CONCAT(ROUND(COUNT(id_transakcji) / (SELECT COUNT(id_transakcji) FROM transakcje) * 100, 2), ' %') AS `Udzial (%)`,
    AVG(kwota) AS `Kwota_transakcji (AVG)`,
    SUM(kwota) AS `Kwota_transakcji (SUMA)`
FROM transakcje
GROUP BY YEAR(data_transakcji)
ORDER BY YEAR(data_transakcji) ASC;

-- LICZBA TRANSAKCJI WG TYPU TRANSAKCJI + UDZIAŁ (%)
SELECT
    typ_transakcji,
    COUNT(id_transakcji) AS `Liczba_transakcji`,
    CONCAT(ROUND(COUNT(id_transakcji) / (SELECT COUNT(id_transakcji) FROM transakcje) * 100, 2), ' %') AS `Udzial (%)`,
    AVG(kwota) AS `Kwota_transakcji (AVG)`,
    SUM(kwota) AS `Kwota_transakcji (SUMA)`
FROM transakcje
GROUP BY typ_transakcji;

-- LICZBA TRANSAKCJI WG TYTULU + UDZIAŁ (%)
SELECT
    tytul,
    COUNT(id_transakcji) AS `Liczba_transakcji`,
    CONCAT(ROUND(COUNT(id_transakcji) / (SELECT COUNT(id_transakcji) FROM transakcje) * 100, 2), ' %') AS `Udzial (%)`,
    AVG(kwota) AS `Kwota_transakcji (AVG)`,
    SUM(kwota) AS `Kwota_transakcji (SUMA)`
FROM transakcje
GROUP BY tytul;
    

-- ZLECENIE STALE -- 


-- LICZBA ZLECEN DLA DANEGO KONTA
SELECT
    x3.id_klienta,
    x3.imie,
    x3.nazwisko,
    x3.pesel,
    COUNT(x1.id_zlecenia) AS `Liczba_zlecen`
FROM zlecenia_stale x1
JOIN konta x2 ON x1.id_konta = x2.id_konta
JOIN klienci x3 ON x2.id_klienta = x3.id_klienta
GROUP BY x3.id_klienta, x3.imie, x3.nazwisko, x3.pesel
ORDER BY COUNT(x1.id_zlecenia) DESC;

-- LICZBA ZLECEN WEDLUG CZESTOTLIWOSCI + UDZIAŁ (%)
SELECT
    czestotliwosc,
    COUNT(id_zlecenia) AS `Liczba_zlecen`,
    CONCAT(ROUND(COUNT(id_zlecenia) / (SELECT COUNT(id_zlecenia) FROM zlecenia_stale) * 100, 2), ' %') AS `Udzial (%)`
FROM zlecenia_stale
GROUP BY czestotliwosc;

-- LICZBA ZLECEN WEDLUG TYTULU/CZESTOTLIWOSCI + UDZIAŁ (%)
SELECT
    tytul,
    COUNT(id_zlecenia) AS `Liczba_zlecen`,
    CONCAT(ROUND(COUNT(id_zlecenia) / (SELECT COUNT(id_zlecenia) FROM zlecenia_stale) * 100, 2), ' %') AS `Udzial (%)`,
    AVG(kwota) AS `Kwota (AVG)`,
    SUM(kwota) AS `Kwota (SUMA)`,
    SUM(CASE WHEN czestotliwosc = 'tygodniowa' THEN 1 ELSE 0 END) as `Tygodniowa`,
    SUM(CASE WHEN czestotliwosc = 'miesieczna' THEN 1 ELSE 0 END) as `Miesieczna`,
    SUM(CASE WHEN czestotliwosc = 'kwartalna' THEN 1 ELSE 0 END) as `Kwartalna`,
    SUM(CASE WHEN czestotliwosc = 'roczna' THEN 1 ELSE 0 END) as `Roczna`
FROM zlecenia_stale
GROUP BY tytul
ORDER BY COUNT(id_zlecenia) DESC;

-- LICZBA ZLECEŃ STAŁYCH WG DATY STARTU
SELECT
    YEAR(data_start) AS `Rok`,
    COUNT(id_zlecenia) AS `Liczba_zlecen`,
    CONCAT(ROUND(COUNT(id_zlecenia) / (SELECT COUNT(id_zlecenia) FROM zlecenia_stale) * 100, 2), ' %') AS `Udzial (%)`
FROM zlecenia_stale
GROUP BY YEAR(data_start)
ORDER BY YEAR(data_start) ASC;

-- NAJSTARSZE ZLECENIA STAŁE (W MIESIĄCACH)
SELECT
    id_zlecenia,
    id_konta,
    odbiorca_nazwa,
    tytul,
    kwota,
    data_start,
    data_koniec,
    czestotliwosc,
    TIMESTAMPDIFF(MONTH, data_start, CURDATE()) AS `Miesiace`
FROM zlecenia_stale
ORDER BY TIMESTAMPDIFF(MONTH, data_start, CURDATE()) DESC;
     

-- WNIOSKI --


-- LICZBA WNIOSKÓW DLA DANEGO KLIENTA
SELECT
    x2.id_klienta,
    x2.imie,
    x2.nazwisko,
    x2.pesel,
    COUNT(x1.id_wniosku) AS `Liczba_wnioskow`
FROM wnioski x1
JOIN klienci x2 ON x1.id_klienta = x2.id_klienta
GROUP BY x2.id_klienta, x2.imie, x2.nazwisko, x2.pesel
ORDER BY COUNT(x1.wniosku) DESC;

-- LICZBA WNIOSKÓW WG LAT + UDZIAŁ (%)
SELECT
    YEAR(data_zlozenia) AS `Rok`,
    COUNT(id_wniosku) AS `Liczba_wnioskow`,
    CONCAT(ROUND(COUNT(id_wniosku) / (SELECT COUNT(id_wniosku) FROM pozyczki) * 100, 2), ' %') AS `Udzial (%)`
FROM wnioski
GROUP BY YEAR(data_zlozenia)
ORDER BY YEAR(data_zlozenia) ASC

-- WNIOSKI WG STATUSU / TYP_WNIOSKU (liczba + udział % w ramach statusu)
SELECT
  `status`,
  SUM(typ_wniosku = 'inne') AS `inne`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'inne') / COUNT(id_wniosku), 2), ' %') AS `Udzial_inne (%)`,
  SUM(typ_wniosku = 'zmiana_hasla') AS `zmiana_hasla`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'zmiana_hasla') / COUNT(id_wniosku), 2), ' %') AS `Udzial_zmiana_hasla (%)`,
  SUM(typ_wniosku = 'karta') AS `karta`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'karta') / COUNT(id_wniosku), 2), ' %') AS `Udzial_karta (%)`,
  SUM(typ_wniosku = 'przeniesienie_konta') AS `przeniesienie_konta`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'przeniesienie_konta') / COUNT(id_wniosku), 2), ' %') AS `Udzial_przeniesienie_konta (%)`,
  SUM(typ_wniosku = 'modyfikacja_umowy') AS `modyfikacja_umowy`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'modyfikacja_umowy') / COUNT(id_wniosku), 2), ' %') AS `Udzial_modyfikacja_umowy (%)`,
  SUM(typ_wniosku = 'klauzula') AS `klauzula`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'klauzula') / COUNT(id_wniosku), 2), ' %') AS `Udzial_klauzula (%)`,
  SUM(typ_wniosku = 'odblokowanie_dostepu') AS `odblokowanie_dostepu`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'odblokowanie_dostepu') / COUNT(id_wniosku), 2), ' %') AS `Udzial_odblokowanie_dostepu (%)`,
  SUM(typ_wniosku = 'wydanie_zaswiadczenia') AS `wydanie_zaswiadczenia`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'wydanie_zaswiadczenia') / COUNT(id_wniosku), 2), ' %') AS `Udzial_wydanie_zaswiadczenia (%)`,
  SUM(typ_wniosku = 'cesja_kredytu') AS `cesja_kredytu`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'cesja_kredytu') / COUNT(id_wniosku), 2), ' %') AS `Udzial_cesja_kredytu (%)`,
  SUM(typ_wniosku = 'aktualizacja_danych') AS `aktualizacja_danych`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'aktualizacja_danych') / COUNT(id_wniosku), 2), ' %') AS `Udzial_aktualizacja_danych (%)`,
  SUM(typ_wniosku = 'zawieszenie_splaty') AS `zawieszenie_splaty`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'zawieszenie_splaty') / COUNT(id_wniosku), 2), ' %') AS `Udzial_zawieszenie_splaty (%)`,
  SUM(typ_wniosku = 'limit') AS `limit`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'limit') / COUNT(id_wniosku), 2), ' %') AS `Udzial_limit (%)`,
  SUM(typ_wniosku = 'wyciag') AS `wyciag`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'wyciag') / COUNT(id_wniosku), 2), ' %') AS `Udzial_wyciag (%)`,
  SUM(typ_wniosku = 'reklamacja') AS `reklamacja`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'reklamacja') / COUNT(id_wniosku), 2), ' %') AS `Udzial_reklamacja (%)`,
  SUM(typ_wniosku = 'kredyt') AS `kredyt`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'kredyt') / COUNT(id_wniosku), 2), ' %') AS `Udzial_kredyt (%)`,
  SUM(typ_wniosku = 'raty') AS `raty`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'raty') / COUNT(id_wniosku), 2), ' %') AS `Udzial_raty (%)`,
  SUM(typ_wniosku = 'wniosek_o_karencje') AS `wniosek_o_karencje`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'wniosek_o_karencje') / COUNT(id_wniosku), 2), ' %') AS `Udzial_wniosek_o_karencje (%)`,
  SUM(typ_wniosku = 'pozyczka') AS `pozyczka`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'pozyczka') / COUNT(id_wniosku), 2), ' %') AS `Udzial_pozyczka (%)`,
  SUM(typ_wniosku = 'zamkniecie_konta') AS `zamkniecie_konta`,
  CONCAT(ROUND(100 * SUM(typ_wniosku = 'zamkniecie_konta') / COUNT(id_wniosku), 2), ' %') AS `Udzial_zamkniecie_konta (%)`
FROM wnioski
GROUP BY status
ORDER BY status;

