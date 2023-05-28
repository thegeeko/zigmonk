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
};
