import gleam/int
import gleam/list
import gleam/string

pub fn parse(input) {
  use line <- list.filter_map(string.split(input, on: "\n"))
  let levels = line |> string.split(" ") |> list.filter_map(int.parse)

  case levels {
    [] -> Error(Nil)
    _ -> Ok(levels)
  }
}

fn is_safe(report) {
  let check = fn(windowed, to_delta) {
    use #(fst, snd) <- list.all(windowed)
    let delta = to_delta(fst, snd)
    delta >= 1 && delta <= 3
  }
  case list.window_by_2(report) {
    [#(fst, snd), ..] as windowed if fst < snd ->
      check(windowed, fn(a, b) { b - a })

    [#(fst, snd), ..] as windowed if fst > snd ->
      check(windowed, fn(a, b) { a - b })

    _ -> False
  }
}

pub fn pt_1(input) {
  use report <- list.count(input)
  is_safe(report)
}

pub fn pt_2(input) {
  use report <- list.count(input)
  use dampened <- list.any(list.combinations(report, list.length(report) - 1))
  is_safe(dampened)
}
