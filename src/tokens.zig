const std = @import("std");

pub const Token = union(enum) {
    illeagl,
    eof,

    identifier: []const u8,
    int: []const u8,

    assign,
    plus,
    minus,
    bang,
    asterisk,
    slash,
    lt,
    gt,
    eq,
    not_eq,

    comma,
    semicolon,
    l_paren,
    r_paren,
    l_bracket,
    r_bracket,

    function,
    let,
    m_true,
    m_false,
    m_if,
    m_else,
    m_return,

    pub fn parse_word(word: []const u8) Token {
        const map = std.ComptimeStringMap(Token, .{
            .{ "let", .let },
            .{ "fn", .function },
            .{ "true", .m_true },
            .{ "false", .m_false },
            .{ "if", .m_if },
            .{ "else", .m_else },
            .{ "return", .m_return },
        });

        if (map.get(word)) |tok| {
            return tok;
        }

        return .{ .identifier = word };
    }

    pub fn to_string(self: *const @This(), allocator: std.mem.Allocator) []const u8 {
        return switch (self.*) {
            .illeagl => allocator.dupe(u8, "illeagl") catch unreachable,
            .eof => allocator.dupe(u8, "eof") catch unreachable,
            .identifier => std.fmt.allocPrint(allocator, "identifier: {s}", .{self.identifier}) catch unreachable,
            .int => std.fmt.allocPrint(allocator, "integer: {s}", .{self.int}) catch unreachable,
            .assign => allocator.dupe(u8, "assign") catch unreachable,
            .plus => allocator.dupe(u8, "plus") catch unreachable,
            .minus => allocator.dupe(u8, "minus") catch unreachable,
            .bang => allocator.dupe(u8, "bang") catch unreachable,
            .asterisk => allocator.dupe(u8, "asterisk") catch unreachable,
            .slash => allocator.dupe(u8, "slash") catch unreachable,
            .lt => allocator.dupe(u8, "lt") catch unreachable,
            .gt => allocator.dupe(u8, "gt") catch unreachable,
            .eq => allocator.dupe(u8, "eq") catch unreachable,
            .not_eq => allocator.dupe(u8, "not_eq") catch unreachable,
            .comma => allocator.dupe(u8, "comma") catch unreachable,
            .semicolon => allocator.dupe(u8, "semicolon") catch unreachable,
            .l_paren => allocator.dupe(u8, "l_paren") catch unreachable,
            .r_paren => allocator.dupe(u8, "r_paren") catch unreachable,
            .l_bracket => allocator.dupe(u8, "l_bracket") catch unreachable,
            .r_bracket => allocator.dupe(u8, "r_bracket") catch unreachable,
            .function => allocator.dupe(u8, "function") catch unreachable,
            .let => allocator.dupe(u8, "let") catch unreachable,
            .m_true => allocator.dupe(u8, "true") catch unreachable,
            .m_false => allocator.dupe(u8, "false") catch unreachable,
            .m_if => allocator.dupe(u8, "if") catch unreachable,
            .m_else => allocator.dupe(u8, "else") catch unreachable,
            .m_return => allocator.dupe(u8, "return") catch unreachable,
        };
    }
};
