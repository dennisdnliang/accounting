CREATE DATABASE accountdb;
CREATE SCHEMA cashrecon;

-------------------------------------------------------------------------------------
----------------------------------Tables---------------------------------------------
CREATE TABLE cashrecon.journal (
	journ_id			SERIAL PRIMARY KEY,
	date				TIMESTAMP, -- format 2019-03-20 00:00:00
    description			VARCHAR(225),
    account				VARCHAR(225),
    invoice				VARCHAR(225),
    amount				DECIMAL(18,4),
    amt_rec_pay			DECIMAL(18,4),
    amt_deferred		DECIMAL(18,4),
    related_journ_id 	INT
    --check (related_journ_id in (select journ_id from cashrecon.test) or related_journ_id is null)
);
   
CREATE TABLE cashrecon.accounts (
	account_id			SERIAL PRIMARY KEY,
    bank				VARCHAR(225),
    description			VARCHAR(225),
    account_number		VARCHAR(225),
    type				VARCHAR(225),
    balance				DECIMAL(18,4),
    tot_amt_rec_pay		DECIMAL(18,4),
    tot_amt_deferred	DECIMAL(18,4),
    CONSTRAINT acc_types CHECK (type IN ('CHECKING','SAVING','BROKERAGE'))
);

-------------------------------------------------------------------------------------
----------------------------------Bank Statement Tables------------------------------

CREATE TABLE cashrecon.transactions (
	transaction_id		SERIAL PRIMARY KEY,
	account_id			INT,
    bank				VARCHAR(225),
    account_number		VARCHAR(225),
    transaction_date	TIMESTAMP,
    post_date			TIMESTAMP,
    description			VARCHAR(225),
    addl_info			VARCHAR(225),
    category			VARCHAR(225),    
    transaction_type	VARCHAR(225), 
    transact_amt		DECIMAL(18,4),
    status				VARCHAR(225),
    reference_number	VARCHAR(225),
    reported_bal		DECIMAL(18,4),
    balance				DECIMAL(18,4)
);

-------------------------------------------------------------------------------------
----------------------------------MTG Escrow and PMT Table---------------------------

CREATE TABLE cashrecon.mtg_loan_bal_details (
	loan_bal_id			SERIAL PRIMARY KEY,
	account_id			INT,
    bank				VARCHAR(225),
    account_number		VARCHAR(225),
    addl_info			VARCHAR(225),
    eff_date			TIMESTAMP,
    due_date			TIMESTAMP,
    description			VARCHAR(225),
    --------------------------------Values-------------------------------------------  
    transaction_amt		DECIMAL(18,4),
    principal_amt		DECIMAL(18,4),
    interest_amt		DECIMAL(18,4),
    escrow_amt			DECIMAL(18,4),
    escrow_bal			DECIMAL(18,4),
    curtailment_bal		DECIMAL(18,4),
    late_chg_amt		DECIMAL(18,4),
    late_chg_bal		DECIMAL(18,4),
    fee_amt				DECIMAL(18,4),
    fee_bal				DECIMAL(18,4),
    unapplied_amt		DECIMAL(18,4),
    unapplied_bal		DECIMAL(18,4)
);


-------------------------------------------------------------------------------------
----------------------------------Validate Related Entries---------------------------

CREATE TRIGGER validate_rj
	AFTER INSERT OR UPDATE ON cashrecon.journal
	FOR EACH ROW
	EXECUTE PROCEDURE cashrecon.check_jid_rels_and_kill();


CREATE OR REPLACE FUNCTION cashrecon.check_jid_rels_and_kill()
RETURNS TRIGGER AS $$
	BEGIN
		IF (NEW.related_journ_id NOT IN
			(SELECT journ_id FROM cashrecon.journal)
			AND NEW.related_journ_id IS NOT NULL) 
			THEN
				RAISE EXCEPTION 'ERROR: Related Jorn ID Must Already Exist or is in-line Journ ID!';
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------------
----------------------------------FILL AMT TRIGGER-----------------------------------

CREATE TRIGGER fill_amt
	BEFORE INSERT OR UPDATE ON cashrecon.journal
	FOR EACH ROW
	EXECUTE PROCEDURE cashrecon.calc_amt ();

CREATE OR REPLACE FUNCTION cashrecon.calc_amt()
RETURNS TRIGGER AS $$
	BEGIN
		CASE
			WHEN NEW.amount IS NOT NULL AND NEW.amt_rec_pay IS NOT NULL AND NEW.amt_deferred IS NOT NULL
			THEN
				IF(NEW.amount != NEW.amt_rec_pay + NEW.amt_deferred)
				THEN
					RAISE EXCEPTION 'ERROR: AMT Does Not SUM Correctly!';
				END IF;
			WHEN NEW.amount IS NOT NULL AND NEW.amt_rec_pay IS NOT NULL AND NEW.amt_deferred IS NULL
			THEN
				NEW.amt_deferred := NEW.amount - NEW.amt_rec_pay;
			WHEN NEW.amount IS NOT NULL AND NEW.amt_rec_pay IS NULL AND NEW.amt_deferred IS NOT NULL
			THEN
				NEW.amt_rec_pay := NEW.amount - NEW.amt_deferred;
			WHEN NEW.amount IS NULL AND NEW.amt_rec_pay IS NOT NULL AND NEW.amt_deferred IS NOT NULL
			THEN
				NEW.amount := NEW.amt_rec_pay + NEW.amt_deferred;
			ELSE
				RAISE EXCEPTION 'ERROR: At Least 2 AMT fields must not be NULL!';
		END CASE;
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------------
----------------------------------AUDIT TABLES---------------------------------------

