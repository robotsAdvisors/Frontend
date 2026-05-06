import '../app/data/models/category_model.dart';
import '../app/data/models/customer_model.dart';
import '../app/data/models/product_model.dart';
import '../app/data/models/store_model.dart';
import '../app/data/models/store_user_model.dart';
import '../app/data/models/voucher_campaign_model.dart';
import '../app/data/models/voucher_model.dart';
import 'constants.dart';

class DummyHelper {
  const DummyHelper._();

  static const _description = 'Ginger is a flowering plant whose rhizome, ginger root or ginger, is widely used as a spice and a folk medicine.';

  static List<Map<String, String>> cards = [
    {'icon': Constants.lotus, 'title': '100%', 'subtitle': 'Organic'},
    {'icon': Constants.calendar, 'title': '1 Year', 'subtitle': 'Expiration'},
    {'icon': Constants.favourites, 'title': '4.8 (256)', 'subtitle': 'Reviews'},
    {'icon': Constants.matches, 'title': '80 kcal', 'subtitle': '100 Gram'},
  ];

  static List<CategoryModel> categories = [
    CategoryModel(id: 1, title: 'Fruits', image: Constants.apple),
    CategoryModel(id: 2, title: 'Vegetables', image: Constants.broccoli),
    CategoryModel(id: 3, title: 'Cheeses', image: Constants.cheese),
    CategoryModel(id: 4, title: 'Meat', image: Constants.meat),
  ];

  static List<ProductModel> products = [
    ProductModel(
      id: 1,
      image: Constants.bellPepper,
      name: 'Bell Pepper Red',
      description: _description,
      category: 'Vegetables',
      sku: 'BP-001',
      quantity: 12,
      originalPrice: 6.99,
      discountPrice: 5.99,
      storeId: 'store_1',
    ),
    ProductModel(
      id: 2,
      image: Constants.lambMeat,
      name: 'Lamb Meat',
      description: _description,
      category: 'Meat',
      sku: 'LM-001',
      quantity: 8,
      originalPrice: 49.99,
      discountPrice: 44.99,
      storeId: 'store_1',
    ),
    ProductModel(
      id: 3,
      image: Constants.ginger,
      name: 'Arabic Ginger',
      description: _description,
      category: 'Spices',
      sku: 'AG-001',
      quantity: 20,
      originalPrice: 5.99,
      discountPrice: 4.99,
      storeId: 'store_1',
    ),
    ProductModel(
      id: 4,
      image: Constants.cabbage,
      name: 'Fresh Lettuce',
      description: _description,
      category: 'Vegetables',
      sku: 'FL-001',
      quantity: 15,
      originalPrice: 4.99,
      discountPrice: 3.99,
      storeId: 'store_2',
    ),
    ProductModel(
      id: 5,
      image: Constants.pumpkin,
      name: 'Butternut Squash',
      description: _description,
      category: 'Vegetables',
      sku: 'BS-001',
      quantity: 10,
      originalPrice: 9.99,
      discountPrice: 8.99,
      storeId: 'store_2',
    ),
    ProductModel(
      id: 6,
      image: Constants.carrot,
      name: 'Organic Carrots',
      description: _description,
      category: 'Vegetables',
      sku: 'OC-001',
      quantity: 18,
      originalPrice: 6.99,
      discountPrice: 5.99,
      storeId: 'store_2',
    ),
    ProductModel(
      id: 7,
      image: Constants.cauliflower,
      name: 'Fresh Broccoli',
      description: _description,
      category: 'Vegetables',
      sku: 'FB-001',
      quantity: 14,
      originalPrice: 4.99,
      discountPrice: 3.99,
      storeId: 'store_2',
    ),
    ProductModel(
      id: 8,
      image: Constants.tomatoes,
      name: 'Cherry Tomato',
      description: _description,
      category: 'Vegetables',
      sku: 'CT-001',
      quantity: 22,
      originalPrice: 6.99,
      discountPrice: 5.99,
      storeId: 'store_2',
    ),
    ProductModel(
      id: 9,
      image: Constants.spinach,
      name: 'Fresh Spinach',
      description: _description,
      category: 'Vegetables',
      sku: 'FS-001',
      quantity: 16,
      originalPrice: 3.99,
      discountPrice: 2.99,
      storeId: 'store_2',
    ),
  ];

  static const String currentAdminEmail = 'admin1@tiendacentral.com';

