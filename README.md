# UV Bank – Symulacja Systemu Bankowego

Projekt przedstawia kompletną, wymyśloną przeze mnie bazę danych banku – zaprojektowaną od podstaw, aby zaprezentować moje umiejętności w zakresie **database design, data analysis i data management**.  

Cała struktura, relacje i logika biznesowa (np. statusy klientów, wzory do obliczeń rat, powiązania między kontami i transakcjami) zostały **stworzona przeze mnie od zera**.  
Dane testowe wygenerowałem przy użyciu własnego **generatora w Pythonie** (konfigurowalnego), opartego o AI, zgodnie z moimi dokładnymi wymaganiami.  

---

## Kluczowe cechy projektu
- **Big Data scale:** miliony rekordów (1,4 mln klientów, 13 mln transakcji, 4,2 mln kart, setki tysięcy lokat, pożyczek i wniosków).  
- **Realistic banking model:** pełna symulacja funkcjonowania banku – klienci, konta, karty, lokaty, pożyczki, pracownicy, wnioski i transakcje, wszystkie połączone relacjami.  
- **SQL (MySQL):** kompletna struktura bazy danych (tabele, klucze, relacje) + rozbudowane zapytania analityczne i widoki raportowe.  
- **Python (data generator):** autorski skrypt generujący dane testowe w skali masowej, z możliwością konfiguracji parametrów i eksportu do CSV.  
- **Data analysis & BI:** raporty i dashboardy w **Excel** oraz **Power BI** – analiza dużych datasetów, identyfikacja ograniczeń (np. Excel vs miliony rekordów).  
- **Tech stack:** MySQL Workbench, phpMyAdmin, Python, Excel, Power BI, pakiet Office.  
 
---

## Struktura repozytorium

📂 assets/ → materiały wizualne i dodatkowe  
└── logo.png → logo projektu UV Bank  

📂 data/ → dane testowe (miliony rekordów w CSV)  
└── CSV/ → eksportowane rekordy dla wszystkich tabel  

📂 sql/ → pliki SQL  
├── START.SQL → definicja struktury bazy (tabele, klucze, relacje)  
├── ZAPYTANIA.SQL → zestaw zapytań analitycznych  
├── WIDOKI.SQL → widoki raportowe  
└── STRUKTURA BANKU.txt → opis logiki biznesowej i pól w tabelach  

📂 excel/ → pliki analityczne Excel  
├── BANK EXCEL.pdf → raport zbiorczy z analizy danych w Excelu  
├── 1KLIENCI.png → wizualizacja analizy klientów  
├── 2KONTA.png → wizualizacja analizy kont  
├── 3KARTY.png → wizualizacja analizy kart  
├── 4PRACOWNICY.png → wizualizacja analizy pracowników  
├── 5KONTA WALUTOWE.png → wizualizacja analizy kont walutowych  
├── 6POŻYCZKI.png → wizualizacja analizy pożyczek  
├── 7WNIOSEK.png → wizualizacja analizy wniosków  
├── 8LOKATY.png → wizualizacja analizy lokat  
├──9ZLECENIA STAŁE.png → wizualizacja analizy zleceń stałych  ├── EXCEL_1.xlsx → analiza cz. 1 (podział ze względu na rozmiar danych)  
├── EXCEL_2.xlsx → analiza cz. 2  
└── EXCEL_3.xlsx → analiza cz. 3  

📂 powerbi/ → pliki Power BI  
├── BANK wizualizacja.pdf → graficzne przedstawienie struktury i działania bazy  
└── BANK.pbix → dashboard analityczny Power BI  

📂 generator/ → generator danych w Pythonie  
└── generate_bank_dataset.py → skrypt generujący dane testowe + konfiguracja  

📂 docs/ → dodatkowa dokumentacja  
└── README.md → dokumentacja projektu (ten plik)  

---

## Struktura danych

