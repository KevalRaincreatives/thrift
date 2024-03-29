///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class OrderDetailModelDataShippingAddress {
/*
{
  "first_name": "Keval",
  "last_name": "Panchal",
  "address": "p-55",
  "city": "Valsad",
  "state": "Christ Church",
  "postcode": "396020",
  "country": "Barbados"
}
*/

  String? firstName;
  String? lastName;
  String? address;
  String? city;
  String? state;
  String? postcode;
  String? country;

  OrderDetailModelDataShippingAddress({
    this.firstName,
    this.lastName,
    this.address,
    this.city,
    this.state,
    this.postcode,
    this.country,
  });
  OrderDetailModelDataShippingAddress.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name']?.toString();
    lastName = json['last_name']?.toString();
    address = json['address']?.toString();
    city = json['city']?.toString();
    state = json['state']?.toString();
    postcode = json['postcode']?.toString();
    country = json['country']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['address'] = address;
    data['city'] = city;
    data['state'] = state;
    data['postcode'] = postcode;
    data['country'] = country;
    return data;
  }
}

class OrderDetailModelDataBillingAddress {
/*
{
  "first_name": "",
  "last_name": "",
  "address": "",
  "city": "",
  "state": "",
  "postcode": "",
  "country": "",
  "email": "kevalpanchal038@gmail.com",
  "phone": "8200503309"
}
*/

  String? firstName;
  String? lastName;
  String? address;
  String? city;
  String? state;
  String? postcode;
  String? country;
  String? email;
  String? phone;

  OrderDetailModelDataBillingAddress({
    this.firstName,
    this.lastName,
    this.address,
    this.city,
    this.state,
    this.postcode,
    this.country,
    this.email,
    this.phone,
  });
  OrderDetailModelDataBillingAddress.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name']?.toString();
    lastName = json['last_name']?.toString();
    address = json['address']?.toString();
    city = json['city']?.toString();
    state = json['state']?.toString();
    postcode = json['postcode']?.toString();
    country = json['country']?.toString();
    email = json['email']?.toString();
    phone = json['phone']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['address'] = address;
    data['city'] = city;
    data['state'] = state;
    data['postcode'] = postcode;
    data['country'] = country;
    data['email'] = email;
    data['phone'] = phone;
    return data;
  }
}

class OrderDetailModelDataProductsVariations {
/*
{
  "attribute_name": "size",
  "attribute_value": "S"
}
*/

  String? attributeName;
  String? attributeValue;

  OrderDetailModelDataProductsVariations({
    this.attributeName,
    this.attributeValue,
  });
  OrderDetailModelDataProductsVariations.fromJson(Map<String, dynamic> json) {
    attributeName = json['attribute_name']?.toString();
    attributeValue = json['attribute_value']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['attribute_name'] = attributeName;
    data['attribute_value'] = attributeValue;
    return data;
  }
}

class OrderDetailModelDataProducts {
/*
{
  "id": 2663,
  "variation_id": 2680,
  "name": "Breathe-Easy Tank - S, Yellow",
  "image": "${Url.BASE_URL}wp-content/uploads/2021/11/wt09-white_main.jpg",
  "quantity": 2,
  "subtotal": "68",
  "total": "68",
  "variations": [
    {
      "attribute_name": "size",
      "attribute_value": "S"
    }
  ]
}
*/

  int? id;
  int? variationId;
  String? name;
  String? image;
  int? quantity;
  String? subtotal;
  String? total;
  List<OrderDetailModelDataProductsVariations?>? variations;

  OrderDetailModelDataProducts({
    this.id,
    this.variationId,
    this.name,
    this.image,
    this.quantity,
    this.subtotal,
    this.total,
    this.variations,
  });
  OrderDetailModelDataProducts.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toInt();
    variationId = json['variation_id']?.toInt();
    name = json['name']?.toString();
    image = json['image']?.toString();
    quantity = json['quantity']?.toInt();
    subtotal = json['subtotal']?.toString();
    total = json['total']?.toString();
    if (json['variations'] != null) {
      final v = json['variations'];
      final arr0 = <OrderDetailModelDataProductsVariations>[];
      v.forEach((v) {
        arr0.add(OrderDetailModelDataProductsVariations.fromJson(v));
      });
      variations = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['variation_id'] = variationId;
    data['name'] = name;
    data['image'] = image;
    data['quantity'] = quantity;
    data['subtotal'] = subtotal;
    data['total'] = total;
    if (variations != null) {
      final v = variations;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['variations'] = arr0;
    }
    return data;
  }
}

