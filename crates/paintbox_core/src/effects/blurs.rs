//! Blurs: Gaussian, Motion, Fragment, Radial and Zoom. Surface Blur and
//! Unfocus slide a disc and live in `local`.

use std::sync::atomic::{AtomicBool, Ordering};

use super::{by_pixels, by_rows};
use crate::color::{average, Rgba8};
use crate::error::Result;
use crate::geom::Rect;
use crate::surface::Surface;

/// Paint.NET's "Gaussian" blur: a tent kernel (weights rise linearly to
/// the centre), separable, colour weighted by alpha. A tent is two box
/// filters in a row, so each axis is two running sums and the cost does
/// not grow with the radius. Rows stream through a ring of row sums, so
/// memory is `(2r + 2)` rows, not the image.
pub(super) fn tent_blur(
    src: &Surface,
    rect: Rect,
    r: usize,
    cancel: &AtomicBool,
) -> Option<Surface> {
    if r == 0 {
        return Some(src.crop(rect));
    }
    let (w, h) = (src.width() as i64, src.height() as i64);
    let out_w = rect.width as usize;
    let r_i = r as i64;
    // Horizontal tent of one row: [weight, a, a·r, a·g, a·b] per output x.
    let horizontal = |y: i64| -> Vec<[f64; 5]> {
        let x0 = rect.x as i64 - r_i;
        let len = out_w + 2 * r;
        let mut values = vec![[0f64; 5]; len];
        for (i, v) in values.iter_mut().enumerate() {
            let x = x0 + i as i64;
            if x >= 0 && x < w {
                let p = src.at(x as i32, y as i32);
                let a = p.a as f64;
                *v = [1.0, a, a * p.r as f64, a * p.g as f64, a * p.b as f64];
            }
        }
        tent_1d(&values, r, out_w)
    };
    let zero = vec![[0f64; 5]; out_w];
    let row_at = |y: i64| -> Vec<[f64; 5]> {
        if y >= 0 && y < h {
            horizontal(y)
        } else {
            zero.clone()
        }
    };
    // Running tent along y: tent(y + 1) = tent(y) + box_after(y + 1) − box_before(y),
    // box_after(y) = Σ rows y..=y + r, box_before(y) = Σ rows y − r..=y.
    let y0 = rect.y as i64;
    let ring_len = 2 * r + 2;
    let mut ring: Vec<Vec<[f64; 5]>> = (0..ring_len).map(|i| row_at(y0 - r_i + i as i64)).collect();
    let slot = |y: i64| ((y - (y0 - r_i)).rem_euclid(ring_len as i64)) as usize;
    let mut tent = vec![[0f64; 5]; out_w];
    let mut after = vec![[0f64; 5]; out_w];
    let mut before = vec![[0f64; 5]; out_w];
    for d in -r_i..=r_i {
        let weight = (r_i + 1 - d.abs()) as f64;
        let row = &ring[slot(y0 + d)];
        for (t, v) in tent.iter_mut().zip(row) {
            for c in 0..5 {
                t[c] += weight * v[c];
            }
        }
    }
    for d in 1..=r_i + 1 {
        add_row(&mut after, &ring[slot(y0 + d)], 1.0);
    }
    for d in -r_i..=0 {
        add_row(&mut before, &ring[slot(y0 + d)], 1.0);
    }
    let mut out = vec![Rgba8::TRANSPARENT; out_w * rect.height as usize];
    for (row_index, line) in out.chunks_mut(out_w).enumerate() {
        if cancel.load(Ordering::Relaxed) {
            return None;
        }
        let y = y0 + row_index as i64;
        for (o, t) in line.iter_mut().zip(&tent) {
            *o = resolve(t);
        }
        if row_index + 1 == rect.height as usize {
            break;
        }
        // Step y -> y + 1.
        for (t, (a, b)) in tent.iter_mut().zip(after.iter().zip(&before)) {
            for c in 0..5 {
                t[c] += a[c] - b[c];
            }
        }
        add_row(&mut before, &ring[slot(y - r_i)], -1.0);
        add_row(&mut before, &ring[slot(y + 1)], 1.0);
        add_row(&mut after, &ring[slot(y + 1)], -1.0);
        // Row y − r leaves the window and row y + r + 2 takes its slot.
        let incoming = row_at(y + r_i + 2);
        add_row(&mut after, &incoming, 1.0);
        ring[slot(y - r_i)] = incoming;
    }
    Some(Surface::from_pixels(rect.width, rect.height, out))
}

