"""Gera o esqueleto do calendário editorial (C01): datas, tempo litúrgico e
celebrações fixas. NÃO inventa referências de Evangelho nem reflexões: essas
colunas ficam vazias para o revisor preencher a partir da fonte (CNBB)."""
import csv, sys
from datetime import date, timedelta

START, END = date(2026, 12, 1), date(2027, 3, 31)
ADVENT1 = date(2026, 11, 29)
CHRISTMAS = date(2026, 12, 25)
EPIPHANY = date(2027, 1, 3)       # domingo (Brasil)
BAPTISM = date(2027, 1, 10)
ASH = date(2027, 2, 10)
EASTER = date(2027, 3, 28)
FIXED = {
    date(2026,12,8): "Imaculada Conceição de Nossa Senhora, Solenidade",
    date(2026,12,25): "Natividade do Senhor, Solenidade",
    date(2026,12,27): "Sagrada Família: Jesus, Maria e José, Festa",
    date(2027,1,1): "Santa Maria, Mãe de Deus, Solenidade",
    date(2027,1,3): "Epifania do Senhor, Solenidade",
    date(2027,1,10): "Batismo do Senhor, Festa",
    date(2027,2,2): "Apresentação do Senhor, Festa",
    date(2027,2,10): "Quarta-feira de Cinzas",
    date(2027,3,19): "São José, esposo da Virgem Maria, Solenidade",
    date(2027,3,21): "Domingo de Ramos da Paixão do Senhor",
    date(2027,3,25): "Quinta-feira Santa",
    date(2027,3,26): "Sexta-feira da Paixão do Senhor",
    date(2027,3,27): "Sábado Santo — Vigília Pascal",
    date(2027,3,28): "Domingo da Páscoa da Ressurreição do Senhor, Solenidade",
}
def season(d):
    if d < CHRISTMAS: return "Advento"
    if d <= BAPTISM: return "Natal"
    if d < ASH: return "Tempo Comum"
    if d < date(2027,3,25): return "Quaresma"
    if d < EASTER: return "Tríduo Pascal" if d>=date(2027,3,25) else "Quaresma"
    return "Páscoa"
def title(d):
    if d in FIXED: return FIXED[d]
    s = season(d)
    sun = d.weekday() == 6
    if s == "Advento":
        wk = (d - ADVENT1).days // 7 + 1
        return f"{wk}º Domingo do Advento, Ano B" if sun else f"{wk}ª Semana do Advento"
    if s == "Natal":
        return "Tempo do Natal" if not sun else "2º Domingo do Natal"
    if s == "Tempo Comum":
        wk = (d - date(2027,1,10)).days // 7 + 1 if sun else (d - date(2027,1,11)).days // 7 + 1
        return f"{wk}º Domingo do Tempo Comum, Ano B" if sun else f"{wk}ª Semana do Tempo Comum"
    if s == "Quaresma":
        if d - ASH < timedelta(days=4): return "Quaresma — após as Cinzas"
        if d >= date(2027,3,22): return "Semana Santa"
        wk = (d - (ASH + timedelta(days=4))).days // 7 + 1
        return f"{wk}º Domingo da Quaresma, Ano B" if sun else f"{wk}ª Semana da Quaresma"
    return "Oitava da Páscoa"
wr = csv.writer(sys.stdout, lineterminator="\n")
wr.writerow(["date","weekday","season","liturgical_title","gospel_reference","reflection","status"])
d = START
while d <= END:
    wr.writerow([d.isoformat(), "seg ter qua qui sex sáb dom".split()[d.weekday()],
                 season(d), title(d), "", "", "a_preencher"])
    d += timedelta(days=1)
