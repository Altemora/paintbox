//! A previewing dialog's controls read from and written to an
//! adjustment's or effect's serde form (`{"GaussianBlur": {"radius":
//! 2}}`), so a shell builds sliders and boxes without knowing each
//! effect: every field is a number (or one per channel, as Levels has),
//! a flag or a seed.

use serde::de::DeserializeOwned;
use serde::Serialize;
use serde_json::{Map, Number, Value};

use crate::error::{invalid, Result};
use crate::preview::ParamRange;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ParamKind {
    Integer,
    Real,
    Flag,
    /// A random seed: no slider, a Reseed button.
    Seed,
}

/// One control of a dialog.
#[derive(Debug, Clone, PartialEq)]
pub struct Param {
    pub name: String,
    pub values: Vec<f64>,
    pub min: f64,
    pub max: f64,
    pub kind: ParamKind,
}

/// The fields of `value`'s variant as controls; fields that are not
/// numbers or flags (Curves' points and mode) have an editor of their
/// own and are left out.
pub fn params_of<T: Serialize>(value: &T, ranges: &[ParamRange]) -> Vec<Param> {
    let Some(fields) = fields_of(value) else {
        return Vec::new();
    };
    let range = |name: &str| ranges.iter().find(|r| r.0 == name).map(|r| (r.1, r.2));
    let mut out = Vec::new();
    for (name, field) in fields {
        let (values, kind) = match &field {
            Value::Bool(b) => (vec![f64::from(u8::from(*b))], ParamKind::Flag),
            Value::Number(n) => (vec![n.as_f64().unwrap_or(0.0)], number_kind(&name, n)),
            Value::Array(items) => {
                let numbers: Vec<_> = items.iter().filter_map(Value::as_number).collect();
                if numbers.is_empty() || numbers.len() != items.len() {
                    continue;
                }
                let kind = number_kind(&name, numbers[0]);
                (
                    numbers.iter().map(|n| n.as_f64().unwrap_or(0.0)).collect(),
                    kind,
                )
            }
            _ => continue,
        };
        let (min, max) = match kind {
            ParamKind::Flag => (0.0, 1.0),
            ParamKind::Seed => (0.0, f64::from(u32::MAX)),
            _ => range(&name).unwrap_or((0.0, 100.0)),
        };
        out.push(Param {
            name,
            values,
            min,
            max,
            kind,
        });
    }
    out
}

/// `value` with one field replaced: one value, or one per channel.
pub fn with_param<T: Serialize + DeserializeOwned>(
    value: &T,
    name: &str,
    values: &[f64],
) -> Result<T> {
    let mut map = variant_of(value)?;
    let fields = fields_mut(&mut map)?;
    let Some(old) = fields.get(name).cloned() else {
        return Err(invalid(format!("no parameter {name}")));
    };
    let number = |old: &Value, v: f64| -> Result<Value> {
        if !v.is_finite() {
            return Err(invalid(format!("{name} is not a number")));
        }
        Ok(match old {
            Value::Bool(_) => Value::Bool(v != 0.0),
            Value::Number(n) if n.is_f64() => Number::from_f64(v)
                .map(Value::Number)
                .unwrap_or(Value::Null),
            Value::Number(n) if n.is_i64() => Value::from(v.round() as i64),
            _ => Value::from(v.round().max(0.0) as u64),
        })
    };
    let new = match &old {
        Value::Array(items) => {
            if items.len() != values.len() {
                return Err(invalid(format!("{name} takes {} values", items.len())));
            }
            Value::Array(
                items
                    .iter()
                    .zip(values)
                    .map(|(item, &v)| number(item, v))
                    .collect::<Result<_>>()?,
            )
        }
        other => match values {
            [v] => number(other, *v)?,
            _ => return Err(invalid(format!("{name} takes one value"))),
        },
    };
    fields.insert(name.to_owned(), new);
    serde_json::from_value(Value::Object(map)).map_err(|e| invalid(e.to_string()))
}

