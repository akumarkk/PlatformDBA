CREATE OR REPLACE VIEW v_app_users AS
SELECT user_id, username, created_at
FROM app_users;
