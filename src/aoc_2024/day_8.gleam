import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/set.{type Set}
import gleam/string

pub type Map {
  Map(antennas: Dict(String, List(#(Int, Int))), width: Int, height: Int)
}

pub fn parse(input: String) {
  let map = Map(dict.new(), 0, 0)
  use map, line, y <- list.index_fold(string.split(input, on: "\n"), map)
  use map, char, x <- list.index_fold(string.to_graphemes(line), map)
  Map(
    antennas: case char != "." {
      True -> {
        use existing <- dict.upsert(map.antennas, char)
        [#(x, y), ..option.unwrap(existing, [])]
      }
      False -> map.antennas
    },
    width: int.max(map.width, x + 1),
    height: int.max(map.height, y + 1),
  )
}

pub fn pt_1(map: Map) {
  set.size({
    use antinodes, _freq, locs <- dict.fold(map.antennas, set.new())
    use antinodes, pair <- list.fold(list.combination_pairs(locs), antinodes)
    let #(#(x1, y1), #(x2, y2)) = pair

    let dx = x2 - x1
    let dy = y2 - y1

    antinodes
    |> insert_bounded(map, x1 - dx, y1 - dy)
    |> insert_bounded(map, x2 + dx, y2 + dy)
  })
}

fn insert_bounded(antinodes: Set(#(Int, Int)), map: Map, x: Int, y: Int) {
  case is_in_bounds(map, x, y) {
    True -> set.insert(antinodes, #(x, y))
    False -> antinodes
  }
}

fn is_in_bounds(map: Map, x: Int, y: Int) {
  0 <= x && x < map.width && 0 <= y && y < map.height
}

pub fn pt_2(map: Map) {
  set.size({
    use antinodes, _freq, locs <- dict.fold(map.antennas, set.new())
    use antinodes, pair <- list.fold(list.combination_pairs(locs), antinodes)
    let #(#(x1, y1), #(x2, y2)) = pair

    let dx = x2 - x1
    let dy = y2 - y1

    walk_antinodes(antinodes, map, dx, dy, x1, y1, x2, y2)
  })
}

fn walk_antinodes(antinodes, map, dx, dy, x1, y1, x2, y2) {
  case !is_in_bounds(map, x1, y1) && !is_in_bounds(map, x2, y2) {
    True -> antinodes
    False -> {
      antinodes
      |> insert_bounded(map, x1, y1)
      |> insert_bounded(map, x2, y2)
      |> walk_antinodes(map, dx, dy, x1 - dx, y1 - dy, x2 + dx, y2 + dy)
    }
  }
}

// -- DEBUG --------------------------------------------------------------------

fn print_locations(map: Map, antinodes: Set(#(Int, Int))) {
  use y <- list.each(list.range(0, map.height - 1))
  io.println(
    string.concat({
      use x <- list.map(list.range(0, map.width - 1))
      case set.contains(antinodes, #(x, y)) {
        True -> "#"
        False -> "."
      }
    }),
  )
}

import gleam/io