/// `value` with the fields in `changes` (`{"radius": 4}`) merged in, for
/// a shell that keeps parameters as a dictionary.
pub fn with_fields<T: Serialize + DeserializeOwned>(
    value: &T,
    changes: &Map<String, Value>,
) -> Result<T> {
    if changes.is_empty() {
        let same = serde_json::to_value(value).map_err(|e| invalid(e.to_string()))?;
        return serde_json::from_value(same).map_err(|e| invalid(e.to_string()));
    }
    let mut map = variant_of(value)?;
    let fields = fields_mut(&mut map)?;
    for (name, v) in changes {
        if !fields.contains_key(name) {
            return Err(invalid(format!("no parameter {name}")));
        }
        fields.insert(name.clone(), v.clone());
    }
    serde_json::from_value(Value::Object(map)).map_err(|e| invalid(e.to_string()))
}

/// The variant's fields as serde writes them, `None` for a variant with
/// none (Invert Colors).
pub fn fields_of<T: Serialize>(value: &T) -> Option<Map<String, Value>> {
    let Ok(Value::Object(map)) = serde_json::to_value(value) else {
        return None;
    };
    match map.into_iter().next() {
        Some((_, Value::Object(fields))) => Some(fields),
        _ => None,
    }
}

fn variant_of<T: Serialize>(value: &T) -> Result<Map<String, Value>> {
    match serde_json::to_value(value) {
        Ok(Value::Object(map)) => Ok(map),
        Ok(_) => Err(invalid("this dialog has no parameters")),
        Err(e) => Err(invalid(e.to_string())),
    }
}

fn fields_mut(map: &mut Map<String, Value>) -> Result<&mut Map<String, Value>> {
    match map.iter_mut().next() {
        Some((_, Value::Object(fields))) => Ok(fields),
        _ => Err(invalid("this dialog has no parameters")),
    }
}

fn number_kind(name: &str, n: &Number) -> ParamKind {
    if name == "seed" {
        ParamKind::Seed
    } else if n.is_f64() {
        ParamKind::Real
    } else {
        ParamKind::Integer
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::adjust::{Adjustment, Levels};
    use crate::effects::Effect;

    #[test]
    fn effects_read_and_write_as_controls() {
        let effect = Effect::MotionBlur {
            angle: 25.0,
            distance: 10,
            centered: true,
        };
        let params = params_of(&effect, effect.ranges());
        let names: Vec<_> = params.iter().map(|p| p.name.as_str()).collect();
        assert_eq!(names, ["angle", "centered", "distance"]);
        assert_eq!(params[0].kind, ParamKind::Real);
        assert_eq!((params[0].min, params[0].max), (-180.0, 180.0));
        assert_eq!(params[1].kind, ParamKind::Flag);
        assert_eq!(params[2].kind, ParamKind::Integer);
        let moved = with_param(&effect, "distance", &[42.4]).unwrap();
        assert_eq!(
            moved,
            Effect::MotionBlur {
                angle: 25.0,
                distance: 42,
                centered: true
            }
        );
        assert!(with_param(&effect, "nope", &[1.0]).is_err());
        assert!(with_param(&effect, "angle", &[f64::NAN]).is_err());
        assert!(with_param(&effect, "angle", &[1.0, 2.0]).is_err());
    }

    #[test]
    fn channels_and_seeds() {
        let levels = Adjustment::Levels(Levels::default());
        let gamma = params_of(&levels, levels.ranges())
            .into_iter()
            .find(|p| p.name == "gamma")
            .unwrap();
        assert_eq!(gamma.values.len(), 3);
        let noise = crate::command::EffectKind::AddNoise.default_effect();
        let seed = params_of(&noise, noise.ranges())
            .into_iter()
            .find(|p| p.name == "seed")
            .unwrap();
        assert_eq!(seed.kind, ParamKind::Seed);
        let mut changes = Map::new();
        changes.insert("coverage".into(), Value::from(50.0));
        let Effect::AddNoise { coverage, .. } = with_fields(&noise, &changes).unwrap() else {
            panic!("not add noise");
        };
        assert_eq!(coverage, 50.0);
        let invert = Adjustment::InvertColors;
        assert_eq!(with_fields(&invert, &Map::new()).unwrap(), invert);
    }
}
