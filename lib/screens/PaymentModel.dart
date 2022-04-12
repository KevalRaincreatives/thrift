


class PaymentModelData {
/*
{
  "order_button_text": null,
  "enabled": "yes",
  "title": "Cash on delivery",
  "description": "Pay with cash upon delivery.",
  "chosen": null,
  "method_title": "Cash on delivery",
  "method_description": "Have your customers pay with cash (or by other means) upon delivery.",
  "has_fields": false,
  "countries": null,
  "availability": null,
  "icon": "",
  "supports": [
    "products"
  ],
  "max_amount": 0,
  "view_transaction_url": "",
  "new_method_label": "",
  "pay_button_id": "",
  "plugin_id": "woocommerce_",
  "id": "cod",
  "errors": [
    null
  ],
  "settings": {
    "enabled": "yes",
    "title": "Cash on delivery",
    "description": "Pay with cash upon delivery.",
    "instructions": "Pay with cash upon delivery.",
    "enable_for_methods": [
      null
    ],
    "enable_for_virtual": "yes"
  },
  "form_fields": {
    "enabled": {
      "title": "Enable/Disable",
      "label": "Enable cash on delivery",
      "type": "checkbox",
      "description": "",
      "default": "no"
    },
    "title": {
      "title": "Title",
      "type": "text",
      "description": "Payment method description that the customer will see on your checkout.",
      "default": "Cash on delivery",
      "desc_tip": true
    },
    "description": {
      "title": "Description",
      "type": "textarea",
      "description": "Payment method description that the customer will see on your website.",
      "default": "Pay with cash upon delivery.",
      "desc_tip": true
    },
    "instructions": {
      "title": "Instructions",
      "type": "textarea",
      "description": "Instructions that will be added to the thank you page.",
      "default": "Pay with cash upon delivery.",
      "desc_tip": true
    },
    "enable_for_methods": {
      "title": "Enable for shipping methods",
      "type": "multiselect",
      "class": "wc-enhanced-select",
      "css": "width: 400px;",
      "default": "",
      "description": "If COD is only available for certain methods, set it up here. Leave blank to enable for all methods.",
      "options": [
        null
      ],
      "desc_tip": true,
      "custom_attributes": {
        "data-placeholder": "Select shipping methods"
      }
    },
    "enable_for_virtual": {
      "title": "Accept for virtual orders",
      "label": "Accept COD if the order is virtual",
      "type": "checkbox",
      "default": "yes"
    }
  },
  "instructions": "Pay with cash upon delivery.",
  "enable_for_methods": [
    null
  ],
  "enable_for_virtual": true,
  "secret_key": "",
  "publishable_key": "",
  "testmode": false
}
*/

  String? title;
  String? description;
  String? methodTitle;
  String? methodDescription;
  String? id;
  dynamic? secretKey;
  dynamic? publishableKey;
  bool? testmode;

  PaymentModelData({
    this.title,
    this.description,
    this.methodTitle,
    this.methodDescription,
    this.id,
    this.secretKey,
    this.publishableKey,
    this.testmode,
  });
  PaymentModelData.fromJson(Map<String, dynamic> json) {
    title = json["title"]?.toString();
    description = json["description"]?.toString();
    methodTitle = json["method_title"]?.toString();
    methodDescription = json["method_description"]?.toString();
    id = json["id"]?.toString();
    secretKey = json["secret_key"]?.toString();
    publishableKey = json["publishable_key"]?.toString();
    testmode = json["testmode"];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["title"] = title;
    data["description"] = description;
    data["method_title"] = methodTitle;
    data["method_description"] = methodDescription;
    data["secret_key"] = secretKey;
    data["publishable_key"] = publishableKey;
    data["testmode"] = testmode;
    return data;
  }
}

class PaymentModel {
/*
{
  "success": true,
  "data": [
    {
      "order_button_text": null,
      "enabled": "yes",
      "title": "Cash on delivery",
      "description": "Pay with cash upon delivery.",
      "chosen": null,
      "method_title": "Cash on delivery",
      "method_description": "Have your customers pay with cash (or by other means) upon delivery.",
      "has_fields": false,
      "countries": null,
      "availability": null,
      "icon": "",
      "supports": [
        "products"
      ],
      "max_amount": 0,
      "view_transaction_url": "",
      "new_method_label": "",
      "pay_button_id": "",
      "plugin_id": "woocommerce_",
      "id": "cod",
      "errors": [
        null
      ],
      "settings": {
        "enabled": "yes",
        "title": "Cash on delivery",
        "description": "Pay with cash upon delivery.",
        "instructions": "Pay with cash upon delivery.",
        "enable_for_methods": [
          null
        ],
        "enable_for_virtual": "yes"
      },
      "form_fields": {
        "enabled": {
          "title": "Enable/Disable",
          "label": "Enable cash on delivery",
          "type": "checkbox",
          "description": "",
          "default": "no"
        },
        "title": {
          "title": "Title",
          "type": "text",
          "description": "Payment method description that the customer will see on your checkout.",
          "default": "Cash on delivery",
          "desc_tip": true
        },
        "description": {
          "title": "Description",
          "type": "textarea",
          "description": "Payment method description that the customer will see on your website.",
          "default": "Pay with cash upon delivery.",
          "desc_tip": true
        },
        "instructions": {
          "title": "Instructions",
          "type": "textarea",
          "description": "Instructions that will be added to the thank you page.",
          "default": "Pay with cash upon delivery.",
          "desc_tip": true
        },
        "enable_for_methods": {
          "title": "Enable for shipping methods",
          "type": "multiselect",
          "class": "wc-enhanced-select",
          "css": "width: 400px;",
          "default": "",
          "description": "If COD is only available for certain methods, set it up here. Leave blank to enable for all methods.",
          "options": [
            null
          ],
          "desc_tip": true,
          "custom_attributes": {
            "data-placeholder": "Select shipping methods"
          }
        },
        "enable_for_virtual": {
          "title": "Accept for virtual orders",
          "label": "Accept COD if the order is virtual",
          "type": "checkbox",
          "default": "yes"
        }
      },
      "instructions": "Pay with cash upon delivery.",
      "enable_for_methods": [
        null
      ],
      "enable_for_virtual": true,
      "secret_key": "",
      "publishable_key": "",
      "testmode": false
    }
  ]
}
*/

  bool? success;
  List<PaymentModelData?>? data;

  PaymentModel({
    this.success,
    this.data,
  });
  PaymentModel.fromJson(Map<String, dynamic> json) {
    success = json["success"];
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <PaymentModelData>[];
      v.forEach((v) {
        arr0.add(PaymentModelData.fromJson(v));
      });
      this.data = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["success"] = success;
    if (this.data != null) {
      final v = this.data;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["data"] = arr0;
    }
    return data;
  }
}
