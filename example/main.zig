const std = @import("std");
const h3 = @cImport(@cInclude("h3api.h"));
const print = std.debug.print;

pub fn main() !void {
    print("H3 Zig Example\n", .{});
    print("==============\n\n", .{});

    // San Francisco coordinates in radians
    const lat = h3.degsToRads(37.7749);
    const lng = h3.degsToRads(-122.4194);

    const location = h3.LatLng{
        .lat = lat,
        .lng = lng,
    };

    // Get H3 index at resolution 9
    var h3_index: h3.H3Index = undefined;
    const err = h3.latLngToCell(&location, 9, &h3_index);

    if (err != h3.E_SUCCESS) {
        print("Error getting H3 index: {}\n", .{err});
        return error.H3Error;
    }

    print("San Francisco (lat={d}, lng={d})\n", .{
        h3.radsToDegs(lat),
        h3.radsToDegs(lng),
    });
    print("H3 Index: {x}\n\n", .{h3_index});

    // Get the center point back
    var center: h3.LatLng = undefined;
    const err2 = h3.cellToLatLng(h3_index, &center);

    if (err2 != h3.E_SUCCESS) {
        return error.H3Error;
    }

    print("Cell center: lat={d}, lng={d}\n", .{
        h3.radsToDegs(center.lat),
        h3.radsToDegs(center.lng),
    });

    // Get cell properties
    const res = h3.getResolution(h3_index);
    const base_cell = h3.getBaseCellNumber(h3_index);
    const is_valid = h3.isValidCell(h3_index);
    const is_pent = h3.isPentagon(h3_index);

    print("Resolution: {}\n", .{res});
    print("Base cell: {}\n", .{base_cell});
    print("Is valid: {}\n", .{is_valid != 0});
    print("Is pentagon: {}\n", .{is_pent != 0});

    // Get cell boundary
    var boundary: h3.CellBoundary = undefined;
    const err3 = h3.cellToBoundary(h3_index, &boundary);

    if (err3 != h3.E_SUCCESS) {
        return error.H3Error;
    }

    print("\nCell boundary vertices: {}\n", .{boundary.numVerts});
    var i: usize = 0;
    while (i < @as(usize, @intCast(boundary.numVerts))) : (i += 1) {
        print("  Vertex {}: lat={d}, lng={d}\n", .{
            i,
            h3.radsToDegs(boundary.verts[i].lat),
            h3.radsToDegs(boundary.verts[i].lng),
        });
    }

    print("\nSuccess!\n", .{});
}
