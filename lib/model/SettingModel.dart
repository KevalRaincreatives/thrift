///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class SettingModelWoosettings {
/*
{
  "wp_page_for_privacy_policy": "https://encros.rcstaging.co.in/?page_id=3",
  "woocommerce_store_address": "143 Rue de Charenton,",
  "woocommerce_store_address_2": "75012 Paris,",
  "woocommerce_store_city": "Paris",
  "woocommerce_default_country": "France",
  "woocommerce_store_postcode": "75012",
  "woocommerce_currency": "EUR",
  "woocommerce_currency_pos": "right",
  "woocommerce_price_thousand_sep": "",
  "woocommerce_price_decimal_sep": ",",
  "woocommerce_weight_unit": "kg",
  "woocommerce_dimension_unit": "cm",
  "woocommerce_enable_reviews": "yes",
  "woocommerce_enable_guest_checkout": "yes",
  "woocommerce_registration_generate_username": "yes",
  "woocommerce_email_from_name": "Encros",
  "woocommerce_email_from_address": "binalshah2@gmail.com",
  "woocommerce_terms_page_id": false,
  "WPLANG": "en_GB",
  "latitude": "23.047590",
  "longitude": "72.539870",
  "currency_symbol": "&euro;",
  "phone_no": "+1-928-2212-221"
}
*/

  String? wpPageForPrivacyPolicy;
  String? woocommerceStoreAddress;
  String? woocommerceStoreAddress_2;
  String? woocommerceStoreCity;
  String? woocommerceDefaultCountry;
  String? woocommerceStorePostcode;
  String? woocommerceCurrency;
  String? woocommerceCurrencyPos;
  String? woocommercePriceThousandSep;
  String? woocommercePriceDecimalSep;
  String? woocommerce_price_num_decimals;
  String? woocommerceWeightUnit;
  String? woocommerceDimensionUnit;
  String? woocommerceEnableReviews;
  String? woocommerceEnableGuestCheckout;
  String? woocommerceRegistrationGenerateUsername;
  String? woocommerceEmailFromName;
  String? woocommerceEmailFromAddress;
  bool? woocommerceTermsPageId;
  String? WPLANG;
  String? latitude;
  String? longitude;
  String? currencySymbol;
  String? phoneNo;

  SettingModelWoosettings({
    this.wpPageForPrivacyPolicy,
    this.woocommerceStoreAddress,
    this.woocommerceStoreAddress_2,
    this.woocommerceStoreCity,
    this.woocommerceDefaultCountry,
    this.woocommerceStorePostcode,
    this.woocommerceCurrency,
    this.woocommerceCurrencyPos,
    this.woocommercePriceThousandSep,
    this.woocommercePriceDecimalSep,
    this.woocommerce_price_num_decimals,
    this.woocommerceWeightUnit,
    this.woocommerceDimensionUnit,
    this.woocommerceEnableReviews,
    this.woocommerceEnableGuestCheckout,
    this.woocommerceRegistrationGenerateUsername,
    this.woocommerceEmailFromName,
    this.woocommerceEmailFromAddress,
    this.woocommerceTermsPageId,
    this.WPLANG,
    this.latitude,
    this.longitude,
    this.currencySymbol,
    this.phoneNo,
  });
  SettingModelWoosettings.fromJson(Map<String, dynamic> json) {
    wpPageForPrivacyPolicy = json["wp_page_for_privacy_policy"]?.toString();
    woocommerceStoreAddress = json["woocommerce_store_address"]?.toString();
    woocommerceStoreAddress_2 = json["woocommerce_store_address_2"]?.toString();
    woocommerceStoreCity = json["woocommerce_store_city"]?.toString();
    woocommerceDefaultCountry = json["woocommerce_default_country"]?.toString();
    woocommerceStorePostcode = json["woocommerce_store_postcode"]?.toString();
    woocommerceCurrency = json["woocommerce_currency"]?.toString();
    woocommerceCurrencyPos = json["woocommerce_currency_pos"]?.toString();
    woocommercePriceThousandSep = json["woocommerce_price_thousand_sep"]?.toString();
    woocommercePriceDecimalSep = json["woocommerce_price_decimal_sep"]?.toString();
    woocommerce_price_num_decimals= json["woocommerce_price_num_decimals"]?.toString();
    woocommerceWeightUnit = json["woocommerce_weight_unit"]?.toString();
    woocommerceDimensionUnit = json["woocommerce_dimension_unit"]?.toString();
    woocommerceEnableReviews = json["woocommerce_enable_reviews"]?.toString();
    woocommerceEnableGuestCheckout = json["woocommerce_enable_guest_checkout"]?.toString();
    woocommerceRegistrationGenerateUsername = json["woocommerce_registration_generate_username"]?.toString();
    woocommerceEmailFromName = json["woocommerce_email_from_name"]?.toString();
    woocommerceEmailFromAddress = json["woocommerce_email_from_address"]?.toString();
    woocommerceTermsPageId = json["woocommerce_terms_page_id"];
    WPLANG = json["WPLANG"]?.toString();
    latitude = json["latitude"]?.toString();
    longitude = json["longitude"]?.toString();
    currencySymbol = json["currency_symbol"]?.toString();
    phoneNo = json["phone_no"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["wp_page_for_privacy_policy"] = wpPageForPrivacyPolicy;
    data["woocommerce_store_address"] = woocommerceStoreAddress;
    data["woocommerce_store_address_2"] = woocommerceStoreAddress_2;
    data["woocommerce_store_city"] = woocommerceStoreCity;
    data["woocommerce_default_country"] = woocommerceDefaultCountry;
    data["woocommerce_store_postcode"] = woocommerceStorePostcode;
    data["woocommerce_currency"] = woocommerceCurrency;
    data["woocommerce_currency_pos"] = woocommerceCurrencyPos;
    data["woocommerce_price_thousand_sep"] = woocommercePriceThousandSep;
    data["woocommerce_price_decimal_sep"] = woocommercePriceDecimalSep;
    data["woocommerce_price_num_decimals"]=woocommerce_price_num_decimals;
    data["woocommerce_weight_unit"] = woocommerceWeightUnit;
    data["woocommerce_dimension_unit"] = woocommerceDimensionUnit;
    data["woocommerce_enable_reviews"] = woocommerceEnableReviews;
    data["woocommerce_enable_guest_checkout"] = woocommerceEnableGuestCheckout;
    data["woocommerce_registration_generate_username"] = woocommerceRegistrationGenerateUsername;
    data["woocommerce_email_from_name"] = woocommerceEmailFromName;
    data["woocommerce_email_from_address"] = woocommerceEmailFromAddress;
    data["woocommerce_terms_page_id"] = woocommerceTermsPageId;
    data["WPLANG"] = WPLANG;
    data["latitude"] = latitude;
    data["longitude"] = longitude;
    data["currency_symbol"] = currencySymbol;
    data["phone_no"] = phoneNo;
    return data;
  }
}

