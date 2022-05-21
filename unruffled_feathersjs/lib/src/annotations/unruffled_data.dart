part of unruffled_feathersjs;

/// Annotation to create an Unruffled collection.
@Target({TargetKind.classType})
class UnruffledFeathersJsData extends UnruffledData {
  const UnruffledFeathersJsData({Type? adapter})
      : super(adapter: adapter ?? FeathersJsRemoteRepository);
}
