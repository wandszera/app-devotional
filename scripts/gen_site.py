"""Gera docs/site/privacidade.html e docs/site/excluir-conta.html.
Edite CONFIG (ou passe env vars) quando D01/D02/D03/D06 forem decididos e rode:
    python scripts/gen_site.py
Valores ainda pendentes ficam destacados em amarelo e a execução avisa quais faltam."""
import html, os, re, sys, datetime
from pathlib import Path

CONFIG = {
    "NOME_APP": os.getenv("NOME_APP", "Semente – Catequese Diária"),  # D01 (provisório)
    "DOMINIO": os.getenv("DOMINIO", "[DOMÍNIO]"),                      # D06
    "EMAIL": os.getenv("EMAIL_SUPORTE", "[EMAIL DE SUPORTE]"),          # D06
    "RESPONSAVEL": os.getenv("RESPONSAVEL", "[RESPONSÁVEL]"),           # D03
    "PROVEDOR": os.getenv("PROVEDOR", "[PROVEDOR DE HOSPEDAGEM]"),      # D02
    "DIAS_BACKUP": os.getenv("DIAS_BACKUP", "[N]"),                     # D02
    "DATA": os.getenv("DATA_ATUALIZACAO", datetime.date.today().strftime("%d/%m/%Y")),
}
pend = [k for k, v in CONFIG.items() if v.startswith("[")]

def v(k):
    val = html.escape(CONFIG[k])
    return f'<mark>{val}</mark>' if CONFIG[k].startswith("[") else val

CSS = """body{font-family:system-ui,sans-serif;max-width:760px;margin:0 auto;padding:16px;line-height:1.6;color:#222}
h1{font-size:1.6rem}h2{font-size:1.2rem;margin-top:1.8rem}table{border-collapse:collapse;width:100%}
td,th{border:1px solid #ccc;padding:6px 8px;text-align:left;vertical-align:top}mark{background:#fff3a3}
.aviso{background:#fff3a3;padding:8px 12px;border-radius:6px}"""

def page(title, body):
    aviso = ('<p class="aviso">Rascunho: campos destacados ainda precisam ser definidos antes de publicar. '
             'Não é aconselhamento jurídico; revisar à luz da LGPD.</p>') if pend else ""
    return (f'<!doctype html><html lang="pt-BR"><head><meta charset="utf-8">'
            f'<meta name="viewport" content="width=device-width,initial-scale=1"><title>{title}</title>'
            f'<style>{CSS}</style></head><body>{aviso}{body}</body></html>')

rows = [
 ("E-mail","Criar e acessar a conta","Cadastro / login"),
 ("Senha (guardada só como hash, nunca em texto)","Autenticação","Cadastro por e-mail"),
 ("Nome e bio (opcionais)","Perfil","Se você preencher"),
 ("Identificador Google/Firebase (uid)","Login com Google","Login com Google"),
 ("Progresso de leitura, sequência (streak) e favoritos","Funcionalidades do app","Uso do app"),
 ("Fuso horário e horário do lembrete","Enviar o lembrete na hora certa","Ao configurar lembretes"),
 ("Token de notificação (FCM)","Enviar notificações push","Ao ativar lembretes"),
 ("Histórico de envio de lembretes","Evitar duplicidade e diagnosticar falhas","Automático"),
]
tabela = "".join(f"<tr><td>{html.escape(a)}</td><td>{html.escape(b)}</td><td>{html.escape(c)}</td></tr>" for a,b,c in rows)

priv = f"""<h1>Política de Privacidade — {v('NOME_APP')}</h1>
<p>Última atualização: {v('DATA')}</p>
<h2>1. Quem somos</h2>
<p>O {v('NOME_APP')} é um aplicativo de devocional diário católico mantido por {v('RESPONSAVEL')}.
Contato para privacidade: {v('EMAIL')}.</p>
<h2>2. Dados que coletamos</h2>
<table><tr><th>Dado</th><th>Para quê</th><th>Quando</th></tr>{tabela}</table>
<p>Não coletamos localização, contatos, fotos, nem dados de pagamento no app. Não vendemos nem compartilhamos dados pessoais para publicidade.</p>
<h2>3. Com quem compartilhamos</h2>
<ul><li><b>Google Firebase</b> (login com Google e notificações push), como operador.</li>
<li><b>Provedor de hospedagem</b> do servidor/banco de dados ({v('PROVEDOR')}), como operador.</li></ul>
<p>Não há anúncios nem SDKs de rastreamento de terceiros.</p>
<h2>4. Base legal e finalidade (LGPD)</h2>
<p>Execução do serviço contratado (conta, progresso, lembretes) e consentimento para notificações push, que pode ser retirado a qualquer momento nas configurações do app ou do sistema.</p>
<h2>5. Segurança</h2>
<p>Comunicação por HTTPS; senhas com hash; tokens de sessão com expiração e rotação.</p>
<h2>6. Retenção e exclusão</h2>
<p>Mantemos os dados enquanto a conta existir. Você pode excluir a conta e todos os dados associados:</p>
<ul><li>No app: Perfil → Excluir conta (confirma com a senha ou novo login Google).</li>
<li>Pela web: <a href="excluir-conta.html">página de exclusão de conta</a> ou e-mail para {v('EMAIL')}.</li></ul>
<p>A exclusão remove e-mail, perfil, progresso, favoritos, lembretes, token de notificação e sessões, de forma imediata no banco principal. Cópias de segurança são descartadas em até {v('DIAS_BACKUP')} dias.</p>
<h2>7. Seus direitos (LGPD, art. 18)</h2>
<p>Confirmação e acesso, correção, anonimização/eliminação, portabilidade, informação sobre compartilhamento e revogação de consentimento: peça por {v('EMAIL')}.</p>
<h2>8. Crianças</h2>
<p>O app não é direcionado a menores de 13 anos.</p>
<h2>9. Alterações</h2>
<p>Mudanças relevantes serão avisadas no app. A data acima indica a versão vigente.</p>"""

excl = f"""<h1>Excluir minha conta — {v('NOME_APP')}</h1>
<p>Você pode excluir sua conta e todos os dados associados de duas formas:</p>
<h2>Pelo app</h2>
<p>Abra o app → <b>Perfil → Editar perfil → Excluir conta</b> e confirme com sua senha (ou refazendo o login com Google).</p>
<h2>Por e-mail</h2>
<p>Envie uma mensagem para {v('EMAIL')} a partir do e-mail cadastrado, com o assunto “Excluir conta”. Respondemos em até 15 dias.</p>
<h2>O que é apagado</h2>
<p>E-mail, perfil, progresso, favoritos, lembretes, token de notificação e sessões. Cópias de segurança são descartadas em até {v('DIAS_BACKUP')} dias.</p>
<p><a href="privacidade.html">Política de Privacidade</a></p>"""

out = Path(__file__).resolve().parent.parent / "docs" / "site"
out.mkdir(parents=True, exist_ok=True)
(out / "privacidade.html").write_text(page("Política de Privacidade", priv), encoding="utf-8")
(out / "excluir-conta.html").write_text(page("Excluir conta", excl), encoding="utf-8")
print("Gerado em", out)
if pend: print("Pendentes:", ", ".join(pend))
