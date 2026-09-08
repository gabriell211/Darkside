-- DarkSide migration 002: Killer AI persistence
-- Use this file if the initial database/schema.sql was imported before ds_killers existed.

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
