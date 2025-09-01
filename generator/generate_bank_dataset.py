#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# === KONFIG ===
N_KLIENCI          = 1_438_000
N_KONTA            = 3_432_493
N_KONTA_WALUTOWE   = 843_493
N_TRANSAKCJE       = 13_340_320
N_POZYCZKI         = 743_500
N_LOKATY           = 432_000
N_KARTY            = 4_234_230
N_PRACOWNICY       = 450
N_WNIOSKI          = 632_012
N_ZLECENIA         = 395_020
# ==============

import csv, random, uuid, time, sys
import csv, random, uuid, time
from datetime import date, timedelta
from pathlib import Path

RNG   = random.Random()
TODAY = date.today()
SCRIPT_DIR = Path(__file__).absolute().parent if "__file__" in globals() else Path.cwd()
DATA_DIR   = SCRIPT_DIR / "data"

# ---------- helpery ----------

def load_list(fname, fallback):
    p = DATA_DIR / fname
    if p.exists():
        with open(p, encoding="utf-8") as f:
            return [ln.strip() for ln in f if ln.strip()]
    return fallback

_weight_cache = {}

def _exp_weights(seq):
    key = id(seq)
    if key not in _weight_cache:
        _weight_cache[key] = [RNG.expovariate(1) for _ in seq]
    return _weight_cache[key]


def pick(seq, weights=None):
    """Losuje element. Jeśli nie podasz własnych wag – tworzy świeże
    rozkład Exponential(1) TEJ samej długości, żeby nie było kolizji
    id(seq)↔len(seq) (bug udający się na Python 3.13).
    """
    if weights is None:
        weights = [RNG.expovariate(1) for _ in seq]  # zawsze len == len(seq)
    return RNG.choices(seq, weights=weights, k=1)[0]


def money(low, high, sigma=1.0):
    val = RNG.lognormvariate(0, sigma)
    return round(min(low + (high - low) * (val / 10), high), 2)

# ---------- słowniki ----------
MALE_NAMES   = load_list("imiona_m.txt", ["Adam","Adrian","Aleksander","Andrzej"])
FEMALE_NAMES = load_list("imiona_k.txt", ["Agata","Aleksandra","Alicja","Amelia"])
BASE_SURNAMES= load_list("nazwiska.txt", ["Kowalski","Nowak","Wisniewski","Wojcik"])
CITIES       = load_list("miasta.txt",   ["Warszawa","Krakow","Lodz","Wroclaw"])

DOMAINS = [
    "gmail.com",
    "outlook.com",
    "hotmail.com",
    "icloud.com",
    "yahoo.com",
    "wp.pl",
    "onet.pl",
    "interia.pl",
    "o2.pl",
    "protonmail.com",
    "tlen.pl",
    "poczta.fm",
    "gazeta.pl",
    "me.com",
    "aol.com",
    "yandex.com",
    "zoho.com",
    "mail.com",
    "fastmail.com",
    "gmx.com",
    "edu.pl",        # dla instytucji edukacyjnych
    "gov.pl",        # rządowe
    "icloud.com",    # Apple
    "live.com",      # starsze konta Microsoftu
    "bk.ru"          # rosyjskie, jeszcze się zdarzają
]
STATUS_KLIENT=["aktywny","zawieszony","zamkniety"]
TYP_KONTA=["Osobiste","Firmowe","Mlodziezowe","Oszczednosciowe","Studenckie","Emerytalne"]
STATUS_KONTA=["aktywne","zamkniete","zablokowane"]
WALUTY=["PLN","EUR","USD","GBP","CHF","SEK","NOK","DKK","CZK","JPY"]
TYP_TRANSAKCJI = [
    "Zakupy",            # płatności kartą, online, sklep
    "Wypłata bankomat",  # gotówka z bankomatu
    "Przelew",           # zwykłe przelewy między rachunkami
    "Zwrot",             # np. reklamacja, oddanie środków
    "Podatek",           # przelewy do US, ZUS itd.
    "Abonament",         # np. telefon, Netflix, usługi cykliczne
    "Wynagrodzenie",     # wpływy z tytułu pracy
    "Czynsz",            # opłaty mieszkaniowe, najem
    "Transport",         # komunikacja miejska, paliwo
    "Inne"               # wszystko, co nie pasuje do reszty
]
TYP_KART=["Debetowa","Kredytowa","Przedplacona","Wirtualna"]
STANOWISKA_INNE=["Doradca","Kasjer","Analityk","Specjalista","Menedzer"]
TYP_WNIOSKU = [
    "kredyt",                # wniosek o nowy kredyt
    "karta",                 # debetowa/kredytowa
    "limit",                 # limit w koncie/na karcie
    "raty",                  # zakup na raty lub rozłożenie transakcji
    "pozyczka",              # szybka pożyczka gotówkowa
    "klauzula",              # RODO, zgody marketingowe
    "wyciag",                # prośba o wyciąg z konta
    "reklamacja",            # skarga/zgłoszenie błędu
    "aktualizacja_danych",   # zmiana danych osobowych
    "zamkniecie_konta",      # wniosek o likwidację konta
    "odblokowanie_dostepu",  # np. do bankowości online
    "przeniesienie_konta",   # zmiana banku (np. z usługą Ognivo)
    "cesja_kredytu",         # przepisanie zobowiązania na inną osobę
    "zmiana_hasla",          # do bankowości elektronicznej
    "wydanie_zaswiadczenia", # np. o saldzie lub historii
    "zawieszenie_splaty",    # wakacje kredytowe
    "wniosek_o_karencje",    # karencja w spłacie kapitału/odsetek
    "modyfikacja_umowy",     # aneks, zmiana warunków kredytu
    "ustawienie_pep",        # zgłoszenie statusu PEP
    "inne"                   # wszystko, co się nie mieści wyżej
]
CZEST_ZLECEN=["miesieczna","kwartalna","roczna","tygodniowa"]

