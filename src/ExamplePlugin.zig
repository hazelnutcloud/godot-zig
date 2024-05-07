const std = @import("std");
const Godot = @import("godot");
const GDE = Godot.GDE;
const builtin = @import("builtin");
const TestResourceFormatLoader = @import("TestResourceFormatLoader.zig");
const TestCustomResource = @import("TestCustomResource.zig");
const GPA = std.heap.GeneralPurposeAllocator(.{});

var resourceFormatLoader: ?*TestResourceFormatLoader = null;

fn initializeLevel(_: ?*anyopaque, p_level: GDE.GDExtensionInitializationLevel) callconv(.C) void {
    if (p_level != GDE.GDEXTENSION_INITIALIZATION_SCENE) {
        return;
    }

    Godot.registerClass(TestResourceFormatLoader);
    resourceFormatLoader = Godot.create(TestResourceFormatLoader) catch unreachable;
    Godot.ResourceLoader.getSingleton().add_resource_format_loader(resourceFormatLoader, false);

    Godot.registerClass(TestCustomResource);

    const ExampleNode = @import("ExampleNode.zig");
    Godot.registerClass(ExampleNode);
}

fn deinitializeLevel(userdata: ?*anyopaque, p_level: GDE.GDExtensionInitializationLevel) callconv(.C) void {
    if (p_level != GDE.GDEXTENSION_INITIALIZATION_CORE) {
        return;
    }

    Godot.ResourceLoader.getSingleton().remove_resource_format_loader(resourceFormatLoader);

    Godot.deinit();
    if (builtin.mode == .Debug) {
        var gpa = @as(*GPA, @ptrCast(@alignCast(userdata.?)));
        _ = gpa.deinit();
        std.heap.c_allocator.destroy(gpa);
    }
}

pub export fn my_extension_init(p_get_proc_address: GDE.GDExtensionInterfaceGetProcAddress, p_library: GDE.GDExtensionClassLibraryPtr, r_initialization: [*c]GDE.GDExtensionInitialization) callconv(.C) GDE.GDExtensionBool {
    r_initialization.*.initialize = initializeLevel;
    r_initialization.*.deinitialize = deinitializeLevel;
    r_initialization.*.minimum_initialization_level = GDE.GDEXTENSION_INITIALIZATION_SCENE;

    var allocator: std.mem.Allocator = undefined;
    if (builtin.mode == .Debug) {
        var gpa = std.heap.c_allocator.create(GPA) catch unreachable;
        gpa.* = GPA{};
        r_initialization.*.userdata = @ptrCast(@alignCast(gpa));
        allocator = gpa.allocator();
    } else {
        allocator = std.heap.c_allocator;
    }

    Godot.init(p_get_proc_address.?, p_library, allocator) catch unreachable;

    return 1;
}
