pub fn to_string(self : Rational) -> String {
  if self.den == 0 {
    if self.num < 0 {
      "-∞"
    } else {
      "∞"
    }
  } else if self.den == 1 {
    self.num.to_string()
  } else {
    self.num.to_string() + "/" + self.den.to_string()
  }
}

pub fn debug_write(self : Rational, buf : Buffer) -> Unit {
  buf.write_string(to_string(self))
}

pub fn op_equal(self : Rational, r2 : Rational) -> Bool {
  self.num * r2.den == r2.num * self.den
}

pub fn compare(self : Rational, r2 : Rational) -> Int {
  self.num * r2.den - r2.num * self.den
}

pub fn op_add(self : Rational, r2 : Rational) -> Rational {
  reduce({ num: self.num * r2.den + r2.num * self.den, den: self.den * r2.den })
}

pub fn op_sub(self : Rational, r2 : Rational) -> Rational {
  reduce({ num: self.num * r2.den - r2.num * self.den, den: self.den * r2.den })
}

pub fn op_mul(self : Rational, r2 : Rational) -> Rational {
  reduce({ num: self.num * r2.num, den: self.den * r2.den })
}

pub fn negate(self : Rational) -> Rational {
  { num: -self.num, den: self.den }
}

pub fn abs(self : Rational) -> Rational {
  { num: self.num.abs(), den: self.den.abs() }
}

pub fn signum(self : Rational) -> Rational {
  { num: self.num.signum(), den: 1 }
}

pub fn from_int(n : Int) -> Rational {
  { num: n, den: 1 }
}

pub fn op_div(self : Rational, r2 : Rational) -> Rational {
  match (self, r2) {
    ({ num: x, den: 0 }, { num: y, den: 0 }) =>
      { num: x.signum() * y.signum(), den: 0 }
    (_, { num: _, den: 0 }) => { num: 0, den: 1 }
    ({ num: x, den: 0 }, _) => { num: x, den: 0 }
    ({ num: x, den: y }, { num: u, den: v }) =>
      reduce({ num: x * v, den: y * u })
  }
}

pub fn reciprocal(self : Rational) -> Rational {
  if self.num < 0 {
    { num: -self.den, den: -self.num }
  } else {
    { num: self.den, den: self.num }
  }
}

pub fn num(r : Rational) -> Int {
  r.num
}

pub fn den(r : Rational) -> Int {
  r.den
}

fn gcd(x : Int, y : Int) -> Int {
  if x == 0 {
    y
  } else {
    gcd(y % x, x)
  }
}

pub fn reduce(r : Rational) -> Rational {
  match r {
    { num: x, den: 0 } => { num: if x < 0 { -1 } else { 1 }, den: 0 }
    { num: x, den: y } => {
      let (u, v) = if y < 0 { (-x, -y) } else { (x, y) }
      let g = gcd(u, v)
      { num: u / g, den: v / g }
    }
  }
}

test "reduce" {
  @assertion.assert_eq(reduce({ num: 0, den: 0 }), { num: 1, den: 0 })?
  @assertion.assert_eq(reduce({ num: 0, den: 1 }), { num: 0, den: 1 })?
  @assertion.assert_eq(reduce({ num: 16, den: 0 }), { num: 1, den: 0 })?
  @assertion.assert_eq(reduce({ num: 16, den: 8 }), { num: 2, den: 1 })?
}

pub fn approx(self : Rational, epsilon : Rational) -> Rational {
  fn simplest(a : Rational, b : Rational) -> Rational {
    if a < b {
      simplest(b, a)
    } else if a == b {
      a
    } else if a > from_int(0) {
      simplest2(a.num, a.den, b.num, b.den)
    } else if b < from_int(0) {
      negate(simplest2(-a.num, a.den, -b.num, b.den))
    } else {
      return from_int(0)
    }
  }

  fn simplest2(n, d, n2, d2) -> Rational {
    let (q, r) = (n / d, n % d)
    let (q2, r2) = (n2 / d2, n2 % d2)
    let { num: n3, den: d3 } = simplest2(d2, r2, d, r)
    if r == 0 {
      { num: q, den: 1 }
    } else if q != q2 {
      { num: q + 1, den: 1 }
    } else {
      { num: q * n3 + d3, den: n3 }
    }
  }

  simplest(self - epsilon, self + epsilon)
}

pub fn approx_cf(self : Rational, cf : List[(Rational, Rational)]) -> Rational {
  match (self, cf) {
    (_, Nil) => { num: 0, den: 1 }
    (eps, x) => {
      let h = x.head().0
      if h.den == 0 {
        h
      } else {
        let (q1, p1) = x.head()
        fn approx_cf_helper(
          ept : Rational,
          y : List[(Rational, Rational)],
          v2 : Rational,
          v1 : Rational,
          u2 : Rational,
          u1 : Rational,
          a1 : Rational,
          n : Int
        ) {
          let (b, a) = y.nth(n)
          let u = b * u1 + a1 * u2
          let v = b * v1 + a1 * v2
          let f = u / v
          let f1 : Rational = u1 / v1
          if (from_int(1) - f1 / f).abs() < ept || a == from_int(0) {
            approx(ept, f)
          } else {
            approx_cf_helper(ept, y, v1, v, u1, u, a, n + 1)
          }
        }

        approx_cf_helper(
          eps,
          x,
          from_int(0),
          from_int(1),
          from_int(1),
          q1,
          p1,
          1,
        )
      }
    }
  }
}

pub fn factorial(n : Int) -> Int {
  if n < 0 {
    0
  } else if n == 0 {
    1
  } else {
    n * factorial(n - 1)
  }
}

pub fn integer_root(i : Int) -> Int {
  fn ir(lo, hi, r, y) {
    let c = r * r
    if c == y {
      r
    } else if c < y {
      ir(lo, r, (r + lo) / 2, y)
    } else if (r + 1) * (r + 1) > y {
      r
    } else {
      ir(r, hi, (r + hi) / 2, y)
    }
  }

  match i {
    1 => 1
    x => ir(0, x, x / 2, x)
  }
}