# resizeImage

A simple CLI tool which allows you to resize jpeg, png, and gif images.
It was written in Swift and uses Swift Argument Parser.

## Installation

- clone repo into desired location
- `cd` into that location
- run command below

  ```bash
  make resizeImage
  ```

- if you run into permission error run

  ```bash
  sudo make resizeImage
  ```

## Usage

There are only a few flags and options:

```bash
# Flags
-v, --verbose # enable verbose output
-d, --delete # delete the file at the input file path once resizing is complete
-h, --help # shot help information

# Options
-H, --height # set the resize height
-W, --width # set the resize width
-f, --format # set the desired image format (options: jpeg, png, gif default = png)
-o, --ouput # set the desired output path
-s, --scale # scale factor to use <float> (default = 1.0)
--version # show the current version
```
