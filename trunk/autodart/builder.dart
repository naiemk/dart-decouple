typedef Object Resolver(ContainerScope c, ParamList params);

interface Builder default AutoBuilder {
  Registerer register(Resolver r);
  Registerer registerInstance(Object instance);
  ContainerScope build();
}

class AutoBuilder implements Builder {
  List<Registerer> _instRegs;
  List<Registerer> _autoRegs;
  
  AutoBuilder() : _instRegs = new List<Registerer>(), 
      _autoRegs = new List<Registerer>();
  
  Registerer register(Resolver r){
    var rv = new AutoRegisterer.fromResolver(r);
    _autoRegs.add(rv);
    return rv;
  }
  
  Registerer registerInstance(Object instance){
    var rv = new _InstanceRegisterer._internal(instance);
    _instRegs.add(rv);
    return(rv);
  }
  
  ContainerScope build(){
    _instRegs.every((r) => _validate(r as AutoRegisterer));
    _autoRegs.every((r) => _validate(r as AutoRegisterer));
    var rv = new AutoContainer.fromCatalogs(_autoRegs, _instRegs);
    return rv;
  }
  
  bool _validate(AutoRegisterer r){
    if (r.type == null){
      throw new IllegalArgumentException("All registerations mst have a type. Make sure you used As() function on registerer :".concat(r.toString()));
    }
    return true;
  }
}
