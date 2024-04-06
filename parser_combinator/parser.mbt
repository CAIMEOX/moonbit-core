pub fn fmap[I, X, Y](self : Parser[I, X], f : (X) -> Y) -> Parser[I, Y] {
  {
    runParser: fn(input) {
      match (self.runParser)(input) {
        Err(err) => Err(err)
        Ok((rest, value)) => Ok((rest, f(value)))
      }
    },
  }
}

pub fn pure[I, X](value : X) -> Parser[I, X] {
  {
    runParser: fn(input) { Ok((input, value)) },
  }
}

pub fn apply[I, X, Y](
  self : Parser[I, (X) -> Y],
  other : Parser[I, X]
) -> Parser[I, Y] {
  {
    runParser: fn(input) {
      match (self.runParser)(input) {
        Err(err) => Err(err)
        Ok((rest, f)) => (other.fmap(f).runParser)(rest)
      }
    },
  }
}

pub fn empty[I, X]() -> Parser[I, X] {
  { runParser: fn(_i) { Err(Nil) } }
}

pub fn or_else[I, X](self : Parser[I, X], other : Parser[I, X]) -> Parser[I, X] {
  {
    runParser: fn(input) {
      match (self.runParser)(input) {
        Ok(ok) => Ok(ok)
        _ => (other.runParser)(input)
      }
    },
  }
}

pub fn bind[I, X, Y](
  self : Parser[I, X],
  f : (X) -> Parser[I, Y]
) -> Parser[I, Y] {
  {
    runParser: fn(input) {
      match (self.runParser)(input) {
        Err(err) => Err(err)
        Ok((rest, value)) => (f(value).runParser)(rest)
      }
    },
  }
}