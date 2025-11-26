/*
 ----------------------------------------------------------------------------
             Génération d'une base de données pour
                        SQL Server 2005
                       (23/11/2025 11:51:24)
 ----------------------------------------------------------------------------
     Nom de la base : Horoazhon
     Projet : Espace de travail
     Auteur : *
     Date de dernière modification : 22/11/2025 16:06:00
 ----------------------------------------------------------------------------
*/

drop database Horoazhon
go

/* -----------------------------------------------------------------------------
      OUVERTURE DE LA BASE Horoazhon
----------------------------------------------------------------------------- */

create database Horoazhon
go

use Horoazhon
go



/* -----------------------------------------------------------------------------
      TABLE : TYPEBIEN
----------------------------------------------------------------------------- */

create table TYPEBIEN
  (
     ID char(32)  not null  ,
     LIB char(32)  null  
     ,
     constraint PK_TYPEBIEN primary key (ID)
  ) 
go



/* -----------------------------------------------------------------------------
      TABLE : UTILISATEUR
----------------------------------------------------------------------------- */

create table UTILISATEUR
  (
     ID smallint  not null  ,
     ID_AVOIR smallint  not null  ,
     ADRESSE varchar(128)  null  ,
     RIB varchar(128)  null  ,
     NOM char(32)  not null  ,
     PRENOM char(32)  not null  ,
     DATENAIS datetime  not null  ,
     DERNIERECO datetime  not null  
     ,
     constraint PK_UTILISATEUR primary key (ID)
  ) 
go



/*      INDEX DE UTILISATEUR      */



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
     ID_DÉFINIR char(32)  not null  ,
     ADRESSE varchar(128)  not null  ,
     ECOSCORE smallint  null  ,
     SUPERFICIE decimal(10,2)  not null  ,
     DESCRIPTION varchar(128)  not null  
     ,
     constraint PK_BIEN primary key (ID)
  ) 
go



/*      INDEX DE BIEN      */



/* -----------------------------------------------------------------------------
      TABLE : SIGNATAIRE
----------------------------------------------------------------------------- */

create table SIGNATAIRE
  (
     ID char(32)  not null  ,
     ID_1 int  not null  ,
     ID_2 smallint  not null  ,
     LIB char(32)  null  
     ,
     constraint PK_SIGNATAIRE primary key (ID)
  ) 
go



/*      INDEX DE SIGNATAIRE      */



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
     ID_CONCLURE smallint  not null  ,
     ID_SIGNER smallint  not null  ,
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
     ID smallint  not null  ,
     ID_ETRE_DISPONIBLE smallint  not null  ,
     CAUTION decimal(10,2)  not null  ,
     DATEDISPO char(32)  null  
     ,
     constraint PK_LOCATION primary key (ID)
  ) 
go



/*      INDEX DE LOCATION      */



/* -----------------------------------------------------------------------------
      TABLE : ACHAT
----------------------------------------------------------------------------- */

create table ACHAT
  (
     ID smallint  not null  ,
     ID_OFFRIR smallint  not null  ,
     PRIX decimal(10,2)  not null  ,
     DATEDISPO datetime  null  
     ,
     constraint PK_ACHAT primary key (ID)
  ) 
go



/*      INDEX DE ACHAT      */



/* -----------------------------------------------------------------------------
      TABLE : TYPELOCOMOTION
----------------------------------------------------------------------------- */

create table TYPELOCOMOTION
  (
     ID char(32)  not null  ,
     LIB char(32)  not null  
     ,
     constraint PK_TYPELOCOMOTION primary key (ID)
  ) 
go



/* -----------------------------------------------------------------------------
      TABLE : TYPEUTILISATEUR
----------------------------------------------------------------------------- */

create table TYPEUTILISATEUR
  (
     ID smallint  not null  ,
     LIB smallint  null  
     ,
     constraint PK_TYPEUTILISATEUR primary key (ID)
  ) 
go



/* -----------------------------------------------------------------------------
      TABLE : TYPESIGNATAIRE
----------------------------------------------------------------------------- */

create table TYPESIGNATAIRE
  (
     ID int  not null  ,
     LIB varchar(128)  not null  
     ,
     constraint PK_TYPESIGNATAIRE primary key (ID)
  ) 
go



/* -----------------------------------------------------------------------------
      TABLE : TYPELIEU
----------------------------------------------------------------------------- */

create table TYPELIEU
  (
     ID int  not null  ,
     LIB smallint  not null  
     ,
     constraint PK_TYPELIEU primary key (ID)
  ) 
