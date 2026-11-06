SELECT VERSION()      AS mysql_version,
       CURRENT_USER() AS logged_in_as,
       NOW()          AS server_time;

SHOW DATABASES;

SHOW SESSION STATUS LIKE 'Ssl_cipher';

SELECT CONNECTION_TYPE
FROM performance_schema.threads
WHERE PROCESSLIST_ID = CONNECTION_ID();

SELECT @@require_secure_transport;