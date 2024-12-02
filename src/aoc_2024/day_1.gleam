import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) {
  let input = {
    use line <- list.filter_map(string.split(input, on: "\n"))
    case line |> string.split(" ") |> list.filter_map(int.parse) {
      [] -> Error(Nil)
      row -> Ok(row)
    }
  }

  input
  |> list.filter_map(fn(pair) {
    case pair {
      [a, b] -> Ok(#(a, b))
      _ -> Error(Nil)
    }
  })
  |> list.unzip
}

pub fn pt_1(input) {
  let #(first, second) = input
  int.sum({
    use a, b <- list.map2(
      list.sort(first, int.compare),
      list.sort(second, int.compare),
    )

    int.absolute_value(a - b)
  })
}

pub fn pt_2(input) {
  let #(first, second) = input
  int.sum({
    use a <- list.map(first)
    a * list.count(second, fn(b) { a == b })
  })
}
