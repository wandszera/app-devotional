# Documento do Produto

## 1. Visão do produto

Aplicativo mobile Android focado em:

- devocionais diários
- criação de hábito espiritual com streak
- engajamento diário por notificações
- monetização via freemium

## 2. Modelo de negócio

Modelo principal: freemium.

- conteúdo básico gratuito
- recursos premium pagos
- anúncios leves para usuários free

Princípio central:

> retenção antes de monetização

## 3. MVP

Objetivo do MVP:

> validar se o usuário volta todos os dias

### Funcionalidades do MVP

#### Devocional do dia

- conteúdo diário em texto
- botão para concluir o dia

#### Sistema de streak

- contador de dias consecutivos
- atualização automática ao concluir

#### Notificação diária

- push uma vez por dia
- horário fixo inicial, como 08:00

#### Tela de progresso

- streak atual
- melhor streak

#### Histórico simples

- lista de dias concluídos

## 4. Core loop

1. notificação chama o usuário
2. usuário entra no app
3. lê o devocional
4. conclui o dia
5. streak aumenta
6. retorno no dia seguinte

## 5. Arquitetura inicial

### Backend

FastAPI com estrutura prevista:

```text
app/
 ├── main.py
 ├── models/
 ├── routes/
 ├── services/
 └── db/
```

### Frontend

Flutter com telas iniciais de:

- Home
- Progresso
- Perfil

## 6. Modelos de domínio

### User

```python
class User:
    id: int
    email: str
    created_at: datetime
```

### Devotional

```python
class Devotional:
    id: int
    title: str
    content: str
    date: date
```

### UserProgress

```python
class UserProgress:
    user_id: int
    date: date
    completed: bool
```

### UserStreak

```python
class UserStreak:
    user_id: int
    current_streak: int
    longest_streak: int
    last_activity_date: date
```

## 7. Regra de streak

```python
from datetime import date, timedelta

def update_streak(streak: UserStreak):
    today = date.today()

    if streak.last_activity_date == today:
        return streak

    if streak.last_activity_date == today - timedelta(days=1):
        streak.current_streak += 1
    else:
        streak.current_streak = 1

    streak.last_activity_date = today

    if streak.current_streak > streak.longest_streak:
        streak.longest_streak = streak.current_streak

    return streak
```

## 8. Endpoints iniciais

```text
POST /auth/login
GET  /devotional/today
POST /devotional/complete
GET  /streak
GET  /progress
```

## 9. Notificações

Canal planejado:

- Firebase Cloud Messaging

Mensagem inicial de exemplo:

> Seu devocional de hoje já está disponível.

## 10. Métricas do MVP

- retenção D1
- retenção D7
- DAU
- média de streak

## 11. Roadmap

### Fase 1

Validar hábito diário em 0 a 3 semanas.

- devocional
- streak
- notificação
- progresso básico

### Fase 2

Melhorar retenção em 3 a 6 semanas.

- notificação inteligente
- marcos de 7 e 30 dias
- feedback emocional
- histórico melhorado

### Fase 3

Monetizar em 6 a 10 semanas.

- assinatura premium
- sem anúncios para premium
- conteúdo exclusivo
- anúncios leves para free

### Fase 4

Escalar o produto.

- áudios
- personalização
- estatísticas avançadas
- comunidade
- aquisição via shorts e redes sociais

## 12. Principais riscos

- baixa retenção
- gamificação exagerada
- monetização precoce

## 13. Diferencial estratégico

- conteúdo com identidade forte
- linguagem direta
- experiência simples

## 14. Diretriz para próximas implementações

Toda decisão de produto e engenharia deve priorizar o retorno diário do usuário antes de otimizações de monetização.
