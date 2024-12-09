import gleam/int
import gleam/list
import gleam/string

pub type Disk {
  Disk(chunks: List(Chunk), max_file_id: Int, size: Int)
}

pub type Chunk {
  File(offset: Int, size: Int, file_id: Int)
  Free(offset: Int, size: Int)
}

pub fn parse(input: String) {
  // let input = "2333133121414131402"
  let disk = Disk(chunks: [], max_file_id: -1, size: 0)
  input
  |> string.trim
  |> string.to_graphemes
  |> parse_loop(0, disk)
}

fn parse_loop(input, file_id, disk: Disk) {
  case input {
    [file_blocks, free_blocks, ..input] -> {
      let assert Ok(file_blocks) = int.parse(file_blocks)
      let assert Ok(free_blocks) = int.parse(free_blocks)
      let disk =
        Disk(
          chunks: [
            Free(offset: disk.size + file_blocks, size: free_blocks),
            File(offset: disk.size, size: file_blocks, file_id:),
            ..disk.chunks
          ],
          max_file_id: int.max(file_id, disk.max_file_id),
          size: disk.size + free_blocks + file_blocks,
        )
      parse_loop(input, file_id + 1, disk)
    }

    [file_blocks, ..input] -> {
      let assert Ok(file_blocks) = int.parse(file_blocks)
      let disk =
        Disk(
          chunks: [
            File(offset: disk.size, size: file_blocks, file_id:),
            ..disk.chunks
          ],
          max_file_id: int.max(file_id, disk.max_file_id),
          size: disk.size + file_blocks,
        )
      parse_loop(input, file_id + 1, disk)
    }

    [] -> Disk(..disk, chunks: list.reverse(disk.chunks))
  }
}

pub fn pt_1(disk: Disk) {
  let defragmented =
    defragment_blocks(disk.chunks, list.reverse(disk.chunks), [])
  checksum(defragmented)
}

fn checksum(chunks: List(Chunk)) {
  use checksum, chunk <- list.fold(chunks, 0)
  case chunk {
    Free(..) -> checksum
    File(offset:, size:, file_id:) -> {
      let positions = list.range(offset, offset + size - 1)
      use checksum, offset <- list.fold(positions, checksum)
      checksum + file_id * offset
    }
  }
}

fn defragment_blocks(forward, backward, result) {
  case forward, backward {
    // special case: we reached the same file from both sides
    // backwards wins because this is where we modify the files
    [File(..) as file1, ..forward], [File(..) as file2, ..backward]
      if file1.offset == file2.offset
    -> defragment_blocks(forward, backward, [file2, ..result])
    // any file gets written
    [File(..) as file, ..forward], _ ->
      defragment_blocks(forward, backward, [file, ..result])
    // we skip free blocks from the backwards list
    _, [Free(..), ..backward] -> defragment_blocks(forward, backward, result)
    // we can skip empty chunks that we produce during looping
    _, [File(size:, ..), ..backward] if size == 0 ->
      defragment_blocks(forward, backward, result)
    [Free(size:, ..), ..forward], _ if size == 0 ->
      defragment_blocks(forward, backward, result)
    // move blocks to the front if possible.
    [Free(..) as free, ..forward], [File(..) as file, ..backward]
      if free.offset < file.offset
    -> {
      let size = int.min(free.size, file.size)
      let forward = [
        Free(size: free.size - size, offset: free.offset + size),
        ..forward
      ]
      let backward = [File(..file, size: file.size - size), ..backward]
      let result = [
        File(offset: free.offset, size:, file_id: file.file_id),
        ..result
      ]
      defragment_blocks(forward, backward, result)
    }

    _, _ -> result
  }
}

pub fn pt_2(disk: Disk) {
  defragment_files([], disk.chunks, list.reverse(disk.chunks), [])
  |> checksum
}

fn defragment_files(forward_skip, forward_curr, backward, result) {
  case forward_curr, backward {
    // we only are interested in files from the backward and skips from forward lst
    _, [Free(..), ..backward] ->
      defragment_files(forward_skip, forward_curr, backward, result)
    [File(..), ..forward], _ ->
      defragment_files(forward_skip, forward, backward, result)
    [Free(size:, ..), ..forward], _ if size <= 0 ->
      defragment_files(forward_skip, forward, backward, result)
    // scanned the entire free list (or past the current file), keep the file where it is
    [], [File(..) as file, ..backward] -> {
      let result = [file, ..result]
      defragment_files([], list.reverse(forward_skip), backward, result)
    }
    [Free(..) as free, ..], [File(..) as file, ..backward]
      if free.offset > file.offset
    -> {
      let result = [file, ..result]
      let forward =
        list.fold(forward_skip, from: forward_curr, with: list.prepend)
      defragment_files([], forward, backward, result)
    }
    // found a nice free slot
    [Free(..) as free, ..forward], [File(..) as file, ..backward]
      if free.size >= file.size
    -> {
      let result = [File(..file, offset: free.offset), ..result]
      let forward = [
        Free(offset: free.offset + file.size, size: free.size - file.size),
        ..forward
      ]
      let forward = list.fold(forward_skip, from: forward, with: list.prepend)
      defragment_files([], forward, backward, result)
    }

    // free slot not big enough, collect it for next round
    [Free(..) as free, ..forward], _ ->
      defragment_files([free, ..forward_skip], forward, backward, result)

    [], [] -> result
  }
}