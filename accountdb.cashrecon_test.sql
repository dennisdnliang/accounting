
-------------------------------------------------------------------------------------
----------------------------------ROLES----------------------------------------------

DROP ROLE auth_user;
DROP TABLE cashrecon.journal_audit;

DROP TABLE cashrecon.transactions;
DROP TABLE audit.transactions_audit;

DROP TABLE cashrecon.mtg_loan_bal_details;
DROP TABLE audit.mtg_loan_bal_details_audit;

SELECT * FROM cashrecon.transactions order by transaction_id desc;

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
CREATE UNIQUE INDEX transaction_idx ON cashrecon.transactions (transaction_id DESC NULLS LAST);
DROP INDEX transaction_idx CASCADE;
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------


INSERT INTO cashrecon.journal_audit VALUES(DEFAULT, user,'ins',now());

REVOKE ALL ON ALL TABLES IN SCHEMA cashrecon FROM python;
GRANT SELECT ON cashrecon.journal TO public;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA cashrecon FROM public;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA cashrecon FROM public;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA cashrecon FROM public;

GRANT USAGE ON SCHEMA cashrecon TO public;
GRANT SELECT ON ALL TABLES IN SCHEMA cashrecon TO public;

GRANT USAGE ON SCHEMA cashrecon to python;
GRANT SELECT ON SCHEMA cashrecon TO python;
GRANT ALL ON cashrecon.journal TO python;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA cashrecon FROM python;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA cashrecon FROM python;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA cashrecon FROM python;
DROP USER python;

REASSIGN OWNED BY python TO auth_user;
DROP OWNED BY python;
DROP ROLE python;

SELECT * FROM cashrecon.journal;
SELECT * FROM audit.journal_audit;

SELECT * FROM cashrecon.accounts;
SELECT * FROM audit.accounts_audit;

SELECT * FROM cashrecon.transactions;
SELECT * FROM audit.transactions_audit;

--DROP TRIGGER IF EXISTS validate_rj ON cashrecon.journal;
--DROP TRIGGER IF EXISTS journal_audit ON cashrecon.journal;
--DROP TRIGGER IF EXISTS accounts_audit on cashrecon.accounts;

--DROP FUNCTION cashrecon.check_rels_and_kill;

-- Actual parameter values may differ, what you see is a default string representation of values
INSERT INTO cashrecon.journal ("date",description,account,invoice,amount,amt_deferred)
VALUES ('2019-03-20 00:00:00.000','ABCDe','124','7',1245,0);
INSERT INTO cashrecon.journal ("date",description,account,invoice,amount,amt_rec_pay)
VALUES ('2019-02-03 00:00:00.000','slk3','345','76',1559,0);

SELECT * from cashrecon.accounts;
SELECT * FROM cashrecon.accounts_audit;


----------------------------------

SELECT * FROM cashrecon.accounts;
DROP TABLE IF EXISTS cashrecon.journal;
   
SELECT * from cashrecon.journal;
INSERT INTO cashrecon.journal (description) values ('ABCD');

DROP DATABASE cashrecon;
DROP SCHEMA cashrecon;




use cashrecon;
select * from cashrecon.journal;
select * from cashrecon.accounts;

select * from cashrecon.journal where date > '2019-03-20';

DROP TABLE IF EXISTS cashrecon.journal;
DROP TABLE IF EXISTS cashrecon.accounts;
DROP TABLE IF EXISTS cashrecon.journal_audit;

DROP PROCEDURE IF EXISTS cashrecon.check_jid_rels_and_kill;
DROP TRIGGER IF EXISTS cashrecon.validate_rj_on_insert;
DROP TRIGGER IF EXISTS cashrecon.validate_rj_on_update;
DROP TRIGGER IF EXISTS cashrecon.fill_amt_on_update;
DROP TRIGGER IF EXISTS cashrecon.fill_amt_on_insert;