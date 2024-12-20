/*
 * SPDX-FileCopyrightText: 2024 Deutsche Telekom AG
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:async';
import 'dart:convert';

import 'package:arc_view/main.dart';
import 'package:arc_view/src/client/models/system_context.dart';
import 'package:arc_view/src/client/models/user_context.dart';
import 'package:arc_view/src/client/notifiers/agent_client_notifier.dart';
import 'package:arc_view/src/client/oneai_client.dart';
import 'package:arc_view/src/conversation/models/conversation.dart';
import 'package:arc_view/src/conversation/models/conversation_message.dart';
import 'package:arc_view/src/conversation/models/conversations.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversations_notifier.g.dart';

@Riverpod(keepAlive: true)
class ConversationsNotifier extends _$ConversationsNotifier {
  final _log = Logger('ConversationNotifier');

  @override
  Conversations build() {
    final userContext = _loadUserContext();
    final systemContext = _loadSystemContext();
    final newConversation = Conversation(
      createdAt: DateTime.now(),
      userContext: userContext,
      systemContext: systemContext,
      messages: List.empty(),
      conversationId: 'cid-${DateTime
          .now()
          .millisecondsSinceEpoch}',
    );
    return Conversations(
      conversations: [],
      current: newConversation,
    );
  }

  UserContext _loadUserContext() {
    final json = _load('conversation_user_context');
    if (json == null) return UserContext(userId: "unknown", profile: []);
    return UserContext.fromJson(jsonDecode(json));
  }

  SystemContext _loadSystemContext() {
    final json = _load('conversation_system_context');
    if (json == null) return SystemContext(entries: []);
    return SystemContext.fromJson(jsonDecode(json));
  }

  String? _load(String key) =>
      ref.read(sharedPreferencesProvider).getString(key);

  updateConversation(Conversation conversation) {
    final preferences = ref.read(sharedPreferencesProvider);
    preferences.setString('conversation_user_context',
        jsonEncode(conversation.userContext.toJson()));
    preferences.setString('conversation_system_context',
        jsonEncode(conversation.systemContext.toJson()));
    state = state.addAsCurrent(conversation);
  }

  replay() async {
    final conversation = state.current;
    newConversation();
    for (final msg in conversation.messages) {
      if (msg.type == MessageType.loading || msg.type == MessageType.bot) {
        continue;
      }
      await addUserMessage(msg.content);
    }
  }

  Future<void> addUserMessage(String msg) {
    return addMessage(ConversationMessage(
      type: MessageType.user,
      content: msg,
      conversationId: state.current.conversationId,
    ));
  }

  Future<void> addMessage(ConversationMessage msg) {
    final callback = Completer();
    final conversation = state.current.add([
      msg,
      loadingMessage(state.current.conversationId),
    ]);
    state = state.update(conversation);
    ref
        .read(agentClientNotifierProvider)
        .sendMessage(conversation)
        .listen((value) {
      final newMessages = [];
      for (final message in conversation.messages) {
        if (message.type != MessageType.loading) {
          newMessages.add(message);
        }
      }
      state = state.update(
        conversation.copyWith(
          messages: [
            ...newMessages,
            _handleBotMessage(value, conversation),
          ],
        ),
      );
      if (!callback.isCompleted) callback.complete();
    });
    return callback.future;
  }

  ConversationMessage _handleBotMessage(MessageResult value,
      Conversation conversation) {
    return switch (value.message) {
      '<LOADING>' => loadingMessage(conversation.conversationId),
      _ =>
          ConversationMessage(
            type: MessageType.bot,
            content: value.message,
            conversationId: conversation.conversationId,
            responseTime: value.responseTime,
            agent: value.agent,
          )
    };
  }

  newConversation() {
    state = state.copyWith(current: build().current);
  }

  deleteAll() {
    state = build();
  }

  delete(Conversation conversation) {
    state = state.remove(conversation);
    if (state.current == conversation) {
      newConversation();
    }
  }
}
