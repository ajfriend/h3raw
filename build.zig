const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const h3 = b.dependency("h3", .{ .target = target, .optimize = optimize });
    const h3_path = h3.path("").getPath(b);

    generateHeader(b, h3_path) catch return;

    const lib = b.addLibrary(.{
        .name = "h3",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    lib.addCSourceFiles(.{
        .root = h3.path(""),
        .files = collectCFiles(b, h3_path) catch return,
        .flags = &.{ "-std=c99", "-O3" },
    });
    lib.addIncludePath(h3.path("src/h3lib/include"));
    lib.installHeadersDirectory(
        h3.path("src/h3lib/include"),
        "",
        .{ .include_extensions = &.{"h3api.h"} },
    );

    b.installArtifact(lib);

    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    tests.linkLibrary(lib);

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_tests.step);
}

fn collectCFiles(b: *std.Build, h3: []const u8) ![]const []const u8 {
    var dir = try std.fs.cwd().openDir(
        b.fmt("{s}/src/h3lib/lib", .{h3}),
        .{ .iterate = true },
    );
    defer dir.close();

    var files: std.ArrayList([]const u8) = .{};
    var it = dir.iterate();
    while (try it.next()) |e| {
        if (e.kind == .file and std.mem.endsWith(u8, e.name, ".c")) {
            try files.append(b.allocator, b.fmt("src/h3lib/lib/{s}", .{e.name}));
        }
    }
    return files.toOwnedSlice(b.allocator);
}

fn generateHeader(b: *std.Build, h3: []const u8) !void {
    const version_file = b.fmt("{s}/VERSION", .{h3});
    const raw = try std.fs.cwd().readFileAlloc(b.allocator, version_file, 1024);
    const version = std.mem.trim(u8, raw, &std.ascii.whitespace);
    var parts = std.mem.splitScalar(u8, version, '.');

    const template_file = b.fmt("{s}/src/h3lib/include/h3api.h.in", .{h3});
    var t = try std.fs.cwd().readFileAlloc(b.allocator, template_file, 1024 * 1024);

    const patterns = [_][]const u8{
        "@H3_VERSION_MAJOR@",
        "@H3_VERSION_MINOR@",
        "@H3_VERSION_PATCH@",
    };
    for (patterns) |pat| {
        const val = parts.next() orelse return error.InvalidVersion;
        const new = try std.mem.replaceOwned(u8, b.allocator, t, pat, val);
        if (new.ptr != t.ptr) b.allocator.free(t);
        t = new;
    }

    const output_file = b.fmt("{s}/src/h3lib/include/h3api.h", .{h3});
    try std.fs.cwd().writeFile(.{ .sub_path = output_file, .data = t });
}
