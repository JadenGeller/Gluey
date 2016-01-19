# Gluey

Gluey defines `Unifiable` types that support unification via a backing `Glue` object that holds unified objects together. The most basic type of `Unifiable` object is a `Binding`. When two bindings are unified, their backing `Glue` objects are tested for compatability (at most one unique value must be assigned). If the two are compatible, a new shared `Glue` replaces their backing and binds them together. If the two are incompatible, a `UnificationError` is thrown.

```swift
let a = Binding<Int>()
let b = Binding<Int>()
let c = Binding<Int>()

try Binding.unify(a, b) // all good
try Binding.unify(b, c) // we're cool

a.value = 10
print(c.value) // -> 10

let d = Binding<Int>()
try Binding.unify(a, d) // no problem
print(d.value) // -> 10
// Since d.value = nil, it will take on a's value.

let e = Binding<Int>()
e.value = 20
try Binding.unify(a, e) // UNIFICATION ERROR!!!
// Since a.value = 10 and b.value = 20, they cannot be unified.
```

Gluey also defines a `Term<Value>` enum with cases `Variable(Binding<Value>)` and `Constant(Value)` that makes it easy to unify known constants with unknown variables. The most useful attribe of `Term` is that it also attempt to recurisvely unify the constant case if `Value: Unifiable`. This allows `Term` to be used to create powerful tree-like structures that can be easily unified.
```swift
let a = Term.Constant(10)
let b = Term.Variable(Binding<Int>())
try Term.unify(a, b)
print(b.value) // -> 10

let c = Term.Constant(Term.Constant(10))
let d = Term.Constant(Term.Variable(Binding<Int>()))
try Term.unify(c, d)
print(d.value?.value) // -> 10
```