  static String? storeIdForAdminEmail(String email) {
    final user = storeUsers.firstWhere(
      (item) => item.email == email,
      orElse: () => StoreUserModel(
        id: '',
        email: '',
        role: '',
        storeId: '',
        createdAt: DateTime.now(),
      ),
    );
    return user.id.isNotEmpty ? user.storeId : null;
  }

  static List<StoreModel> stores = [
    StoreModel(
      id: 'store_1',
      name: 'Tienda Orgánica Central',
      description: 'Tienda especializada en productos orgánicos frescos',
      ownerId: 'owner_1',
      ownerEmail: 'owner1@example.com',
      adminUserIds: ['admin_1', 'admin_2'],
      fiscalId: 'FISCAL-1234',
      address: 'Calle Principal 123, Ciudad',
      logoUrl: Constants.logo,
      billingEmail: 'facturas@tiendacentral.com',
      billingPhone: '+34 600 123 456',
      pin: '1234',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    StoreModel(
      id: 'store_2',
      name: 'Verduras del Valle',
      description: 'Productos frescos directamente del campo',
      ownerId: 'owner_2',
      ownerEmail: 'owner2@example.com',
      adminUserIds: ['admin_3'],
      fiscalId: 'FISCAL-5678',
      address: 'Camino del Huerto 45, Pueblo',
      logoUrl: Constants.logo,
      billingEmail: 'facturas@verdurasvalle.com',
      billingPhone: '+34 611 234 567',
      pin: '5678',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  static List<StoreUserModel> storeUsers = [
    StoreUserModel(
      id: 'admin_1',
      email: 'admin1@tiendacentral.com',
      role: 'store_admin',
      storeId: 'store_1',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    StoreUserModel(
      id: 'admin_2',
      email: 'admin2@tiendacentral.com',
      role: 'store_admin',
      storeId: 'store_1',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    StoreUserModel(
      id: 'admin_3',
      email: 'admin@verdurasvalle.com',
      role: 'store_admin',
      storeId: 'store_2',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    StoreUserModel(
      id: 'viewer_1',
      email: 'viewer@tiendacentral.com',
      role: 'store_viewer',
      storeId: 'store_1',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  static List<CustomerModel> customers = [
    CustomerModel(
      id: 'customer_1',
      storeId: 'store_1',
      name: 'Carlos Perez',
      email: 'carlos.perez@example.com',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    CustomerModel(
      id: 'customer_2',
      storeId: 'store_1',
      name: 'Lucia Fernandez',
      email: 'lucia.fernandez@example.com',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    CustomerModel(
      id: 'customer_3',
      storeId: 'store_1',
      name: 'Miguel Ramirez',
      email: 'miguel.ramirez@example.com',
      createdAt: DateTime.now().subtract(const Duration(days: 80)),
    ),
    CustomerModel(
      id: 'customer_4',
      storeId: 'store_2',
      name: 'Ana Gomez',
      email: 'ana.gomez@example.com',
      createdAt: DateTime.now().subtract(const Duration(days: 70)),
    ),
    CustomerModel(
      id: 'customer_5',
      storeId: 'store_2',
      name: 'Pedro Sanchez',
      email: 'pedro.sanchez@example.com',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    CustomerModel(
      id: 'customer_demo',
      storeId: 'store_1',
      name: 'Cliente Demo',
      email: 'cliente@marketplace.com',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  static List<VoucherCampaignModel> voucherCampaigns = [
    VoucherCampaignModel(
      id: 'campaign_1',
      storeId: 'store_1',
      name: 'Campana bienvenida tienda 1',
      validFrom: DateTime.now().subtract(const Duration(days: 120)),
      validUntil: DateTime.now().add(const Duration(days: 120)),
      discountPercent: 20,
    ),
    VoucherCampaignModel(
      id: 'campaign_2',
      storeId: 'store_2',
      name: 'Campana bienvenida tienda 2',
      validFrom: DateTime.now().subtract(const Duration(days: 120)),
      validUntil: DateTime.now().add(const Duration(days: 120)),
      discountPercent: 15,
    ),
  ];

  static String customerNameById(String id) {
    final customer = customers.firstWhere(
      (item) => item.id == id,
      orElse: () => CustomerModel(
        id: '',
        storeId: '',
        name: 'Cliente desconocido',
        email: '',
        createdAt: DateTime.now(),
      ),
    );
    return customer.name;
  }

  static String customerEmailById(String id) {
    final customer = customers.firstWhere(
      (item) => item.id == id,
      orElse: () => CustomerModel(
        id: '',
        storeId: '',
        name: '',
        email: 'sin-email@example.com',
        createdAt: DateTime.now(),
      ),
    );
    return customer.email;
  }

  static String? customerIdForEmail(String email) {
    final customer = customers.firstWhere(
      (item) => item.email == email,
      orElse: () => CustomerModel(
        id: '',
        storeId: '',
        name: '',
        email: '',
        createdAt: DateTime.now(),
      ),
    );
    return customer.id.isEmpty ? null : customer.id;
  }

  static String productNameById(String productId) {
    final int? parsed = int.tryParse(productId);
    if (parsed == null) {
      return 'Producto desconocido';
    }
    final product = products.firstWhere(
      (item) => item.id == parsed,
      orElse: () => ProductModel(
        id: -1,
        image: '',
        name: 'Producto desconocido',
        description: '',
        category: '',
        sku: '',
        quantity: 0,
        originalPrice: 0,
        discountPrice: 0,
        storeId: '',
      ),
    );
    return product.name;
  }

  static List<VoucherModel> vouchers = [
    VoucherModel(
      id: 'voucher_1',
      campaignId: 'campaign_1',
      storeId: 'store_1',
      customerUserId: 'customer_1',
      productId: '1',
      code: 'VCH-1001',
      issuedAt: DateTime.now().subtract(const Duration(days: 40)),
      redeemedAt: DateTime.now().subtract(const Duration(days: 38, hours: 4)),
      expiresAt: DateTime.now().subtract(const Duration(days: 30)),
      discountPercent: 20,
      status: VoucherStatus.redeemed,
    ),
    VoucherModel(
      id: 'voucher_2',
      campaignId: 'campaign_1',
      storeId: 'store_1',
      customerUserId: 'customer_2',
      productId: '2',
      code: 'VCH-1002',
      issuedAt: DateTime.now().subtract(const Duration(days: 15)),
      redeemedAt: null,
      expiresAt: DateTime.now().add(const Duration(days: 7, hours: 12)),
      discountPercent: 15,
      status: VoucherStatus.pending,
    ),
    VoucherModel(
      id: 'voucher_3',
      campaignId: 'campaign_1',
      storeId: 'store_1',
      customerUserId: 'customer_3',
      productId: '3',
      code: 'VCH-1003',
      issuedAt: DateTime.now().subtract(const Duration(days: 95)),
      redeemedAt: null,
      expiresAt: DateTime.now().subtract(const Duration(days: 5)),
      discountPercent: 10,
      status: VoucherStatus.expired,
    ),
    VoucherModel(
      id: 'voucher_4',
      campaignId: 'campaign_2',
      storeId: 'store_2',
      customerUserId: 'customer_4',
      productId: '4',
      code: 'VCH-2001',
      issuedAt: DateTime.now().subtract(const Duration(days: 20)),
      redeemedAt: DateTime.now().subtract(const Duration(days: 19, hours: 5)),
      expiresAt: DateTime.now().subtract(const Duration(days: 10)),
      discountPercent: 25,
      status: VoucherStatus.redeemed,
    ),
    VoucherModel(
      id: 'voucher_5',
      campaignId: 'campaign_2',
      storeId: 'store_2',
      customerUserId: 'customer_5',
      productId: '5',
      code: 'VCH-2002',
      issuedAt: DateTime.now().subtract(const Duration(days: 5)),
      redeemedAt: null,
      expiresAt: DateTime.now().add(const Duration(days: 3, hours: 2)),
      discountPercent: 12,
      status: VoucherStatus.pending,
    ),
    VoucherModel(
      id: 'voucher_6',
      campaignId: 'campaign_1',
      storeId: 'store_1',
      customerUserId: 'customer_demo',
      productId: '6',
      code: 'WLT-9001',
      issuedAt: DateTime.now().subtract(const Duration(days: 2)),
      redeemedAt: null,
      expiresAt: DateTime.now().add(const Duration(days: 5)),
      discountPercent: 18,
      status: VoucherStatus.pending,
    ),
    VoucherModel(
      id: 'voucher_7',
      campaignId: 'campaign_1',
      storeId: 'store_1',
      customerUserId: 'customer_demo',
      productId: '9',
      code: 'WLT-9002',
      issuedAt: DateTime.now().subtract(const Duration(days: 9)),
      redeemedAt: DateTime.now().subtract(const Duration(days: 8, hours: 1)),
      expiresAt: DateTime.now().subtract(const Duration(days: 7)),
      discountPercent: 22,
      status: VoucherStatus.redeemed,
    ),
  ];

}