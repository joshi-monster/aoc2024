import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/order
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub fn parse(input: String) {
  let assert Ok(#(orderings, manuals)) = string.split_once(input, on: "\n\n")
  let orderings = {
    use dict, line <- list.fold(string.split(orderings, on: "\n"), dict.new())
    let result = {
      use #(a, b) <- result.try(string.split_once(line, on: "|"))
      use a <- result.try(int.parse(a))
      use b <- result.map(int.parse(b))
      use existing <- dict.upsert(dict, a)
      let existing = option.unwrap(existing, set.new())
      set.insert(existing, b)
    }
    result.unwrap(result, dict)
  }

  let manuals = {
    use line <- list.map(string.split(manuals, on: "\n"))
    use col <- list.filter_map(string.split(line, on: ","))
    int.parse(col)
  }

  #(orderings, manuals)
}

pub fn pt_1(input: #(Dict(Int, Set(Int)), List(List(Int)))) {
  let #(orderings, manuals) = input
  manuals
  |> list.filter(fn(manual) { is_valid(orderings, manual, set.new()) })
  |> list.map(fn(manual) { find_middle(manual, manual) })
  |> int.sum
}

fn find_middle(fast: List(Int), slow: List(Int)) {
  case fast, slow {
    _, [] -> 0
    [_, _, ..fast], [_, ..slow] -> find_middle(fast, slow)
    [_], [middle, ..] | [], [middle, ..] -> middle
  }
}

fn is_valid(orderings: Dict(Int, Set(Int)), manual: List(Int), seen: Set(Int)) {
  case manual {
    [] -> True
    [page, ..manual] -> {
      case
        orderings
        |> dict.get(page)
        |> result.unwrap(set.new())
        |> set.intersection(seen)
        |> set.is_empty
      {
        True -> is_valid(orderings, manual, set.insert(seen, page))
        False -> False
      }
    }
  }
}

pub fn pt_2(input: #(Dict(Int, Set(Int)), List(List(Int)))) {
  let #(orderings, manuals) = input
  manuals
  |> list.filter(fn(manual) { !is_valid(orderings, manual, set.new()) })
  |> list.map(list.sort(_, fn(a, b) {
    case
      orderings |> dict.get(a) |> result.unwrap(set.new()) |> set.contains(b),
      orderings |> dict.get(b) |> result.unwrap(set.new()) |> set.contains(a)
    {
      False, False | True, True -> order.Eq
      True, False -> order.Lt
      False, True -> order.Gt
    }
  }))
  |> list.map(fn(manual) { find_middle(manual, manual) })
  |> int.sum
}
