# PhotonCLI

A CLI tool to batch process images with options for format conversion, HDR, resizing, and output naming.

## Supported Input Formats

PNG, JPEG, HEIC, TIFF

## Installation

A prebuilt binary is available in the `Release/` folder. To use it, just add that folder to your PATH:

```zsh
export PATH="/path/to/PhotonCLI/Release:$PATH"
```

To build from source yourself:

```zsh
./build.sh
```

## Usage

```
photoncli <files...> --output-dir <path> [options]
```

`<files...>` accepts one or more file paths or directories. Directories are expanded to their contained image files (recursively by default).

## Parameters

| Parameter | Short | Default | Description |
|---|---|---|---|
| `--output-dir` | `-o` | required | Directory to write output files into. Created if it does not exist. |
| `--format` | `-f` | `heif` | Output format. Accepted values: `jpeg`, `heif`. |
| `--hdr` / `--no-hdr` | | `--hdr` | Whether to include the HDR gain map in the output (HEIF only). |
| `--longest-side` | `-l` | none | Resize so the longest side equals this value in pixels. Aspect ratio is preserved. Images smaller than this value are not upscaled. |
| `--prefix` | `-p` | none | String prepended to each output filename. |
| `--suffix` | `-s` | `-converted` | String appended to each output filename before the extension. Pass `--suffix=` to use an empty suffix. |
| `--recursive` / `--no-recursive` | | `--recursive` | When a directory is given as input, whether to recurse into subdirectories. |
| `--quality` | `-q` | none | Output compression quality from `0.0` (lowest) to `1.0` (highest). Omit to use the system default. Applies to JPEG and HEIF. |

## Examples

Convert a single file to HEIF:
```zsh
photoncli photo.jpg --output-dir ./out
```

Convert all images in a folder to JPEG, no HDR:
```zsh
photoncli ./photos --output-dir ./out --format jpeg --no-hdr
```

Resize to 2048px on the longest side:
```zsh
photoncli ./photos --output-dir ./out --longest-side 2048
```

Custom naming — output `export-photo.heic` instead of `photo-converted.heic`:
```zsh
photoncli photo.jpg --output-dir ./out --prefix=export- --suffix=
```

Non-recursive directory processing:
```zsh
photoncli ./photos --output-dir ./out --no-recursive
```

## Output

Each processed file is printed to stdout as an absolute path, one per line.