class OrderDetailModelDataDateCreated {
/*
{
  "date": "2021-12-16 09:08:55.000000",
  "timezone_type": 1,
  "timezone": "+00:00"
}
*/

  String? date;
  int? timezoneType;
  String? timezone;

  OrderDetailModelDataDateCreated({
    this.date,
    this.timezoneType,
    this.timezone,
  });
  OrderDetailModelDataDateCreated.fromJson(Map<String, dynamic> json) {
    date = json['date']?.toString();
    timezoneType = json['timezone_type']?.toInt();
    timezone = json['timezone']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['timezone_type'] = timezoneType;
    data['timezone'] = timezone;
    return data;
  }
}

class OrderDetailModelData {
/*
{
  "order_id": 2769,
  "order_key": "wc_order_PZnxi9X1clvtD",
  "currency": "USD",
  "order_status": "on-hold",
  "customer_note": "",
  "total": 186,
  "sub_total": 186,
  "shipping_total": "0",
  "coupon_discount": 0,
  "shipping_method": "Flat rate",
  "payment_method": "Cash on delivery",
  "total_products": 2,
  "coupons": null,
  "date_created": {
    "date": "2021-12-16 09:08:55.000000",
    "timezone_type": 1,
    "timezone": "+00:00"
  },
  "products": [
    {
      "id": 2663,
      "variation_id": 2680,
      "name": "Breathe-Easy Tank - S, Yellow",
      "image": "${Url.BASE_URL}wp-content/uploads/2021/11/wt09-white_main.jpg",
      "quantity": 2,
      "subtotal": "68",
      "total": "68",
      "variations": [
        {
          "attribute_name": "size",
          "attribute_value": "S"
        }
      ]
    }
  ],
  "billing_address": {
    "first_name": "",
    "last_name": "",
    "address": "",
    "city": "",
    "state": "",
    "postcode": "",
    "country": "",
    "email": "kevalpanchal038@gmail.com",
    "phone": "8200503309"
  },
  "shipping_address": {
    "first_name": "Keval",
    "last_name": "Panchal",
    "address": "p-55",
    "city": "Valsad",
    "state": "Christ Church",
    "postcode": "396020",
    "country": "Barbados"
  }
}
*/

  int? orderId;
  String? orderKey;
  String? currency;
  String? orderStatus;
  String? customerNote;
  dynamic? total;
  dynamic? subTotal;
  String? shippingTotal;
  int? couponDiscount;
  String? shippingMethod;
  String? paymentMethod;
  int? totalProducts;
  List<Coupons>? coupons;
  OrderDetailModelDataDateCreated? dateCreated;
  List<OrderDetailModelDataProducts?>? products;
  OrderDetailModelDataBillingAddress? billingAddress;
  OrderDetailModelDataShippingAddress? shippingAddress;

  OrderDetailModelData({
    this.orderId,
    this.orderKey,
    this.currency,
    this.orderStatus,
    this.customerNote,
    this.total,
    this.subTotal,
    this.shippingTotal,
    this.couponDiscount,
    this.shippingMethod,
    this.paymentMethod,
    this.totalProducts,
    this.coupons,
    this.dateCreated,
    this.products,
    this.billingAddress,
    this.shippingAddress,
  });
  OrderDetailModelData.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id']?.toInt();
    orderKey = json['order_key']?.toString();
    currency = json['currency']?.toString();
    orderStatus = json['order_status']?.toString();
    customerNote = json['customer_note']?.toString();
    total = json['total'];
    subTotal = json['sub_total'];
    shippingTotal = json['shipping_total']?.toString();
    couponDiscount = json['coupon_discount']?.toInt();
    shippingMethod = json['shipping_method']?.toString();
    paymentMethod = json['payment_method']?.toString();
    totalProducts = json['total_products']?.toInt();
    if (json['coupons'] != null) {
      coupons = <Coupons>[];
      json['coupons'].forEach((v) {
        coupons!.add(new Coupons.fromJson(v));
      });
    }