# ---------- unikalne liczniki ----------
_used_pesel = set()
_used_phone  = set()
_acc26  = 0
_card16 = 0
_email_counter = {}


def pesel():
    """Zwraca losowy 11‑cyfrowy PESEL; pilnuje unikalności."""
    while True:
        p = RNG.randint(0, 99_999_999_999)
        if p not in _used_pesel:
            _used_pesel.add(p)
            return f"{p:011}"


def phone():
    """Losowy 9‑cyfrowy numer (500‑000‑000 … 999‑999‑999), również unikalny."""
    while True:
        p = RNG.randint(500_000_000, 999_999_999)
        if p not in _used_phone:
            _used_phone.add(p)
            return p


def account26():
    global _acc26
    _acc26 += 1
    return f"{_acc26:026}"


def card16():
    global _card16
    _card16 += 1
    return f"{_card16:016}"


def iban():
    return RNG.choice(["PL","DE","GB"]) + f"{RNG.randint(0,99):02}" + account26()

# ---------- date utils ----------

def rand_date(start, end):
    return start + timedelta(days=RNG.randint(0, (end - start).days))


def years_after(d, yrs):
    try:
        return d.replace(year=d.year + yrs)
    except ValueError:
        return d + timedelta(days=365 * yrs)

# ---------- misc ----------

def female_surname(s):
    if s.endswith("ski"):
        return s[:-3] + "ska"
    if s.endswith("cki"):
        return s[:-3] + "cka"
    if s.endswith("dzki"):
        return s[:-4] + "dzka"
    return s


def email(imie, nazw):
    domain   = pick(DOMAINS)
    key      = f"{imie.lower()}.{nazw.lower()}@{domain}"
    _email_counter[key] = _email_counter.get(key, 0) + 1
    idx = _email_counter[key]
    return key if idx == 1 else key.replace("@", f"{idx}@")


def salary(role):
    if role == "Prezes":
        return RNG.randint(50_000, 100_000)
    if role == "Informatyk":
        return RNG.randint(10_000, 25_000)
    return RNG.randint(4_000, 12_000)

# ---------- GENERATORY ----------

def gen_klienci(n):
    p_male = RNG.random()
    rows = []
    append = rows.append
    for i in range(1, n + 1):
        plec = "M" if RNG.random() < p_male else "K"
        imie = pick(MALE_NAMES if plec == "M" else FEMALE_NAMES)
        base = pick(BASE_SURNAMES)
        nazw = female_surname(base) if plec == "K" else base
        dob  = rand_date(date(1950, 1, 1), date(2005, 1, 1))
        append({
            "id_klienta": i,
            "imie": imie,
            "nazwisko": nazw,
            "plec": plec,
            "pesel": pesel(),
            "data_urodzenia": dob,
            "adres_zamieszkania": pick(CITIES),
            "email": email(imie, nazw),
            "telefon": phone(),
            "status": pick(STATUS_KLIENT, [80, 15, 5])
        })
    return rows


def gen_konta(clients, n):
    AGE_18 = date(TODAY.year - 18, TODAY.month, TODAY.day)
    eligible = [cl for cl in clients if cl["data_urodzenia"] <= AGE_18]
    rows = []
    append = rows.append
    for i in range(1, n + 1):
        cl = RNG.choice(eligible)
        opened = rand_date(years_after(cl["data_urodzenia"], 18),
                           min(years_after(cl["data_urodzenia"], 25), TODAY))
        status = pick(STATUS_KONTA, [85, 10, 5])
        saldo  = 0 if status == "zamkniete" else money(1, 1_500_000, 1.1)
        append({
            "id_konta": i,
            "id_klienta": cl["id_klienta"],
            "iban": iban(),
            "numer_konta": account26(),
            "data_otwarcia": opened,
            "saldo": saldo,
            "typ_konta": pick(TYP_KONTA),
            "status": status
        })
    return rows


