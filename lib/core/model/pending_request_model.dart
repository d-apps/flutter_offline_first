import 'package:flutter_offline_first/core/enums/operation_type_enum.dart';
import 'package:flutter_offline_first/core/model/note_model.dart';

class PendingRequestModel {
  final String id;
  final OperationTypeEnum type;
  final NoteModel note;

  PendingRequestModel({
    required this.id,
    required this.type,
    required this.note,
  });

  factory PendingRequestModel.fromJson(Map<dynamic, dynamic> json) {
    return PendingRequestModel(
      id: json['id'],
      type: OperationTypeEnum.fromString(json['type']),
      note: NoteModel.fromJson(json['note']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'note': note.toJson(),
    };
  }

}