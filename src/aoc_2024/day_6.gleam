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
  walk(floor, floor.start.0, floor.start.1, N, set.new())
  |> set.size
}

fn walk(floor: Floor, x: Int, y: Int, dir: Dir, visited: Set(Pos)) {
  let #(x2, y2, d2) = step(x, y, dir)
  case set.contains(floor.obstacles, #(x2, y2)) {
    True -> walk(floor, x, y, d2, visited)
    False ->
      case x2 > floor.width || y2 > floor.height || x2 < 0 || y2 < 0 {
        False -> walk(floor, x2, y2, dir, set.insert(visited, #(x, y)))
        True -> set.insert(visited, #(x, y))
      }
  }
}

fn step(x, y, dir) {
  case dir {
    N -> #(x, y - 1, E)
    W -> #(x - 1, y, N)
    S -> #(x, y + 1, W)
    E -> #(x + 1, y, S)
  }
}

pub fn pt_2(floor: Floor) {
  use count, x <- list.fold(list.range(0, floor.width - 1), 0)
  use count, y <- list.fold(list.range(0, floor.height - 1), count)
  use <- bool.guard(when: #(x, y) == floor.start, return: count)
  let floor = Floor(..floor, obstacles: set.insert(floor.obstacles, #(x, y)))
  case is_loop(floor, floor.start.0, floor.start.1, N, set.new()) {
    True -> count + 1
    False -> count
  }
}

fn is_loop(floor: Floor, x: Int, y: Int, dir: Dir, visited: Set(#(Pos, Dir))) {
  use <- bool.guard(set.contains(visited, #(#(x, y), dir)), return: True)
  let visited = set.insert(visited, #(#(x, y), dir))
  let #(x2, y2, d2) = step(x, y, dir)
  case set.contains(floor.obstacles, #(x2, y2)) {
    True -> is_loop(floor, x, y, d2, visited)
    False ->
      case x2 > floor.width || y2 > floor.height || x2 < 0 || y2 < 0 {
        False -> is_loop(floor, x2, y2, dir, visited)
        True -> False
      }
  }
}
