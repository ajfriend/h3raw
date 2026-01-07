# h3raw

Zig package for [Uber's H3](https://github.com/uber/h3) geospatial indexing library.

Compiles the H3 C library for use via `@cImport`. No wrapper layer.

## Installation

Add to `build.zig.zon`:

```zig
.h3raw = .{
    .url = "https://github.com/ajfriend/h3raw/archive/refs/tags/v4.4.1.tar.gz",
    .hash = "...",  // zig build will provide the correct hash
},
```

Link in `build.zig`:

```zig
const h3raw = b.dependency("h3raw", .{ .target = target, .optimize = optimize });
exe.linkLibrary(h3raw.artifact("h3raw"));
```

For complete working examples, see:

- [`example/`](example/)
- https://github.com/ajfriend/h3raw_example

## Usage

```zig
const h3 = @cImport(@cInclude("h3api.h"));

const lat = h3.degsToRads(37.7749);
const lng = h3.degsToRads(-122.4194);
const location = h3.LatLng{ .lat = lat, .lng = lng };

var cell: h3.H3Index = undefined;
_ = h3.latLngToCell(&location, 9, &cell);
```

## API

Full H3 C API available via `@cImport`. See [H3 docs](https://h3geo.org/docs/api/indexing).

## License

Apache 2.0. See [H3 LICENSE](https://github.com/uber/h3/blob/master/LICENSE).