go



/* -----------------------------------------------------------------------------
      TABLE : ETREADISTANCEDE
----------------------------------------------------------------------------- */

create table ETREADISTANCEDE
  (
     ID smallint  not null  ,
     ID_1 char(32)  not null  ,
     ID_2 int  not null  ,
     MINUTES tinyint  null  
     ,
     constraint PK_ETREADISTANCEDE primary key (ID, ID_1, ID_2)
  ) 
go



/*      INDEX DE ETREADISTANCEDE      */



/* -----------------------------------------------------------------------------
      TABLE : ETRESIGNER
----------------------------------------------------------------------------- */

create table ETRESIGNER
  (
     ID smallint  not null  ,
     ID_1 char(32)  not null  
     ,
     constraint PK_ETRESIGNER primary key (ID, ID_1)
  ) 
go



/*      INDEX DE ETRESIGNER      */



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
      TABLE : POSSÉDER
----------------------------------------------------------------------------- */

create table POSSÉDER
  (
     ID smallint  not null  ,
     ID_1 smallint  not null  
     ,
     constraint PK_POSSÉDER primary key (ID, ID_1)
  ) 
go



/*      INDEX DE POSSÉDER      */



/* -----------------------------------------------------------------------------
      REFERENCES SUR LES TABLES
----------------------------------------------------------------------------- */



alter table UTILISATEUR 
     add constraint FK_UTILISATEUR_TYPEUTILISATEUR foreign key (ID_AVOIR) 
               references TYPEUTILISATEUR (ID)
go




alter table BIEN 
     add constraint FK_BIEN_TYPEBIEN foreign key (ID_DÉFINIR) 
               references TYPEBIEN (ID)
go




alter table SIGNATAIRE 
     add constraint FK_SIGNATAIRE_TYPESIGNATAIRE foreign key (ID_1) 
               references TYPESIGNATAIRE (ID)
go




alter table SIGNATAIRE 
     add constraint FK_SIGNATAIRE_UTILISATEUR foreign key (ID_2) 
               references UTILISATEUR (ID)
go




alter table PHOTO 
     add constraint FK_PHOTO_BIEN foreign key (ID_APPARAITRE) 
               references BIEN (ID)
go




alter table CONTRAT 
     add constraint FK_CONTRAT_ACHAT foreign key (ID_CONCLURE) 
               references ACHAT (ID)
go




alter table CONTRAT 
     add constraint FK_CONTRAT_LOCATION foreign key (ID_SIGNER) 
               references LOCATION (ID)
go




alter table LOCATION 
     add constraint FK_LOCATION_BIEN foreign key (ID_ETRE_DISPONIBLE) 
               references BIEN (ID)
go




alter table ACHAT 
     add constraint FK_ACHAT_BIEN foreign key (ID_OFFRIR) 
               references BIEN (ID)
go




alter table ETREADISTANCEDE 
     add constraint FK_ETREADISTANCEDE_BIEN foreign key (ID) 
               references BIEN (ID)
go




alter table ETREADISTANCEDE 
     add constraint FK_ETREADISTANCEDE_TYPELOCOMOTION foreign key (ID_1) 
               references TYPELOCOMOTION (ID)
go




alter table ETREADISTANCEDE 
     add constraint FK_ETREADISTANCEDE_TYPELIEU foreign key (ID_2) 
               references TYPELIEU (ID)
go




alter table ETRESIGNER 
     add constraint FK_ETRESIGNER_CONTRAT foreign key (ID) 
               references CONTRAT (ID)
go




alter table ETRESIGNER 
     add constraint FK_ETRESIGNER_SIGNATAIRE foreign key (ID_1) 
               references SIGNATAIRE (ID)
go




alter table CONTENIR 
     add constraint FK_CONTENIR_CARACTERISTIQUES foreign key (ID) 
               references CARACTERISTIQUES (ID)
go




alter table CONTENIR 
     add constraint FK_CONTENIR_BIEN foreign key (ID_1) 
               references BIEN (ID)
go




alter table POSSÉDER 
     add constraint FK_POSSÉDER_BIEN foreign key (ID) 
               references BIEN (ID)
go




alter table POSSÉDER 
     add constraint FK_POSSÉDER_UTILISATEUR foreign key (ID_1) 
               references UTILISATEUR (ID)
go




/*
 -----------------------------------------------------------------------------
               FIN DE GENERATION
 -----------------------------------------------------------------------------
*/