# Square Era Database (`sedb`)

Primary Git-backed database for **Square Era** user accounts, player profiles, and personal world save states.

## Data Collections
- `data/users.json`: Player credentials, unique user IDs, and SHA-256 hashed passwords.
- `data/profiles.json`: Player save states including hotbar inventory, health, hunger, last coordinates, and playtime.
- `data/worlds.json`: Personal custom world modifications (`"x,y,z": blockId`) saved per user account.
- `data/activities.json`: Audit log of player registrations, logins, and world checkpoints.

## Integration
Games query this repository via GitHub raw endpoints and authenticate user accounts client-side with native SHA-256 hashing.
