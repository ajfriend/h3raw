// Test/demo for using H3 internal headers beyond the public API.
//
// The public H3 API is available via @cInclude("h3api.h").
// Internal headers like "iterators.h" provide additional functionality
// (e.g., cell iterators) that aren't part of the public API.
// Include them explicitly alongside "h3api.h" to use them.
//
// Warning: Internal headers are not part of H3's public API.
// They may change or be removed without notice in any H3 release.

const std = @import("std");
const h3 = @cImport({
    @cInclude("h3api.h");
    @cInclude("iterators.h");
});

test "iterInitParent iterates children" {
    const location = h3.LatLng{ .lat = 0, .lng = 0 };

    var parent: h3.H3Index = undefined;
    _ = h3.latLngToCell(&location, 5, &parent);

    var count: usize = 0;
    var it = h3.iterInitParent(parent, 6);
    while (it.h != h3.H3_NULL) : (h3.iterStepChild(&it)) {
        try std.testing.expect(h3.isValidCell(it.h) != 0);
        try std.testing.expectEqual(@as(c_int, 6), h3.getResolution(it.h));
        count += 1;
    }
    try std.testing.expect(count == 7);
}

test "iterInitRes iterates cells at resolution" {
    var count: usize = 0;
    var it = h3.iterInitRes(0);
    while (it.h != h3.H3_NULL) : (h3.iterStepRes(&it)) {
        try std.testing.expect(h3.isValidCell(it.h) != 0);
        try std.testing.expectEqual(@as(c_int, 0), h3.getResolution(it.h));
        count += 1;
    }
    // 122 base cells at resolution 0
    try std.testing.expectEqual(@as(usize, 122), count);
}

test "iterInitBaseCellNum iterates from base cell" {
    var count: usize = 0;
    var it = h3.iterInitBaseCellNum(0, 1);
    while (it.h != h3.H3_NULL) : (h3.iterStepChild(&it)) {
        try std.testing.expect(h3.isValidCell(it.h) != 0);
        try std.testing.expectEqual(@as(c_int, 1), h3.getResolution(it.h));
        count += 1;
    }
    try std.testing.expect(count > 0);
}
