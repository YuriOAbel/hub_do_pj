import 'package:freezed_annotation/freezed_annotation.dart';

part 'cnd_catalog_model.freezed.dart';
part 'cnd_catalog_model.g.dart';

@freezed
class CndCertificateItem with _$CndCertificateItem {
  const factory CndCertificateItem({
    required String id,
    required String slug,
    required String name,
    String? subtitle,
  }) = _CndCertificateItem;

  factory CndCertificateItem.fromJson(Map<String, dynamic> json) =>
      _$CndCertificateItemFromJson(json);
}

@freezed
class CndCatalogProduct with _$CndCatalogProduct {
  const factory CndCatalogProduct({
    required String id,
    required String kind,
    required String name,
    required String shortLabel,
    required int priceCents,
  }) = _CndCatalogProduct;

  factory CndCatalogProduct.fromJson(Map<String, dynamic> json) =>
      _$CndCatalogProductFromJson(json);
}

@freezed
class CndCatalogModel with _$CndCatalogModel {
  const CndCatalogModel._();

  const factory CndCatalogModel({
    required String packageId,
    required String packageName,
    required String whatsappNumber,
    @Default('cnd') String defaultKind,
    @Default([]) List<CndCatalogProduct> products,
    @Default([]) List<CndCertificateItem> certificates,
  }) = _CndCatalogModel;

  factory CndCatalogModel.fromJson(Map<String, dynamic> json) =>
      _$CndCatalogModelFromJson(json);

  CndCatalogProduct? productByKind(String kind) {
    for (final product in products) {
      if (product.kind == kind) return product;
    }
    return null;
  }

  CndCatalogProduct? productById(String productId) {
    for (final product in products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  String kindForProductId(String productId) {
    return productById(productId)?.kind ?? defaultKind;
  }

  String resolveProductId(String kind) {
    return productByKind(kind)?.id ?? packageId;
  }
}
