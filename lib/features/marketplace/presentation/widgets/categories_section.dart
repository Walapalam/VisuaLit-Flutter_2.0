import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/marketplace/presentation/widgets/category_row.dart';

class CategoriesSection extends ConsumerWidget {
  final List<Map<String, String>> categories = [
    {'name': 'Fiction', 'subject': 'fiction'},
    {'name': 'Science', 'subject': 'science'},
    {'name': 'History', 'subject': 'history'},
    {'name': 'Philosophy', 'subject': 'philosophy'},
  ];

  CategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...categories.map((category) => CategoryRow(
          title: category['name']!,
          subject: category['subject']!,
        )),
      ],
    );
  }
}
