const std = @import("std");
const Godot = @import("godot");
const Self = @This();

pub usingnamespace Godot.Resource;
godot_object: *Godot.Resource,

pub fn loadResource(self: *Self, path: *Godot.String) void {
    _ = self;

    var buf: [256]u8 = undefined;
    std.debug.print("Loading from path: {any}", .{Godot.stringToAscii(path.*, &buf)}); // path is empty
}
