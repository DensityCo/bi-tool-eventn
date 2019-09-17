/*
 *	meta_space
 */
CREATE TABLE IF NOT EXISTS meta_space (
  `id` VARCHAR(64) NOT NULL,
  `name` VARCHAR(128) NULL,
  `description` VARCHAR(256) NULL,
  `space_type` VARCHAR(64) NULL,
  `capacity` int DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY `space_id` (`id`)
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_bin;


/*
 *	meta_space_doorway
 */
CREATE TABLE IF NOT EXISTS meta_space_doorway (
  id int NOT NULL AUTO_INCREMENT,
  space_id VARCHAR(64) NOT NULL,
  doorway_id VARCHAR(64) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY `meta_space_doorway_space_id_doorway_id` (`space_id`, `doorway_id`)
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_bin;


/*
 *	doorway_minute
 */
CREATE TABLE IF NOT EXISTS doorway_minute (
  id int NOT NULL AUTO_INCREMENT,
  doorway_id VARCHAR(64) NOT NULL,
  entrances int NOT NULL default 0,
  exits int NOT NULL default 0,
  total_events int NOT NULL default 0,
  peak_occupancy int NOT NULL default 0,
  utilization DECIMAL(5,2) NULL DEFAULT 00.00,
  timestamp DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY `doorway_minute_doorway_id` (`doorway_id`, `timestamp`)
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_bin;

CREATE INDEX doorway_minute_doorway_id_idx ON doorway_minute (doorway_id);
CREATE INDEX doorway_minute_timestamp_idx ON doorway_minute (timestamp);


/*
 *	doorway_hourly
 */
CREATE TABLE IF NOT EXISTS doorway_hourly (
  id int NOT NULL AUTO_INCREMENT,
  doorway_id VARCHAR(64) NOT NULL,
  entrances int NOT NULL default 0,
  exits int NOT NULL default 0,
  total_events int NOT NULL default 0,
  peak_occupancy int NOT NULL default 0,
  utilization DECIMAL(5,2) NULL DEFAULT 00.00,
  timestamp DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY `doorway_hourly_doorway_id` (`doorway_id`, `timestamp`)
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_bin;

CREATE INDEX doorway_hourly_doorway_id_idx ON doorway_hourly (doorway_id);
CREATE INDEX doorway_hourly_timestamp_idx ON doorway_hourly (timestamp);


/*
 *	doorway_daily
 */
CREATE TABLE IF NOT EXISTS doorway_daily (
  id int NOT NULL AUTO_INCREMENT,
  doorway_id VARCHAR(64) NOT NULL,
  entrances int NOT NULL default 0,
  exits int NOT NULL default 0,
  total_events int NOT NULL default 0,
  peak_occupancy int NOT NULL default 0,
  utilization DECIMAL(5,2) NULL DEFAULT 00.00,
  timestamp DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY `doorway_daily_doorway_id` (`doorway_id`, `timestamp`)
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_bin;

CREATE INDEX doorway_daily_doorway_id_idx ON doorway_daily (doorway_id);
CREATE INDEX doorway_daily_timestamp_idx ON doorway_daily (timestamp);


/*
 *	event delete_doorway_minute - delete < 12 hours
 */
DROP EVENT IF EXISTS `delete_doorway_minute`;

DELIMITER ||

CREATE 
	EVENT `delete_doorway_minute` 
	ON SCHEDULE EVERY 1 minute
	DO BEGIN
		DELETE FROM doorway_minute WHERE timestamp < DATE_SUB(NOW(), INTERVAL 12 hour);
	END
||	

DELIMITER ;