import numpy as np

# Filipino labels matching the dictionary service
filipino_labels = [
    "MAGANDANG UMAGA",      # 0
    "MAGANDANG HAPON",      # 1
    "MAGANDANG GABI",       # 2
    "KUMUSTA",              # 3
    "KUMUSTA KA",           # 4
    "AYOS LANG AKO",        # 5
    "IKINAGAGALAK KONG MAKILALA KA",  # 6
    "SALAMAT",              # 7
    "WALANG ANUMAN",        # 8
    "MAGKITA TAYO BUKAS",   # 9
    "NAIINTINDIHAN",        # 10
    "HINDI NAIINTINDIHAN",  # 11
    "ALAM",                 # 12
    "HINDI ALAM",           # 13
    "HINDI",                # 14
    "OO",                   # 15
    "MALI",                 # 16
    "TAMA",                 # 17
    "MABAGAL",              # 18
    "MABILIS",              # 19
    "ISA",                  # 20
    "DALAWA",               # 21
    "TATLO",                # 22
    "APAT",                 # 23
    "LIMA",                 # 24
    "ANIM",                 # 25
    "PITO",                 # 26
    "WALO",                 # 27
    "SIYAM",                # 28
    "SAMPU",                # 29
    "ENERO",                # 30
    "PEBRERO",              # 31
    "MARSO",                # 32
    "ABRIL",                # 33
    "MAYO",                 # 34
    "HUNYO",                # 35
    "HULYO",                # 36
    "AGOSTO",               # 37
    "SETYEMBRE",            # 38
    "OKTUBRE",              # 39
    "NOBYEMBRE",            # 40
    "DISYEMBRE",            # 41
    "LUNES",                # 42
    "MARTES",               # 43
    "MIYERKULES",           # 44
    "HUWEBES",              # 45
    "BIYERNES",             # 46
    "SABADO",               # 47
    "LINGGO",               # 48
    "NGAYON",               # 49
    "BUKAS",                # 50
    "KAHAPON",              # 51
    "TATAY",                # 52
    "NANAY",                # 53
    "ANAK NA LALAKI",       # 54
    "ANAK NA BABAE",        # 55
    "LOLO",                 # 56
    "LOLA",                 # 57
    "TITO",                 # 58
    "TITA",                 # 59
    "PINSAN",               # 60
    "MAGULANG",             # 61
    "BATANG LALAKI",        # 62
    "BATANG BABAE",         # 63
    "LALAKI",               # 64
    "BABAE",                # 65
    "BINGI",                # 66
    "MAHINA ANG PANDINIG",  # 67
    "TAONG NAKA-WHEELCHAIR", # 68
    "BULAG",                # 69
    "BINGI AT BULAG",       # 70
    "KASAL",                # 71
    "ASUL",                 # 72
    "BERDE",                # 73
    "PULA",                 # 74
    "KAYUMANGGI",           # 75
    "ITIM",                 # 76
    "PUTI",                 # 77
    "DILAW",                # 78
    "KAHEL",                # 79
    "KULAY ABO",            # 80
    "KULAY ROSAS",          # 81
    "LILA",                 # 82
    "LIWANAG",              # 83
    "DILIM",                # 84
    "TINAPAY",              # 85
    "ITLOG",                # 86
    "ISDA",                 # 87
    "KARNE",                # 88
    "MANOK",                # 89
    "ISPAGETI",             # 90
    "KANIN",                # 91
    "LONGGANISA",           # 92
    "HIPON",                # 93
    "ALIMANGO",             # 94
    "MAINIT",               # 95
    "MALAMIG",              # 96
    "JUICE",                # 97
    "GATAS",                # 98
    "KAPE",                 # 99
    "TSAA",                 # 100
    "BEER",                 # 101
    "ALAK",                 # 102
    "ASUKAL",               # 103
    "WALANG ASUKAL",        # 104
]

# Save as numpy array
np.save('assets/classes.npy', np.array(filipino_labels))
print(f"✅ Updated classes.npy with {len(filipino_labels)} Filipino labels")
print(f"First 5 labels: {filipino_labels[:5]}")
print(f"Last 5 labels: {filipino_labels[-5:]}")
