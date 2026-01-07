const std = @import("std");
const h3 = @cImport(@cInclude("h3api.h"));

fn expectSuccess(err: h3.H3Error) !void {
    try std.testing.expectEqual(@as(h3.H3Error, h3.E_SUCCESS), err);
}

test "latLngToCell returns valid cell" {
    const lat = h3.degsToRads(37.7749);
    const lng = h3.degsToRads(-122.4194);
    const location = h3.LatLng{ .lat = lat, .lng = lng };

    var cell: h3.H3Index = undefined;
    const err = h3.latLngToCell(&location, 9, &cell);

    try expectSuccess(err);
    try std.testing.expect(cell != 0);
    try std.testing.expect(h3.isValidCell(cell) != 0);
}

test "cellToLatLng roundtrip" {
    const lat = h3.degsToRads(37.7749);
    const lng = h3.degsToRads(-122.4194);
    const location = h3.LatLng{ .lat = lat, .lng = lng };

    var cell: h3.H3Index = undefined;
    _ = h3.latLngToCell(&location, 9, &cell);

    var center: h3.LatLng = undefined;
    const err = h3.cellToLatLng(cell, &center);

    try expectSuccess(err);
    try std.testing.expectApproxEqAbs(lat, center.lat, 0.001);
    try std.testing.expectApproxEqAbs(lng, center.lng, 0.001);
}

test "getResolution returns correct resolution" {
    const location = h3.LatLng{ .lat = 0, .lng = 0 };

    var cell: h3.H3Index = undefined;
    _ = h3.latLngToCell(&location, 5, &cell);

    try std.testing.expectEqual(@as(c_int, 5), h3.getResolution(cell));
}

test "cellToBoundary returns valid boundary" {
    const location = h3.LatLng{ .lat = 0, .lng = 0 };

    var cell: h3.H3Index = undefined;
    _ = h3.latLngToCell(&location, 9, &cell);

    var boundary: h3.CellBoundary = undefined;
    const err = h3.cellToBoundary(cell, &boundary);

    try expectSuccess(err);
    try std.testing.expect(boundary.numVerts >= 5);
    try std.testing.expect(boundary.numVerts <= 6);
}

test "gridDisk returns neighbors" {
    const location = h3.LatLng{ .lat = 0, .lng = 0 };

    var cell: h3.H3Index = undefined;
    _ = h3.latLngToCell(&location, 9, &cell);

    var max_size: i64 = undefined;
    _ = h3.maxGridDiskSize(1, &max_size);

    var neighbors: [7]h3.H3Index = undefined;
    const err = h3.gridDisk(cell, 1, &neighbors);

    try expectSuccess(err);
    try std.testing.expectEqual(@as(i64, 7), max_size);
}

test "degsToRads and radsToDegs roundtrip" {
    const degrees: f64 = 45.0;
    const radians = h3.degsToRads(degrees);
    const back = h3.radsToDegs(radians);

    try std.testing.expectApproxEqAbs(degrees, back, 0.0001);
}
