using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace Horoazhon.Domain.Models;

public partial class HoroazhonContext : DbContext
{
    public HoroazhonContext()
    {
    }

    public HoroazhonContext(DbContextOptions<HoroazhonContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Achat> Achats { get; set; }

    public virtual DbSet<Agence> Agences { get; set; }

    public virtual DbSet<Bien> Biens { get; set; }

    public virtual DbSet<Caracteristique> Caracteristiques { get; set; }

    public virtual DbSet<Contenir> Contenirs { get; set; }

    public virtual DbSet<Contrat> Contrats { get; set; }

    public virtual DbSet<Cosigner> Cosigners { get; set; }

    public virtual DbSet<Deplacer> Deplacers { get; set; }

    public virtual DbSet<Lieux> Lieuxes { get; set; }

    public virtual DbSet<Location> Locations { get; set; }

    public virtual DbSet<Personne> Personnes { get; set; }

    public virtual DbSet<Photo> Photos { get; set; }

    public virtual DbSet<Utilisateur> Utilisateurs { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Server=192.168.154.253;Database=Horoazhon;User ID=sa;Password=P@ssw0rd2025;TrustServerCertificate=true;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Achat>(entity =>
        {
            entity.HasKey(e => new { e.IdOffrir, e.Id });

            entity.ToTable("ACHAT");

            entity.Property(e => e.IdOffrir).HasColumnName("ID_OFFRIR");
            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Datedispo)
                .HasColumnType("datetime")
                .HasColumnName("DATEDISPO");
            entity.Property(e => e.IdConclure).HasColumnName("ID_CONCLURE");
            entity.Property(e => e.Prix).HasColumnName("PRIX");

            entity.HasOne(d => d.IdConclureNavigation).WithMany(p => p.Achats)
                .HasForeignKey(d => d.IdConclure)
                .HasConstraintName("FK_ACHAT_CONTRAT");

            entity.HasOne(d => d.IdOffrirNavigation).WithMany(p => p.Achats)
                .HasForeignKey(d => d.IdOffrir)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ACHAT_BIEN");
        });

        modelBuilder.Entity<Agence>(entity =>
        {
            entity.HasKey(e => e.Siret);

            entity.ToTable("AGENCE");

            entity.Property(e => e.Siret)
                .HasMaxLength(14)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("SIRET");
            entity.Property(e => e.Codepostal)
                .HasMaxLength(5)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("CODEPOSTAL");
            entity.Property(e => e.Nom)
                .HasMaxLength(64)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("NOM");
            entity.Property(e => e.Numerotva)
                .HasMaxLength(13)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("NUMEROTVA");
            entity.Property(e => e.Rue)
                .HasMaxLength(200)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("RUE");
            entity.Property(e => e.Ville)
                .HasMaxLength(64)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("VILLE");
        });

        modelBuilder.Entity<Bien>(entity =>
        {
            entity.ToTable("BIEN");

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasColumnName("ID");
            entity.Property(e => e.Codepostal)
                .HasMaxLength(5)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("CODEPOSTAL");
            entity.Property(e => e.Description)
                .HasMaxLength(500)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("DESCRIPTION");
            entity.Property(e => e.Ecoscore).HasColumnName("ECOSCORE");
            entity.Property(e => e.Rue)
                .HasMaxLength(200)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("RUE");
            entity.Property(e => e.Superficie).HasColumnName("SUPERFICIE");
            entity.Property(e => e.Type)
                .HasMaxLength(32)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("TYPE");
            entity.Property(e => e.Ville)
                .HasMaxLength(200)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("VILLE");

            entity.HasMany(d => d.Id1s).WithMany(p => p.Ids)
                .UsingEntity<Dictionary<string, object>>(
                    "Posseder",
                    r => r.HasOne<Personne>().WithMany()
                        .HasForeignKey("Id1")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK_POSSEDER_PERSONNE"),
                    l => l.HasOne<Bien>().WithMany()
                        .HasForeignKey("Id")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK_POSSEDER_BIEN"),
                    j =>
                    {
                        j.HasKey("Id", "Id1");
                        j.ToTable("POSSEDER");
                        j.IndexerProperty<short>("Id").HasColumnName("ID");
                        j.IndexerProperty<short>("Id1").HasColumnName("ID_1");
                    });
        });

        modelBuilder.Entity<Caracteristique>(entity =>
        {
            entity.ToTable("CARACTERISTIQUES");

            entity.Property(e => e.Id)
                .HasMaxLength(32)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("ID");
            entity.Property(e => e.Lib)
                .HasMaxLength(32)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("LIB");
        });

        modelBuilder.Entity<Contenir>(entity =>
        {
            entity.HasKey(e => new { e.Id, e.Id1 });

            entity.ToTable("CONTENIR");

            entity.Property(e => e.Id)
                .HasMaxLength(32)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("ID");
            entity.Property(e => e.Id1).HasColumnName("ID_1");
            entity.Property(e => e.Unite)
                .HasMaxLength(32)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("UNITE");
            entity.Property(e => e.Valeur)
                .HasMaxLength(32)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("VALEUR");

            entity.HasOne(d => d.IdNavigation).WithMany(p => p.Contenirs)
                .HasForeignKey(d => d.Id)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_CONTENIR_CARACTERISTIQUES");

            entity.HasOne(d => d.Id1Navigation).WithMany(p => p.Contenirs)
                .HasForeignKey(d => d.Id1)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_CONTENIR_BIEN");
        });

        modelBuilder.Entity<Contrat>(entity =>
        {
            entity.ToTable("CONTRAT");

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasColumnName("ID");
            entity.Property(e => e.Datecont)
                .HasColumnType("datetime")
                .HasColumnName("DATECONT");
            entity.Property(e => e.IdConclure).HasColumnName("ID_CONCLURE");
            entity.Property(e => e.IdEtreDisponible).HasColumnName("ID_ETRE_DISPONIBLE");
            entity.Property(e => e.IdOffrir).HasColumnName("ID_OFFRIR");
            entity.Property(e => e.IdSigner).HasColumnName("ID_SIGNER");

            entity.HasOne(d => d.Location).WithMany(p => p.Contrats)
                .HasForeignKey(d => new { d.IdEtreDisponible, d.IdSigner })
                .HasConstraintName("FK_CONTRAT_LOCATION");

            entity.HasOne(d => d.Achat).WithMany(p => p.Contrats)
                .HasForeignKey(d => new { d.IdOffrir, d.IdConclure })
                .HasConstraintName("FK_CONTRAT_ACHAT");
        });

        modelBuilder.Entity<Cosigner>(entity =>
        {
            entity.HasKey(e => new { e.Id, e.Id1 });

            entity.ToTable("COSIGNER");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Id1).HasColumnName("ID_1");
            entity.Property(e => e.Typesignataire)
                .HasMaxLength(32)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("TYPESIGNATAIRE");

            entity.HasOne(d => d.IdNavigation).WithMany(p => p.Cosigners)
                .HasForeignKey(d => d.Id)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_COSIGNER_PERSONNE");

            entity.HasOne(d => d.Id1Navigation).WithMany(p => p.Cosigners)
                .HasForeignKey(d => d.Id1)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_COSIGNER_CONTRAT");
        });

