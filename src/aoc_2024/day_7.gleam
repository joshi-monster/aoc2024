import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) {
  use line <- list.filter_map(string.split(input, on: "\n"))
  use #(result, numbers) <- result.try(string.split_once(line, on: ": "))
  use result <- result.try(int.parse(result))
  use numbers <- result.try(
    numbers |> string.split(" ") |> list.try_map(int.parse),
  )
  Ok(#(result, list.reverse(numbers)))
}

pub fn pt_1(input: List(#(Int, List(Int)))) {
  sum(input, is_solvable1)
}

fn is_solvable1(result: Int, numbers) {
  case numbers {
    [] -> result == 0
    [first, ..numbers] -> {
      let fraction = result / first
      { result >= first && is_solvable1(result - first, numbers) }
      || { fraction * first == result && is_solvable1(fraction, numbers) }
    }
  }
}

fn sum(input, is_solvable) {
  use sum, #(result, numbers) <- list.fold(input, 0)
  case is_solvable(result, numbers) {
    True -> sum + result
    False -> sum
  }
}

pub fn pt_2(input: List(#(Int, List(Int)))) {
  sum(input, is_solvable2)
}

fn is_solvable2(result: Int, numbers) {
  case numbers {
    [] -> result == 0
    [first, ..numbers] if result >= first -> {
      { result >= first && is_solvable2(result - first, numbers) }
      || {
        let fraction = result / first
        fraction * first == result && is_solvable2(fraction, numbers)
      }
      || {
        let pow10 = to_pow10(first)
        let next = { result - first } / pow10
        next * pow10 + first == result && is_solvable2(next, numbers)
      }
    }
    _ -> False
  }
}

fn to_pow10(number) {
  case number >= 10 {
    True -> 10 * to_pow10(number / 10)
    False -> 10
  }
}
