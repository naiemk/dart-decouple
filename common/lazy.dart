
/**
 * Lazily get an object
 */
class Lazy<T> {
  T _object;
  Function _initializer;
  
  Lazy(T fun()) : _initializer = fun;
  
  bool get isInitialize() {
    return _object != null;
  }
  
  T get object() {
    if (_object == null) {
      _object = _initializer();
    }
    return _object;
  }
}