    if (json['coupons'] != null && json['coupons'] != '') {
      coupons = <Coupons>[];
      json['coupons'].forEach((v) {
        coupons!.add(new Coupons.fromJson(v));
      });
    }else{
      coupons = [];
    }
    dateCreated = (json['date_created'] != null) ? OrderDetailModelDataDateCreated.fromJson(json['date_created']) : null;
    if (json['products'] != null) {
      final v = json['products'];
      final arr0 = <OrderDetailModelDataProducts>[];
      v.forEach((v) {
        arr0.add(OrderDetailModelDataProducts.fromJson(v));
      });
      products = arr0;
    }
    billingAddress = (json['billing_address'] != null) ? OrderDetailModelDataBillingAddress.fromJson(json['billing_address']) : null;
    shippingAddress = (json['shipping_address'] != null) ? OrderDetailModelDataShippingAddress.fromJson(json['shipping_address']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['order_key'] = orderKey;
    data['currency'] = currency;
    data['order_status'] = orderStatus;
    data['customer_note'] = customerNote;
    data['total'] = total;
    data['sub_total'] = subTotal;
    data['shipping_total'] = shippingTotal;
    data['coupon_discount'] = couponDiscount;
    data['shipping_method'] = shippingMethod;
    data['payment_method'] = paymentMethod;
    data['total_products'] = totalProducts;
    data['coupons'] = coupons;
    if (dateCreated != null) {
      data['date_created'] = dateCreated!.toJson();
    }
    if (products != null) {
      final v = products;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['products'] = arr0;
    }
    if (billingAddress != null) {
      data['billing_address'] = billingAddress!.toJson();
    }
    if (shippingAddress != null) {
      data['shipping_address'] = shippingAddress!.toJson();
    }
    return data;
  }
}

class OrderDetailModel {
/*
{
  "success": true,
  "data": {
    "order_id": 2769,
    "order_key": "wc_order_PZnxi9X1clvtD",
    "currency": "USD",
    "order_status": "on-hold",
    "customer_note": "",
    "total": 186,
    "sub_total": 186,
    "shipping_total": "0",
    "coupon_discount": 0,
    "shipping_method": "Flat rate",
    "payment_method": "Cash on delivery",
    "total_products": 2,
    "coupons": null,
    "date_created": {
      "date": "2021-12-16 09:08:55.000000",
      "timezone_type": 1,
      "timezone": "+00:00"
    },
    "products": [
      {
        "id": 2663,
        "variation_id": 2680,
        "name": "Breathe-Easy Tank - S, Yellow",
        "image": "${Url.BASE_URL}wp-content/uploads/2021/11/wt09-white_main.jpg",
        "quantity": 2,
        "subtotal": "68",
        "total": "68",
        "variations": [
          {
            "attribute_name": "size",
            "attribute_value": "S"
          }
        ]
      }
    ],
    "billing_address": {
      "first_name": "",
      "last_name": "",
      "address": "",
      "city": "",
      "state": "",
      "postcode": "",
      "country": "",
      "email": "kevalpanchal038@gmail.com",
      "phone": "8200503309"
    },
    "shipping_address": {
      "first_name": "Keval",
      "last_name": "Panchal",
      "address": "p-55",
      "city": "Valsad",
      "state": "Christ Church",
      "postcode": "396020",
      "country": "Barbados"
    }
  }
}
*/

  bool? success;
  OrderDetailModelData? data;

  OrderDetailModel({
    this.success,
    this.data,
  });
  OrderDetailModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = (json['data'] != null) ? OrderDetailModelData.fromJson(json['data']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    if (data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
class Coupons {
  String? code;
  String? amount;

  Coupons({this.code, this.amount});

  Coupons.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['amount'] = this.amount;
    return data;
  }
}