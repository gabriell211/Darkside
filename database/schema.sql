CREATE TABLE IF NOT EXISTS ds_characters (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(64) NOT NULL,
    clan_id VARCHAR(64) NULL,
    clan_rank INT NOT NULL DEFAULT 0,
    level INT NOT NULL DEFAULT 1,
    xp BIGINT NOT NULL DEFAULT 0,
    energy INT NOT NULL DEFAULT 100,
    max_energy INT NOT NULL DEFAULT 100,
    reputation JSON NULL,
    discoveries JSON NULL,
    story_progress JSON NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_ds_characters_citizenid (citizenid),
    KEY idx_ds_characters_clan_id (clan_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ds_player_powers (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(64) NOT NULL,
    power_id VARCHAR(64) NOT NULL,
    level INT NOT NULL DEFAULT 1,
    unlocked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_ds_player_power (citizenid, power_id),
    KEY idx_ds_player_powers_citizenid (citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ds_world_state (
    state_key VARCHAR(128) NOT NULL,
    state_value JSON NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (state_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ds_audit_logs (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(64) NULL,
    category VARCHAR(64) NOT NULL,
    action VARCHAR(128) NOT NULL,
    payload JSON NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_ds_audit_category (category),
    KEY idx_ds_audit_citizenid (citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Killer NPC runtime registry/history.
-- Active killer entities live in RedM/OneSync; this table stores their lifecycle for
-- debugging, analytics, persistence decisions and future Horror Director integration.
CREATE TABLE IF NOT EXISTS ds_killer_instances (
    instance_id VARCHAR(96) NOT NULL,
    killer_id VARCHAR(64) NOT NULL,
    owner_citizenid VARCHAR(64) NOT NULL,
    net_id INT UNSIGNED NULL,
    state VARCHAR(32) NOT NULL DEFAULT 'REQUESTED',
    target_citizenid VARCHAR(64) NULL,
    spawn_coords JSON NULL,
    failure_reason VARCHAR(128) NULL,
    despawn_reason VARCHAR(128) NULL,
    spawned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    died_at TIMESTAMP NULL DEFAULT NULL,
    despawned_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (instance_id),
    KEY idx_ds_killer_instances_killer (killer_id),
    KEY idx_ds_killer_instances_owner (owner_citizenid),
    KEY idx_ds_killer_instances_target (target_citizenid),
    KEY idx_ds_killer_instances_state (state),
    KEY idx_ds_killer_instances_spawned (spawned_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Append-only event log for killer encounters. This lets us later tune AI from real
-- data: how often a killer detects, chases, loses, attacks and dies around players.
CREATE TABLE IF NOT EXISTS ds_killer_encounters (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    instance_id VARCHAR(96) NOT NULL,
    killer_id VARCHAR(64) NOT NULL,
    citizenid VARCHAR(64) NULL,
    event_type VARCHAR(32) NOT NULL,
    payload JSON NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_ds_killer_encounters_instance (instance_id),
    KEY idx_ds_killer_encounters_killer (killer_id),
    KEY idx_ds_killer_encounters_citizen (citizenid),
    KEY idx_ds_killer_encounters_event (event_type),
    KEY idx_ds_killer_encounters_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
