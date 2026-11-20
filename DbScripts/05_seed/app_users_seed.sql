--liquibase formatted sql
--changeset platform-dba:app_users_seed runOnChange:true

MERGE INTO app_users t
USING (
  SELECT 'alice' AS username,'alice@example.com' AS email FROM dual 
  UNION ALL
  SELECT 'bob'   AS username, 'bob@example.com'   AS email FROM dual
) s
ON (t.username = s.username)
WHEN MATCHED THEN
  UPDATE SET t.email = s.email
WHEN NOT MATCHED THEN
  INSERT (username,email) VALUES (s.username,s.email);

COMMIT;
