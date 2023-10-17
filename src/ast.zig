const Token = @import("./tokens.zig").Token;
const std = @import("std");

pub const LetStatment = struct {
    tokken: Token = .let,
    identifier: Token,
    value: Expression,
};

pub const Statment = union(enum) {
    let: LetStatment,
    null,
};

pub const Expression = union(enum) {
    null,
};

pub const Program = struct {
    const Self = @This();
    statments: std.ArrayList(Statment),

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{ .statments = std.ArrayList(Statment).init(allocator) };
    }
};
