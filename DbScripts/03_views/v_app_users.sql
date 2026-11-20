--liquibase formatted sql
--changeset platform-dba:v_app_users runOnChange:true

CREATE OR REPLACE VIEW v_app_users AS
SELECT user_id, username, email,created_at
FROM app_users;
