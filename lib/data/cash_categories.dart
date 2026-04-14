import 'package:flutter/material.dart';

import '../models/cash_models.dart';

/// Static configuration for all categories and cash unit values.
const List<CashCategory> cashCategories = [
  CashCategory(
    title: 'Rollen',
    backgroundColor: Color(0xFFE7F4FF),
    items: [
      CashItem(id: 'rollen_2', label: '2 EUR Rolle', value: 100.0),
      CashItem(id: 'rollen_1', label: '1 EUR Rolle', value: 50.0),
      CashItem(id: 'rollen_50c', label: '50 Cent Rolle', value: 20.0),
      CashItem(id: 'rollen_20c', label: '20 Cent Rolle', value: 8.0),
      CashItem(id: 'rollen_10c', label: '10 Cent Rolle', value: 4.0),
      CashItem(id: 'rollen_5c', label: '5 Cent Rolle', value: 2.5),
      CashItem(id: 'rollen_2c', label: '2 Cent Rolle', value: 1.0),
      CashItem(id: 'rollen_1c', label: '1 Cent Rolle', value: 0.5),
    ],
  ),
  CashCategory(
    title: 'Scheine',
    backgroundColor: Color(0xFFFFF4E8),
    items: [
      CashItem(id: 'schein_500', label: '500 EUR Schein', value: 500.0),
      CashItem(id: 'schein_200', label: '200 EUR Schein', value: 200.0),
      CashItem(id: 'schein_100', label: '100 EUR Schein', value: 100.0),
      CashItem(id: 'schein_50', label: '50 EUR Schein', value: 50.0),
      CashItem(id: 'schein_20', label: '20 EUR Schein', value: 20.0),
      CashItem(id: 'schein_10', label: '10 EUR Schein', value: 10.0),
      CashItem(id: 'schein_5', label: '5 EUR Schein', value: 5.0),
    ],
  ),
  CashCategory(
    title: 'Muenzen',
    backgroundColor: Color(0xFFEEF9EC),
    items: [
      CashItem(id: 'muenze_2', label: '2 EUR Muenze', value: 2.0),
      CashItem(id: 'muenze_1', label: '1 EUR Muenze', value: 1.0),
      CashItem(id: 'muenze_50c', label: '50 Cent Muenze', value: 0.5),
      CashItem(id: 'muenze_20c', label: '20 Cent Muenze', value: 0.2),
      CashItem(id: 'muenze_10c', label: '10 Cent Muenze', value: 0.1),
      CashItem(id: 'muenze_5c', label: '5 Cent Muenze', value: 0.05),
      CashItem(id: 'muenze_2c', label: '2 Cent Muenze', value: 0.02),
      CashItem(id: 'muenze_1c', label: '1 Cent Muenze', value: 0.01),
    ],
  ),
];