fn add_row(acc: &mut [[f64; 5]], row: &[[f64; 5]], sign: f64) {
    for (a, v) in acc.iter_mut().zip(row) {
        for c in 0..5 {
            a[c] += sign * v[c];
        }
    }
}

/// The tent of radius `r` over `values` (which carry `r` extra entries
/// on each side), for `out_len` outputs.
fn tent_1d(values: &[[f64; 5]], r: usize, out_len: usize) -> Vec<[f64; 5]> {
    let mut prefix = vec![[0f64; 5]; values.len() + 1];
    for (i, v) in values.iter().enumerate() {
        for c in 0..5 {
            prefix[i + 1][c] = prefix[i][c] + v[c];
        }
    }
    // First box: b1[i] = Σ values[i .. i + r] (r + 1 wide), for i in 0..out_len + r.
    let n1 = out_len + r;
    let mut b1 = vec![[0f64; 5]; n1 + 1];
    for i in 0..n1 {
        let end = (i + r + 1).min(values.len());
        for c in 0..5 {
            b1[i + 1][c] = b1[i][c] + prefix[end][c] - prefix[i][c];
        }
    }
    // Second box over b1: out[i] = Σ b1[i .. i + r], centred on values[i + r].
    (0..out_len)
        .map(|i| {
            let mut v = [0f64; 5];
            for (c, slot) in v.iter_mut().enumerate() {
                *slot = b1[i + r + 1][c] - b1[i][c];
            }
            v
        })
        .collect()
}

pub(super) fn resolve(t: &[f64; 5]) -> Rgba8 {
    // Running sums drift by tiny amounts; any real contribution is at
    // least weight 1 times alpha 1.
    if t[0] < 0.5 || t[1] < 0.5 {
        return Rgba8::TRANSPARENT;
    }
    let to = |v: f64| v.round().clamp(0.0, 255.0) as u8;
    Rgba8::new(
        to(t[2] / t[1]),
        to(t[3] / t[1]),
        to(t[4] / t[1]),
        to(t[1] / t[0]),
    )
}

/// `(1 + d)·3/2` bilinear samples along the segment, averaged by alpha.
pub(super) fn motion(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    angle: f64,
    distance: u32,
    centered: bool,
) -> Result<Surface> {
    let theta = (angle + 180.0).to_radians();
    let (mut sx, mut sy) = (0.0f32, 0.0f32);
    let mut ex = (distance as f64 * theta.cos()) as f32;
    let mut ey = -(distance as f64 * theta.sin()) as f32;
    if centered {
        sx = -ex / 2.0;
        sy = -ey / 2.0;
        ex /= 2.0;
        ey /= 2.0;
    }
    let count = ((1 + distance) * 3 / 2) as usize;
    let points: Vec<(f32, f32)> = if count <= 1 {
        vec![(0.0, 0.0)]
    } else {
        (0..count)
            .map(|i| {
                let f = i as f32 / (count - 1) as f32;
                (sx + (ex - sx) * f, sy + (ey - sy) * f)
            })
            .collect()
    };
    let (w, h) = (src.width() as f32, src.height() as f32);
    by_rows(rect, cancel, |y, line| {
        let mut samples = Vec::with_capacity(points.len());
        for (i, out) in line.iter_mut().enumerate() {
            let x = rect.x + i as i32;
            samples.clear();
            for &(dx, dy) in &points {
                let (px, py) = (x as f32 + dx, y as f32 + dy);
                if px >= 0.0 && py >= 0.0 && px <= w - 1.0 && py <= h - 1.0 {
                    samples.push(src.bilinear(px, py));
                }
            }
            *out = average(&samples);
        }
    })
}

