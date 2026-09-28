# Square Era Data Repository (`sedb`)

Central persistence repository for **Square Era**. This repository stores canonical game data, PostgreSQL relational schemas, and snapshot state for user profiles, voxel world modifications, and multiplayer rooms.

## Repository Overview
- **Data Collections (`data/`)**:
  - `data/users.json`: Player credentials, unique user identifiers (`usr_...`), SHA-256 password digests, and roles.
  - `data/profiles.json`: Player save states including hotbar inventory, health, hunger, coordinates, and game mode.
  - `data/worlds.json`: Block modifications per room and user account (`"x,y,z": blockId`).
  - `data/rooms.json`: 5 active multiplayer room presets (Sanctuary Hub, Survival Frontier, Builder Paradise, Cyber City, Anarchy Wilds).
  - `data/inventories.json`: Extended player inventories, main bag slots, and ender chests.
  - `data/activities.json`: Telemetry and audit logs for player joins, registrations, and saves.
- **Relational Schema (`schema/`)**:
  - `schema/init.sql`: Full PostgreSQL DDL (users, profiles, rooms, world_blocks, inventories, sessions, audit_logs).
  - `schema/seed.sql`: Baseline room definitions and default explorer records.
- **Automation Scripts (`scripts/`)**:
  - `scripts/migrate.js`: Applies DDL migrations on PostgreSQL instances.
  - `scripts/sync_data.js`: Bi-directional bridge between JSON snapshot collections and live PostgreSQL tables.

## Managed By
This repository is managed continuously by two redundant PostgreSQL database runner nodes:
1. `yasamarium/sesydb`: Primary PostgreSQL Manager Node (5-Hour Auto-Restart Workflow)
2. `yasamarium/sesydb2`: Secondary Failover PostgreSQL Manager Node (5-Hour Auto-Restart Workflow)
