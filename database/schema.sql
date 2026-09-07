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