/// `FragmentEffect`: the average of `fragments` copies of the picture
/// moved `distance` pixels outwards, evenly around the circle from
/// `rotation` (0 is straight up).
pub(super) fn fragment(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    fragments: u32,
    distance: u32,
    rotation: f64,
) -> Result<Surface> {
    let step = std::f64::consts::TAU / fragments as f64;
    let start = (rotation - 90.0).to_radians();
    let d = distance as f64;
    let offsets: Vec<(i32, i32)> = (0..fragments)
        .map(|i| {
            let a = start + step * i as f64;
            // `MidpointRounding.AwayFromZero`, as `f64::round`.
            ((d * -a.sin()).round() as i32, (d * -a.cos()).round() as i32)
        })
        .collect();
    by_rows(rect, cancel, |y, line| {
        let mut samples = Vec::with_capacity(offsets.len());
        for (i, out) in line.iter_mut().enumerate() {
            let x = rect.x + i as i32;
            samples.clear();
            samples.extend(
                offsets
                    .iter()
                    .filter_map(|&(ox, oy)| src.get(x - ox, y - oy)),
            );
            *out = average(&samples);
        }
    })
}

/// Premultiplied sums `[r·a, g·a, b·a, a]` and the count of samples,
/// resolved as the source's radial and zoom blurs do (truncated).
fn resolve_sums(s: [i64; 4], count: i64) -> Rgba8 {
    if s[3] <= 0 {
        return Rgba8::TRANSPARENT;
    }
    let to = |v: i64| v.clamp(0, 255) as u8;
    Rgba8::new(
        to(s[0] / s[3]),
        to(s[1] / s[3]),
        to(s[2] / s[3]),
        to(s[3] / count),
    )
}

fn add_sample(sums: &mut [i64; 4], count: &mut i64, p: Rgba8) {
    let a = p.a as i64;
    sums[0] += p.r as i64 * a;
    sums[1] += p.g as i64 * a;
    sums[2] += p.b as i64 * a;
    sums[3] += a;
    *count += 1;
}

/// The centre of the radial and zoom blurs in 16.16 fixed point: the
/// layer's centre moved by `offset` half-sizes.
fn fixed_centre(src: &Surface, (ox, oy): (f64, f64)) -> (i64, i64) {
    let (w, h) = (src.width() as i64, src.height() as i64);
    (
        (w << 15) + (ox * (w << 15) as f64) as i64,
        (h << 15) + (oy * (h << 15) as f64) as i64,
    )
}

/// `RadialBlurEffect`: the pixel plus samples along the arc through it
/// around the centre, `angle` degrees in all, both ways. The source's
/// fixed-point rotation (`sin x ≈ x`, `cos x ≈ 1 − x²/2`) is kept, in
/// 64 bits so large pictures do not overflow.
pub(super) fn radial(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    angle: f64,
    offset: (f64, f64),
    quality: u32,
) -> Result<Surface> {
    let (w, h) = (src.width() as i64, src.height() as i64);
    let (fcx, fcy) = fixed_centre(src, offset);
    let q = quality as i64;
    let n = q * q * (30 + q * q);
    let fr = (angle * std::f64::consts::PI * 65536.0 / 181.0) as i64;
    let fsr = fr / n;
    let rotate = |fx: &mut i64, fy: &mut i64, fr: i64| {
        let (cx, cy) = (*fx, *fy);
        *fx = cx - (((cy >> 8) * fr) >> 8) - (((cx >> 14) * ((fr * fr) >> 11)) >> 8);
        *fy = cy + (((cx >> 8) * fr) >> 8) - (((cy >> 14) * ((fr * fr) >> 11)) >> 8);
    };
    by_pixels(rect, cancel, |x, y| {
        let (fx, fy) = (((x as i64) << 16) - fcx, ((y as i64) << 16) - fcy);
        let mut sums = [0i64; 4];
        let mut count = 0;
        add_sample(&mut sums, &mut count, src.at(x, y));
        let (mut ox1, mut oy1, mut ox2, mut oy2) = (fx, fy, fx, fy);
        for _ in 0..n {
            rotate(&mut ox1, &mut oy1, fsr);
            rotate(&mut ox2, &mut oy2, -fsr);
            for (ox, oy) in [(ox1, oy1), (ox2, oy2)] {
                let u = (ox + fcx + 32768) >> 16;
                let v = (oy + fcy + 32768) >> 16;
                // The source skips the first row and column too (`> 0`).
                if u > 0 && v > 0 && u < w && v < h {
                    add_sample(&mut sums, &mut count, src.at(u as i32, v as i32));
                }
            }
        }
        resolve_sums(sums, count)
    })
}

