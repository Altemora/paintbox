//! The one failure type of the public API. Nothing in the crate panics
//! across it; every fallible call returns [`Result`].

use thiserror::Error;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, Clone, PartialEq, Eq, Error)]
#[non_exhaustive]
pub enum Error {
    #[error("not enough memory for the image")]
    OutOfMemory,
    #[error("invalid image size {width}x{height}")]
    InvalidSize { width: u32, height: u32 },
    #[error("layer index {0} is out of range")]
    LayerIndex(usize),
    #[error("the last layer cannot be deleted")]
    LastLayer,
    #[error("there is no layer below to merge into")]
    NoLayerBelow,
    #[error("an edit is already in progress")]
    EditInProgress,
    #[error("no edit is in progress")]
    NoEdit,
    #[error("nothing is selected")]
    NoSelection,
    #[error("nothing has been lifted")]
    NothingLifted,
    #[error("invalid parameter: {0}")]
    InvalidParameter(String),
    #[error("i/o failed: {0}")]
    Io(String),
    #[error("cannot decode the image: {0}")]
    Decode(String),
    #[error("cannot encode the image: {0}")]
    Encode(String),
    #[error("invalid OpenRaster file: {0}")]
    OpenRaster(String),
    #[error("invalid palette: {0}")]
    Palette(String),
    #[error("the render was cancelled")]
    Cancelled,
}

impl From<std::io::Error> for Error {
    fn from(error: std::io::Error) -> Self {
        Error::Io(error.to_string())
    }
}

pub(crate) fn invalid(message: impl Into<String>) -> Error {
    Error::InvalidParameter(message.into())
}

impl Error {
    /// A stable identifier for shells that map failures to their own
    /// messages (bridges, translations).
    pub fn code(&self) -> &'static str {
        match self {
            Error::OutOfMemory => "out_of_memory",
            Error::InvalidSize { .. } => "invalid_size",
            Error::LayerIndex(_) => "layer_index",
            Error::LastLayer => "last_layer",
            Error::NoLayerBelow => "no_layer_below",
            Error::EditInProgress => "edit_in_progress",
            Error::NoEdit => "no_edit",
            Error::NoSelection => "no_selection",
            Error::NothingLifted => "nothing_lifted",
            Error::InvalidParameter(_) => "invalid_parameter",
            Error::Io(_) => "io",
            Error::Decode(_) => "decode",
            Error::Encode(_) => "encode",
            Error::OpenRaster(_) => "open_raster",
            Error::Palette(_) => "palette",
            Error::Cancelled => "cancelled",
        }
    }
}
