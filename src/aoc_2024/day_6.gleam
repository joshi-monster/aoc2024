import gleam/bool
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Pos =
  #(Int, Int)

pub type Floor {
  Floor(start: Pos, obstacles: Set(Pos), width: Int, height: Int)
}

pub type Dir {
  N
  W
  S
  E
}

pub fn parse(input: String) {
  let floor = Floor(#(0, 0), set.new(), 0, 0)
  use floor, line, row <- list.index_fold(string.split(input, "\n"), floor)
  use floor, char, col <- list.index_fold(string.to_graphemes(line), floor)
  let floor =
    Floor(
      ..floor,
      width: int.max(floor.width, col),
      height: int.max(floor.height, row),
    )
  let pos = #(col, row)
  case char {
    "^" -> Floor(..floor, start: pos)
    "#" -> Floor(..floor, obstacles: set.insert(floor.obstacles, pos))
    _ -> floor
  }
}

pub fn pt_1(floor: Floor) {
  walk(floor, floor.start, N, set.new())
  |> set.size
}

fn walk(floor: Floor, pos: Pos, dir: Dir, visited: Set(Pos)) {
  let #(pos2, dir2) = step(pos, dir)
  case set.contains(floor.obstacles, pos2) {
    True -> walk(floor, pos, dir2, visited)
    False ->
      case is_in_bounds(floor, pos2) {
        True -> walk(floor, pos2, dir, set.insert(visited, pos))
        False -> set.insert(visited, pos)
      }
  }
}

fn step(pos: Pos, dir) {
  case dir {
    N -> #(#(pos.0, pos.1 - 1), E)
    W -> #(#(pos.0 - 1, pos.1), N)
    S -> #(#(pos.0, pos.1 + 1), W)
    E -> #(#(pos.0 + 1, pos.1), S)
  }
}

fn is_in_bounds(floor: Floor, pos: Pos) {
  0 <= pos.0 && pos.0 < floor.width && 0 <= pos.1 && pos.1 < floor.height
}

pub fn pt_2(floor: Floor) {
  let candidates = walk(floor, floor.start, N, set.new())
  use count, pos <- set.fold(candidates, 0)
  // io.debug(pos)
  use <- bool.guard(when: pos == floor.start, return: count)
  let floor = Floor(..floor, obstacles: set.insert(floor.obstacles, pos))
  case is_loop(floor, floor.start, N, set.new()) {
    True -> count + 1
    False -> count
  }
}

fn is_loop(floor: Floor, pos: Pos, dir: Dir, visited: Set(#(Pos, Dir))) {
  case set.contains(visited, #(pos, dir)) {
    True -> True
    False -> {
      let visited = set.insert(visited, #(pos, dir))
      let #(pos2, dir2) = step(pos, dir)
      case set.contains(floor.obstacles, pos2) {
        True -> is_loop(floor, pos, dir2, visited)
        False ->
          case is_in_bounds(floor, pos2) {
            True -> is_loop(floor, pos2, dir, visited)
            False -> False
          }
      }
    }
  }
}
