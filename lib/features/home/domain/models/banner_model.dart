import 'package:flutter_restaurant/common/models/product_model.dart';

class BannerModel {
  int? _id;
  String? _title;
  String? _image; // can be full URL (image_url) or path (image)
  String? _imageArUrl; // optional arabic image
  int? _productId;
  String? _createdAt;
  String? _updatedAt;
  int? _categoryId;
  String? _dimensionType; // "mobile" | "desktop"
  String? _bannerType; // e.g. "banner" | "ads"
  int? _status;
  Product? _product;

  BannerModel({
    int? id,
    String? title,
    String? image,
    String? imageArUrl,
    int? productId,
    int? status,
    String? createdAt,
    String? updatedAt,
    int? categoryId,
    String? dimensionType,
    String? bannerType,
    Product? product,
  }) {
    _id = id;
    _title = title;
    _image = image;
    _imageArUrl = imageArUrl;
    _productId = productId;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _categoryId = categoryId;
    _dimensionType = dimensionType;
    _bannerType = bannerType;
    _status = status;
    _product = product;
  }

  int? get id => _id;
  String? get title => _title;
  String? get image => _image;
  String? get imageArUrl => _imageArUrl;
  int? get productId => _productId;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  int? get categoryId => _categoryId;
  String? get dimensionType => _dimensionType;
  String? get bannerType => _bannerType;
  int? get status => _status;
  Product? get product => _product;

  BannerModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _title = json['title'];
    // backend may send `image` (path) or `image_url` (full URL)
    _image = json['image'] ?? json['image_url'];
    _imageArUrl = json['image_ar_url'];
    _productId = json['product_id'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _categoryId = json['category_id'];
    _dimensionType = json['dimension_type'];
    _bannerType = json['banner_type'];
    _status = json['status'];
    if (json['product'] != null) {
      _product = Product.fromJson(json['product']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['title'] = _title;
    data['image'] = _image;
    data['image_ar_url'] = _imageArUrl;
    data['product_id'] = _productId;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['category_id'] = _categoryId;
    data['dimension_type'] = _dimensionType;
    data['banner_type'] = _bannerType;
    data['status'] = _status;
    data['product'] = _product?.toJson();
    return data;
  }
}