### STRUKTURA KLIENCI - `Klienci` - (klienci.csv) - 1438000 REKORDÓW:
- `id_klienta` - UNIKALNE, klucz główny, numerowane od 1.
- `imie` - Imie z imiona_m.txt/imiona_k.txt (generowane losowo).
- `nazwisko` - Nazwisko z nazwiska.txt - bezokolicznikowe (generowane losowo).
- `plec` - K/M - płeć odpowiadająca wybranemu imieniu.
- `pesel` - UNIKALNY, 11cyfrowy (generowany losowo).
- `data_urodzenia` - Minimalny wiek klienta to 18+.
- `adres_zamieszkania` - Miasto z miasta.txt (generowane losowo).
- `email` - Generowany losowo z imienia + nazwiska + domena (generowany losowo).
* DOMENY:     "gmail.com", "outlook.com", "hotmail.com", "icloud.com", "yahoo.com", "wp.pl", "onet.pl", "interia.pl", "o2.pl", "protonmail.com", "tlen.pl", "poczta.fm", "gazeta.pl", "me.com", "aol.com", "yandex.com", "zoho.com", "mail.com", "fastmail.com", "gmx.com", "edu.pl", "gov.pl", "icloud.com", "live.com", "bk.ru".
- `telefon` - Generowany losowo (9-cyfrowy numer 500‑000‑000 … 999‑999‑999).
- `status` - Status klienta: Aktywny/Zawieszony/Zamkniety.

### STRUKTURA KONT - `Konta` - (konta.csv) - 3432493 REKORDÓW:
- `id_konta` - UNIKALNE, klucz główny, numerowane od 1.
- `id_klienta` - Klucz obcy z tabeli `Klienci` (generowane losowo).
- `iban` -  PL/DE/GB (generowane losowo).
- `numer_konta` - Numer konta nie jest powtarzalny, 26cyfrowy (generowane losowo).
- `data_otwarcia` - Korzysta z daty_urodzenia klienta, minimum 18 lat - do dziś maksymalnie (generowane losowo).
- `saldo` - Od 1 do 1500000 (generowane losowo).
- `typ_konta` - Osobiste/Firmowe/Mlodziezowe/Oszczednosciowe/Studenckie/Emerytalne (generowane losowo).
- `status` - Aktywne/Zamkniete/Zablokowane (generowane losowo).

### STRUKTURA KONT WALUTOWYCH - `Konta_walutowe` - (konta_walutowe.csv) - 843493 REKORDÓW:
- `id_konta_walutowego` - UNIKALNE, klucz główny, numerowane od 1.
- `id_klienta` - Klucz obcy z tabeli `Klienci` (generowane losowo).
- `waluta` - "PLN","EUR","USD","GBP","CHF","SEK","NOK","DKK","CZK","JPY" (generowane losowo).
- `numer_konta` - Numer konta nie jest powtarzalny, 26cyfrowy (generowane losowo).
- `saldo` - Od 1 do 1500000 (generowane losowo).
- `data_otwarcia` - Korzysta z daty_urodzenia klienta, minimum 18 lat - do dziś maksymalnie (generowane losowo).
- `status` - Aktynwe/Zamkniete/Zablokowane (generowane losowo).

### STRUKTURA KART - `Karty` - (karty.csv) - 4234230 REKORDÓW:
- `id_karty` - UNIKALNE, klucz główny, numerowane od 1.
- `id_konta` - Klucz obcy z tabeli `Konta` (generowane losowo).
- `numer_karty` - Numer karty nie jest powtarzalny, 16cyfrowy (generowane losowo).
- `typ_karty` - "Debetowa","Kredytowa","Przedplacona","Wirtualna" (generowane losowo).
- `data_wydania` - Data wydania karty (między otwarciem konta a dziś) (generowane losowo).
- `data_waznosci` - Data ważności (zawsze +5 lat od data_wydania)
- `cvv` - Od 000 - Od 0000 do 9999 (cztery cyfry) (generowane losowo).
- `limit_kredytowy` Tylko dla kart typu "Kredytowa" (5000,10000,15000,20000,30000) (generowane losowo).
- `status` - "Wygasla" (jeśli karta już po terminie) lub "aktywna", "zablokowana" (generowane losowo).