def gen_konta_walutowe(clients,n):
    rows=[]
    for i in range(1, n+1):
        cl = RNG.choice(clients)
        opened = rand_date(date(2010,1,1), TODAY)
        status = pick(STATUS_KONTA,[90,7,3])
        saldo  = 0 if status!="aktywne" else money(1,1_000_000,1.1)
        rows.append({
            "id_konta_walutowego": i, "id_klienta": cl["id_klienta"],
            "waluta": pick(WALUTY[1:]), "numer_konta": account26(),
            "saldo": saldo, "data_otwarcia": opened, "status": status
        })
    return rows

def gen_transakcje(konta,n):
    rows=[]; wmap={}
    for i in range(1, n+1):
        acc = RNG.choice(konta)
        opened = acc["data_otwarcia"]
        if acc["id_konta"] not in wmap:
            wmap[acc["id_konta"]] = "PLN" if RNG.random()<0.8 else pick(WALUTY[1:])
        rows.append({
            "id_transakcji": i, "id_konta": acc["id_konta"],
            "data_transakcji": rand_date(opened, TODAY),
            "kwota": money(1,150_000,0.9),
            "waluta": wmap[acc["id_konta"]],
            "typ_transakcji": pick(TYP_TRANSAKCJI),
            "odbiorca_nazwa": pick(MALE_NAMES+FEMALE_NAMES),
            "odbiorca_numer_konta": account26(),
            "tytul": pick(TYP_TRANSAKCJI) + " oplata"
        })
    return rows

def gen_pozyczki(clients,n):
    rows=[]
    for i in range(1,n+1):
        cl = RNG.choice(clients)
        udz = rand_date(years_after(cl["data_urodzenia"],18), TODAY)
        kwota = money(5_000,200_000,0.8)
        oproc = round(RNG.uniform(3,12),2)
        okres = RNG.randint(24,300)
        rat   = kwota*(oproc/1200)/(1-(1+oproc/1200)**(-okres))
        m     = RNG.randint(0,okres)
        saldo = round(kwota*((1+oproc/1200)**okres-(1+oproc/1200)**m)/((1+oproc/1200)**okres-1),2)
        pozostalo = round(rat*(okres-m),2)
        status = "splacona" if m>=okres else ("w_windykacji" if RNG.random()<0.05 else "aktywna")
        rows.append({
            "id_pozyczki": i, "id_klienta": cl["id_klienta"],
            "kwota_pozyczki": kwota, "oprocentowanie": oproc,
            "data_udzielenia": udz, "okres_miesiecy": okres,
            "rata_miesieczna": round(rat,2),
            "saldo_pozostale": saldo, "pozostalo_do_zaplaty": pozostalo,
            "status": status
        })
    return rows

def gen_lokaty(clients,n):
    rows=[]; oprogi=[1.4,3.4,5.6,7.5]
    for i in range(1,n+1):
        cl = RNG.choice(clients)
        start = rand_date(date(2010,1,1), TODAY)
        koniec = years_after(start, RNG.randint(2,5))
        status = "aktywna" if koniec>TODAY and RNG.random()<0.5 else "zakonczona"
        koniec = min(koniec, TODAY)
        kwota = money(1,1_000_000,1.1)
        rows.append({
            "id_lokaty": i, "id_klienta": cl["id_klienta"],
            "kwota": kwota, "oprocentowanie": pick(oprogi),
            "data_rozpoczecia": start, "data_zakonczenia": koniec,
            "kapitalizacja": pick(["miesieczna","kwartalna","roczna"]),
            "status": status
        })
    return rows

def gen_karty(konta,n):
    rows=[]
    for i in range(1,n+1):
        acc = RNG.choice(konta)
        issued = rand_date(acc["data_otwarcia"], TODAY)
        expires = years_after(issued,5)
        typ = pick(TYP_KART)
        status = "wygasla" if expires<TODAY else pick(["aktywna","zablokowana"])
        limit = "" if typ!="Kredytowa" else pick([5000,10000,15000,20000,30000])
        rows.append({
            "id_karty": i, "id_konta": acc["id_konta"],
            "numer_karty": card16(), "typ_karty": typ,
            "data_wydania": issued, "data_waznosci": expires,
            "cvv": f"{RNG.randint(0,9999):04}", "limit_kredytowy": limit,
            "status": status
        })
    return rows

