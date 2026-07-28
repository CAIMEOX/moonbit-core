///|
/// Types that can enumerate "smaller" variants of a given value for
/// the classical QuickCheck shrinker. Each call to `shrink(x)` returns
/// an `Iter[Self]` of candidates strictly simpler than `x`; the driver
/// walks these candidates after a failure, keeping the first one that
/// still falsifies the property.
///
/// The return type is `Iter[Self]` rather than `Array[Self]` so large
/// or recursive shrink spaces stay lazy. The default body (`= _`)
/// means "no shrinks" — a conservative starting point for types where
/// shrinking isn't meaningful.
///
/// ```mbt check
/// test {
///   // `Int` has a built-in Shrink instance that walks toward 0.
///   let candidates : Array[Int] = Shrink::shrink(100).collect()
///   assert_true(candidates.contains(0))
///   assert_true(candidates.length() > 0)
///   // `Bool` shrinks `true` to `false`, and `false` has no shrinks.
///   @debug.assert_eq(Shrink::shrink(true).collect(), [false])
///   @debug.assert_eq(Shrink::shrink(false).collect(), [])
/// }
/// ```
pub(open) trait Shrink {
  fn shrink(Self) -> Iter[Self] = _
}

///|
impl Shrink with fn shrink(_a) {
  Iter::empty()
}

///|
pub impl Shrink for Int with fn shrink(x) {
  apply_while_list(x, z => z / 2, z => (x - z).abs() < x.abs())
  .map(i => x - i)
  .iter()
  .concat(Iter::singleton(0))
  .filter(u => u != x)
}

///|
pub impl Shrink for Int64 with fn shrink(x) {
  apply_while_list(x, z => z / 2, z => (x - z).abs() < x.abs())
  .map(i => x - i)
  .iter()
  .concat(Iter::singleton(0))
  .filter(u => u != x)
}

///|
pub impl Shrink for UInt with fn shrink(x) {
  apply_while_list(x, z => z / 2, z => z > 0)
  .map(i => x - i)
  .iter()
  .concat(Iter::singleton(0))
  .filter(u => u != x)
}

///|
pub impl Shrink for UInt64 with fn shrink(x) {
  apply_while_list(x, z => z / 2, z => z > 0)
  .map(i => x - i)
  .iter()
  .concat(Iter::singleton(0))
  .filter(u => u != x)
}

///|
pub impl Shrink for Bool with fn shrink(b) {
  if !b {
    Iter::empty()
  } else {
    Iter::singleton(false)
  }
}

///|
pub impl Shrink for Byte with fn shrink(x) {
  let xi = x.to_int()
  apply_while_list(xi, z => z / 2, z => z > 0)
  .map(i => (xi - i).to_byte())
  .iter()
  .concat(Iter::singleton(Int::to_byte(0)))
  .filter(u => u != x)
}

///|
pub impl Shrink for Char with fn shrink(c) {
  let ci = c.to_int()
  if ci == 0 {
    return Iter::empty()
  } else {
    let (cl, ch) = (Int::unsafe_to_char(ci - 1), Int::unsafe_to_char(ci + 1))
    [|cl, ch, 'a', 'A', '1', '\n', '\t', '\b', '\\', '\'', '\r', ' '|]
  }
}

///|
pub impl Shrink for Double with fn shrink(x) {
  shrink_decimal(x)
}

///|
pub impl Shrink for Float with fn shrink(x) {
  shrink_decimal(x.to_double()).map(Float::from_double)
}

///|
pub impl Shrink for String

///|
pub impl Shrink for Bytes

///|
pub impl Shrink for Unit

///|
pub impl[T : Shrink] Shrink for T? with fn shrink(x) {
  match x {
    None => Iter::empty()
    Some(v) =>
      Shrink::shrink(v).map(v1 => Some(v1)).concat(Iter::singleton(None))
  }
}

