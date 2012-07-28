
interface ContainerScope extends Disposable {
  ContainerScope beginLifetimeScope([void builder(Builder b)]);
  Object resolve(String type, [ParamList params]);
  Lazy<Object> resolveLazy(String type, [ParamList params]);
}

class AutoContainer implements ContainerScope {
  Catalog _baseCatalog;
  Catalog _instanceCatalog;
  List<Disposable> _disposalList; 
  AutoContainer _parent;
  AutoContainer _root;
  bool _isDisposed;
  
  void dispose(){
    _disposalList.forEach((i) => i.dispose());
    _isDisposed = true;
  }
  
  bool isDisposed(){
    return _isDisposed;
  }
  
  ContainerScope get parent() {
    return _parent;
  }
  
  ContainerScope beginLifetimeScope([void builder(Builder b)]){
    var b = new AutoBuilder();
    if (builder != null){
      builder(b);
    }
    var rv = b.build() as AutoContainer;
    rv._parent = this;
    return rv;
  }
  
  /**
   * Return type: [Registerer, Container]
   */
  List _findRegisterer(String type, [bool isOriginalCaller = true]){
    //Algorithm:
    // 1. Test the local cache.
    // 2. Test the local catalog.
    // if non of above could find the reg, recursively find upwart.
    var reg = _instanceCatalog.getRegisterer(type) as AutoRegisterer;
    if (!isOriginalCaller && reg != null && reg._scope == _Scopes.instancePerLifetimeScope){
      reg = null;
    }
    if (reg == null){
      reg = _baseCatalog.getRegisterer(type);
    }
    var container = this;
    if (reg == null) {
      var list = _parent._findRegisterer(type, false);
      if (list == null){
        _throwUnregistered(type);
      }
      reg = list[0] as AutoRegisterer;
      container = list[1] as AutoContainer;
    }
    return [reg, container];
  }
  
  Object resolve(String type, [ParamList params]){    
    var rc = _findRegisterer(type);
    var reg = rc[0] as AutoRegisterer;
    var con = rc[1] as AutoContainer;
    if (reg is _InstanceRegisterer){
      return (reg as _InstanceRegisterer)._instance;
    }
    assert(reg != null);
    
    if (reg._scope == _Scopes.instancePerLifetimeScope){ //In this case, we want to create a new instance
      con = this;
    }
    
    var rv = reg.resolver(this, params);
    var insReg = new _InstanceRegisterer(reg, rv);
    con._register(insReg, rv);
    return rv;
  }
  
  void _register(_InstanceRegisterer reg, Object o){
    assert(reg != null);
    if (reg._scope == _Scopes.instancePerDependency)
    {
      _registerExternallyOwned(reg, o);
    }
    if (reg._scope == _Scopes.instancePerLifetimeScope)
    {
      _registerExternallyOwned(reg, o);
      _registerInstance(reg, o);
    }
    if (reg._scope == _Scopes.singleInstance){
      if (_root == null){
        _root = _getRoot();
      }
      _root._registerExternallyOwned(reg, o);
      _root._registerInstance(reg, o);
    }
  }
  
  Lazy<Object> resolveLazy(String type, [ParamList params]){
    var rc = _findRegisterer(type);
    var reg = rc[0] as AutoRegisterer;
    var con = rc[1] as AutoContainer;
    if (reg is _InstanceRegisterer){
      return new Lazy<Object>( () => (reg as _InstanceRegisterer)._instance);
    }

    var rv = new Lazy<Object>(fun(){
      var o = reg.resolver(this, params);
      var insReg = new _InstanceRegisterer(reg, o);
      con._register(insReg, o);
      return o;
    });
    
    return rv;
  }
  
  AutoContainer _getRoot()
  {
    if (_parent == null){
      return this;
    }
    return _parent._getRoot();
  }
  
  void _registerInstance(_InstanceRegisterer reg, Object instance){
    _instanceCatalog.register(reg);
  }
  
  void _registerExternallyOwned(AutoRegisterer r, Object o){
    if (r.isExternallyOwned){
      return;
    }
    if (o is Disposable){
      _disposalList.add(o as Disposable);
    }
  }
  
  void _throwUnregistered(String type){
    throw new IndexOutOfRangeException("The following type is not registered with container : ".concat(type));
  }
  
  AutoContainer._catalogs(this._baseCatalog, this._instanceCatalog){
    assert(_baseCatalog != null);
    assert(_instanceCatalog != null);
}
  
  factory AutoContainer.fromCatalogs(Iterable<Registerer> masterRegs, Iterable<Registerer> instanceRegs){
    var rv = new AutoContainer._catalogs(
      new _AutoCatalog.fromList(masterRegs),
      new _AutoCatalog.fromList(instanceRegs)
      );
    return rv;
  }
}
