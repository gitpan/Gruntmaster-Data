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

CREATE TABLE table_comments (
	table_name   TEXT NOT NULL PRIMARY KEY,
	comment_text TEXT NOT NULL
);

CREATE TABLE column_comments (
	table_name   TEXT NOT NULL,
	column_name  TEXT NOT NULL,
	comment_text TEXT NOT NULL,
	PRIMARY KEY (table_name, column_name)
);

INSERT INTO table_comments VALUES ('users',   'List of users');
INSERT INTO table_comments VALUES ('contests',   'List of contests');
INSERT INTO table_comments VALUES ('contest_status',   'List of (contest, user, result)');
INSERT INTO table_comments VALUES ('problems',   'List of problems');
INSERT INTO table_comments VALUES ('contest_problems', 'Many-to-many bridge between contests and problems');
INSERT INTO table_comments VALUES ('jobs',   'List of jobs');
INSERT INTO table_comments VALUES ('problem_status', 'List of (problem, user, result)');
INSERT INTO table_comments VALUES ('opens', 'List of (contest, problem, user, time when user opened problem)');

INSERT INTO column_comments VALUES ('users', 'passphrase', 'RFC2307-encoded passphrase');
INSERT INTO column_comments VALUES ('users', 'name', 'Full name of user');
INSERT INTO column_comments VALUES ('users', 'level', 'Highschool, Undergraduate, Master, Doctorate or Other');
INSERT INTO column_comments VALUES ('users', 'lastjob', 'Unix time when this user last submitted a job');

INSERT INTO column_comments VALUES ('contests', 'start', 'Unix time when contest starts');
INSERT INTO column_comments VALUES ('contests', 'stop', 'Unix time when contest ends');

INSERT INTO column_comments VALUES ('problems', 'author', 'Full name(s) of problem author(s)/problemsetter(s)/tester(s)/etc');
INSERT INTO column_comments VALUES ('problems', 'writer', 'Full name(s) of statement writer(s) (DEPRECATED)');
INSERT INTO column_comments VALUES ('problems', 'generator', 'Generator class, without the leading Gruntmaster::Daemon::Generator::');
INSERT INTO column_comments VALUES ('problems', 'runner', 'Runner class, without the leading Gruntmaster::Daemon::Runner::');
INSERT INTO column_comments VALUES ('problems', 'judge', 'Judge class, without the leading Gruntmaster::Daemon::Judge::');
INSERT INTO column_comments VALUES ('problems', 'level', 'Problem level, one of beginner, easy, medium, hard');
INSERT INTO column_comments VALUES ('problems', 'olimit', 'Output limit (in bytes)');
INSERT INTO column_comments VALUES ('problems', 'timeout', 'Time limit (in seconds)');
INSERT INTO column_comments VALUES ('problems', 'solution', 'Solution (HTML)');
INSERT INTO column_comments VALUES ('problems', 'statement', 'Statement (HTML)');
INSERT INTO column_comments VALUES ('problems', 'testcnt', 'Number of tests');
INSERT INTO column_comments VALUES ('problems', 'tests', 'JSON array of test values for ::Runner::File');
INSERT INTO column_comments VALUES ('problems', 'value', 'Problem value when used in a contest.');
INSERT INTO column_comments VALUES ('problems', 'genformat', 'Format (programming language) of the generator if using the Run generator');
INSERT INTO column_comments VALUES ('problems', 'gensource', 'Source code of generator if using the Run generator');
INSERT INTO column_comments VALUES ('problems', 'verformat', 'Format (programming language) of the verifier if using the Verifier runner');
INSERT INTO column_comments VALUES ('problems', 'versource', 'Source code of verifier if using the Verifier runner');

INSERT INTO column_comments VALUES ('jobs', 'daemon', 'hostname:PID of daemon that last executed this job. NULL if never executed');
INSERT INTO column_comments VALUES ('jobs', 'date', 'Unix time when job was submitted');
INSERT INTO column_comments VALUES ('jobs', 'errors', 'Compiler errors');
INSERT INTO column_comments VALUES ('jobs', 'extension', 'File extension of submitted program, without a leading dot');
INSERT INTO column_comments VALUES ('jobs', 'format', 'Format (programming language) of submitted program');
INSERT INTO column_comments VALUES ('jobs', 'result', 'Job result (integer constant from Gruntmaster::Daemon::Constants)');
INSERT INTO column_comments VALUES ('jobs', 'result_text', 'Job result (human-readable text)');
INSERT INTO column_comments VALUES ('jobs', 'results', 'Per-test results (JSON array of hashes with keys id (test number, counting from 1), result (integer constant from Gruntmaster::Daemon::Constants), result_text (human-readable text), time (execution time in decimal seconds))');

INSERT INTO column_comments VALUES ('problem_status', 'solved', 'True if the result is Accepted, False otherwise');
