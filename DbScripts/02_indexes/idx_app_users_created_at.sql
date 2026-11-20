--liquibase formatted sql
--changeset platform-dba:idx_app_users_created_at

CREATE INDEX idx_app_users_created_at ON app_users (created_at);