### STRUKTURA LOKAT - `Lokaty` - (lokaty.csv) - 432000 REKORDÓW:
- `id_lokaty` - UNIKALNE, klucz główny, numerowane od 1.
- `id_klienta` - Klucz obcy z tabeli `Klienci` (generowane losowo).
- `kwota` - Od 1 do 1000000 (generowane losowo).
- `oprocentowanie` - 1.4,3.4,5.6,7.5 (generowane losowo).
- `data_rozpoczecia` - Nie wcześniej, niż data założenia konta klienta (generowane losowo).
- `data_zakonczenia` - 2-5 LAT od daty rozpoczęcia (generowane losowo).
- `kapitalizacja` - Miesieczna/Kwartalna/Roczna (generowane losowo).
- `status` - Aktywna/Zakonczona (jesli data_zakonczenia już mineła z automatu jest zakończona).

### STRUKTURA POZYCZEK - `Pozyczki` - (pozyczki.csv) - 743500 REKORDÓW:
- `id_pozyczki` - UNIKALNE, klucz główny, numerowane od 1.
- `id_klienta` - Klucz obcy z tabeli `Klienci` (generowane losowo).
- `kwota_pozyczki` - Od 5000 do 200000 (generowane losowo).
- `oprocentowanie` - Liczba zmiennoprzecinkowa od 3.00 % do 12.00% (generowane losowo).
- `data_udzielenia` - Minimum klient 18lat, od daty otwarcia konta do dziś (generowane losowo).
- `okres_miesiecy` - Okres miesiecy liczone automatycznie, od daty udzielenia min. 2 lata do 25 lat (generowane losowo).
- `rata_miesieczna` - Liczone z wzoru na ratę równą (rat = kwota*(oproc/1200)/(1-(1+oproc/1200)**(-okres))). 
- `saldo_pozostale` - To jest bieżące saldo kapitału pozostałego do spłaty, po m miesiącach.
- `pozostalo_do_zaplaty` - Całkowitą kwotę do zapłaty, uwzględniając kapitał i odsetki.
- `status` - Jeżeli wszystkie raty zostały spłacone (m >= okres) → splacona, albo 5% szansy w_windykacji, w przeciwnym razie aktywna.

