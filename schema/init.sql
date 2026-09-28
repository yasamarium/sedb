-- Square Era PostgreSQL Core Database Schema
-- Repository: yasamarium/sedb
-- Managed by: yasamarium/sesydb & yasamarium/sesydb2 (5-Hour Auto-Restart Workflow)

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(64) PRIMARY KEY,
    username VARCHAR(32) NOT NULL UNIQUE,
    password_hash VARCHAR(128) NOT NULL,
    role VARCHAR(16) NOT NULL DEFAULT 'player',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- 2. Player Profiles Table
CREATE TABLE IF NOT EXISTS profiles (
    user_id VARCHAR(64) PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    username VARCHAR(32) NOT NULL,
    pos_x DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    pos_y DOUBLE PRECISION NOT NULL DEFAULT 30.0,
    pos_z DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    inventory JSONB NOT NULL DEFAULT '[]'::jsonb,
    health INTEGER NOT NULL DEFAULT 20,
    hunger INTEGER NOT NULL DEFAULT 20,
    game_mode VARCHAR(16) NOT NULL DEFAULT 'survival',
    play_time_minutes INTEGER NOT NULL DEFAULT 0,
    last_room_id INTEGER NOT NULL DEFAULT 1,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_updated_at ON profiles(updated_at);

-- 3. Multiplayer Rooms Table
CREATE TABLE IF NOT EXISTS rooms (
    id INTEGER PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    mode VARCHAR(16) NOT NULL DEFAULT 'creative',
    max_players INTEGER NOT NULL DEFAULT 16,
    current_players INTEGER NOT NULL DEFAULT 0,
    description TEXT,
    seed BIGINT NOT NULL DEFAULT 1337,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. World Block Modifications Table (Voxel Persistent Grid)
CREATE TABLE IF NOT EXISTS world_blocks (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(64) REFERENCES users(id) ON DELETE SET NULL,
    room_id INTEGER NOT NULL DEFAULT 1 REFERENCES rooms(id) ON DELETE CASCADE,
    coord_key VARCHAR(48) NOT NULL,
    pos_x INTEGER NOT NULL,
    pos_y INTEGER NOT NULL,
    pos_z INTEGER NOT NULL,
    block_id INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_room_coord UNIQUE (room_id, coord_key)
);

CREATE INDEX IF NOT EXISTS idx_world_blocks_room ON world_blocks(room_id);
CREATE INDEX IF NOT EXISTS idx_world_blocks_coords ON world_blocks(pos_x, pos_y, pos_z);
CREATE INDEX IF NOT EXISTS idx_world_blocks_user ON world_blocks(user_id);

-- 5. Extended Player Inventories Table
CREATE TABLE IF NOT EXISTS inventories (
    user_id VARCHAR(64) PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    hotbar JSONB NOT NULL DEFAULT '[]'::jsonb,
    main_inventory JSONB NOT NULL DEFAULT '[]'::jsonb,
    ender_chest JSONB NOT NULL DEFAULT '[]'::jsonb,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Player Sessions Table
CREATE TABLE IF NOT EXISTS sessions (
    session_id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) REFERENCES users(id) ON DELETE CASCADE,
    client_ip VARCHAR(64),
    user_agent TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_sessions_user_active ON sessions(user_id, is_active);

-- 7. Audit & Telemetry Logs Table
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,
    event_type VARCHAR(32) NOT NULL,
    user_id VARCHAR(64),
    payload JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_event ON audit_logs(event_type, created_at);
