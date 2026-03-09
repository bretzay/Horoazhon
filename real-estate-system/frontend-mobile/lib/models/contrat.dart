class Contrat {
  final int id;
  final String? dateCreation;
  final String? dateModification;
  final String statut;
  final String type;
  final int? bienId;
  final String? typeContrat;
  final Map<String, dynamic>? bien;
  final bool hasSignedDocument;
  final List<CosignerDTO> cosigners;

  // Snapshot fields (copied from offer at contract creation)
  final double? snapMensualite;
  final double? snapCaution;
  final int? snapDureeMois;
  final double? snapPrix;
  final String? snapDateDispo;

  Contrat({
    required this.id,
    this.dateCreation,
    this.dateModification,
    this.statut = '',
    this.type = '',
    this.bienId,
    this.typeContrat,
    this.bien,
    this.hasSignedDocument = false,
    this.cosigners = const [],
    this.snapMensualite,
    this.snapCaution,
    this.snapDureeMois,
    this.snapPrix,
    this.snapDateDispo,
  });

  factory Contrat.fromJson(Map<String, dynamic> json) {
    return Contrat(
      id: json['id'] as int,
      dateCreation: json['dateCreation'] as String?,
      dateModification: json['dateModification'] as String?,
      statut: json['statut'] as String? ?? '',
      type: json['type'] as String? ?? '',
      bienId: json['bienId'] as int? ?? (json['bien'] as Map<String, dynamic>?)?['id'] as int?,
      typeContrat: json['typeContrat'] as String? ?? json['type'] as String?,
      bien: json['bien'] as Map<String, dynamic>?,
      hasSignedDocument: json['hasSignedDocument'] as bool? ?? false,
      cosigners: (json['cosigners'] as List?)
              ?.map((c) => CosignerDTO.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      snapMensualite: (json['snapMensualite'] as num?)?.toDouble(),
      snapCaution: (json['snapCaution'] as num?)?.toDouble(),
      snapDureeMois: json['snapDureeMois'] as int?,
      snapPrix: (json['snapPrix'] as num?)?.toDouble(),
      snapDateDispo: json['snapDateDispo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (dateCreation != null) 'dateCreation': dateCreation,
      if (dateModification != null) 'dateModification': dateModification,
      'statut': statut,
      'type': type,
      if (bienId != null) 'bienId': bienId,
      if (typeContrat != null) 'typeContrat': typeContrat,
      if (bien != null) 'bien': bien,
      'hasSignedDocument': hasSignedDocument,
      'cosigners': cosigners.map((c) => c.toJson()).toList(),
      if (snapMensualite != null) 'snapMensualite': snapMensualite,
      if (snapCaution != null) 'snapCaution': snapCaution,
      if (snapDureeMois != null) 'snapDureeMois': snapDureeMois,
      if (snapPrix != null) 'snapPrix': snapPrix,
      if (snapDateDispo != null) 'snapDateDispo': snapDateDispo,
    };
  }
}

class CosignerDTO {
  final int? personneId;
  final String? nom;
  final String? prenom;
  final String typeSignataire;

  CosignerDTO({
    this.personneId,
    this.nom,
    this.prenom,
    required this.typeSignataire,
  });

  factory CosignerDTO.fromJson(Map<String, dynamic> json) {
    return CosignerDTO(
      personneId: json['personneId'] as int?,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      typeSignataire: json['typeSignataire'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (personneId != null) 'personneId': personneId,
      if (nom != null) 'nom': nom,
      if (prenom != null) 'prenom': prenom,
      'typeSignataire': typeSignataire,
    };
  }
}
