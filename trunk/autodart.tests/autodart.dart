#import('dart:unittest');
#import("../autodart/autodart.dart");

class Baz{
  String name;
}

class Bar{
  Baz baz;
  Bar(this.baz);
}

class Foo{
  Bar bar;
  Foo(this.bar);
}

void _ResolvePerDepNoScopeWithParam(){
  var b = new AutoBuilder();
  b.register(fun(c, p){ var bz = new Baz(); bz.name = p.named("name", false); return bz;})
    .As("Baz");
  
  b.register((c, p) => new Bar(c.resolve("Baz", p)))
    .As("Bar");
  
  b.register((c, p) => new Foo(c.resolve("Bar", p)))
    .As("Foo");
  
  var c = b.build();
  
  var foo = c.resolve("Foo", new ParamList([new NamedParameter<String>("name", "name")])) as Foo;
  expect(foo, isNotNull);
  expect(foo.bar, isNotNull);
  expect(foo.bar.baz, isNotNull);
  
  var excThrown = false; //The expect(...,throws) did not work!
  try{
    foo = c.resolve("Foo", new ParamList([new NamedParameter<String>("name2","")]));
  }
  catch(IndexOutOfRangeException x){
    excThrown = true;
  }
  expect(excThrown, isTrue);
}

void _ResolvePreDepNoScope(){
  var b = new AutoBuilder();
  b.register((c, p) => new Baz())
    .As("Baz");
  
  b.register((c, p) => new Bar(c.resolve("Baz")))
    .As("Bar");
  
  b.register((c, p) => new Foo(c.resolve("Bar")))
    .As("Foo");
  
  var c = b.build();
  
  var foo = c.resolve("Foo") as Foo;
  expect(foo, isNotNull);
  expect(foo.bar, isNotNull);
  expect(foo.bar.baz, isNotNull);
}

void _ResolveWithScoping(){
  var b = new AutoBuilder();
  b.register((c, p) => new Baz())
    .As("Baz")
    .singleInstance();
  b.register((c, p) => new Bar(c.resolve("Baz")))
    .As("Bar")
    .instancePerLifetimeScope();
  b.register((c, p) => new Foo(c.resolve("Bar")))
    .As("Foo")
    .instancePerDependency();
  var scope1 = b.build();
  var foo1 = scope1.resolve("Foo") as Foo;
  
  var scope2 = scope1.beginLifetimeScope();
  var foo2 = scope2.resolve("Foo") as Foo;
  var foo3 = scope2.resolve("Foo") as Foo;

  expect(foo1 === foo2, isFalse);
  expect(foo2 === foo3, isFalse);
  expect(foo1.bar === foo2.bar, isFalse);
  expect(foo2.bar === foo3.bar, isTrue);
  expect(foo1.bar.baz === foo2.bar.baz, isTrue);
  expect(foo2.bar.baz === foo3.bar.baz, isTrue);
}

void _ResolveUnregistered(){
  var b = new AutoBuilder();
  b.register((c, p) => new Bar(c.resolve("Baz")))
    .As("Bar");
  b.register((c, p) => new Foo(c.resolve("Bar")))
  .As("Foo");
  var c = b.build();
  var ex = false;// expect(..,except) does not work!
  try{
    c.resolve("Foo");
  }
  catch(Exception x){
    ex = true;
  }
  expect(ex, isTrue);
}

void _DuplicateRegister(){
  var b = new AutoBuilder();
  b.register((c, p) => new Foo(c.resolve("Bar")))
  .As("Foo");
  
  var ex = false;
  try
  {
    b.register((c, p) => new Foo(c.resolve("Bar")))
    .As("Foo");
    b.build();
  }catch(Exception x){
    ex = true;
  }
  expect(ex, isTrue);  
}
void main(){
  test("Resolve Per Dependency No Scoping", () => _ResolvePreDepNoScope());
  test("Resolve Per Dependency No Scoping Parameter", () => _ResolvePerDepNoScopeWithParam());
  test("Resolve with Scoping", () => _ResolveWithScoping());
  test("Resolve Unregistered", () => _ResolveUnregistered());
  test("Duplicate Registeration", () => _DuplicateRegister());
}