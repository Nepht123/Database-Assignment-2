-- =====================================================================
-- File:     schema.sql
-- Project:  CSC312 Practical Assignment 2
--           Clearpoint Financial Advisors: client, policy and claims database
-- Team:     Power Rangers
-- Members:  Rufaro Ruvarashe Chipoyera (4417552)
--           Ketsia Elengemoke-Mbombo   (4397468)
--           Amy Felix                  (4419804)
--           Harrison Ibeh              (4276312)
--           Thiana Moodley             (4323023)
--           Nephtali Mwamba            (4492340)
--
-- Purpose:  Creates the nine tables of the Clearpoint database with all
--           primary key, foreign key, unique, not-null, default and check
--           constraints. Run this file first, then data.sql.
--
-- Target:   MySQL 8.0.16 or later (CHECK constraints are only enforced
--           from 8.0.16). Run in MySQL Workbench against your OWN schema:
--           double-click your schema in the Navigator so it is in bold,
--           then open this file and run it with the lightning-bolt button.
--
-- Safe to re-run: every table is dropped first (children before parents),
-- so running schema.sql again gives you a clean, empty database.
-- =====================================================================

-- If your account is allowed to create databases, you may uncomment the
-- next two lines. If not, leave them commented and select your own schema.
-- CREATE DATABASE IF NOT EXISTS clearpoint;
-- USE clearpoint;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS claim;
DROP TABLE IF EXISTS policy;
DROP TABLE IF EXISTS goal;
DROP TABLE IF EXISTS compliance_document;
DROP TABLE IF EXISTS client;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS provider;
DROP TABLE IF EXISTS adviser_licence;
DROP TABLE IF EXISTS adviser;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- ADVISER: a licensed financial adviser employed by Clearpoint.
-- Business rule 1 (adviser side).
-- ---------------------------------------------------------------------
CREATE TABLE adviser (
    adviser_id   INT          NOT NULL,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    email        VARCHAR(100) NOT NULL,
    phone        VARCHAR(15)  NOT NULL,
    hire_date    DATE         NOT NULL,
    CONSTRAINT pk_adviser       PRIMARY KEY (adviser_id),
    CONSTRAINT uq_adviser_email UNIQUE (email)
);