        modelBuilder.Entity<Deplacer>(entity =>
        {
            entity.HasKey(e => new { e.Id, e.Id1 });

            entity.ToTable("DEPLACER");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Id1).HasColumnName("ID_1");
            entity.Property(e => e.Minutes).HasColumnName("MINUTES");
            entity.Property(e => e.Typelocomotion)
                .HasMaxLength(32)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("TYPELOCOMOTION");

            entity.HasOne(d => d.IdNavigation).WithMany(p => p.Deplacers)
                .HasForeignKey(d => d.Id)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_DEPLACER_BIEN");

            entity.HasOne(d => d.Id1Navigation).WithMany(p => p.Deplacers)
                .HasForeignKey(d => d.Id1)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_DEPLACER_LIEUX");
        });

        modelBuilder.Entity<Lieux>(entity =>
        {
            entity.ToTable("LIEUX");

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasColumnName("ID");
            entity.Property(e => e.Lib).HasColumnName("LIB");
        });

        modelBuilder.Entity<Location>(entity =>
        {
            entity.HasKey(e => new { e.IdEtreDisponible, e.Id });

            entity.ToTable("LOCATION");

            entity.Property(e => e.IdEtreDisponible).HasColumnName("ID_ETRE_DISPONIBLE");
            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Caution).HasColumnName("CAUTION");
            entity.Property(e => e.Datedispo)
                .HasMaxLength(32)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("DATEDISPO");
            entity.Property(e => e.IdSigner).HasColumnName("ID_SIGNER");
            entity.Property(e => e.Mensualite).HasColumnName("MENSUALITE");

            entity.HasOne(d => d.IdEtreDisponibleNavigation).WithMany(p => p.Locations)
                .HasForeignKey(d => d.IdEtreDisponible)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_LOCATION_BIEN");

            entity.HasOne(d => d.IdSignerNavigation).WithMany(p => p.Locations)
                .HasForeignKey(d => d.IdSigner)
                .HasConstraintName("FK_LOCATION_CONTRAT");
        });

        modelBuilder.Entity<Personne>(entity =>
        {
            entity.ToTable("PERSONNE");

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasColumnName("ID");
            entity.Property(e => e.Avoirs)
                .HasDefaultValue((short)0)
                .HasColumnName("AVOIRS");
            entity.Property(e => e.CodePostal)
                .HasMaxLength(5)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("CODE_POSTAL");
            entity.Property(e => e.Datenais)
                .HasColumnType("datetime")
                .HasColumnName("DATENAIS");
            entity.Property(e => e.Derniereco)
                .HasColumnType("datetime")
                .HasColumnName("DERNIERECO");
            entity.Property(e => e.Nom)
                .HasMaxLength(64)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("NOM");
            entity.Property(e => e.Prenom)
                .HasMaxLength(32)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("PRENOM");
            entity.Property(e => e.Rib)
                .HasMaxLength(23)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("RIB");
            entity.Property(e => e.Rue)
                .HasMaxLength(200)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("RUE");
            entity.Property(e => e.Siret)
                .HasMaxLength(14)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("SIRET");
            entity.Property(e => e.Ville)
                .HasMaxLength(200)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("VILLE");

            entity.HasOne(d => d.SiretNavigation).WithMany(p => p.Personnes)
                .HasForeignKey(d => d.Siret)
                .HasConstraintName("FK_PERSONNE_AGENCE");
        });

        modelBuilder.Entity<Photo>(entity =>
        {
            entity.HasKey(e => new { e.IdApparaitre, e.Id });

            entity.ToTable("PHOTO");

            entity.Property(e => e.IdApparaitre).HasColumnName("ID_APPARAITRE");
            entity.Property(e => e.Id)
                .HasMaxLength(32)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("ID");
            entity.Property(e => e.Fichier)
                .HasMaxLength(255)
                .IsFixedLength()
                .HasColumnName("FICHIER");

            entity.HasOne(d => d.IdApparaitreNavigation).WithMany(p => p.Photos)
                .HasForeignKey(d => d.IdApparaitre)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PHOTO_BIEN");
        });

        modelBuilder.Entity<Utilisateur>(entity =>
        {
            entity.ToTable("UTILISATEUR");

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasColumnName("ID");
            entity.Property(e => e.Codepin)
                .HasMaxLength(6)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("CODEPIN");
            entity.Property(e => e.Derniereco)
                .HasColumnType("datetime")
                .HasColumnName("DERNIERECO");
            entity.Property(e => e.Email)
                .HasMaxLength(100)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("EMAIL");
            entity.Property(e => e.Login)
                .HasMaxLength(32)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("LOGIN");
            entity.Property(e => e.Mdp)
                .HasMaxLength(32)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("MDP");
            entity.Property(e => e.Niveauacces)
                .HasMaxLength(32)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("NIVEAUACCES");

            entity.HasOne(d => d.IdNavigation).WithOne(p => p.Utilisateur)
                .HasForeignKey<Utilisateur>(d => d.Id)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UTILISATEUR_PERSONNE");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