### STRUKTURA PRACOWNICY - `Pracownicy` - (pracownicy.csv) - 450 REKORDÓW:
- `id_pracownika` - UNIKALNE, klucz główny, numerowane od 1.
- `imie` - Imie z imiona_m.txt/imiona_k.txt (generowane losowo).
- `nazwisko` - Nazwisko z nazwiska.txt - bezokolicznikowe (generowane losowo).
- `email_sluzbowy` - Imie (małymi literami) + "." + nazwisko (małymi literami) + liczba losowa od 1 do 99 + "@uvbank.com".
- `plec` - K/M - płeć odpowiadająca wybranemu imieniu.
- `pesel` - UNIKALNY, 11 cyfrowy (generowane losowo).
- `telefon_sluzbowy` - Zakres od 500 000 000 - 999 999 999 (generowane losowo).
- `stanowisko` - Pierwszy pracownik to zawsze Prezes, później TRZECH informatyków, nastepnie losowo: ["Doradca", "Kasjer", "Analityk", "Specjalista", "Menedzer" (generowane losowo).
- `dzial` -  Jeśli stanowisko to Prezes, dział to Zarzad, jeśli stanowisko to Informatyk, dział to IT, w przeciwnym razie dział to Operacje (generowane losowo).
- `data_urodzenia` - Data urodzenia między 1 stycznia 1955 a 1 stycznia 2004 (generowane losowo).
- `data_zatrudnienia` - Data zatrudnienia między 18 urodzinami pracownika (dob + 18 lat) a dzisiaj (generowane losowo).
- `status` - 85% szans na aktywny, 10% na zwolniony, 5% na zawieszony (generowane losowo).
- `haslo_hash` - Unikalny hash hasła generowany przez UUID4 (32-znakowy hex) (generowane losowo).
- `wynagrodzenie` - Dla Prezesa losowa pensja 50k–100k, dla Informatyka losowa pensja 10k–25k, dla pozostałych losowa pensja 4k–12k (generowane losowo).

### STRUKTURA TRANSAKACJE - `Transakcje` - (transakacje.csv) - 13340320 REKORDÓW:
- `id_transakcji` - UNIKALNE, klucz główny, numerowane od 1.
- `id_konta` - Klucz obcy z tabeli `Konta` (generowane losowo).
- `data_transakcji` - Data otwarcia konta do dziś (generowane losowo).
- `kwota` - Od 0 do 150000 (generowane losowo).
- `waluta` - "PLN","EUR","USD","GBP","CHF","SEK","NOK","DKK","CZK","JPY" (generowane losowo).
- `typ_transakcji` - "Zakupy", "Wypłata bankomat", "Przelew", "Zwrot",  "Podatek", "Abonament", "Wynagrodzenie", "Czynsz", "Transport", "Inne" (generowane losowo).
- `odbiorca_nazwa` - Imie spośród podanych w notatnikach (generowane losowo).
- `odbiorca_numer_konta` - 26 cyfrowy numer konta (generowany losowo - mogą być powtórki).
- `tytul` - Typ transakcji + 'oplata'.

### STRUKTURA ZLECENIA STAŁE - `Zlecenia_stale` - (zlecenia_stale.csv) - 395020 REKORDÓW;
- `id_zlecenia` - UNIKALNE, klucz główny, numerowane od 1.
- `id_konta` - Klucz obcy z tabeli `Konta` (generowane losowo).
- `odbiorca_nazwa` - Imie spośród podanych w notatnikach (generowane losowo).
- `tytul` - "Zakupy", "Wypłata bankomat", "Przelew", "Zwrot",  "Podatek", "Abonament", "Wynagrodzenie", "Czynsz", "Transport", "Inne" (generowane losowo) + 'stala oplata'.
- `kwota` - Od 1 do 5000 (generowane losowo).
- `data_start` - Minimum klient 18lat, od daty otwarcia konta do dziś (generowane losowo).
- `data_koniec` - Od daty startu + 5 lat.
- `czestotliwosc` - "miesieczna","kwartalna","roczna","tygodniowa" (generowane losowo).

### STRUKTURA WNIOSKÓW - `Wnioski` - (wnioski.csv) - 632012 REKORDÓW:
- `id_wniosku` - UNIKALNE, klucz główny, numerowane od 1.
- `id_klienta` - Klucz obcy z tabeli `Klienci` (generowane losowo).
- `typ_wniosku` - "kredyt", "karta", "limit", "raty", "pozyczka", "klauzula", "wyciag", "reklamacja", "aktualizacja_danych", "zamkniecie_konta", "odblokowanie_dostepu","przeniesienie_konta", "cesja_kredytu", "zmiana_hasla", "wydanie_zaswiadczenia", "zawieszenie_splaty", "wniosek_o_karencje", "modyfikacja_umowy", "ustawienie_pep", "inne" (generowane losowo).
- `data_zlozenia` - Minimum klient 18lat, od daty otwarcia konta do dziś (generowane losowo).
- `status` - "nowy" (50% szans), "w_trakcie" (25%), "zrealizowany" (20%), "odrzucony" (5%) (generowane losowo).

---

## Potencjalne zastosowania
- Trening i nauka **SQL** – od podstawowych zapytań po zaawansowane widoki i analizy.  
- Symulacja pracy na **dużych zbiorach danych** (miliony rekordów) – idealne do testów wydajności i optymalizacji.  
- Budowa scenariuszy do **machine learning / fraud detection** (np. analiza transakcji, scoring klientów).  
- Integracja z narzędziami **BI** (Power BI, Excel) – raportowanie, dashboardy, analizy biznesowe.  
- Podstawa do rozwoju własnych projektów: od API bankowego, przez analitykę, aż po systemy testowe.  

---

## Dlaczego ten projekt?
Ten projekt to praktyczny dowód moich umiejętności w obszarze:  
- **Projektowania dużych baz danych** – przemyślane tabele, relacje, klucze, zależności.  
- **Data engineering & ETL** – generowanie i przetwarzanie danych testowych w Pythonie.  
- **SQL (MySQL)** – tworzenie zapytań analitycznych, widoków, rankingów, agregacji.  
- **Business Intelligence (Power BI, Excel)** – budowanie raportów i dashboardów na podstawie milionowych datasetów.  
- **Data analysis & problem solving** – praca z realnymi ograniczeniami (np. Excel nie radzący sobie z >1M rekordów i podział danych na części).  
- **Full data lifecycle** – od generacji danych → przez przechowywanie w bazie → po raporty i wizualizacje.  
