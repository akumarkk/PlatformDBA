--liquibase formatted sql
--changeset platform-dba:pkg_app_users runOnChange:true endDelimiter:/

CREATE OR REPLACE PACKAGE pkg_app_users AS
  PROCEDURE add_user(p_username IN VARCHAR2);
END pkg_app_users;
/

CREATE OR REPLACE PACKAGE BODY pkg_app_users AS
  PROCEDURE add_user(p_username IN VARCHAR2) IS
  BEGIN
    INSERT INTO app_users (username) VALUES (p_username);
  END add_user;
END pkg_app_users;
/
