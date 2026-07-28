///|
test "shrink int" {
  debug_inspect(
    @shrink.Shrink::shrink(100).collect(),
    content=(
      #|[99, 97, 94, 88, 75, 50, 0]
    ),
  )
  debug_inspect(
    @shrink.Shrink::shrink(0).collect(),
    content=(
      #|[]
    ),
  )
}

///|
test "shrink int64" {
  debug_inspect(
    @shrink.Shrink::shrink(10000L).collect(),
    content=(
      #|[
      #|  9999,
      #|  9998,
      #|  9996,
      #|  9991,
      #|  9981,
      #|  9961,
      #|  9922,
      #|  9844,
      #|  9688,
      #|  9375,
      #|  8750,
      #|  7500,
      #|  5000,
      #|  0,
      #|]
    ),
  )
}

///|
test "shrink uint" {
  debug_inspect(
    @shrink.Shrink::shrink(37000U).collect(),
    content=(
      #|[
      #|  36999,
      #|  36998,
      #|  36996,
      #|  36991,
      #|  36982,
      #|  36964,
      #|  36928,
      #|  36856,
      #|  36711,
      #|  36422,
      #|  35844,
      #|  34688,
      #|  32375,
      #|  27750,
      #|  18500,
      #|  0,
      #|]
    ),
  )
}

///|
test "shrink uint64" {
  debug_inspect(
    @shrink.Shrink::shrink((42000 : UInt64)).collect(),
    content=(
      #|[
      #|  41999,
      #|  41998,
      #|  41995,
      #|  41990,
      #|  41980,
      #|  41959,
      #|  41918,
      #|  41836,
      #|  41672,
      #|  41344,
      #|  40688,
      #|  39375,
      #|  36750,
      #|  31500,
      #|  21000,
      #|  0,
      #|]
    ),
  )
}

///|
test "shrink byte" {
  let s = @shrink.Shrink::shrink(Int::to_byte(200)).collect()
  debug_inspect(
    s,
    content=(
      #|[0xc7, 0xc5, 0xc2, 0xbc, 0xaf, 0x96, 0x64, 0x00]
    ),
  )
  debug_inspect(
    @shrink.Shrink::shrink(Int::to_byte(0)).collect(),
    content=(
      #|[]
    ),
  )
}

///|
test "shrink boolean" {
  debug_inspect(
    @shrink.Shrink::shrink(true).collect(),
    content=(
      #|[false]
    ),
  )
  debug_inspect(
    @shrink.Shrink::shrink(false).collect(),
    content=(
      #|[]
    ),
  )
}

///|
test "shrink char" {
  debug_inspect(
    @shrink.Shrink::shrink('测').collect(),
    content=(
      #|['浊', '浌', 'a', 'A', '1', '\n', '\t', '\b', '\\', '\'', '\r', ' ']
    ),
  )
}

///|
test "shrink double: pi" {
  let s = @shrink.Shrink::shrink(3.14159).collect()
  assert_true(s.contains(3.0))
  assert_true(s.contains(0.0))
  assert_true(s.all(y => y < 3.14159))
}

///|
test "shrink double: exact output for 3.5" {
  debug_inspect(
    @shrink.Shrink::shrink(3.5).collect(),
    content=(
      #|[3, 2, 0, 3.4, 3.3, 3.1, 2.7, 1.8, 0]
    ),
  )
}

///|
test "shrink double: zero" {
  debug_inspect(
    @shrink.Shrink::shrink(0.0).collect(),
    content=(
      #|[]
    ),
  )
}

///|
test "shrink double: negative" {
  debug_inspect(
    @shrink.Shrink::shrink(-5.5).collect(),
    content=(
      #|[5.5, -5, -3, 0, -5.4, -5.2, -4.9, -4.2, -2.8, 0]
    ),
  )
}

///|
test "shrink double: nan" {
  debug_inspect(
    @shrink.Shrink::shrink(0.0 / 0.0).collect(),
    content=(
      #|[0, 1, -1, 2]
    ),
  )
}

