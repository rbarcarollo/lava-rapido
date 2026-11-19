require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
app.use(cors());
app.use(express.json());

// No Render, o PostgreSQL exige SSL.
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.DATABASE_SSL === 'false' ? false : { rejectUnauthorized: false },
});

async function criarTabela() {
  await pool.query(`
    create table if not exists lavagens (
      id serial primary key,
      valor numeric(10,2) not null,
      numero_vaga integer not null,
      criado_em timestamptz not null default now()
    )
  `);
}

// Verifica se a API e o banco estão respondendo.
app.get('/teste-banco', async (req, res) => {
  try {
    const resultado = await pool.query('select now() as agora');
    res.json({ ok: true, agora: resultado.rows[0].agora });
  } catch (erro) {
    res.status(500).json({ ok: false, erro: erro.message });
  }
});

app.get('/lavagens', async (req, res) => {
  try {
    const resultado = await pool.query(
      'select id, valor::float8 as valor, numero_vaga from lavagens order by id'
    );
    res.json(resultado.rows);
  } catch (erro) {
    res.status(500).json({ erro: erro.message });
  }
});

app.post('/lavagens', async (req, res) => {
  const { valor, numero_vaga } = req.body;

  if (typeof valor !== 'number' || !Number.isFinite(valor) || valor < 0) {
    return res.status(400).json({ erro: 'valor deve ser um número maior ou igual a zero' });
  }
  if (!Number.isInteger(numero_vaga)) {
    return res.status(400).json({ erro: 'numero_vaga deve ser um número inteiro' });
  }

  try {
    const resultado = await pool.query(
      'insert into lavagens (valor, numero_vaga) values ($1, $2) returning id, valor::float8 as valor, numero_vaga',
      [valor, numero_vaga]
    );
    res.status(201).json(resultado.rows[0]);
  } catch (erro) {
    res.status(500).json({ erro: erro.message });
  }
});

const porta = process.env.PORT || 3000;

criarTabela()
  .then(() => app.listen(porta, () => console.log(`API rodando na porta ${porta}`)))
  .catch((erro) => {
    console.error('Erro ao preparar o banco:', erro);
    process.exit(1);
  });
