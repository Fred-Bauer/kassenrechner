import 'package:flutter/material.dart';

import '../models/cash_models.dart';

/// Static configuration for all categories and cash unit values.
const List<CashCategory> cashCategories = [
  CashCategory(
    title: 'Rollen',
    items: [
      CashItem(id: 'rollen_2', label: '2€ Rolle', value: 100.0, cardColor: Color(0xFF6F42C1)),
      CashItem(id: 'rollen_1', label: '1€ Rolle', value: 50.0, cardColor: Color(0xFF2E7D32)),
      CashItem(id: 'rollen_50c', label: '50ct Rolle', value: 20.0, cardColor: Color(0xFFE67E22)),
      CashItem(id: 'rollen_20c', label: '20ct Rolle', value: 8.0, cardColor: Color(0xFFEF5350)),
      CashItem(id: 'rollen_10c', label: '10ct Rolle', value: 4.0, cardColor: Color(0xFF1E88E5)),
      CashItem(id: 'rollen_5c', label: '5ct Rolle', value: 2.5, cardColor: Color(0xFFFDD835)),
      CashItem(id: 'rollen_2c', label: '2ct Rolle', value: 1.0, cardColor: Color(0xFF90A4AE)),
      CashItem(id: 'rollen_1c', label: '1ct Rolle', value: 0.5, cardColor: Color(0xFFECEFF1)),
    ],
  ),
  CashCategory(
    title: 'Scheine',
    useValueAsLabel: true,
    items: [
      CashItem(id: 'schein_500', label: '500€ Schein', value: 500.0, cardColor: Color(0xFF7D3C98)),
      CashItem(id: 'schein_200', label: '200€ Schein', value: 200.0, cardColor: Color(0xFFD4A017)),
      CashItem(id: 'schein_100', label: '100€ Schein', value: 100.0, cardColor: Color(0xFF2E8B57)),
      CashItem(id: 'schein_50', label: '50€ Schein', value: 50.0, cardColor: Color(0xFFE67E22)),
      CashItem(id: 'schein_20', label: '20€ Schein', value: 20.0, cardColor: Color(0xFF2E86C1)),
      CashItem(id: 'schein_10', label: '10€ Schein', value: 10.0, cardColor: Color(0xFFC0392B)),
      CashItem(id: 'schein_5', label: '5€ Schein', value: 5.0, cardColor: Color(0xFF95A5A6)),
    ],
  ),
  CashCategory(
    title: 'Münzen',
    useValueAsLabel: true,
    items: [
      CashItem(
        id: 'muenze_2',
        label: '2€ Münze',
        value: 2.0,
        cardColor: Color(0xFFC0C6CF),
        borderColor: Color(0xFFD4AF37),
        borderWidth: 15,
      ),
      CashItem(
        id: 'muenze_1',
        label: '1€ Münze',
        value: 1.0,
        cardColor: Color(0xFFD4AF37),
        borderColor: Color(0xFFC0C6CF),
        borderWidth: 15,
      ),
      CashItem(id: 'muenze_50c', label: '50ct Münze', value: 0.5, cardColor: Color(0xFFD4AF37)),
      CashItem(id: 'muenze_20c', label: '20ct Münze', value: 0.2, cardColor: Color(0xFFD8B23F)),
      CashItem(id: 'muenze_10c', label: '10ct Münze', value: 0.1, cardColor: Color(0xFFD8B23F)),
      CashItem(id: 'muenze_5c', label: '5ct Münze', value: 0.05, cardColor: Color(0xFFC87848)),
      CashItem(id: 'muenze_2c', label: '2ct Münze', value: 0.02, cardColor: Color(0xFFC87848)),
      CashItem(id: 'muenze_1c', label: '1ct Münze', value: 0.01, cardColor: Color(0xFFC87848)),
    ],
  ),
];
