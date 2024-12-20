/*
 * SPDX-FileCopyrightText: 2024 Deutsche Telekom AG
 *
 * SPDX-License-Identifier: Apache-2.0
 */
import 'package:arc_view/src/chat/message/copy_to_clipboard_button.dart';
import 'package:arc_view/src/conversation/models/conversation_message.dart';
import 'package:arc_view/src/conversation/services/conversation_colors.dart';
import 'package:flutter/material.dart';
import 'package:smiles/smiles.dart';

class BotChatMessageCard extends StatelessWidget {
  const BotChatMessageCard({super.key, required this.message});

  final ConversationMessage message;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(8),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 4,
              height: 12,
              color: color(message.conversationId),
            ),
          ),
          message.content.txt.padding(16).pad(0, 0, 24, 0),
          Positioned(
            bottom: 0,
            right: 0,
            child: CopyToClipBoardButton(message.content),
          ),
          if (message.responseTime != null)
            Positioned(
              bottom: 0,
              left: 0,
              child: '${message.responseTime} sec'.small.pad(8, 16, 8, 16),
            ),
        ],
      ),
    ).max(width: 600);
  }
}
