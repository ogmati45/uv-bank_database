# Dane CSV – pełny zestaw

> Ze względu na duży rozmiar plików, pełne dane w formacie **CSV** zostały umieszczone na Google Drive.  
> W repozytorium mogą znajdować się jedynie próbki (sample), natomiast pełne zbiory danych pobierzesz tutaj:

📂 Pobierz wszystkie pliki CSV:  
👉 [Pełny folder CSV (Google Drive)](https://drive.google.com/drive/folders/1-cC9sBm77O2mrOFtjmMlVjKRJkauEhgj?usp=sharing)

---

## Lista plików CSV i ich zawartość

### 👤 klienci.csv  
- Dane osobowe i kontaktowe klientów banku.  
- Ponad **1,4 mln rekordów**.  
- Pola: imię, nazwisko, PESEL, data urodzenia, adres, email, telefon, status.  

---

### 💳 konta.csv  
- Dane dotyczące rachunków bankowych klientów.  
- Ponad **3,4 mln rekordów**.  
- Pola: numer konta, IBAN, saldo, typ konta, status, data otwarcia.  

---

### 💱 konta_walutowe.csv  
- Informacje o rachunkach walutowych.  
- Ponad **840 tys. rekordów**.  
- Pola: numer konta, waluta, saldo, status.  

---

### 🏦 karty.csv  
- Dane o kartach płatniczych i kredytowych.  
- Ponad **4,2 mln rekordów**.  
- Pola: numer karty, typ, CVV, data ważności, limit kredytowy, status.  

---

### 📈 lokaty.csv  
- Informacje o lokatach klientów.  
- Ponad **430 tys. rekordów**.  
- Pola: kwota, oprocentowanie, kapitalizacja, status.  

---

### 💸 pozyczki.csv  
- Dane o udzielonych pożyczkach.  
- Ponad **740 tys. rekordów**.  
- Pola: kwota, oprocentowanie, okres, rata, saldo, status.  

---

### 👔 pracownicy.csv  
- Dane o pracownikach banku.  
- 450 rekordów.  
- Pola: imię, nazwisko, stanowisko, dział, data zatrudnienia, status, wynagrodzenie.  

---

### 🔄 transakcje.csv  
- Wszystkie transakcje przeprowadzane na kontach klientów.  
- Ponad **13,3 mln rekordów**.  
- Pola: kwota, data, typ transakcji, odbiorca, numer konta, tytuł.  

---

### 📑 wnioski.csv  
- Informacje o wnioskach klientów.  
- Ponad **630 tys. rekordów**.  
- Pola: typ wniosku, data złożenia, status.  

---

### 📆 zlecenia_stale.csv  
- Dane o zleceniach stałych klientów.  
- Ponad **390 tys. rekordów**.  
- Pola: odbiorca, tytuł, kwota, częstotliwość, daty obowiązywania.  

---

## Jak korzystać?

1. Pobierz pliki z Google Drive (link powyżej).  
2. Zaimportuj dane do MySQL (pliki są zgodne ze strukturą tabel w `START.SQL`).  
3. Możesz również użyć plików CSV jako źródła dla Excela lub Power BI.  

---

✅ Dzięki temu zbiorowi można przeprowadzać **analizy big data**, symulacje **SQL/BI/ML** i testy systemów bankowych.
