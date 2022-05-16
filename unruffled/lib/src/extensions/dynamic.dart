part of unruffled;

extension UnruffledDynamicExt on dynamic {
  int compareTo(dynamic obj) {
    if (obj is num && this is num) {
      return obj.compareTo(this);
    }
    if (obj is String && this is String) {
      return obj.compareTo(this);
    }
    if (obj is DateTime && this is DateTime) {
      return obj.compareTo(this);
    }
    return 1;
  }
}