/// `ZoomBlurEffect`: the pixel plus 64 samples stepping towards the
/// centre, each `amount / 16384` of the way.
pub(super) fn zoom(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    amount: u32,
    offset: (f64, f64),
) -> Result<Surface> {
    let (w, h) = (src.width() as i64, src.height() as i64);
    let (fcx, fcy) = fixed_centre(src, offset);
    let fz = amount as i64;
    by_pixels(rect, cancel, |x, y| {
        let (mut fx, mut fy) = (((x as i64) << 16) - fcx, ((y as i64) << 16) - fcy);
        let mut sums = [0i64; 4];
        let mut count = 0;
        add_sample(&mut sums, &mut count, src.at(x, y));
        for _ in 0..64 {
            fx -= ((fx >> 4) * fz) >> 10;
            fy -= ((fy >> 4) * fz) >> 10;
            let u = (fx + fcx + 32768) >> 16;
            let v = (fy + fcy + 32768) >> 16;
            if u >= 0 && v >= 0 && u < w && v < h {
                add_sample(&mut sums, &mut count, src.at(u as i32, v as i32));
            }
        }
        resolve_sums(sums, count)
    })
}

#[cfg(test)]
mod tests {
    use super::super::testing::*;
    use super::super::Effect;
    use super::*;

    fn naive_tent(src: &Surface, x: i32, y: i32, r: i32) -> Rgba8 {
        let mut t = [0f64; 5];
        for dy in -r..=r {
            for dx in -r..=r {
                let (sx, sy) = (x + dx, y + dy);
                if let Some(p) = src.get(sx, sy) {
                    let wgt = ((r + 1 - dx.abs()) * (r + 1 - dy.abs())) as f64;
                    let a = p.a as f64;
                    t[0] += wgt;
                    t[1] += wgt * a;
                    t[2] += wgt * a * p.r as f64;
                    t[3] += wgt * a * p.g as f64;
                    t[4] += wgt * a * p.b as f64;
                }
            }
        }
        resolve(&t)
    }

    #[test]
    fn tent_blur_matches_the_direct_sum() {
        let mut s = checker(23, 17);
        s.set(5, 5, Rgba8::new(255, 0, 0, 40));
        s.set(20, 3, Rgba8::TRANSPARENT);
        for r in [1, 3, 9] {
            let rect = Rect::new(2, 1, 19, 14);
            let out = Effect::GaussianBlur { radius: r }.render(&s, rect).unwrap();
            for y in 0..rect.height as i32 {
                for x in 0..rect.width as i32 {
                    let want = naive_tent(&s, x + rect.x, y + rect.y, r as i32);
                    let got = out.at(x, y);
                    assert!(close(got, want, 1), "r={r} ({x},{y}): {got:?} vs {want:?}");
                }
            }
        }
    }