class SettingModel {
/*
{
  "woosettings": {
    "wp_page_for_privacy_policy": "https://encros.rcstaging.co.in/?page_id=3",
    "woocommerce_store_address": "143 Rue de Charenton,",
    "woocommerce_store_address_2": "75012 Paris,",
    "woocommerce_store_city": "Paris",
    "woocommerce_default_country": "France",
    "woocommerce_store_postcode": "75012",
    "woocommerce_currency": "EUR",
    "woocommerce_currency_pos": "right",
    "woocommerce_price_thousand_sep": "",
    "woocommerce_price_decimal_sep": ",",
    "woocommerce_weight_unit": "kg",
    "woocommerce_dimension_unit": "cm",
    "woocommerce_enable_reviews": "yes",
    "woocommerce_enable_guest_checkout": "yes",
    "woocommerce_registration_generate_username": "yes",
    "woocommerce_email_from_name": "Encros",
    "woocommerce_email_from_address": "binalshah2@gmail.com",
    "woocommerce_terms_page_id": false,
    "WPLANG": "en_GB",
    "latitude": "23.047590",
    "longitude": "72.539870",
    "currency_symbol": "&euro;",
    "phone_no": "+1-928-2212-221"
  }
}
*/

  SettingModelWoosettings? woosettings;

  SettingModel({
    this.woosettings,
  });
  SettingModel.fromJson(Map<String, dynamic> json) {
    woosettings = (json["woosettings"] != null) ? SettingModelWoosettings.fromJson(json["woosettings"]) : null;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (woosettings != null) {
      data["woosettings"] = woosettings!.toJson();
    }
    return data;
  }
}