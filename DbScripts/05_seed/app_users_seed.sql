MERGE INTO app_users t
USING (SELECT 'alice' AS username FROM dual UNION ALL SELECT 'bob' FROM dual) s
ON (t.username = s.username)
WHEN NOT MATCHED THEN
  INSERT (username) VALUES (s.username);

COMMIT;
