# JPEG minimum coded unit tool

A [JPEG image](https://en.wikipedia.org/wiki/JPEG) is encoded as a series of
small blocks, usually around 8x8 or 16x16 pixels in size.  This block primitive
is called the [minimum coded
unit](https://www.impulseadventure.com/photo/jpeg-minimum-coded-unit.html).

Very few tools display information about the size and number of minimum coded
units.  The [JPEGSnoop](https://github.com/ImpulseAdventure/JPEGsnoop) tool
can overlay a grid showing the division of an image into MCUs but it does not
display MCU statistics.  A [blog entry on
quippe.eu](https://quippe.eu/blog/2016/11/17/determining-minimum-coded-unit-dimensions.html)
contains a script that calculates and displays the MCU size for YUV-encoded
JPEG images.  This project enhances that script.

## Changes from the original on quippe.eu
### Bug fixes
- Use proper SOF offset (past the two SOF header bytes FF C0 instead of
  including them)
- Pass filename as last param to hexdump (for macOS BSD hexdump)

### Enhancements
- Retrieve and display image width and height
- Calculate and display number of MCUs

## Dependencies
[`exiv2`](https://www.exiv2.org/) must be installed.

On macOS, install `exiv2` with [Homebrew](https://brew.sh/):
```bash
brew install exiv2
```
