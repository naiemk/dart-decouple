
interface Catalog {
  Registerer getRegisterer(String type);
  void register(Registerer r);
}

class _AutoCatalog implements Catalog {
  final Map<String, Registerer> _regs;
  
  _AutoCatalog() : _regs = new Map<String, Registerer>();
  
  Registerer getRegisterer(String type){
    return _regs[type];
  }
  
  void register(Registerer r){
    var rv = _regs[r.type];
    if (rv != null){
      throw new IllegalArgumentException("Following type is already registered in catalog :".concat(r.type));
    }
    _regs.putIfAbsent(r.type,() => r);
  }
  
  factory _AutoCatalog.fromList(Iterable<Registerer> reg){
    var rv = new _AutoCatalog();
    for(var r in reg){
      rv.register(r);
    }
    return rv;
  }
}
