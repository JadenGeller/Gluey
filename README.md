# Gluey

Gluey is a bare-bones unification framework. It defines low-level primitives for unifying objects including support for *recursive unfication* and *backtracking*. Though it does not define tree-like unification types, it does define primitives that make these very simple to build. For a full-featured logic framework (built on top of Gluey!), check out [Axiomatic](https://github.com/JadenGeller/Axiomatic).

## Binding

> Your handy unification primitive.

A `Binding` is a sort of variable that can be linked to another binding such that they will always have the same value. The unification of two `Binding`s will always succeed unless both already have values, and these values are not equal. If the two are incompatible, a `UnificationError` is thrown. Behind the scenes, `Binding`s are held together by sharing a common `Glue`, but you don't need to worry about this. All you need to know is that once two `Binding`s are bound, they will always have the same value.

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

## Unifiable

> The recursive unification superstar!

Gluey also defines a generic enum `Unifiable<Element>` with cases `Variable(Binding<Element>)` and `Constant(Element)` making it easy to unify known constants with unknown variables. A very useful property of `Unifiable` is that it will also attempt to recurisvely unify the constant case if `Element: UnifiableType`. This allows `Unifiable` to be used to create powerful tree-like structures that can be easily unified.

```swift
// Unification of constant and variable
let a = Unifiable.Constant(10)
let b = Unifiable.Variable(Binding<Int>())
try Unifiable.unify(a, b)
print(b.value) // -> 10

// Recursive unification
let c = Unifiable.Constant(Unifiable.Constant(10))
let d = Unifiable.Constant(Unifiable.Variable(Binding<Int>()))
try Unifiable.unify(c, d)
print(d.value?.value) // -> 10
```

## Documentation

Still confused? Read more about Gluey in the [documentation](http://jadengeller.github.io/Gluey/docs/index.html) or maybe check out how its used in [Axiomatic](https://github.com/JadenGeller/Axiomatic)! Or tweet at [me](https://twitter.com/jadengeller) if you still need some help. :)