///|
test "shrink double: infinity" {
  debug_inspect(
    @shrink.Shrink::shrink(1.0 / 0.0).collect(),
    content=(
      #|[0, 1, -1, 1000, -1000]
    ),
  )
}

///|
test "shrink double: small value" {
  debug_inspect(
    @shrink.Shrink::shrink(0.001).collect(),
    content=(
      #|[0, 0]
    ),
  )
}

///|
test "shrink float: basic" {
  let s = @shrink.Shrink::shrink((3.14 : Float)).collect()
  assert_true(s.contains(3.0))
  assert_true(s.contains(0.0))
}

///|
test "shrink option" {
  debug_inspect(
    @shrink.Shrink::shrink((None : Unit?)).collect(),
    content=(
      #|[]
    ),
  )
  debug_inspect(
    @shrink.Shrink::shrink(Some(1000)).collect(),
    content=(
      #|[
      #|  Some(999),
      #|  Some(997),
      #|  Some(993),
      #|  Some(985),
      #|  Some(969),
      #|  Some(938),
      #|  Some(875),
      #|  Some(750),
      #|  Some(500),
      #|  Some(0),
      #|  None,
      #|]
    ),
  )
}

///|
test "shrink result" {
  let b : Result[Bool, Int] = Err(100)
  let x : Result[Bool, Int] = Ok(true)
  debug_inspect(
    @shrink.Shrink::shrink(b).collect(),
    content=(
      #|[Err(99), Err(97), Err(94), Err(88), Err(75), Err(50), Err(0)]
    ),
  )
  debug_inspect(
    @shrink.Shrink::shrink(x).collect(),
    content=(
      #|[Ok(false)]
    ),
  )
}

///|
test "shrink tuple" {
  let x = (120, true)
  debug_inspect(
    @shrink.Shrink::shrink(x).collect(),
    content=(
      #|[
      #|  (119, true),
      #|  (117, true),
      #|  (113, true),
      #|  (105, true),
      #|  (90, true),
      #|  (60, true),
      #|  (0, true),
      #|  (120, false),
      #|]
    ),
  )
}

///|
test "shrink 6-tuple" {
  let x = (20, 'A', 30U, true, true, true)
  debug_inspect(
    @shrink.Shrink::shrink(x).collect(),
    content=(
      #|[
      #|  (19, 'A', 30, true, true, true),
      #|  (18, 'A', 30, true, true, true),
      #|  (15, 'A', 30, true, true, true),
      #|  (10, 'A', 30, true, true, true),
      #|  (0, 'A', 30, true, true, true),
      #|  (20, '@', 30, true, true, true),
      #|  (20, 'B', 30, true, true, true),
      #|  (20, 'a', 30, true, true, true),
      #|  (20, 'A', 30, true, true, true),
      #|  (20, '1', 30, true, true, true),
      #|  (20, '\n', 30, true, true, true),
      #|  (20, '\t', 30, true, true, true),
      #|  (20, '\b', 30, true, true, true),
      #|  (20, '\\', 30, true, true, true),
      #|  (20, '\'', 30, true, true, true),
      #|  (20, '\r', 30, true, true, true),
      #|  (20, ' ', 30, true, true, true),
      #|  (20, 'A', 29, true, true, true),
      #|  (20, 'A', 27, true, true, true),
      #|  (20, 'A', 23, true, true, true),
      #|  (20, 'A', 15, true, true, true),
      #|  (20, 'A', 0, true, true, true),
      #|  (20, 'A', 30, false, true, true),
      #|  (20, 'A', 30, true, false, true),
      #|  (20, 'A', 30, true, true, false),
      #|]
    ),
  )
}

