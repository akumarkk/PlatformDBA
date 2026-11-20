$updates = @{
    'DbScripts\01_tables\app_users.sql'                  = "--liquibase formatted sql`r`n--changeset platform-dba:app_users"
    'DbScripts\02_indexes\idx_app_users_created_at.sql'  = "--liquibase formatted sql`r`n--changeset platform-dba:idx_app_users_created_at"
    'DbScripts\03_views\v_app_users.sql'                 = "--liquibase formatted sql`r`n--changeset platform-dba:v_app_users runOnChange:true"
    'DbScripts\05_seed\app_users_seed.sql'               = "--liquibase formatted sql`r`n--changeset platform-dba:app_users_seed runOnChange:true"
}

foreach ($file in $updates.Keys) {
    $body = Get-Content $file -Raw
    if ($body -notmatch '^--liquibase formatted sql') {
        "$($updates[$file])`r`n`r`n$body" | Set-Content $file -Encoding ASCII -NoNewline
    }
}