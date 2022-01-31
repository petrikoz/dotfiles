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

-- set domain for localhost
UPDATE django_site
	SET domain = 'localhost:8000'
	WHERE id = 1;
