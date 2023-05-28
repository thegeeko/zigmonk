const std = @import("std");
const Token = @import("./tokens.zig").Token;

// @TODO support full unicode range

fn is_char(ch: u8) bool {
    return std.ascii.isAlphabetic(ch) or ch == '_';
}

fn is_int(ch: u8) bool {
    return std.ascii.isDigit(ch);
}

pub const Lexer = struct {
    const Self = @This();

    src: []const u8,

    pos: usize = 0,
    read_pos: usize = 0,
    curr_ch: u8 = 0,

    pub fn init(src: []const u8) Self {
        var lex = Self{ .src = src };
        lex.read_ch();

        return lex;
    }

    pub fn next_token(self: *Self) Token {
        self.skip_whitespace();

        const token: Token = switch (self.curr_ch) {
            '=' => (
                if (self.peak_ch() == '=') {
                    // hack you can't mix if and switch
                    self.read_ch();
                    self.read_ch();
                    return .eq;
                } else {
                    self.read_ch();
                    return .assign;
                }
            ),
            ';' => .semicolon,
            ',' => .comma,
            '(' => .l_paren,
            ')' => .r_paren,
            '{' => .l_bracket,
            '}' => .r_bracket,
            '+' => .plus,
            '-' => .minus,
            '!' => {
                if (self.peak_ch() == '=') {
                    // hack you can't mix if and switch
                    self.read_ch();
                    self.read_ch();
                    return .not_eq;
                } else {
                    self.read_ch();
                    return .bang;
                }
            },
            '/' => .slash,
            '*' => .asterisk,
            '>' => .gt,
            '<' => .lt,

            'A'...'Z', 'a'...'z', '_' => Token.parse_word(self.read_identifier()),
            '0'...'9' => .{ .int = self.read_number() },

            0 => .eof,
            else => .illeagl,
        };

        self.read_ch();
        return token;
    }

    fn read_ch(self: *Self) void {
        if (self.read_pos >= self.src.len) {
            self.curr_ch = 0;
            return;
        }

        self.curr_ch = self.src[self.read_pos];
        self.pos = self.read_pos;
        self.read_pos += 1;
    }

    fn peak_ch(self: *Self) u8 {
        if (self.read_pos > self.src.len) return 0;
        return self.src[self.read_pos];
    }

    fn read_identifier(self: *Self) []const u8 {
        const start_pos = self.pos;

        while (is_char(self.peak_ch())) {
            self.read_ch();
        }

        return self.src[start_pos..self.read_pos];
    }

    fn read_number(self: *Self) []const u8 {
        const start_pos = self.pos;

        while (is_int(self.peak_ch())) {
            self.read_ch();
        }

        return self.src[start_pos..self.read_pos];
    }

    fn skip_whitespace(self: *Self) void {
        const l = self;
        while (l.curr_ch == ' ' or l.curr_ch == '\t' or l.curr_ch == '\n' or l.curr_ch == '\r') {
            self.read_ch();
        }
    }
};

test "lexer" {
    const expectEqualDeep = @import("std").testing.expectEqualDeep;
    const src =
        \\let five = 5;
        \\let ten = 10;
        \\let add = fn(x, y) {
        \\    x + y;
        \\};
        \\let result = add(five, ten);
        \\!-/*5;
        \\5 < 10 > 5;
        \\if (5 < 10) {
        \\    return true;
        \\} else {
        \\    return false;
        \\}
        \\10 == 10;
        \\10 != 5;
    ;

    const expected = [_]Token{
        .let,
        .{ .identifier = "five" },
        .assign,
        .{ .int = "5" },
        .semicolon,
        .let,
        .{ .identifier = "ten" },
        .assign,
        .{ .int = "10" },
        .semicolon,
        .let,
        .{ .identifier = "add" },
        .assign,
        .function,
        .l_paren,
        .{ .identifier = "x" },
        .comma,
        .{ .identifier = "y" },
        .r_paren,
        .l_bracket,
        .{ .identifier = "x" },
        .plus,
        .{ .identifier = "y" },
        .semicolon,
        .r_bracket,
        .semicolon,
        .let,
        .{ .identifier = "result" },
        .assign,
        .{ .identifier = "add" },
        .l_paren,
        .{ .identifier = "five" },
        .comma,
        .{ .identifier = "ten" },
        .r_paren,
        .semicolon,
        .bang,
        .minus,
        .slash,
        .asterisk,
        .{ .int = "5" },
        .semicolon,
        .{ .int = "5" },
        .lt,
        .{ .int = "10" },
        .gt,
        .{ .int = "5" },
        .semicolon,
        .m_if,
        .l_paren,
        .{ .int = "5" },
        .lt,
        .{ .int = "10" },
        .r_paren,
        .l_bracket,
        .m_return,
        .m_true,
        .semicolon,
        .r_bracket,
        .m_else,
        .l_bracket,
        .m_return,
        .m_false,
        .semicolon,
        .r_bracket,
        .{ .int = "10" },
        .eq,
        .{ .int = "10" },
        .semicolon,
        .{ .int = "10" },
        .not_eq,
        .{ .int = "5" },
        .semicolon,
        .eof,
    };

    var lex = Lexer.init(src);
    for (expected) |t| {
        const lex_token = lex.next_token();
        expectEqualDeep(t, lex_token) catch {
            std.debug.panic("\n\n Error: expected ({}) but found ({})  \n\n", .{ t, lex_token });
        };
    }
}
