-------------------------------------------------------------------------------------
----------------------------CREATE ROLES AND GROUPS----------------------------------

REVOKE ALL ON ALL TABLES IN SCHEMA cashrecon FROM public;
GRANT SELECT ON ALL TABLES IN SCHEMA cashrecon TO public;

REVOKE ALL ON ALL TABLES IN SCHEMA audit FROM public;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO public;

GRANT USAGE ON SCHEMA cashrecon TO public;
GRANT USAGE ON SCHEMA audit TO public;

--------------------------------auth_auditorS---------------------------------------------

CREATE ROLE auth_auditors WITH ENCRYPTED PASSWORD 'xxxxxxxxxx';
GRANT ALL ON ALL TABLES IN SCHEMA audit TO auth_auditors;
GRANT USAGE ON SCHEMA audit TO auth_auditors;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA audit TO auth_auditors;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA audit TO auth_auditors;

ALTER FUNCTION audit.process_audit() OWNER TO auth_auditors;

CREATE ROLE auth_auth_auditor1 WITH LOGIN ENCRYPTED PASSWORD 'XXXXXXX' INHERIT;
GRANT auth_auditors to auth_auth_auditor1;

-------------------------------- L1 USERS -------------------------------------------

CREATE ROLE loaders WITH ENCRYPTED PASSWORD 'yyyyyyyyyyy';
GRANT ALL ON ALL TABLES IN SCHEMA cashrecon TO loaders;
GRANT USAGE ON SCHEMA cashrecon TO loaders;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA cashrecon TO loaders;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA cashrecon TO loaders;

CREATE ROLE python WITH LOGIN ENCRYPTED PASSWORD 'YYYYYYYYY' INHERIT;
GRANT loaders to python;


--------------------------------DROP ROLES-------------------------------------------

REASSIGN OWNED BY auth_auth_auditor1 TO auth_user;
DROP OWNED BY auth_auth_auditor1;
DROP ROLE auth_auth_auditor1;

REASSIGN OWNED BY auth_auditors TO auth_user;
DROP OWNED BY auth_auditors;
DROP ROLE auth_auditors;

REASSIGN OWNED BY python TO auth_user;
DROP OWNED BY python;
DROP ROLE python;

REASSIGN OWNED BY loaders TO auth_user;
DROP OWNED BY loaders;
DROP ROLE loaders;

