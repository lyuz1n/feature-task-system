DROP TABLE IF EXISTS feature_tasks_rewards;
DROP TABLE IF EXISTS feature_tasks_history;
DROP TABLE IF EXISTS feature_tasks_monsters;
DROP TABLE IF EXISTS feature_tasks;

CREATE TABLE IF NOT EXISTS feature_tasks (
	id INTEGER NOT NULL PRIMARY KEY,
	name VARCHAR(256) NOT NULL,
	kills INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS feature_tasks_history (
	id VARCHAR(36) PRIMARY KEY,
	player_id INTEGER NOT NULL,
	task_id INTEGER NOT NULL,
	current_kills INTEGER NOT NULL DEFAULT 0,
	status ENUM ('in_progress', 'pending_reward', 'completed', 'canceled') NOT NULL DEFAULT 'in_progress',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

	FOREIGN KEY (player_id) REFERENCES players (id)
);

CREATE TABLE IF NOT EXISTS feature_tasks_monsters (
	task_id INTEGER NOT NULL,
	name VARCHAR(256) NOT NULL,

	FOREIGN KEY (task_id) REFERENCES feature_tasks (id)
);

CREATE TABLE IF NOT EXISTS feature_tasks_rewards (
	task_id INTEGER NOT NULL,
	id INTEGER NOT NULL,
	count INTEGER NOT NULL,
	receive_only_once TINYINT NOT NULL,

	FOREIGN KEY (task_id) REFERENCES feature_tasks (id)
);
