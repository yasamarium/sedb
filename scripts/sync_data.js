/**
 * scripts/sync_data.js
 * Synchronizes Square Era JSON data collections with PostgreSQL tables.
 * Can run locally or inside GitHub Actions PostgreSQL runner.
 */

const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const DATA_DIR = path.join(__dirname, '..', 'data');

async function runSync() {
  const connectionString = process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/square_era';
  const client = new Client({ connectionString });

  try {
    await client.connect();
    console.log('[SEDB Sync] Connected to PostgreSQL at:', connectionString.replace(/:[^:]*@/, ':***@'));

    // 1. Sync Rooms
    const roomsFile = path.join(DATA_DIR, 'rooms.json');
    if (fs.existsSync(roomsFile)) {
      const rooms = JSON.parse(fs.readFileSync(roomsFile, 'utf8'));
      for (const room of rooms) {
        await client.query(`
          INSERT INTO rooms (id, name, mode, max_players, current_players, description)
          VALUES ($1, $2, $3, $4, $5, $6)
          ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            mode = EXCLUDED.mode,
            max_players = EXCLUDED.max_players,
            current_players = EXCLUDED.current_players,
            description = EXCLUDED.description;
        `, [room.id, room.name, room.mode || 'creative', room.maxPlayers || 16, room.currentPlayers || 0, room.description || '']);
      }
      console.log(`[SEDB Sync] Synchronized ${rooms.length} rooms to PostgreSQL.`);
    }

    // 2. Sync Users
    const usersFile = path.join(DATA_DIR, 'users.json');
    if (fs.existsSync(usersFile)) {
      const users = JSON.parse(fs.readFileSync(usersFile, 'utf8'));
      for (const user of users) {
        await client.query(`
          INSERT INTO users (id, username, password_hash, role, created_at, last_login)
          VALUES ($1, $2, $3, $4, $5, $6)
          ON CONFLICT (id) DO UPDATE SET
            username = EXCLUDED.username,
            password_hash = EXCLUDED.password_hash,
            last_login = EXCLUDED.last_login;
        `, [user.id, user.username, user.passwordHash, user.role || 'player', user.createdAt || new Date().toISOString(), user.lastLogin || new Date().toISOString()]);
      }
      console.log(`[SEDB Sync] Synchronized ${users.length} users to PostgreSQL.`);
    }

    // 3. Sync Profiles
    const profilesFile = path.join(DATA_DIR, 'profiles.json');
    if (fs.existsSync(profilesFile)) {
      const profiles = JSON.parse(fs.readFileSync(profilesFile, 'utf8'));
      for (const p of profiles) {
        await client.query(`
          INSERT INTO profiles (user_id, username, pos_x, pos_y, pos_z, inventory, health, hunger, game_mode, play_time_minutes, last_room_id, updated_at)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
          ON CONFLICT (user_id) DO UPDATE SET
            username = EXCLUDED.username,
            pos_x = EXCLUDED.pos_x,
            pos_y = EXCLUDED.pos_y,
            pos_z = EXCLUDED.pos_z,
            inventory = EXCLUDED.inventory,
            health = EXCLUDED.health,
            hunger = EXCLUDED.hunger,
            game_mode = EXCLUDED.game_mode,
            play_time_minutes = EXCLUDED.play_time_minutes,
            last_room_id = EXCLUDED.last_room_id,
            updated_at = EXCLUDED.updated_at;
        `, [
          p.userId,
          p.username,
          p.position ? p.position.x : 0,
          p.position ? p.position.y : 30,
          p.position ? p.position.z : 0,
          JSON.stringify(p.inventory || []),
          p.health || 20,
          p.hunger || 20,
          p.gameMode || 'survival',
          p.playTimeMinutes || 0,
          p.lastRoomId || 1,
          p.updatedAt || new Date().toISOString()
        ]);
      }
      console.log(`[SEDB Sync] Synchronized ${profiles.length} profiles to PostgreSQL.`);
    }

    // 4. Sync Worlds
    const worldsFile = path.join(DATA_DIR, 'worlds.json');
    if (fs.existsSync(worldsFile)) {
      const worlds = JSON.parse(fs.readFileSync(worldsFile, 'utf8'));
      let blockCount = 0;
      for (const [userId, worldData] of Object.entries(worlds)) {
        if (worldData && worldData.modifications) {
          for (const [coordKey, blockId] of Object.entries(worldData.modifications)) {
            const [x, y, z] = coordKey.split(',').map(Number);
            if (!isNaN(x) && !isNaN(y) && !isNaN(z)) {
              await client.query(`
                INSERT INTO world_blocks (user_id, room_id, coord_key, pos_x, pos_y, pos_z, block_id)
                VALUES ($1, 1, $2, $3, $4, $5, $6)
                ON CONFLICT (room_id, coord_key) DO UPDATE SET
                  block_id = EXCLUDED.block_id,
                  user_id = EXCLUDED.user_id;
              `, [userId, coordKey, x, y, z, blockId]);
              blockCount++;
            }
          }
        }
      }
      console.log(`[SEDB Sync] Synchronized ${blockCount} world blocks to PostgreSQL.`);
    }

    console.log('[SEDB Sync] All collections successfully synchronized.');
  } catch (err) {
    console.error('[SEDB Sync] Error during synchronization:', err.message);
    process.exitCode = 1;
  } finally {
    await client.end();
  }
}

if (require.main === module) {
  runSync();
}

module.exports = { runSync };
