# Visit here for updated resources for Zig on WASM-4

* [WASM-4 Documentation - Snake Tutorial](https://wasm4.org/docs/tutorials/snake/goal)
* [WASM-4 Tutorial Games](https://github.com/christopher-kleine/wasm-4-tutorial-games)

# WASM-4 Tutorial Snake game written in Zig

![screenshot](wasm4-screenshot.png)

## Prerequisites

* [The Zig language](https://ziglang.org/) - needs a recent build with [this change](https://github.com/ziglang/zig/commit/e89e3735f3faead04e7b2e443a1795213c927ec8)
* [WASM-4: Build retro games using WebAssembly for a fantasy console](https://wasm4.org/)

## Build and run

```sh
zig build
w4 run zig-out/lib/main.wasm
```
