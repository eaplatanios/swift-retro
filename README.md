# Swift Retro

This repository contains a Swift API for Gym Retro.

## Installation

### Prerequisites

#### Retro

If `libretro.so` or `libretro.dylib` is not in your 
`LD_LIBRARY_PATH`, you need to provide the following 
extra flags when using `swift build` or any other SwiftPM 
command: `-Xlinker -L<path>`, where `<path>` represents the 
path to the dynamic library. For MacOS, you also need to 
use the following flags: `-Xlinker -rpath -Xlinker <path>`.
The simplest way to start is to execute the following 
commands from within your code directory:

```bash
git clone git@github.com:eaplatanios/retro.git
cd retro
git checkout c-api
cmake . -G 'Unix Makefiles' -DBUILD_PYTHON=OFF -DBUILD_C=ON
make -j4 retro-c

# The following is also necessary when you are on MacOS:
install_name_tool -id "$(pwd)/libretro.dylib" libretro.dylib
```

This will result in a `libretro.so` or `libretro.dylib` 
file in the `retro` subdirectory and in compiled core files 
for multiple gaming platforms in the `retro/cores`
subdirectory. Then you can set `<path>` to 
`<repository>/retro`, where `<repository>` is the path 
where you cloned the Swift Retro repository.

#### GLFW

**NOTE:** The GLFW flag is not currently working and so the 
GLFW library needs to be installed in order to use 
`retro-swift`.

In order to use the image renderer you need to first 
install GLFW. You can do so, as follows:

```bash
# For MacOS:
brew install --HEAD git glfw3

# For Linux:
sudo apt install libglfw3-dev libglfw3
```

Then, in order to use it you need to provide the following
extra flags when using `swift build` or any other SwiftPM 
command: `-Xcc -DGLFW -Xswiftc -DGLFW`. Furthermore, if 
`libglfw.so` or `libglfw.dylib` is not in your 
`LD_LIBRARY_PATH`, you also need to provide the following 
flags: `-Xlinker -lglfw -Xlinker -L<path>`, where `<path>` 
represents the path to the dynamic library. For example:

```bash
swift test \
  -Xcc -DGLFW -Xswiftc -DGLFW \
  -Xlinker -lglfw -Xlinker -L/usr/local/lib
```

**Note:** If the rendered image does not update according 
to the specified frames per second value and you are using 
MacOS 10.14, you should update to 10.14.4 because there is 
a bug in previous releases of 10.14 which breaks VSync.

### Example

This is how I can get things set up on my MacBook:

```bash
git clone git@github.com:eaplatanios/retro.git
cd retro
git checkout c-api
cmake . -G 'Unix Makefiles' -DBUILD_PYTHON=OFF -DBUILD_C=ON
make -j4 retro-c
make install
```

## Example

**WARNING:** The below is not relevant anymore. I have been
working on a new simpler and more powerful interface and
plan to update the examples shown in this file soon.

The following code runs a random policy on the 
`Airstriker-Genesis` game for which a ROM is provided by 
Gym Retro.

```swift
let retroURL = URL(fileURLWithPath: "/Users/eaplatanios/Development/GitHub/retro-swift/retro")
let config = try! Emulator.Config(
  coreInformationLookupPath: retroURL.appendingPathComponent("cores"),
  coreLookupPathHint: retroURL.appendingPathComponent("retro/cores"),
  gameDataLookupPathHint: retroURL.appendingPathComponent("retro/data"))

// We only use the OpenGL-based renderer if the GLFW flag is enabled.
#if GLFW
var renderer = try! SingleImageRenderer(initialMaxWidth: 800)
#else
var renderer = ShapedArrayPrinter<UInt8>(maxEntries: 10)
#endif

let game = emulatorConfig.game(called: "Airstriker-Genesis")!
let emulator = try! Emulator(for: game, configuredAs: emulatorConfig)
var environment = try! Environment(using: emulator, actionsType: FilteredActions())
try! environment.render(using: &renderer)
for _ in 0..<1000000 {
  let action = environment.sampleAction()
  let result = environment.step(taking: action)
  try! environment.render(using: &renderer)
  if result.finished {
    environment.reset()
  }
}
```
