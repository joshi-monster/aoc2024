import gleam/list
import gleam/result
import gleam/string

pub fn pt_1(input: String) {
  use acc, #(x, y) <- list.fold(parse1(input, []), 0)
  acc + x * y
}

fn parse1(input, acc) {
  case parse_mul(input) {
    Ok(#(x, y, input)) -> parse1(input, [#(x, y), ..acc])
    Error(Nil) ->
      case string.pop_grapheme(input) {
        Ok(#(_, input)) -> parse1(input, acc)
        Error(_) -> list.reverse(acc)
      }
  }
}

fn parse_mul(input) {
  use input <- result.try(parse_literal(input, "mul("))
  use #(x, input) <- result.try(parse_number(input))
  use input <- result.try(parse_literal(input, ","))
  use #(y, input) <- result.try(parse_number(input))
  use input <- result.try(parse_literal(input, ")"))
  Ok(#(x, y, input))
}

fn parse_literal(input, literal) {
  case string.starts_with(input, literal) {
    True -> Ok(string.drop_start(input, string.length(literal)))
    False -> Error(Nil)
  }
}

fn parse_number(input) {
  do_parse_number(input, 0, 0)
}

fn do_parse_number(input, number, digits) {
  case digits, parse_digit(input) {
    0, Ok(#(0, _)) -> Error(Nil)
    0, Error(Nil) -> Error(Nil)
    _, Ok(#(digit, input)) ->
      do_parse_number(input, digit + 10 * number, digits + 1)
    _, Error(Nil) -> Ok(#(number, input))
  }
}

fn parse_digit(input) {
  case input {
    "0" <> input -> Ok(#(0, input))
    "1" <> input -> Ok(#(1, input))
    "2" <> input -> Ok(#(2, input))
    "3" <> input -> Ok(#(3, input))
    "4" <> input -> Ok(#(4, input))
    "5" <> input -> Ok(#(5, input))
    "6" <> input -> Ok(#(6, input))
    "7" <> input -> Ok(#(7, input))
    "8" <> input -> Ok(#(8, input))
    "9" <> input -> Ok(#(9, input))
    _ -> Error(Nil)
  }
}

pub fn pt_2(input: String) {
  use #(acc, do), inst <- list.fold(parse2(input, []), #(0, True))
  case do, inst {
    _, Do -> #(acc, True)
    _, Dont -> #(acc, False)
    True, Mul(x, y) -> #(acc + x * y, True)
    False, Mul(..) -> #(acc, False)
  }
}

type Inst {
  Mul(Int, Int)
  Do
  Dont
}

fn parse2(input, acc) {
  case input {
    "do()" <> input -> parse2(input, [Do, ..acc])
    "don't()" <> input -> parse2(input, [Dont, ..acc])
    _ ->
      case parse_mul(input) {
        Ok(#(x, y, input)) -> parse2(input, [Mul(x, y), ..acc])
        Error(Nil) ->
          case string.pop_grapheme(input) {
            Ok(#(_, input)) -> parse2(input, acc)
            Error(Nil) -> list.reverse(acc)
          }
      }
  }
}