///|
test "shrink int list" {
  let il : @list.List[Int] = List([1, 2, 3, 4, 5, 6])
  debug_inspect(
    @shrink.Shrink::shrink(il).collect(),
    content=(
      #|[
      #|  <List: [2, 3, 4, 5, 6]>,
      #|  <List: [1, 3, 4, 5, 6]>,
      #|  <List: [1, 2, 4, 5, 6]>,
      #|  <List: [1, 2, 3, 5, 6]>,
      #|  <List: [1, 2, 3, 4, 6]>,
      #|  <List: [4, 5, 6]>,
      #|  <List: [0, 2, 3, 4, 5, 6]>,
      #|  <List: [1, 1, 3, 4, 5, 6]>,
      #|  <List: [1, 0, 3, 4, 5, 6]>,
      #|  <List: [1, 2, 2, 4, 5, 6]>,
      #|  <List: [1, 2, 0, 4, 5, 6]>,
      #|  <List: [1, 2, 3, 3, 5, 6]>,
      #|  <List: [1, 2, 3, 2, 5, 6]>,
      #|  <List: [1, 2, 3, 0, 5, 6]>,
      #|  <List: [1, 2, 3, 4, 4, 6]>,
      #|  <List: [1, 2, 3, 4, 3, 6]>,
      #|  <List: [1, 2, 3, 4, 0, 6]>,
      #|  <List: [1, 2, 3, 4, 5, 5]>,
      #|  <List: [1, 2, 3, 4, 5, 3]>,
      #|  <List: [1, 2, 3, 4, 5, 0]>,
      #|]
    ),
  )
}

///|
test "shrink array" {
  let ar = [1, 2, 3, 4, 5, 6]
  debug_inspect(
    @shrink.Shrink::shrink(ar).collect(),
    content=(
      #|[
      #|  [2, 3, 4, 5, 6],
      #|  [1, 3, 4, 5, 6],
      #|  [1, 2, 4, 5, 6],
      #|  [1, 2, 3, 5, 6],
      #|  [1, 2, 3, 4, 6],
      #|  [4, 5, 6],
      #|  [0, 2, 3, 4, 5, 6],
      #|  [1, 1, 3, 4, 5, 6],
      #|  [1, 0, 3, 4, 5, 6],
      #|  [1, 2, 2, 4, 5, 6],
      #|  [1, 2, 0, 4, 5, 6],
      #|  [1, 2, 3, 3, 5, 6],
      #|  [1, 2, 3, 2, 5, 6],
      #|  [1, 2, 3, 0, 5, 6],
      #|  [1, 2, 3, 4, 4, 6],
      #|  [1, 2, 3, 4, 3, 6],
      #|  [1, 2, 3, 4, 0, 6],
      #|  [1, 2, 3, 4, 5, 5],
      #|  [1, 2, 3, 4, 5, 3],
      #|  [1, 2, 3, 4, 5, 0],
      #|]
    ),
  )
}

///|
test "shrink iter" {
  let it = [|1, 2, 3, 4, 5, 6|]
  debug_inspect(
    @shrink.Shrink::shrink(it).map(candidate => candidate.collect()).collect(),
    content=(
      #|[
      #|  [2, 3, 4, 5, 6],
      #|  [1, 3, 4, 5, 6],
      #|  [1, 2, 4, 5, 6],
      #|  [1, 2, 3, 5, 6],
      #|  [1, 2, 3, 4, 6],
      #|  [1, 2, 3, 4, 5],
      #|  [0, 2, 3, 4, 5, 6],
      #|  [1, 1, 3, 4, 5, 6],
      #|  [1, 0, 3, 4, 5, 6],
      #|  [1, 2, 2, 4, 5, 6],
      #|  [1, 2, 0, 4, 5, 6],
      #|  [1, 2, 3, 3, 5, 6],
      #|  [1, 2, 3, 2, 5, 6],
      #|  [1, 2, 3, 0, 5, 6],
      #|  [1, 2, 3, 4, 4, 6],
      #|  [1, 2, 3, 4, 3, 6],
      #|  [1, 2, 3, 4, 0, 6],
      #|  [1, 2, 3, 4, 5, 5],
      #|  [1, 2, 3, 4, 5, 3],
      #|  [1, 2, 3, 4, 5, 0],
      #|]
    ),
  )
}
