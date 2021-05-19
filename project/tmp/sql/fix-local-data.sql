-- set superuser's password to 'Qwer123$'
UPDATE auth_user
    SET password = 'pbkdf2_sha256$36000$mUvjGNuoKowK$6iG/ciPVfyrsNqNAZYlsS5HUD7k/OiZrG1QosbB+Up8='
    WHERE username = 'admin';