///|
pub impl[T : Shrink, E : Shrink] Shrink for Result[T, E] with fn shrink(x) {
  match x {
    Ok(v) => Shrink::shrink(v).map(v1 => Ok(v1))
    Err(e) => Shrink::shrink(e).map(e1 => Err(e1))
  }
}

///|
pub impl[A : Shrink, B : Shrink] Shrink for (A, B) with fn shrink(x) {
  let (a, b) = x
  Shrink::shrink(a)
  .map(a1 => (a1, b))
  .concat(Shrink::shrink(b).map(b1 => (a, b1)))
}

///|
pub impl[A : Shrink, B : Shrink, C : Shrink] Shrink for (A, B, C) with fn shrink(
  x,
) {
  let (a, b, c) = x
  Shrink::shrink((a, (b, c))).map(y => {
    let (a1, (b1, c1)) = y
    (a1, b1, c1)
  })
}

///|
pub impl[A : Shrink, B : Shrink, C : Shrink, D : Shrink] Shrink for (A, B, C, D) with fn shrink(
  x,
) {
  let (a, b, c, d) = x
  Shrink::shrink((a, (b, c, d))).map(y => {
    let (a1, (b1, c1, d1)) = y
    (a1, b1, c1, d1)
  })
}

///|
pub impl[A : Shrink, B : Shrink, C : Shrink, D : Shrink, E : Shrink] Shrink for (
  A,
  B,
  C,
  D,
  E,
) with fn shrink(x) {
  let (a, b, c, d, e) = x
  Shrink::shrink((a, (b, c, d, e))).map(y => {
    let (a1, (b1, c1, d1, e1)) = y
    (a1, b1, c1, d1, e1)
  })
}

///|
pub impl[A : Shrink, B : Shrink, C : Shrink, D : Shrink, E : Shrink, F : Shrink] Shrink for (
  A,
  B,
  C,
  D,
  E,
  F,
) with fn shrink(x) {
  let (a, b, c, d, e, f) = x
  Shrink::shrink((a, (b, c, d, e, f))).map(y => {
    let (a1, (b1, c1, d1, e1, f1)) = y
    (a1, b1, c1, d1, e1, f1)
  })
}

///|
pub impl[T : Shrink] Shrink for @list.List[T] with fn shrink(xs) {
  let n = xs.length()
  fn shr_sub_terms(lst : @list.List[T]) {
    match lst {
      Empty => Iter::empty()
      More(x, tail=xs) =>
        T::shrink(x)
        .map(x_ => xs.add(x_))
        .concat(shr_sub_terms(xs).map(xs_ => xs_.add(x)))
    }
  }

  apply_while_list(n, x => x / 2, x => x > 0)
  .map(k => removes_list(k, n, xs))
  .flatten()
  .iter()
  .concat(shr_sub_terms(xs))
}

///|
pub impl[X : Shrink] Shrink for Array[X] with fn shrink(xs) {
  let view = xs[:]
  let n = view.length()
  fn shr_sub_terms(arr : ArrayView[X]) {
    match arr {
      [] => Iter::empty()
      [x, .. xs] =>
        X::shrink(x)
        .map(x_ => [x_, ..xs])
        .concat(shr_sub_terms(xs).map(xs_ => [x, ..xs_]))
    }
  }

  apply_while_array(n, x => x / 2, x => x > 0)
  .map(k => removes_array(k, n, xs))
  .flatten()
  .iter()
  .concat(shr_sub_terms(view))
}

///|
pub impl[X : Shrink] Shrink for Iter[X] with fn shrink(xs) {
  let arr = xs.to_array()
  let its : Array[_] = Array::makei(arr.length(), x => {
    X::shrink(arr[x])
    .map(y => {
      let cp = arr.copy()
      cp[x] = y
      cp.iter()
    })
    .to_array()
  }).flatten()
  let rms : Array[Iter[X]] = arr.mapi((i, _) => {
    let a = arr.copy()
    a.remove(i) |> ignore
    a.iter()
  })
  rms.iter().concat(its.iter())
}
