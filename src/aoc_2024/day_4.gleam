import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/string

pub fn parse(input: String) {
  use dict, line, row <- list.index_fold(string.split(input, "\n"), dict.new())
  use dict, chr, col <- list.index_fold(string.to_graphemes(line), dict)
  case chr {
    "X" | "M" | "A" | "S" -> dict.insert(dict, #(row, col), chr)
    _ -> dict
  }
}

const directions = [
  #(1, 0), #(-1, 0), #(0, 1), #(0, -1), #(1, 1), #(-1, 1), #(1, -1), #(-1, -1),
]

pub fn pt_1(input: Dict(#(Int, Int), String)) {
  use count, #(row, col), chr <- dict.fold(input, 0)
  use <- bool.guard(when: chr != "X", return: count)
  use count, #(dy, dx) <- list.fold(directions, count)
  case
    dict.get(input, #(row + 1 * dy, col + 1 * dx)),
    dict.get(input, #(row + 2 * dy, col + 2 * dx)),
    dict.get(input, #(row + 3 * dy, col + 3 * dx))
  {
    Ok("M"), Ok("A"), Ok("S") -> count + 1
    _, _, _ -> count
  }
}

pub fn pt_2(input: Dict(#(Int, Int), String)) {
  use count, #(row, col), chr <- dict.fold(input, 0)
  use <- bool.guard(when: chr != "A", return: count)
  case
    dict.get(input, #(row + 1, col + 1)),
    dict.get(input, #(row - 1, col + 1)),
    dict.get(input, #(row - 1, col - 1)),
    dict.get(input, #(row + 1, col - 1))
  {
    Ok("M"), Ok("M"), Ok("S"), Ok("S")
    | Ok("S"), Ok("S"), Ok("M"), Ok("M")
    | Ok("M"), Ok("S"), Ok("S"), Ok("M")
    | Ok("S"), Ok("M"), Ok("M"), Ok("S")
    -> count + 1
    _, _, _, _ -> count
  }
}
