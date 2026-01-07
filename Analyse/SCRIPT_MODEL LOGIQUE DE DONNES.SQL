/*
 ----------------------------------------------------------------------------
             Génération d'une base de données pour
                        SQL Server 2005
                       (7/1/2026 10:16:07)
 ----------------------------------------------------------------------------
     Nom de la base : horoazhon
     Projet : Aggregation
     Auteur : *
     Date de dernière modification : 7/1/2026 10:14:36
 ----------------------------------------------------------------------------
*/

drop database horoazhon
go

/* -----------------------------------------------------------------------------
      OUVERTURE DE LA BASE horoazhon
----------------------------------------------------------------------------- */

create database horoazhon
go

use horoazhon
go



/* -----------------------------------------------------------------------------
      TABLE : LIEUX
----------------------------------------------------------------------------- */

create table LIEUX
  (
     ID int  not null  ,
     LIB smallint  not null  
     ,
     constraint PK_LIEUX primary key (ID)
  ) 
go



/* -----------------------------------------------------------------------------
      TABLE : PERSONNE
----------------------------------------------------------------------------- */

create table PERSONNE
  (
     SIRET char(14)  not null  ,
     ID smallint  not null  ,
     RUE char(200)  null  ,
     VILLE char(200)  null  ,
     CODE_POSTAL char(5)  null  ,
     RIB char(23)  null  ,
     NOM char(64)  not null  ,
     PRENOM char(32)  not null  ,
     DATENAIS datetime  not null  ,
     DERNIERECO datetime  not null  
     ,
     constraint PK_PERSONNE primary key (SIRET, ID)
  ) 
go



/*      INDEX DE PERSONNE      */



/* -----------------------------------------------------------------------------
      TABLE : UTILISATEUR
----------------------------------------------------------------------------- */

create table UTILISATEUR
  (
     SIRET char(14)  not null  ,
     ID smallint  not null  ,
     LOGIN char(32)  null  ,
     MDP char(32)  null  ,
     EMAIL char(100)  null  ,
     CODEPIN char(6)  null  ,
     DERNIERECO datetime  null  ,
     NIVEAUACCES char(32)  null  
     ,
     constraint PK_UTILISATEUR primary key (SIRET, ID)
  ) 
go



/* -----------------------------------------------------------------------------
      TABLE : CARACTERISTIQUES
----------------------------------------------------------------------------- */

create table CARACTERISTIQUES
  (
     ID char(32)  not null  ,
     LIB char(32)  not null  
     ,
     constraint PK_CARACTERISTIQUES primary key (ID)
  ) 
go



/* -----------------------------------------------------------------------------
      TABLE : BIEN
----------------------------------------------------------------------------- */

create table BIEN
  (
     ID smallint  not null  ,
     RUE char(200)  not null  ,
     VILLE char(200)  not null  ,
     CODEPOSTAL char(5)  not null  ,
     ECOSCORE smallint  null  ,
     SUPERFICIE smallint  null  ,
     DESCRIPTION char(500)  not null  ,
     TYPE char(32)  not null       CHECK (TYPE in ('Immeuble', 'Appartement', 'Maison', 'Garage', 'Parking', 'Terre arable'))
     ,
     constraint PK_BIEN primary key (ID)
  ) 
go



/* -----------------------------------------------------------------------------
      TABLE : PHOTO
----------------------------------------------------------------------------- */

create table PHOTO
  (
     ID_APPARAITRE smallint  not null  ,
     ID char(32)  not null  ,
     FICHIER binary(255)  null  
     ,
     constraint PK_PHOTO primary key (ID_APPARAITRE, ID)
  ) 
go



/*      INDEX DE PHOTO      */



/* -----------------------------------------------------------------------------
      TABLE : CONTRAT
----------------------------------------------------------------------------- */

create table CONTRAT
  (
     ID smallint  not null  ,
     ID_CONCLURE smallint  null  ,
     ID_SIGNER smallint  null  ,
     ID_OFFRIR smallint  null  ,
     ID_ETRE_DISPONIBLE smallint  null  ,
     DATECONT datetime  null  
     ,
     constraint PK_CONTRAT primary key (ID)
  ) 
go



/*      INDEX DE CONTRAT      */



/* -----------------------------------------------------------------------------
      TABLE : LOCATION
----------------------------------------------------------------------------- */

create table LOCATION
  (
     ID_ETRE_DISPONIBLE smallint  not null  ,
     ID smallint  not null  ,
     ID_SIGNER smallint  null  ,
     CAUTION smallint  not null  ,
     DATEDISPO char(32)  null  ,
     MENSUALITE smallint  not null  
     ,
     constraint PK_LOCATION primary key (ID_ETRE_DISPONIBLE, ID)
  ) 
go



/*      INDEX DE LOCATION      */



/* -----------------------------------------------------------------------------
      TABLE : ACHAT
----------------------------------------------------------------------------- */

create table ACHAT
  (
     ID_OFFRIR smallint  not null  ,
     ID smallint  not null  ,
     ID_CONCLURE smallint  null  ,
     PRIX smallint  not null  ,
     DATEDISPO datetime  null  
     ,
     constraint PK_ACHAT primary key (ID_OFFRIR, ID)
  ) 
go



/*      INDEX DE ACHAT      */



