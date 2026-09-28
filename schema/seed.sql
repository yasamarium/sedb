-- Square Era Seed Data for PostgreSQL
-- Default Rooms and Baseline Admin Profile

INSERT INTO rooms (id, name, mode, max_players, current_players, description, seed)
VALUES
(1, 'Sanctuary Hub', 'creative', 16, 0, 'Community Creative Sanctuary Hub with AI Sanctuary builds.', 1001),
(2, 'Survival Frontier', 'survival', 16, 0, 'Hardcore Survival Frontier, shared mining shafts and mob defense.', 2002),
(3, 'Builder Paradise', 'creative', 16, 0, 'Infinite Creative Canvas for megastructures and architecture.', 3003),
(4, 'Cyber City', 'creative', 16, 0, 'Futuristic Cyberpunk Nexus with Obsidian towers and Amethyst conduits.', 4004),
(5, 'Anarchy Wilds', 'survival', 16, 0, 'High-Intensity PvP and TNT Blast Playground.', 5005)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    mode = EXCLUDED.mode,
    max_players = EXCLUDED.max_players,
    description = EXCLUDED.description,
    seed = EXCLUDED.seed;

INSERT INTO users (id, username, password_hash, role, created_at, last_login)
VALUES
('usr_alex_default', 'alex', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'player', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO profiles (user_id, username, pos_x, pos_y, pos_z, inventory, health, hunger, game_mode, play_time_minutes, last_room_id, updated_at)
VALUES
('usr_alex_default', 'alex', 7.5, 28.0, 3.5, '[1,2,3,4,5,6,7,8,213]'::jsonb, 20, 20, 'creative', 15, 1, NOW())
ON CONFLICT (user_id) DO NOTHING;
