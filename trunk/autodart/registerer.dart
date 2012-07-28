
interface Registerer {
  Registerer singleInstance();
  Registerer instancePerDependency();
  Registerer instancePerLifetimeScope();
  Registerer As(String type);
  String get type();
}

class AutoRegisterer implements Registerer{
  num _scope = null;
  String _type;
  bool _isExternallyOwned = false;
  Resolver _resolver;
  
  num get scope(){ return _scope; }
  String get type(){ return _type; }
  bool get isExternallyOwned() {return _isExternallyOwned;}
  Resolver get resolver() {return _resolver;}
  
  void _ensureScopeIsNotSet(){
    if (_scope != null){
      throw new IllegalArgumentException("Scope is already set.");
    }
  }
  
  Registerer singleInstance(){
    _ensureScopeIsNotSet();
    _scope = _Scopes.singleInstance;
    return this;
  }
  
  Registerer instancePerDependency(){
    _ensureScopeIsNotSet();
    _scope = _Scopes.instancePerDependency;
    return this;
  }
  
  Registerer instancePerLifetimeScope(){
    _ensureScopeIsNotSet();
    _scope = _Scopes.instancePerLifetimeScope;
    return this;
  }
  
  Registerer As(String type){
    _type = type;
    return this;
  }
  
  AutoRegisterer.fromResolver(this._resolver);
}

class _InstanceRegisterer extends AutoRegisterer {
  final Object _instance;
  _InstanceRegisterer._internal(this._instance): super.fromResolver(null);
  
  factory _InstanceRegisterer(AutoRegisterer obj, Object instance){
    var rv = new _InstanceRegisterer._internal(instance);
    rv._scope = obj.scope;
    rv._type = obj.type;
    rv._isExternallyOwned = obj.isExternallyOwned;
    rv._resolver = null;
    return rv;
  }
}