/* -----------------------------------------------------------------------------
      TABLE : AGENCE
----------------------------------------------------------------------------- */

create table AGENCE
  (
     SIRET char(14)  not null  ,
     NOM char(64)  not null  ,
     NUMEROTVA char(13)  not null  ,
     RUE char(200)  not null  ,
     VILLE char(64)  not null  ,
     CODEPOSTAL char(5)  not null  
     ,
     constraint PK_AGENCE primary key (SIRET)
  ) 
go



/* -----------------------------------------------------------------------------
      TABLE : POSSEDER
----------------------------------------------------------------------------- */

create table POSSEDER
  (
     ID smallint  not null  ,
     SIRET char(14)  not null  ,
     ID_1 smallint  not null  
     ,
     constraint PK_POSSEDER primary key (ID, SIRET, ID_1)
  ) 
go



/*      INDEX DE POSSEDER      */



/* -----------------------------------------------------------------------------
      TABLE : CONTENIR
----------------------------------------------------------------------------- */

create table CONTENIR
  (
     ID char(32)  not null  ,
     ID_1 smallint  not null  ,
     UNITE char(32)  null  ,
     VALEUR char(32)  null  
     ,
     constraint PK_CONTENIR primary key (ID, ID_1)
  ) 
go



/*      INDEX DE CONTENIR      */



/* -----------------------------------------------------------------------------
      TABLE : COSIGNER
----------------------------------------------------------------------------- */

create table COSIGNER
  (
     SIRET char(14)  not null  ,
     ID smallint  not null  ,
     ID_1 smallint  not null  ,
     TYPESIGNATAIRE char(32)  null  
     ,
     constraint PK_COSIGNER primary key (SIRET, ID, ID_1)
  ) 
go



/*      INDEX DE COSIGNER      */



/* -----------------------------------------------------------------------------
      TABLE : DEPLACER
----------------------------------------------------------------------------- */

create table DEPLACER
  (
     ID smallint  not null  ,
     ID_1 int  not null  ,
     MINUTES tinyint  null  ,
     TYPELOCOMOTION char(32)  null       CHECK (TYPELOCOMOTION in ('Pieds', 'Vélo', 'Voiture', 'Train', 'Métro', 'Bus'))
     ,
     constraint PK_DEPLACER primary key (ID, ID_1)
  ) 
go



/*      INDEX DE DEPLACER      */



/* -----------------------------------------------------------------------------
      REFERENCES SUR LES TABLES
----------------------------------------------------------------------------- */



alter table PERSONNE 
     add constraint FK_PERSONNE_AGENCE foreign key (SIRET) 
               references AGENCE (SIRET)
go




alter table UTILISATEUR 
     add constraint FK_UTILISATEUR_PERSONNE foreign key (SIRET, ID) 
               references PERSONNE (SIRET, ID)
go




alter table PHOTO 
     add constraint FK_PHOTO_BIEN foreign key (ID_APPARAITRE) 
               references BIEN (ID)
go




alter table CONTRAT 
     add constraint FK_CONTRAT_ACHAT foreign key (ID_OFFRIR, ID_CONCLURE) 
               references ACHAT (ID_OFFRIR, ID)
go




alter table CONTRAT 
     add constraint FK_CONTRAT_LOCATION foreign key (ID_ETRE_DISPONIBLE, ID_SIGNER) 
               references LOCATION (ID_ETRE_DISPONIBLE, ID)
go




alter table LOCATION 
     add constraint FK_LOCATION_CONTRAT foreign key (ID_SIGNER) 
               references CONTRAT (ID)
go




alter table LOCATION 
     add constraint FK_LOCATION_BIEN foreign key (ID_ETRE_DISPONIBLE) 
               references BIEN (ID)
go




alter table ACHAT 
     add constraint FK_ACHAT_CONTRAT foreign key (ID_CONCLURE) 
               references CONTRAT (ID)
go




alter table ACHAT 
     add constraint FK_ACHAT_BIEN foreign key (ID_OFFRIR) 
               references BIEN (ID)
go




alter table POSSEDER 
     add constraint FK_POSSEDER_BIEN foreign key (ID) 
               references BIEN (ID)
go




alter table POSSEDER 
     add constraint FK_POSSEDER_PERSONNE foreign key (SIRET, ID_1) 
               references PERSONNE (SIRET, ID)
go




alter table CONTENIR 
     add constraint FK_CONTENIR_CARACTERISTIQUES foreign key (ID) 
               references CARACTERISTIQUES (ID)
go




alter table CONTENIR 
     add constraint FK_CONTENIR_BIEN foreign key (ID_1) 
               references BIEN (ID)
go




alter table COSIGNER 
     add constraint FK_COSIGNER_PERSONNE foreign key (SIRET, ID) 
               references PERSONNE (SIRET, ID)
go




alter table COSIGNER 
     add constraint FK_COSIGNER_CONTRAT foreign key (ID_1) 
               references CONTRAT (ID)
go




alter table DEPLACER 
     add constraint FK_DEPLACER_BIEN foreign key (ID) 
               references BIEN (ID)
go




alter table DEPLACER 
     add constraint FK_DEPLACER_LIEUX foreign key (ID_1) 
               references LIEUX (ID)
go




/*
 -----------------------------------------------------------------------------
               FIN DE GENERATION
 -----------------------------------------------------------------------------
*/