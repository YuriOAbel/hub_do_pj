# Skill: New Model

How to create or update domain models in `lib/domain/models/`.

## When to Use Freezed

- Domain data crossing service/provider/view boundaries.
- App entities stored, displayed, filtered, or composed by providers.
- Models that benefit from immutability and `copyWith`.

## Standard Template

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_model.freezed.dart';
part 'my_model.g.dart';

@freezed
sealed class MyModel with _$MyModel {
  const factory MyModel({
    required String id,
    required DateTime createdAt,
    @Default(false) bool isActive,
  }) = _MyModel;

  factory MyModel.fromJson(Map<String, dynamic> json) =>
      _$MyModelFromJson(json);
}
```

## Rules

- Keep model fields strongly typed.
- Keep model responsibility focused on structure/serialization.
- Add computed getters only when they remove repeated logic.
- Update `lib/domain/models/models.dart` exports when adding a file.

## Required Command

After creating or changing a Freezed/json model:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Cross-Skill Ownership

- Architecture and boundaries: `.cursor/skills/dart-architecture/SKILL.md`
- Remote Config parsing/default fallback: `.cursor/skills/remote-config/SKILL.md`
