// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AgentEventImpl _$$AgentEventImplFromJson(Map<String, dynamic> json) =>
    _$AgentEventImpl(
      type: json['type'] as String,
      payload: json['payload'] as String,
      conversationId: json['conversationId'] as String?,
    );

Map<String, dynamic> _$$AgentEventImplToJson(_$AgentEventImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'payload': instance.payload,
      'conversationId': instance.conversationId,
    };