CREATE SCHEMA audit;

CREATE TABLE audit.journal_audit(
	audit_id			SERIAL PRIMARY KEY,
	userid				TEXT NOT NULL,
	operation 			CHAR(3) NOT NULL,
	mod_time			TIMESTAMP,
	---------------------------------------
	journ_id			INT,
	date				TIMESTAMP, -- format 2019-03-20 00:00:00
    description			VARCHAR(225),
    account				VARCHAR(225),
    invoice				VARCHAR(225),
    amount				DECIMAL(18,4),
    amt_rec_pay			DECIMAL(18,4),
    amt_deferred		DECIMAL(18,4),
    related_journ_id 	INT
);

CREATE TABLE audit.accounts_audit(
	audit_id			SERIAL PRIMARY KEY,
	userid				TEXT NOT NULL,
	operation 			CHAR(3) NOT NULL,
	mod_time			TIMESTAMP,
	---------------------------------------
	account_id			INT,
    bank				VARCHAR(225),
    description			VARCHAR(225),
    account_number		VARCHAR(225),
    type				VARCHAR(225),
    balance				DECIMAL(18,4),
    tot_amt_rec_pay		DECIMAL(18,4),
    tot_amt_deferred	DECIMAL(18,4)
);

CREATE TABLE audit.transactions_audit(
	audit_id			SERIAL PRIMARY KEY,
	userid				TEXT NOT NULL,
	operation 			CHAR(3) NOT NULL,
	mod_time			TIMESTAMP,
	---------------------------------------
	transaction_id		INT,
	account_id			INT,
    bank				VARCHAR(225),
    account_number		VARCHAR(225),
    transaction_date	TIMESTAMP,
    post_date			TIMESTAMP,
    description			VARCHAR(225),
    addl_info			VARCHAR(225),
    category			VARCHAR(225),    
    transaction_type	VARCHAR(225), 
    transact_amt		DECIMAL(18,4),
    status				VARCHAR(225),
    reference_number	VARCHAR(225),
    reported_bal		DECIMAL(18,4),
    balance				DECIMAL(18,4)
);

CREATE TABLE audit.mtg_loan_bal_details_audit (
	audit_id			SERIAL PRIMARY KEY,
	userid				TEXT NOT NULL,
	operation 			CHAR(3) NOT NULL,
	mod_time			TIMESTAMP,
	---------------------------------------
	loan_bal_id			INT,
	account_id			INT,
    bank				VARCHAR(225),
    account_number		VARCHAR(225),
    addl_info			VARCHAR(225),
    eff_date			TIMESTAMP,
    due_date			TIMESTAMP,
    description			VARCHAR(225),
    --------------------------------Values-------------------------------------------  
    transaction_amt		DECIMAL(18,4),
    principal_amt		DECIMAL(18,4),
    interest_amt		DECIMAL(18,4),
    escrow_amt			DECIMAL(18,4),
    escrow_bal			DECIMAL(18,4),
    curtailment_bal		DECIMAL(18,4),
    late_chg_amt		DECIMAL(18,4),
    late_chg_bal		DECIMAL(18,4),
    fee_amt				DECIMAL(18,4),
    fee_bal				DECIMAL(18,4),
    unapplied_amt		DECIMAL(18,4),
    unapplied_bal		DECIMAL(18,4)
);

CREATE TRIGGER zz_journal_audit
	AFTER INSERT OR UPDATE OR DELETE ON cashrecon.journal
	FOR EACH ROW EXECUTE PROCEDURE audit.process_audit();

CREATE TRIGGER zz_accounts_audit
	AFTER INSERT OR UPDATE OR DELETE ON cashrecon.accounts
	FOR EACH ROW EXECUTE PROCEDURE audit.process_audit();

CREATE TRIGGER zz_transactions_audit
	AFTER INSERT OR UPDATE OR DELETE ON cashrecon.transactions
	FOR EACH ROW EXECUTE PROCEDURE audit.process_audit();

CREATE TRIGGER zz_mtg_loan_bal_details_audit
	AFTER INSERT OR UPDATE OR DELETE ON cashrecon.mtg_loan_bal_details
	FOR EACH ROW EXECUTE PROCEDURE audit.process_audit();

CREATE OR REPLACE FUNCTION audit.process_audit()
RETURNS TRIGGER AS $$
	BEGIN
		CASE TG_OP
			WHEN 'DELETE' THEN
				EXECUTE format ('INSERT INTO audit.%I_audit VALUES(DEFAULT,session_user,%s,now(),$1.*)',TG_TABLE_NAME,$text$'del'$text$) USING OLD;
				RETURN OLD;
			WHEN 'UPDATE' THEN
				EXECUTE format ('INSERT INTO audit.%I_audit VALUES(DEFAULT,session_user,%s,now(),$1.*)',TG_TABLE_NAME,$text$'u_d'$text$) USING OLD;
				EXECUTE format ('INSERT INTO audit.%I_audit VALUES(DEFAULT,session_user,%s,now(),$1.*)',TG_TABLE_NAME,$text$'u_i'$text$) USING NEW;
				RETURN NEW;
			WHEN 'INSERT' THEN
				EXECUTE format ('INSERT INTO audit.%I_audit VALUES(DEFAULT,session_user,%s,now(),$1.*)',TG_TABLE_NAME,$text$'ins'$text$) USING NEW;
				RETURN NEW;
		END CASE;
	END;
$$ LANGUAGE plpgsql
	SECURITY DEFINER
	SET search_path = cashrecon, pg_temp;
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
