WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
WHENEVER OSERROR EXIT FAILURE
SET ECHO ON FEEDBACK ON

@@01_tables/app_users.sql
@@02_indexes/idx_app_users_created_at.sql
@@03_views/v_app_users.sql
@@04_packages/pkg_app_users.sql
@@05_seed/app_users_seed.sql

EXIT;