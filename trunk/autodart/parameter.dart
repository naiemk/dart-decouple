
abstract class Parameter<T> {
  abstract T get value();
}

class ParamList {
  List<Parameter> _param;
  ParamList(this._param);
  Object named(String name, [bool optional=true]){
    assert(name != null);
    var p = _param.filter((p) => p is NamedParameter && (p as NamedParameter).name == name);
    if (!optional && p.isEmpty()){
      throw new IndexOutOfRangeException(name);
    }
    for(var v in p){
      return v.value;
    }
  }
}

class NamedParameter<T> extends Parameter<T> {
  final T _value;
  final String name;
  NamedParameter(this.name, this._value);
  
  T get value(){
    return _value;
  }
}
