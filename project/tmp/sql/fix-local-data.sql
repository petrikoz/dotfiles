-- set superuser:
INSERT INTO
	auth_user (
		password,
		is_superuser,
		username,
		first_name,
		last_name,
		email,
		is_staff,
		is_active,
		date_joined
	)
VALUES (
	-- 'Qwer123$'
	'pbkdf2_sha256$36000$mUvjGNuoKowK$6iG/ciPVfyrsNqNAZYlsS5HUD7k/OiZrG1QosbB+Up8=',
	true,
	'admin',
	'Super',
	'Admin',
	'admin@example.com',
	true,
	true,
	now()
) ON CONFLICT
	ON CONSTRAINT auth_user_username_key
DO UPDATE SET
	password = EXCLUDED.password,
	is_superuser=EXCLUDED.is_superuser,
	username = EXCLUDED.username,
	is_staff=EXCLUDED.is_staff,
	is_active=EXCLUDED.is_active;

-- set superuser's authtoken:
INSERT INTO
	authtoken_token (
		key,
		created,
		user_id
	)
VALUES (
	'236cdd541215b122fd3415de0155664f7512221a',
	now(),
	(SELECT id FROM auth_user WHERE username = 'admin' LIMIT 1)
) ON CONFLICT
	ON CONSTRAINT authtoken_token_user_id_key
DO UPDATE SET
	key = EXCLUDED.key;

-- set domain for localhost
UPDATE django_site
	SET domain = 'localhost:8000'
	WHERE id = 1;
