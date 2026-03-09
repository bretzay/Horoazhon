class Bien {
  final int id;
  final String? rue;
  final String? ville;
  final String? codePostal;
  final String? ecoScore;
  final double? superficie;
  final String? description;
  final String? type;
  final String? dateCreation;
  final bool actif;
  final bool availableForSale;
  final bool availableForRent;
  final double? salePrice;
  final double? monthlyRent;
  final String? principalPhotoUrl;
  final int? photoCount;
  final List<String>? photoUrls;
  final Map<String, dynamic>? agence;

  Bien({
    required this.id,
    this.rue,
    this.ville,
    this.codePostal,
    this.ecoScore,
    this.superficie,
    this.description,
    this.type,
    this.dateCreation,
    this.actif = true,
    this.availableForSale = false,
    this.availableForRent = false,
    this.salePrice,
    this.monthlyRent,
    this.principalPhotoUrl,
    this.photoCount,
    this.photoUrls,
    this.agence,
  });

  factory Bien.fromJson(Map<String, dynamic> json) {
    return Bien(
      id: json['id'] as int,
      rue: json['rue'] as String?,
      ville: json['ville'] as String?,
      codePostal: json['codePostal'] as String?,
      ecoScore: json['ecoScore'] as String?,
      superficie: (json['superficie'] as num?)?.toDouble(),
      description: json['description'] as String?,
      type: json['type'] as String?,
      dateCreation: json['dateCreation'] as String?,
      actif: json['actif'] as bool? ?? true,
      availableForSale: json['availableForSale'] as bool? ?? false,
      availableForRent: json['availableForRent'] as bool? ?? false,
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      monthlyRent: (json['monthlyRent'] as num?)?.toDouble(),
      principalPhotoUrl: json['principalPhotoUrl'] as String?,
      photoCount: json['photoCount'] as int?,
      photoUrls: (json['photoUrls'] as List?)?.cast<String>(),
      agence: json['agence'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (rue != null) 'rue': rue,
      if (ville != null) 'ville': ville,
      if (codePostal != null) 'codePostal': codePostal,
      if (ecoScore != null) 'ecoScore': ecoScore,
      if (superficie != null) 'superficie': superficie,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (dateCreation != null) 'dateCreation': dateCreation,
      'actif': actif,
      'availableForSale': availableForSale,
      'availableForRent': availableForRent,
      if (salePrice != null) 'salePrice': salePrice,
      if (monthlyRent != null) 'monthlyRent': monthlyRent,
      if (principalPhotoUrl != null) 'principalPhotoUrl': principalPhotoUrl,
      if (photoCount != null) 'photoCount': photoCount,
      if (photoUrls != null) 'photoUrls': photoUrls,
      if (agence != null) 'agence': agence,
    };
  }
}
