/*
 * SPDX-FileCopyrightText: 2024 Deutsche Telekom AG
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:arc_view/src/client/agents_notifier.dart';
import 'package:arc_view/src/core/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_localization.dart';

class AgentTabs extends ConsumerWidget {
  const AgentTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agents = ref.watch(agentsNotifierProvider).valueOrNull;

    return Row(
      children: [
        Icons.refresh.onPressed(
          onPressed: () => ref.refreshAgents(),
          size: 16,
          color: context.colorScheme.onSurface,
        ),
        if (agents == null || agents.names.isEmpty)
          AppLocalizations.of(context)
              .translate('AgentNotFoundKey')
              .style(color: context.colorScheme.onSurface.withOpacity(0.5))
              .pad(4, 8, 4, 8),
        if (agents != null)
          for (var e in agents.names)
            ((e == agents.activated)
                ? Container(
                    decoration: BoxDecoration(
                      color:
                          context.colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: e.txt.pad(4, 8, 4, 8))
                : e.onPressed(() {
                    ref.activateAgent(e, agents.names);
                  }))
      ],
    );
  }
}
