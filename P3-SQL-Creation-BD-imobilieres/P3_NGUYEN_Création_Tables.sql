-- création de la table TYPE_BIEN
create table type_bien 
(
	code_type_bien INTEGER NOT NULL,
	type_bien VARCHAR(50) NOT NULL,
	
	PRIMARY KEY (code_type_bien)
);

-- création de la table PARCELLE
create table parcelle
(
	id_parcelle INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
	code_postal VARCHAR(5)NOT NULL,
	code_dep VARCHAR (3)NOT NULL,
	code_id_commune VARCHAR(5)NOT NULL,
	commune VARCHAR(100)NOT NULL,
	code_commune INTEGER NOT NULL,
	pref_sect VARCHAR(3),
	sect VARCHAR(2),
	no_plan VARCHAR(4)NOT NULL,
	
	PRIMARY KEY (id_parcelle)
);
-- création de la table TYPE_VOIE
create table type_voie
(
	code_type_voie INTEGER NOT NULL,
	type_voie VARCHAR(5),
	
	PRIMARY KEY (code_type_voie)
)
;
-- création de la table ADRESSE
create table adresse
(
	id_adresse INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
	no_voie INTEGER,
	b_t_q VARCHAR (1),
	code_voie VARCHAR(5) NOT NULL,
	voie VARCHAR (100) NOT NULL,
	id_parcelle INTEGER NOT NULL,
	code_type_voie INTEGER NOT NULL,
	
	PRIMARY KEY (id_adresse),
	CONSTRAINT fk_adresse_parcelle FOREIGN KEY (id_parcelle) REFERENCES parcelle (id_parcelle),
	CONSTRAINT fk_adresse_code_type_voie FOREIGN kEY (code_type_voie) REFERENCES type_voie (code_type_voie)
);

-- création de la table BIEN
create table bien
(
	id_bien INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
	lot_1er VARCHAR(10)NOT NULL,
	surf_reel_bati INTEGER NOT NULL,
	surf_carrez_1er_lot DECIMAL(10,2)NOT NULL,
	nb_pieces_princ INTEGER NOT NULL,
	nat_cult VARCHAR(5),
	nat_cult_spe VARCHAR(5),
	surf_terr INTEGER,
	code_type_bien INTEGER NOT NULL,
	id_adresse INTEGER NOT NULL,
	
	PRIMARY KEY (id_bien),
	CONSTRAINT fk_bien_type_bien FOREIGN KEY (code_type_bien) REFERENCES type_bien (code_type_bien) ON DELETE RESTRICT,
	CONSTRAINT fk_bien_adresse FOREIGN KEY (id_adresse) REFERENCES adresse (id_adresse) ON DELETE RESTRICT
);

-- création de la table VENTE
create table vente
(	
	id_vente INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
	no_dispo INTEGER NOT NULL,
	date_mutation TIMESTAMP NOT NULL,
	valeur_fonciere DECIMAL (20,2),
	nb_lots INTEGER NOT NULL,
	id_bien INTEGER NOT NULL,
	
	PRIMARY KEY (id_vente),
	CONSTRAINT fk_vente_bien FOREIGN KEY (id_bien) REFERENCES bien (id_bien) ON DELETE RESTRICT
);