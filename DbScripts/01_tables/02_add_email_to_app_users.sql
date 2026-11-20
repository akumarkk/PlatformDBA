--liquibase formatted sql
--changeset platform-dba:add_email_to_app_users
ALTER TABLE app_users ADD (email VARCHAR2(100));