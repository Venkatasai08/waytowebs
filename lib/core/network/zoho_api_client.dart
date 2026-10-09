
abstract class ZohoApiClient {
  Future<Map<String, dynamic>> fetchWorkbookData();
  Future<bool> verifyDealerPhone(String phone);
  Future<bool> verifyPlumberPhone(String phone);
  Future<bool> pushOrderToZoho(Map<String, dynamic> orderData);
  Future<bool> syncInventoryUpdates(List<Map<String, dynamic>> items);
}

class ZohoApiClientImpl implements ZohoApiClient {
  final Map<String, dynamic> _mockZohoRegistry = {
    'dealers': [
      {
        'phone': '9876543210',
        'name': 'Apex Hardware & Sanitary',
        'isVerified': true,
        'credit30Days': true,
        'credit90Days': true,
        'creditLimit': 250000.0,
        'availableCredit': 185000.0,
        'gstNumber': '33AAAAA0000A1Z5',
      },
      {
        'phone': '9876543211',
        'name': 'Metro Plumbing Traders',
        'isVerified': true,
        'credit30Days': true,
        'credit90Days': false,
        'creditLimit': 100000.0,
        'availableCredit': 75000.0,
        'gstNumber': '33BBBBB1111B2Z6',
      },
      {
        'phone': '9876543212',
        'name': 'Unverified Store',
        'isVerified': false,
        'credit30Days': false,
        'credit90Days': false,
        'creditLimit': 0.0,
        'availableCredit': 0.0,
        'gstNumber': '',
      },
    ],
    'plumbers': [
      {
        'phone': '9123456780',
        'name': 'Ramesh Kumar',
        'isVerified': true,
        'licenseNumber': 'PLUMB-IN-2024-889',
        'rating': 4.9,
        'completedJobs': 142,
      },
      {
        'phone': '9123456781',
        'name': 'Suresh Verma',
        'isVerified': true,
        'licenseNumber': 'PLUMB-IN-2023-412',
        'rating': 4.7,
        'completedJobs': 98,
      },
      {
        'phone': '9123456782',
        'name': 'Pending Plumber',
        'isVerified': false,
        'licenseNumber': 'PENDING-001',
        'rating': 0.0,
        'completedJobs': 0,
      }
    ],
    'workbook_items': [
      {
        'id': 'ZOHO-PROD-001',
        'name': 'CPVC Brass Female Threaded Adapter 25mm',
        'categoryId': 'cat_pipes',
        'categoryName': 'Pipes & Fittings',
        'customerPrice': 185.00,
        'dealerPrice': 130.00,
        'stockQuantity': 450,
        'sku': 'WTW-CPVC-FTA-25',
        'unit': 'Piece',
        'description': 'High tensile brass threaded adapter engineered for hot and cold potable water plumbing.',
        'imageUrl': 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500',
        'specifications': {
          'Material': 'Chlorinated Polyvinyl Chloride & Brass',
          'Size': '25 mm x 1 inch',
          'Pressure Rating': 'PN 16',
          'Standard': 'ASTM D2846'
        }
      },
      {
        'id': 'ZOHO-PROD-002',
        'name': 'Quarter Turn Ceramic Disc Bib Cock Tap',
        'categoryId': 'cat_faucets',
        'categoryName': 'Faucets & Taps',
        'customerPrice': 650.00,
        'dealerPrice': 460.00,
        'stockQuantity': 120,
        'sku': 'WTW-TAP-QT-01',
        'unit': 'Piece',
        'description': 'Heavy chrome finish brass bib cock with durable ceramic disc cartridge providing drip-free flow.',
        'imageUrl': 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500',
        'specifications': {
          'Finish': 'Polished Chrome',
          'Cartridge': 'High Grade Ceramic Disc',
          'Inlet': '1/2 inch BSP',
          'Warranty': '7 Years'
        }
      },
      {
        'id': 'ZOHO-PROD-003',
        'name': 'Submersible Single Phase Openwell Water Pump 1HP',
        'categoryId': 'cat_pumps',
        'categoryName': 'Pumps & Motors',
        'customerPrice': 8200.00,
        'dealerPrice': 6400.00,
        'stockQuantity': 35,
        'sku': 'WTW-PMP-1HP-OW',
        'unit': 'Unit',
        'description': 'Energy efficient 100% copper winding openwell pump for residential water supply and overhead tanks.',
        'imageUrl': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=500',
        'specifications': {
          'Power': '1.0 HP / 0.75 kW',
          'Voltage': '220V Single Phase',
          'Head Range': '10 - 36 meters',
          'Discharge': '150 - 45 LPM'
        }
      },
      {
        'id': 'ZOHO-PROD-004',
        'name': 'Wall Mounted Overhead Rain Shower 8x8 Inch',
        'categoryId': 'cat_sanitary',
        'categoryName': 'Sanitaryware',
        'customerPrice': 1450.00,
        'dealerPrice': 980.00,
        'stockQuantity': 85,
        'sku': 'WTW-SHW-RAIN-08',
        'unit': 'Piece',
        'description': 'Ultra slim stainless steel 304 rain shower with silicone easy-clean anti-clog jets.',
        'imageUrl': 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500',
        'specifications': {
          'Material': 'SS 304 Grade',
          'Dimensions': '200 mm x 200 mm',
          'Arm Length': '12 Inch Wall Arm Included',
          'Color': 'Mirror Chrome'
        }
      },
      {
        'id': 'ZOHO-PROD-005',
        'name': 'Solvent Cement Heavy Duty Clear 250ml',
        'categoryId': 'cat_adhesives',
        'categoryName': 'Solvents & Adhesives',
        'customerPrice': 190.00,
        'dealerPrice': 125.00,
        'stockQuantity': 600,
        'sku': 'WTW-SOL-PVC-250',
        'unit': 'Can',
        'description': 'Fast setting medium-bodied solvent cement for UPVC, CPVC pipe and fitting bonding.',
        'imageUrl': 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500',
        'specifications': {
          'Volume': '250 ml',
          'Application': 'UPVC / CPVC Jointing',
          'Drying Time': 'Initial set in 5 minutes',
          'Standard': 'ASTM D2564'
        }
      },
      {
        'id': 'ZOHO-PROD-006',
        'name': 'Multi-Angle Professional Pipe Wrench 14 Inch',
        'categoryId': 'cat_tools',
        'categoryName': 'Plumbing Tools',
        'customerPrice': 850.00,
        'dealerPrice': 590.00,
        'stockQuantity': 70,
        'sku': 'WTW-TLS-WRN-14',
        'unit': 'Piece',
        'description': 'Ductile iron cast heavy-duty pipe wrench with hardened forged alloy steel jaws.',
        'imageUrl': 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500',
        'specifications': {
          'Length': '350 mm (14 Inch)',
          'Jaw Capacity': '50 mm',
          'Handle': 'Ergonomic I-Beam Handle',
          'Weight': '1.2 kg'
        }
      }
    ]
  };

  @override
  Future<Map<String, dynamic>> fetchWorkbookData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Map<String, dynamic>.from(_mockZohoRegistry);
  }

  @override
  Future<bool> verifyDealerPhone(String phone) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final dealers = _mockZohoRegistry['dealers'] as List<dynamic>;
    return dealers.any((d) => d['phone'] == phone && d['isVerified'] == true);
  }

  @override
  Future<bool> verifyPlumberPhone(String phone) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final plumbers = _mockZohoRegistry['plumbers'] as List<dynamic>;
    return plumbers.any((p) => p['phone'] == phone && p['isVerified'] == true);
  }

  @override
  Future<bool> pushOrderToZoho(Map<String, dynamic> orderData) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return true;
  }

  @override
  Future<bool> syncInventoryUpdates(List<Map<String, dynamic>> items) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockZohoRegistry['workbook_items'] = items;
    return true;
  }
}
