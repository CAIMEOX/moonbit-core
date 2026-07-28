///|
fn[T] removes_list(
  k : Int,
  n : Int,
  xs : @list.List[T],
) -> @list.List[@list.List[T]] {
  if k > n {
    @list.empty()
  } else {
    let xs_drop = xs.drop(k)
    if xs_drop.is_empty() {
      @list.empty()
    } else {
      let xs_take = xs.take(k)
      removes_list(k, n - k, xs_drop).map(x => xs_take.concat(x)).add(xs_drop)
    }
  }
}

///|
fn[T] removes_array(k : Int, n : Int, xs : Array[T]) -> Array[Array[T]] {
  if k > n {
    []
  } else {
    let xs2 = xs[:k].to_owned()
    let xs1 = xs[k:].to_owned()
    if xs1.is_empty() {
      []
    } else {
      [xs1, ..removes_array(k, n - k, xs1).map(x => xs2 + x)]
    }
  }
}

///|
fn[T] apply_while_list(
  x : T,
  f : (T) -> T,
  cond : (T) -> Bool,
) -> @list.List[T] {
  for acc = x, lst = @list.empty() {
    let next = f(acc)
    if cond(next) {
      continue next, lst.add(next)
    } else {
      break lst
    }
  }
}

///|
fn[T] apply_while_array(x : T, f : (T) -> T, cond : (T) -> Bool) -> Array[T] {
  for acc = x, lst = [] {
    let next = f(acc)
    if cond(next) {
      continue next, [next, ..lst]
    } else {
      break lst
    }
  }
}

///|
fn shrink_decimal(x : Double) -> Iter[Double] {
  guard !x.is_nan() else { [|0.0, 1.0, -1.0, 2.0|] }
  guard !x.is_inf() else { [|0.0, 1.0, -1.0, 1000.0, -1000.0|] }
  guard x >= 0.0 else {
    Iter::singleton(-x).concat(shrink_decimal(-x).map(Double::neg))
  }
  guard x != 0.0 else { Iter::empty() }
  [|1.0, 10.0, 100.0, 1000.0, 10000.0, 100000.0|].flat_map(p => {
    let m = (x * p + 0.5).floor().to_int64()
    if p != 1.0 && m % 10L == 0L {
      return Iter::empty()
    }
    Iter::singleton(m)
    .concat(Shrink::shrink(m))
    .map(n => n.to_double() / p)
    .filter(y => y >= 0.0 && y < x)
  })
}
