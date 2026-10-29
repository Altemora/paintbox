//! Row-parallel loops over pixel buffers with `std::thread::scope`, so
//! full-image work on 4k pictures uses every core without a thread-pool
//! dependency.

use std::thread;

use std::sync::{Mutex, OnceLock};

/// Below this many pixels of work a loop stays on the calling thread:
/// spawning costs more than it saves (a brush dab is far below).
const SERIAL_LIMIT: usize = 1 << 16;

fn thread_count(rows: usize) -> usize {
    static CORES: OnceLock<usize> = OnceLock::new();
    let cores = *CORES.get_or_init(|| thread::available_parallelism().map_or(1, |n| n.get()));
    cores.min(rows).max(1)
}

/// Calls `f(y, row)` for every row of `data` (rows of `width` items),
/// spreading rows over threads.
pub(crate) fn for_rows<T: Send>(data: &mut [T], width: usize, f: impl Fn(usize, &mut [T]) + Sync) {
    let work = data.len();
    for_rows_with_work(data, width, work, f);
}

/// [`for_rows`] when only `work` items of each row are actually
/// processed (a narrow rectangle of full-width rows).
pub(crate) fn for_rows_with_work<T: Send>(
    data: &mut [T],
    width: usize,
    work: usize,
    f: impl Fn(usize, &mut [T]) + Sync,
) {
    if width == 0 || data.is_empty() {
        return;
    }
    let rows = data.len() / width;
    let threads = if work < SERIAL_LIMIT {
        1
    } else {
        thread_count(rows)
    };
    if threads == 1 {
        for (y, row) in data.chunks_mut(width).enumerate() {
            f(y, row);
        }
        return;
    }
    // Threads take rows one at a time instead of a fixed share each: the
    // cost of a row can vary a lot (a fractal's inside, a blur's edge),
    // and a fixed share would leave threads idle behind the slowest.
    // One lock per row is nothing next to a row's work.
    let next = Mutex::new(data.chunks_mut(width).enumerate());
    thread::scope(|scope| {
        for _ in 0..threads {
            let (f, next) = (&f, &next);
            scope.spawn(move || loop {
                let taken = next.lock().ok().and_then(|mut rows| rows.next());
                let Some((y, row)) = taken else {
                    break;
                };
                f(y, row);
            });
        }
    });
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn every_row_is_visited_once_with_its_index() {
        let width = 300;
        let mut data = vec![0usize; width * 400];
        for_rows(&mut data, width, |y, row| {
            for v in row.iter_mut() {
                *v += y;
            }
        });
        for (y, row) in data.chunks(width).enumerate() {
            assert!(row.iter().all(|&v| v == y));
        }
    }
}
