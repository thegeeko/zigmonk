const std = @import("std");
const repl = @import("repl.zig");

pub fn main() !void {
    try repl.start();
}

test {
    std.testing.refAllDecls(@This());
}
