const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const h3raw = b.dependency("h3raw", .{ .target = target, .optimize = optimize });

    const exe = b.addExecutable(.{
        .name = "h3-example",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.linkLibrary(h3raw.artifact("h3raw"));
    b.installArtifact(exe);

    const run = b.step("run", "Run the example");
    run.dependOn(&b.addRunArtifact(exe).step);
}