-- ---------------------------------------------------------------------
-- ADVISER_LICENCE (weak): one adviser holds one or more licences.
-- PK = parent key + partial key. Business rules 7 and 13.
-- ---------------------------------------------------------------------
CREATE TABLE adviser_licence (
    adviser_id    INT          NOT NULL,
    licence_seq   TINYINT      NOT NULL,
    licence_type  VARCHAR(30)  NOT NULL,
    licence_ref   VARCHAR(20)  NOT NULL,
    issue_date    DATE         NOT NULL,
    expiry_date   DATE         NOT NULL,
    CONSTRAINT pk_adviser_licence  PRIMARY KEY (adviser_id, licence_seq),
    CONSTRAINT uq_licence_ref      UNIQUE (licence_ref),
    CONSTRAINT fk_licence_adviser  FOREIGN KEY (adviser_id)
        REFERENCES adviser (adviser_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_licence_dates    CHECK (expiry_date > issue_date)
);

-- ---------------------------------------------------------------------
-- CLIENT: each client is assigned exactly one adviser. Business rule 1.
-- address is a composite attribute split into street, city, postal code.
-- Derived (not stored): age, annual_review_due.
-- ---------------------------------------------------------------------
CREATE TABLE client (
    client_id         INT          NOT NULL,
    adviser_id        INT          NOT NULL,
    first_name        VARCHAR(50)  NOT NULL,
    last_name         VARCHAR(50)  NOT NULL,
    id_number         CHAR(13)     NOT NULL,
    date_of_birth     DATE         NOT NULL,
    email             VARCHAR(100) NOT NULL,
    phone             VARCHAR(15)  NOT NULL,
    address_street       VARCHAR(100) NULL,
    address_city         VARCHAR(50)  NULL,
    address_postal_code  CHAR(4)      NULL,
    onboarding_date   DATE         NOT NULL,
    last_review_date  DATE         NULL,
    CONSTRAINT pk_client           PRIMARY KEY (client_id),
    CONSTRAINT uq_client_id_number UNIQUE (id_number),
    CONSTRAINT uq_client_email     UNIQUE (email),
    CONSTRAINT fk_client_adviser   FOREIGN KEY (adviser_id)
        REFERENCES adviser (adviser_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------
-- COMPLIANCE_DOCUMENT (weak): signed onboarding documents (FICA, POPIA,
-- FAIS disclosure). PK = parent key + partial key. Business rule 5.
-- "Signed on or before onboarding" compares two tables, so it is checked
-- by the application, not by a constraint (see report section 2.4).
-- ---------------------------------------------------------------------
CREATE TABLE compliance_document (
    client_id       INT          NOT NULL,
    document_no     TINYINT      NOT NULL,
    document_type   VARCHAR(30)  NOT NULL,
    signed_date     DATE         NOT NULL,
    file_reference  VARCHAR(60)  NOT NULL,
    CONSTRAINT pk_compliance_document PRIMARY KEY (client_id, document_no),
    CONSTRAINT fk_document_client     FOREIGN KEY (client_id)
        REFERENCES client (client_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------
-- GOAL: a client's financial goals. Business rules 6 and 14.
-- ---------------------------------------------------------------------
CREATE TABLE goal (
    goal_id        INT           NOT NULL,
    client_id      INT           NOT NULL,
    goal_type      VARCHAR(20)   NOT NULL,
    description    VARCHAR(150)  NOT NULL,
    target_amount  DECIMAL(12,2) NULL,
    target_date    DATE          NOT NULL,
    status         VARCHAR(10)   NOT NULL DEFAULT 'Active',
    CONSTRAINT pk_goal          PRIMARY KEY (goal_id),
    CONSTRAINT fk_goal_client   FOREIGN KEY (client_id)
        REFERENCES client (client_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_goal_amount   CHECK (target_amount IS NULL
                                       OR target_amount > 0),
    CONSTRAINT ck_goal_status   CHECK (status IN
        ('Active', 'Achieved', 'Abandoned'))
);

-- ---------------------------------------------------------------------
-- PROVIDER: an insurer or investment house whose products Clearpoint
-- sells. Business rule 2 (provider side).
-- ---------------------------------------------------------------------
CREATE TABLE provider (
    provider_id    INT          NOT NULL,
    provider_name  VARCHAR(80)  NOT NULL,
    fsp_number     VARCHAR(10)  NOT NULL,
    contact_email  VARCHAR(100) NOT NULL,
    contact_phone  VARCHAR(15)  NULL,
    CONSTRAINT pk_provider       PRIMARY KEY (provider_id),
    CONSTRAINT uq_provider_name  UNIQUE (provider_name),
    CONSTRAINT uq_provider_fsp   UNIQUE (fsp_number)
);

-- ---------------------------------------------------------------------
-- PRODUCT: a catalogue item offered by exactly one provider.
-- Business rules 2 and 12.
-- ---------------------------------------------------------------------
CREATE TABLE product (
    product_id    INT           NOT NULL,
    provider_id   INT           NOT NULL,
    product_name  VARCHAR(80)   NOT NULL,
    category      VARCHAR(10)   NOT NULL,
    description   VARCHAR(200)  NULL,
    base_premium  DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_product           PRIMARY KEY (product_id),
    CONSTRAINT uq_product_name      UNIQUE (provider_id, product_name),
    CONSTRAINT fk_product_provider  FOREIGN KEY (provider_id)
        REFERENCES provider (provider_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_product_category  CHECK (category IN
        ('Insurance', 'Investment')),
    CONSTRAINT ck_product_premium   CHECK (base_premium > 0)
);

-- ---------------------------------------------------------------------
-- POLICY (bridge): resolves the CLIENT to PRODUCT many-to-many.
-- Surrogate PK because the same client may hold the same product more
-- than once. Business rules 3 and 11. Derived (not stored): renewal_due_date.
-- start_date is the start of the current term.
-- ---------------------------------------------------------------------
CREATE TABLE policy (
    policy_id       INT           NOT NULL,
    client_id       INT           NOT NULL,
    product_id      INT           NOT NULL,
    policy_number   VARCHAR(12)   NOT NULL,
    start_date      DATE          NOT NULL,
    term_months     SMALLINT      NOT NULL,
    premium_amount  DECIMAL(10,2) NOT NULL,
    status          VARCHAR(10)   NOT NULL DEFAULT 'Active',
    CONSTRAINT pk_policy          PRIMARY KEY (policy_id),
    CONSTRAINT uq_policy_number   UNIQUE (policy_number),
    CONSTRAINT fk_policy_client   FOREIGN KEY (client_id)
        REFERENCES client (client_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_policy_product  FOREIGN KEY (product_id)
        REFERENCES product (product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_policy_term     CHECK (term_months > 0),
    CONSTRAINT ck_policy_premium  CHECK (premium_amount > 0),
    CONSTRAINT ck_policy_status   CHECK (status IN
        ('Active', 'Lapsed', 'Cancelled', 'Expired'))
);

-- ---------------------------------------------------------------------
-- CLAIM: lodged against exactly one policy and tracked to close.
-- Business rules 4, 9 and 10. Derived (not stored): claim_duration.
-- closed_date is filled in only when the claim's status is Closed.
-- ---------------------------------------------------------------------
CREATE TABLE claim (
    claim_id              INT           NOT NULL,
    policy_id             INT           NOT NULL,
    claim_number          VARCHAR(14)   NOT NULL,
    incident_date         DATE          NOT NULL,
    incident_description  VARCHAR(200)  NOT NULL,
    date_reported         DATE          NOT NULL,
    claim_amount          DECIMAL(12,2) NOT NULL,
    status                VARCHAR(12)   NOT NULL DEFAULT 'Lodged',
    closed_date           DATE          NULL,
    CONSTRAINT pk_claim          PRIMARY KEY (claim_id),
    CONSTRAINT uq_claim_number   UNIQUE (claim_number),
    CONSTRAINT fk_claim_policy   FOREIGN KEY (policy_id)
        REFERENCES policy (policy_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_claim_amount   CHECK (claim_amount > 0),
    CONSTRAINT ck_claim_status   CHECK (status IN
        ('Lodged', 'Under Review', 'Approved', 'Rejected', 'Closed')),
    CONSTRAINT ck_claim_reported CHECK (date_reported >= incident_date),
    CONSTRAINT ck_claim_closed   CHECK (closed_date IS NULL
                                        OR closed_date >= date_reported),
    CONSTRAINT ck_claim_open     CHECK ((status = 'Closed')
                                        = (closed_date IS NOT NULL))
);
