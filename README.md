# Swift Retro

This repository contains a Swift API for Gym Retro.

## Installation

### Prerequisites

`Retro` depends on the native Gym Retro library and on
[GLFW](https://www.glfw.org/) which is used for rendering.
The native Gym Retro library can be installed by executing
the following commands in a temporary working directory:

```bash
git clone git@github.com:eaplatanios/retro.git
cd retro
git checkout c-api
cmake . -G 'Unix Makefiles' -DBUILD_PYTHON=OFF -DBUILD_C=ON
make -j8 retro-c
make install
```

GLFW can be installed by executing the following commands:

```bash
# For MacOS:
brew install --HEAD git glfw3

# For Linux:
sudo apt install libglfw3-dev libglfw3
```

After having installed these libraries you should be able
to use this library.

**NOTE:** The Swift Package Manager uses `pkg-config` to 
locate the installed libraries and so you need to make sure
that `pkg-config` is configured correctly. That may require
you to set the `PKG_CONFIG_PATH` environment variable
correctly.

**NOTE:** If the rendered image does not update according 
to the specified frames per second value and you are using 
MacOS 10.14, you should update to 10.14.4 because there is 
a bug in previous releases of 10.14 which breaks VSync.

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
