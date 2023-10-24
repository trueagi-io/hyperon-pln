# Subtyping

Define a [subtyping](https://en.wikipedia.org/wiki/Subtyping)
relationship `<:`.  That is

```
(<: T1 T2)
```

means that type `T1` is a subtype of `T2`.

## Algebraic Laws

- Reflexive: `(<: T T)`
- Transitive: If `(<: T1 T2)` and `(<: T2 T3)` then `(<: T1 T3)`

## Relationships between Subtyping and Typing

There are two variants of that experiment, one with explicit coercion,
and one implicit coercion.

### Explicit Coercion

### Implicit Coercion

Because MeTTa supports non-determinism, we are also able to use
implicit type coercion.
