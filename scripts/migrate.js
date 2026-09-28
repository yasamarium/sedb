/**
 * scripts/migrate.js
 * Applies schema and seed files to a PostgreSQL database.
 */

const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

async function migrate() {
  const connectionString = process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/square_era';
  const client = new Client({ connectionString });

  try {
    await client.connect();
    console.log('[SEDB Migrate] Connected to PostgreSQL.');

    const schemaPath = path.join(__dirname, '..', 'schema', 'init.sql');
    if (fs.existsSync(schemaPath)) {
      console.log('[SEDB Migrate] Applying init.sql...');
      const ddl = fs.readFileSync(schemaPath, 'utf8');
      await client.query(ddl);
      console.log('[SEDB Migrate] init.sql applied successfully.');
    }

    const seedPath = path.join(__dirname, '..', 'schema', 'seed.sql');
    if (fs.existsSync(seedPath)) {
      console.log('[SEDB Migrate] Applying seed.sql...');
      const seedSql = fs.readFileSync(seedPath, 'utf8');
      await client.query(seedSql);
      console.log('[SEDB Migrate] seed.sql applied successfully.');
    }

    console.log('[SEDB Migrate] Migration complete.');
  } catch (err) {
    console.error('[SEDB Migrate] Migration failed:', err.message);
    process.exitCode = 1;
  } finally {
    await client.end();
  }
}

if (require.main === module) {
  migrate();
}

module.exports = { migrate };
