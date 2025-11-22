using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace Horoazhon.Domain.Models;

public partial class CabinetContext : DbContext
{
    public CabinetContext()
    {
    }

    public CabinetContext(DbContextOptions<CabinetContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Connexion> Connexions { get; set; }

    public virtual DbSet<Consultation> Consultations { get; set; }

    public virtual DbSet<Medecin> Medecins { get; set; }

    public virtual DbSet<Client> Clients { get; set; }

    public virtual DbSet<Personne> Personnes { get; set; }

    public virtual DbSet<Rendezvou> Rendezvous { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {if(!optionsBuilder.IsConfigured)
        optionsBuilder.UseLazyLoadingProxies().UseSqlServer("Server=192.168.175.253;Database=cabinet2;User ID=acortes;Password=P@ssw0rd;TrustServerCertificate=true;");
    }
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Connexion>(entity =>
        {
            entity.HasKey(e => e.Idpers);

            entity.ToTable("CONNEXION");

            entity.Property(e => e.Idpers)
                .ValueGeneratedNever()
                .HasColumnName("IDPERS");
            entity.Property(e => e.Codepincon)
                .HasMaxLength(6)
                .HasColumnName("CODEPINCON");
            entity.Property(e => e.Datedernierecon)
                .HasColumnType("datetime")
                .HasColumnName("DATEDERNIERECON");
            entity.Property(e => e.Logincon)
                .HasMaxLength(255)
                .HasColumnName("LOGINCON");
            entity.Property(e => e.Mdpcon)
                .HasColumnType("text")
                .HasColumnName("MDPCON");

            entity.HasOne(d => d.IdpersNavigation).WithOne(p => p.Connexion)
                .HasForeignKey<Connexion>(d => d.Idpers)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_CONNEXION_PERSONNE");
        });

        modelBuilder.Entity<Consultation>(entity =>
        {
            entity.HasKey(e => e.Idcons);

            entity.ToTable("CONSULTATION");

            entity.Property(e => e.Idcons).HasColumnName("IDCONS");
            entity.Property(e => e.Datedebutrdv).HasColumnName("DATEDEBUTRDV");
            entity.Property(e => e.Datefinrdv).HasColumnName("DATEFINRDV");
            entity.Property(e => e.Idpersmedecin).HasColumnName("IDPERSMEDECIN");
            entity.Property(e => e.Indisponibilite)
                .HasDefaultValue(true)
                .HasColumnName("INDISPONIBILITE");
            entity.Property(e => e.Lienweb)
                .HasMaxLength(255)
                .HasColumnName("LIENWEB");
            entity.Property(e => e.Motifcons)
                .HasMaxLength(255)
                .HasColumnName("MOTIFCONS");
            entity.Property(e => e.Notecons)
                .HasColumnType("text")
                .HasColumnName("NOTECONS");
            entity.Property(e => e.Ordonnancecons)
                .HasColumnType("text")
                .HasColumnName("ORDONNANCECONS");
            entity.Property(e => e.Prixcons)
                .HasColumnType("decimal(10, 2)")
                .HasColumnName("PRIXCONS");
            entity.Property(e => e.Statutcons)
                .HasMaxLength(100)
                .HasDefaultValue("libre")
                .HasColumnName("STATUTCONS");

            entity.HasOne(d => d.Rendezvou).WithMany(p => p.Consultations)
                .HasForeignKey(d => new { d.Idpersmedecin, d.Datedebutrdv, d.Datefinrdv })
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_CONSULTATION_RENDEZVOUS");
        });

        modelBuilder.Entity<Medecin>(entity =>
        {
            entity.HasKey(e => e.Idpers);

            entity.ToTable("MEDECIN");

            entity.Property(e => e.Idpers)
                .ValueGeneratedNever()
                .HasColumnName("IDPERS");
            entity.Property(e => e.Numsiretmedecin)
                .HasMaxLength(14)
                .HasColumnName("NUMSIRETMEDECIN");
            entity.Property(e => e.Specmedecin)
                .HasMaxLength(200)
                .HasColumnName("SPECMEDECIN");

            entity.HasOne(d => d.IdpersNavigation).WithOne(p => p.Medecin)
                .HasForeignKey<Medecin>(d => d.Idpers)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_MEDECIN_PERSONNE");
        });

        modelBuilder.Entity<Client>(entity =>
        {
            entity.HasKey(e => e.Idpers);

            entity.ToTable("Client");

            entity.Property(e => e.Idpers)
                .ValueGeneratedNever()
                .HasColumnName("IDPERS");

            entity.HasOne(d => d.IdpersNavigation).WithOne(p => p.Client)
                .HasForeignKey<Client>(d => d.Idpers)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Client_PERSONNE");
        });

        modelBuilder.Entity<Personne>(entity =>
        {
            entity.HasKey(e => e.Idpers);

            entity.ToTable("PERSONNE");

            entity.Property(e => e.Idpers).HasColumnName("IDPERS");
            entity.Property(e => e.Datecreation)
                .HasColumnType("datetime")
                .HasColumnName("DATECREATION");
            entity.Property(e => e.Emailpers)
                .HasMaxLength(255)
                .HasColumnName("EMAILPERS");
            entity.Property(e => e.Nompers)
                .HasMaxLength(255)
                .HasColumnName("NOMPERS");
            entity.Property(e => e.Prenompers)
                .HasMaxLength(255)
                .HasColumnName("PRENOMPERS");
            entity.Property(e => e.Rolepers)
                .HasMaxLength(100)
                .HasColumnName("ROLEPERS");
            entity.Property(e => e.Telpers)
                .HasMaxLength(10)
                .HasColumnName("TELPERS");
        });

        modelBuilder.Entity<Rendezvou>(entity =>
        {
            entity.HasKey(e => new { e.Idpersmedecin, e.Datedebutrdv, e.Datefinrdv });

            entity.ToTable("RENDEZVOUS");

            entity.Property(e => e.Idpersmedecin).HasColumnName("IDPERSMEDECIN");
            entity.Property(e => e.Datedebutrdv).HasColumnName("DATEDEBUTRDV");
            entity.Property(e => e.Datefinrdv).HasColumnName("DATEFINRDV");
            entity.Property(e => e.Commentairerdv)
                .HasMaxLength(255)
                .HasColumnName("COMMENTAIRERDV");
            entity.Property(e => e.Disponibilite).HasColumnName("DISPONIBILITE");
            entity.Property(e => e.IdpersClient).HasColumnName("IDPERSClient");

            entity.HasOne(d => d.IdpersmedecinNavigation).WithMany(p => p.Rendezvous)
                .HasForeignKey(d => d.Idpersmedecin)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_RENDEZVOUS_MEDECIN");

            entity.HasOne(d => d.IdpersClientNavigation).WithMany(p => p.Rendezvous)
                .HasForeignKey(d => d.IdpersClient)
                .HasConstraintName("FK_RENDEZVOUS_Client");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
