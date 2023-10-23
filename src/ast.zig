const Token = @import("./tokens.zig").Token;
const std = @import("std");

pub const LetStatment = struct {
    const Self = @This();

    token: Token = .let,
    identifier: Token,
    value: Expression,

    pub fn to_string(self: *const Self, allocator: std.mem.Allocator) []const u8 {
        return std.fmt.allocPrint(allocator,
            \\   Let Statment:
            \\      |-identifer: {s}
            \\      |-value: *unimplimented*
        , .{self.identifier.identifier}) catch unreachable;
    }
};

pub const ReturnStatment = struct {
    const Self = @This();
    token: Token = .m_return,
    value: Expression,

    pub fn to_string(self: *const Self, allocator: std.mem.Allocator) []const u8 {
        _ = self;
        return std.fmt.allocPrint(allocator,
            \\   Return Statment:
            \\      |-value: *unimplimented*
        , .{}) catch unreachable;
    }
};

pub const Statment = union(enum) {
    const Self = @This();

    let: LetStatment,
    m_return: ReturnStatment,
    null,

    pub fn to_string(self: Self, allocator: std.mem.Allocator) []const u8 {
        var string = switch (self) {
            .let => self.let.to_string(allocator),
            .m_return => self.m_return.to_string(allocator),
            .null => "Null statment",
        };

        return string;
    }
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

    pub fn deinit(self: *Self) void {
        self.statments.deinit();
    }

    pub fn to_string(self: *Self, allcator: std.mem.Allocator) []const u8 {
        var stream = std.ArrayList(u8).init(allcator);
        for (self.statments.items) |statment| {
            var statment_string = statment.to_string(allcator);
            stream.appendSlice(statment_string) catch unreachable;
            stream.append('\n') catch unreachable;
            allcator.free(statment_string);
        }

        var string = stream.toOwnedSlice() catch unreachable;
        return string;
    }
};