def gen_pracownicy(n):
    rows=[]; used=set()
    for i in range(1,n+1):
        role = ("Prezes" if i==1 else
               ("Informatyk" if i in (2,3,4) else pick(STANOWISKA_INNE)))
        plec = pick(["M","K"])
        imie = pick(MALE_NAMES if plec=="M" else FEMALE_NAMES)
        base = pick(BASE_SURNAMES)
        nazw = female_surname(base) if plec=="K" else base
        dob  = rand_date(date(1955,1,1), date(2004,1,1))
        hire = rand_date(years_after(dob,18), TODAY)
        mail = f"{imie.lower()}.{nazw.lower()}{RNG.randint(1,99)}@uvbank.com"
        while mail in used:
            mail = f"{imie.lower()}.{nazw.lower()}{RNG.randint(1,99)}@uvbank.com"
        used.add(mail)
        rows.append({
            "id_pracownika": i, "imie": imie, "nazwisko": nazw, "email_sluzbowy": mail,
            "plec": plec, "pesel": pesel(), "telefon_sluzbowy": f"5{RNG.randint(0,99999999):08}",
            "stanowisko": role, "dzial": ("Zarzad" if role=="Prezes" else ("IT" if role=="Informatyk" else "Operacje")),
            "data_urodzenia": dob, "data_zatrudnienia": hire,
            "status": pick(["aktywny","zwolniony","zawieszony"],[85,10,5]),
            "haslo_hash": uuid.uuid4().hex, "wynagrodzenie": salary(role)
        })
    return rows

def gen_wnioski(clients,n):
    rows=[]
    for i in range(1,n+1):
        cl = RNG.choice(clients)
        submit = rand_date(years_after(cl["data_urodzenia"],18), TODAY)
        rows.append({
            "id_wniosku": i, "id_klienta": cl["id_klienta"],
            "typ_wniosku": pick(TYP_WNIOSKU),
            "data_zlozenia": submit,
            "status": pick(["nowy","w_trakcie","zrealizowany","odrzucony"],[50,25,20,5])
        })
    return rows

def gen_zlecenia(konta,n):
    rows=[]
    for i in range(1,n+1):
        acc = RNG.choice(konta)
        start = rand_date(acc["data_otwarcia"], TODAY)
        end   = rand_date(start, years_after(start,5))
        rows.append({
            "id_zlecenia": i, "id_konta": acc["id_konta"],
            "odbiorca_nazwa": pick(MALE_NAMES+FEMALE_NAMES),
            "tytul": pick(TYP_TRANSAKCJI) + " stala oplata",
            "kwota": money(1,5_000,0.7),
            "data_start": start, "data_koniec": end,
            "czestotliwosc": pick(CZEST_ZLECEN,[70,15,10,5])
        })
    return rows

# ------------------------------- DUMP ---------------------------------------
def dump(path, rows):
    if not rows: return
    with open(path, "w", newline="", encoding="utf-8") as f:
        w=csv.DictWriter(f, fieldnames=rows[0].keys()); w.writeheader(); w.writerows(rows)
# ------------------------------- MAIN ---------------------------------------
if __name__=="__main__":
    t0=time.perf_counter(); print("📦 Startuję generację…\n📁 Szukam danych w:", DATA_DIR.resolve())
    out=SCRIPT_DIR
    def run(step_name, func):
        s=time.perf_counter(); rows=func(); dump(out/f"{step_name}.csv", rows)
        print(f"✅ {step_name}.csv gotowe w {time.perf_counter()-s:.2f}s (wielkość: {len(rows):,})"); sys.stdout.flush(); return rows
    klienci=run("klienci", lambda: gen_klienci(N_KLIENCI))
    konta=run("konta", lambda: gen_konta(klienci, N_KONTA))
    kw=run("konta_walutowe", lambda: gen_konta_walutowe(klienci, N_KONTA_WALUTOWE))
    transakcje=run("transakcje", lambda: gen_transakcje(konta, N_TRANSAKCJE))
    pozyczki=run("pozyczki", lambda: gen_pozyczki(klienci, N_POZYCZKI))
    lokaty=run("lokaty", lambda: gen_lokaty(klienci, N_LOKATY))
    karty=run("karty", lambda: gen_karty(konta, N_KARTY))
    pracownicy=run("pracownicy", lambda: gen_pracownicy(N_PRACOWNICY))
    wnioski=run("wnioski", lambda: gen_wnioski(klienci, N_WNIOSKI))
    zlecenia=run("zlecenia_stale", lambda: gen_zlecenia(konta, N_ZLECENIA))
    print(f"\n🎉 Wszystko gotowe w {time.perf_counter()-t0:.2f}s. CSV‑ki w {out}")
