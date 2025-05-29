class ApiEndpoints {
  // IP address of your backend server
  static final String serverIp = '192.168';

  // Base URL for all API endpoints
  static final String baseUrl = 'http://$serverIp:5000';

  // Product categories
  static String get aquafishProducts => '$baseUrl/aquafish_products';
  static String get birdfeedProducts => '$baseUrl/birdfeed_products';
  static String get catAccessories => '$baseUrl/catacc_products';
  static String get dogfoodProducts => '$baseUrl/dogfood_products';
  static String get petGroomingProducts => '$baseUrl/petgrooming_products';
  static String get petHealthProducts => '$baseUrl/pethealth_products';

  // General products
  static String get allProducts => '$baseUrl/products';
  static String productSearch(String query) => '$baseUrl/api/products?query=$query';

  // 🔥 Image URL builder
  static String imageUrl(String imagePath) => '$baseUrl$imagePath';

  // Cart operations
  static String get cart => '$baseUrl/cart';
  static String get addToCart => '$baseUrl/add_to_cart'; // 👈 Added here
  static String deleteCartItem(String itemId) => '$baseUrl/cart/$itemId';

  // Checkout
  static String get checkout => '$baseUrl/api/checkout';

  // Signup endpoint
  static String get signup => '$baseUrl/signup';

  // Login endpoint
  static String get login => '$baseUrl/login';

  // Delivery endpoints
  static String get assignedDeliveries => '$baseUrl/api/assigned_deliveries';
  static String get markDelivered => '$baseUrl/api/mark_delivered';

  // Additional or fallback server endpoint (IP ending with .200)
  static String get altProducts => 'http://192.168.254:5000/products';
}
