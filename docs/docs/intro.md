---
sidebar_position: 1
---

# Quick Start

## Setup

### 1. Add to pubspec.yaml

```yaml
dependencies:
  json_annotation: ^4.5.0
  unruffled: ^1.0.0

dev_dependencies:
  build_runner: any
  json_serializable: ^6.2.0
  unruffled_generator: ^1.0.0
```

**NOTE :** Unruffled relies to json_annotation and json_serializable to work as expected, please ensure to add theme in your dependencies.

### 2. Declare models

Declare models used by your remote service and generate Unruffled adapters.

```dart
@UnruffledData()
@JsonSerializable()
class User extends DataModel<User> {
  String name;
  String surname;

  User({String? key, int? id, required this.name, required this.surname})
      : super(id, key);
}
```

Build your flutter directory to generate a UserAdapter()

`flutter pub run build_runner build`

**NOTE:** Your class must construct a `String? key` and `Object? id` and pass it to `super();`\
- `id` refers to your remote object ID\
- `key` refers to your local object ID generated by unruffled

### 3. Register adapters

For all platforms except web, use [path_provider](https://pub.dev/packages/path_provider) to generate a directory path.
```dart
final dir = await getApplicationSupportDirectory(); // path_provider package
var unruffled = Unruffled(
      baseDirectory: dir,
      defaultBaseUrl: 'http://example.com',
      dio: dio,
  )
  .registerAdapter(UserAdapter());
  ```

### 4. Initialize Unruffled

Before using Unruffled, ensure to initialize it.

```
await unruffled.init();
```

🚀 That's it, you're ready to go !

## Usage

### 1. Create a user

Define a user and call User repository.
```dart
final testUser = User(name: 'John', surname: 'Doe');
final repository = unruffled.repository<User>();
```

Create your user by calling post() method.

```dart
var user = await repository.post(model: testUser);
```

### 2. Get a user

```dart
var user = await repository.get(key: user.key);
```

### 3. Delete a user

```dart
var user = await repository.delete(key: user.key);
```

### 4. Manage connectivity isues

If connectivity errors occur, Unruffled stores automatically requests to retry them later, just call the global method :

```dart
final operations = unruffled.offlineOperations;
for (var remoteRepository in operations.keys) {
  await operations[remoteRepository].retry(remoteRepository);
}
```

Or call for each remote repository :
```dart
final operations = repository.offlineOperations;
for (var operation in operations) {
  await operation.retry(repository);
}
```
