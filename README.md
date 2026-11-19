# Lava-Rápido

Nome da temática do aplicativo: Lava-Rápido

Nome completo do estudante: <PREENCHER>

Link da API publicada: <PREENCHER - ex.: https://lava-rapido-api.onrender.com>

Descrição resumida da aplicação: Aplicativo Flutter para controle de lavagens de um lava-rápido (número da vaga e valor do serviço). Os dados ficam no SQLite do aparelho e são enviados para uma API própria (Node.js + Express + PostgreSQL). Funciona offline-first: se a API estiver indisponível, o cadastro é salvo localmente como pendente e pode ser sincronizado manualmente depois.

## Estrutura

```
/                 app Flutter
├── lib/
│   ├── components/   widgets reutilizáveis
│   ├── models/       Lavagem
│   ├── screens/      lista e formulário
│   ├── services/     chamadas HTTP (ApiService)
│   ├── repository/   escolhe SQLite / API / offline-first
│   ├── database/     SQLite (sqflite)
│   └── main.dart
└── api/              API Node.js + Express + PostgreSQL
```

## Rotas da API

| Método | Rota | Descrição |
| --- | --- | --- |
| GET | `/lavagens` | Lista as lavagens |
| POST | `/lavagens` | Cadastra uma lavagem. Body: `{"valor": 35.5, "numero_vaga": 12}` |
| GET | `/teste-banco` | Verifica API e banco |

## Offline-first

1. API disponível: o registro é enviado e guardado localmente como sincronizado (`sincronizado = 1`).
2. API indisponível: o registro é salvo no SQLite como pendente (`sincronizado = 0`) e aparece com ícone laranja.
3. API de volta: o botão de sincronizar (ícone de setas na barra superior, com o número de pendentes) envia os pendentes e os marca como sincronizados.

## Como rodar

Flutter: `flutter pub get` e `flutter run`. A URL da API fica em `lib/services/api_service.dart` (`baseUrl`).

API: dentro de `api/`, copie `.env.example` para `.env`, preencha `DATABASE_URL`, rode `npm install` e `npm start`.
