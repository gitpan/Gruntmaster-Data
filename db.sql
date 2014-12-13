CREATE TABLE users (
	id         TEXT    PRIMARY KEY,
	passphrase TEXT,   -- NOT NULL,
	admin      BOOLEAN NOT NULL DEFAULT FALSE,
	name       TEXT,  -- NOT NULL,
	email      TEXT,  -- NOT NULL,
	phone      TEXT,  -- NOT NULL,
	town       TEXT,  -- NOT NULL,
	university TEXT,  -- NOT NULL,
	level      TEXT,  -- NOT NULL,
	lastjob    BIGINT
);

CREATE TABLE contests (
	id    TEXT PRIMARY KEY,
	name  TEXT NOT NULL,
	start INT  NOT NULL,
	stop  INT  NOT NULL,
	owner TEXT NOT NULL REFERENCES users ON DELETE CASCADE,
	CONSTRAINT positive_duration CHECK (stop > start)
);

CREATE TABLE contest_status (
	contest TEXT NOT NULL REFERENCES contests ON DELETE CASCADE,
	owner   TEXT NOT NULL REFERENCES users ON DELETE CASCADE,
	score   INT  NOT NULL,
	rank    INT  NOT NULL,

	PRIMARY KEY (owner, contest)
);

CREATE TABLE problems (
	id        TEXT      PRIMARY KEY,
	author    TEXT,
	writer    TEXT,
	generator TEXT    NOT NULL,
	judge     TEXT    NOT NULL,
	level     TEXT    NOT NULL,
	name      TEXT    NOT NULL,
	olimit    INT,
	owner     TEXT    NOT NULL REFERENCES users ON DELETE CASCADE,
	private   BOOLEAN NOT NULL DEFAULT FALSE,
	runner    TEXT    NOT NULL,
	solution  TEXT ,
	statement TEXT    NOT NULL,
	testcnt   INT     NOT NULL,
	tests     TEXT,
	timeout   REAL    NOT NULL,
	value     INT     NOT NULL,
	genformat TEXT,
	gensource TEXT,
	verformat TEXT,
	versource TEXT
);

CREATE TABLE contest_problems (
	contest TEXT REFERENCES contests ON DELETE CASCADE,
	problem TEXT NOT NULL REFERENCES problems ON DELETE CASCADE,
	PRIMARY KEY (contest, problem)
);

CREATE TABLE jobs (
	id          SERIAL  PRIMARY KEY,
	contest     TEXT    REFERENCES contests ON DELETE CASCADE,
	daemon      TEXT,
	date        BIGINT  NOT NULL,
	errors      TEXT,
	extension   TEXT    NOT NULL,
	format      TEXT    NOT NULL,
	private     BOOLEAN NOT NULL DEFAULT FALSE,
	problem     TEXT    NOT NULL REFERENCES problems ON DELETE CASCADE,
	result      INT,
	result_text TEXT,
	results     TEXT,
	source      TEXT    NOT NULL,
	owner       TEXT    NOT NULL REFERENCES users ON DELETE CASCADE
);

CREATE TABLE problem_status (
	problem TEXT    NOT NULL REFERENCES problems ON DELETE CASCADE,
	owner   TEXT    NOT NULL REFERENCES users ON DELETE CASCADE,
	job     SERIAL  NOT NULL REFERENCES jobs ON DELETE CASCADE,
	solved  BOOLEAN NOT NULL DEFAULT FALSE,

	PRIMARY KEY (owner, problem)
);

CREATE TABLE opens (
	contest TEXT   NOT NULL REFERENCES contests ON DELETE CASCADE,
	problem TEXT   NOT NULL REFERENCES problems ON DELETE CASCADE,
	owner   TEXT   NOT NULL REFERENCES users ON DELETE CASCADE,
	time    BIGINT NOT NULL,
	PRIMARY KEY (contest, problem, owner)
);
