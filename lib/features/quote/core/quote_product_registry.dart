import 'package:gen_ui_poc/features/quote/core/models/quote_product.dart';
import 'package:gen_ui_poc/features/quote/core/quote_product_module.dart';
import 'package:gen_ui_poc/features/quote/products/auto/auto_quote_module.dart';
import 'package:gen_ui_poc/features/quote/products/life/life_quote_module.dart';
import 'package:gen_ui_poc/features/quote/products/travel/travel_quote_module.dart';

class QuoteProductRegistry {
  QuoteProductRegistry()
    : _modules = {
        QuoteProduct.auto: AutoQuoteModule(),
        QuoteProduct.life: LifeQuoteModule(),
        QuoteProduct.travel: TravelQuoteModule(),
      };

  final Map<QuoteProduct, QuoteProductModule> _modules;

  QuoteProductModule? getModule(QuoteProduct product) => _modules[product];
}
