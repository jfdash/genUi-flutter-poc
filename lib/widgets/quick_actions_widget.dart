import 'package:flutter/material.dart';
import 'package:gen_ui_poc/service/ai_service.dart';
import 'package:provider/provider.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final quickActions = [
      {
        'title': '🚗 Assicurazione Auto',
        'message': 'Vorrei un preventivo per assicurare la mia auto',
      },
      {'title': '🏠 Assicurazione Casa', 'message': 'Sono interessato ad assicurare la mia casa'},
      {
        'title': '🏥 Assicurazione Salute',
        'message': 'Vorrei informazioni sull\'assicurazione sanitaria',
      },
      {'title': '🛵 Assicurazione Moto', 'message': 'Devo assicurare la mia moto'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: quickActions.map((action) {
        return ActionChip(
          avatar: Text(action['title']!.split(' ')[0], style: const TextStyle(fontSize: 20)),
          label: Text(
            action['title']!.substring(action['title']!.indexOf(' ') + 1),
            style: const TextStyle(fontSize: 13),
          ),
          onPressed: () {
            context.read<AIService>().sendMessage(action['message']!);
          },
          backgroundColor: Colors.blue.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }
}