    #[test]
    fn blurs_of_a_flat_colour_are_the_colour() {
        let flat = Rgba8::new(10, 20, 30, 200);
        let s = Surface::filled(40, 30, flat).unwrap();
        let blurs = [
            Effect::GaussianBlur { radius: 50 },
            Effect::Fragment {
                fragments: 7,
                distance: 5,
                rotation: 30.0,
            },
            Effect::RadialBlur {
                angle: 40.0,
                offset_x: 0.3,
                offset_y: -0.5,
                quality: 2,
            },
            Effect::ZoomBlur {
                amount: 60,
                offset_x: -1.0,
                offset_y: 0.5,
            },
        ];
        for effect in blurs {
            assert!(all(&render(effect, &s), flat), "{effect:?}");
        }
    }

    #[test]
    fn motion_blur_smears_along_the_angle() {
        let mut s = Surface::filled(21, 5, Rgba8::BLACK).unwrap();
        s.set(10, 2, Rgba8::WHITE);
        let m = render(
            Effect::MotionBlur {
                angle: 0.0,
                distance: 6,
                centered: true,
            },
            &s,
        );
        assert!(m.at(12, 2).r > 0);
        assert_eq!(m.at(10, 0).r, 0);
    }

    #[test]
    fn fragment_averages_the_moved_copies() {
        // Four fragments at distance 2 from rotation 0 sample the pixels
        // 2 to the left, below, to the right and above.
        let mut s = Surface::filled(9, 9, Rgba8::BLACK).unwrap();
        s.set(4, 2, Rgba8::WHITE);
        let f = render(
            Effect::Fragment {
                fragments: 4,
                distance: 2,
                rotation: 0.0,
            },
            &s,
        );
        // (4, 4) sees (4, 2) through the offset (0, 2): one of four white.
        assert_eq!(f.at(4, 4), Rgba8::opaque(64, 64, 64));
        assert_eq!(f.at(4, 2), Rgba8::BLACK);
        // At the corner only the two copies inside the picture count.
        let corner = Effect::Fragment {
            fragments: 4,
            distance: 2,
            rotation: 0.0,
        }
        .render(&s, Rect::new(0, 0, 1, 1))
        .unwrap();
        assert_eq!(corner.at(0, 0), Rgba8::BLACK);
        // Distance 0 leaves the picture as it is.
        let same = render(
            Effect::Fragment {
                fragments: 5,
                distance: 0,
                rotation: 10.0,
            },
            &s,
        );
        assert_eq!(same, s);
    }

    #[test]
    fn radial_blur_leaves_the_centre_and_smears_around_it() {
        let mut s = Surface::filled(41, 41, Rgba8::BLACK).unwrap();
        s.set(35, 20, Rgba8::WHITE);
        let effect = Effect::RadialBlur {
            angle: 30.0,
            offset_x: 0.0,
            offset_y: 0.0,
            quality: 1,
        };
        let out = render(effect, &s);
        // The arc through (35, 20) around (20.5, 20.5) reaches the
        // pixels above and below it; the radius it lies on stays dark.
        assert!(out.at(35, 22).r > 0 && out.at(35, 18).r > 0);
        assert_eq!(out.at(25, 20).r, 0);
        assert!(out.at(35, 20).r < 255);
        // Angle 0 samples only the pixel itself.
        let none = Effect::RadialBlur {
            angle: 0.0,
            offset_x: 0.0,
            offset_y: 0.0,
            quality: 2,
        };
        assert_eq!(render(none, &s), s);
    }

    #[test]
    fn zoom_blur_streaks_towards_the_centre() {
        let mut s = Surface::filled(41, 41, Rgba8::BLACK).unwrap();
        s.set(30, 20, Rgba8::WHITE);
        let out = render(
            Effect::ZoomBlur {
                amount: 100,
                offset_x: 0.0,
                offset_y: 0.0,
            },
            &s,
        );
        // Pixels further out than the white one sample it on the way in.
        assert!(out.at(34, 20).r > 0);
        assert_eq!(out.at(26, 20).r, 0);
        let none = Effect::ZoomBlur {
            amount: 0,
            offset_x: 0.0,
            offset_y: 0.0,
        };
        assert_eq!(render(none, &s), s);
    }
}
