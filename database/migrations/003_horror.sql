-- DarkSide migration 003: horror zones / atmosphere event telemetry
-- Run this if database/schema.sql was imported before ds_horror existed.

CREATE TABLE IF NOT EXISTS ds_horror_events (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    citizenid VARCHAR(64) NULL,
    zone_id VARCHAR(64) NOT NULL,
    event_type VARCHAR(32) NOT NULL,
    effect_id VARCHAR(64) NULL,
    intensity DECIMAL(5,4) NOT NULL DEFAULT 0.0000,
    coords JSON NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_ds_horror_events_citizen (citizenid),
    KEY idx_ds_horror_events_zone (zone_id),
    KEY idx_ds_horror_events_type (event_type),
    KEY idx_ds_horror_events_effect (effect_id),
    KEY idx_ds_horror_events_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ds_horror_zone_state (
    zone_id VARCHAR(64) NOT NULL,
    state VARCHAR(32) NOT NULL DEFAULT 'DORMANT',
    intensity DECIMAL(5,4) NOT NULL DEFAULT 0.0000,
    state_data JSON NULL,
    activated_at TIMESTAMP NULL DEFAULT NULL,
    expires_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (zone_id),
    KEY idx_ds_horror_zone_state_state (state),
    KEY idx_ds_horror_zone_state_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
