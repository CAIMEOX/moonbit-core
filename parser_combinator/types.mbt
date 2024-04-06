struct Parser[I, O] {
  runParser : (I) -> Result[(I, O), List[String]]
}

