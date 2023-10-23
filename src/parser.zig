const std = @import("std");

const Lexer = @import("./lexer.zig").Lexer;
const Token = @import("./tokens.zig").Token;
const Ast = @import("./ast.zig");
const Program = Ast.Program;
const Statment = Ast.Statment;

pub const Error = struct {
    const Self = @This();
    msg: []const u8,
    fn make_error(
        allocator: std.mem.Allocator,
        comptime fmt: []const u8,
        args: anytype,
    ) Self {
        var error_msg = std.fmt.allocPrint(allocator, fmt, args) catch {
            unreachable;
        };

        return Self{
            .msg = error_msg,
        };
    }
};

pub const Parser = struct {
    const Self = @This();

    l: *Lexer,
    curr_token: Token,
    peek_token: Token,
    allocator: std.mem.Allocator,
    errors: std.ArrayList(Error),

    pub fn init(lexer: *Lexer, allocator: std.mem.Allocator) Self {
        var parser = Self{
            .l = lexer,
            .allocator = allocator,
            .curr_token = .eof,
            .peek_token = .eof,
            .errors = std.ArrayList(Error).init(allocator),
        };

        parser.next_token();
        parser.next_token();

        return parser;
    }

    pub fn deinit(self: *Self) void {
        self.errors.deinit();
    }

    pub fn parse_program(self: *Self) Program {
        var program = Program.init(self.allocator);

        while (self.curr_token != .eof) {
            // std.debug.print("\n{s}", .{self.curr_token.to_string()});
            var statment: Statment = switch (self.curr_token) {
                .let => self.parse_let_statment(),
                .m_return => self.parse_return_statment(),
                .m_if => self.parse_if_statment(),
                else => unreachable,
            };

            if (statment != .null) {
                program.statments.append(statment) catch {
                    unreachable;
                };
            } else unreachable;

            if (self.errors.items.len > 0) {
                var writer = std.io.getStdErr().writer();
                for (self.errors.items) |err| {
                    _ = writer.write(err.msg) catch unreachable;
                }
                std.os.exit(1);
            }
        }

        return program;
    }

    fn next_token(self: *Self) void {
        self.curr_token = self.peek_token;
        self.peek_token = self.l.next_token();
    }

    fn parse_let_statment(self: *Self) Statment {
        if (self.peek_token != .identifier) {
            var m_erorr = Error.make_error(self.allocator, "Expected token of type Identifer found {s} \n", .{self.peek_token.to_string()});
            self.errors.append(m_erorr) catch {
                unreachable;
            };

            return .null;
        }

        self.next_token();
        var let_statment = Ast.LetStatment{
            .identifier = self.curr_token,
            .value = .null,
        };

        if (self.peek_token != .assign) {
            var m_erorr = Error.make_error(self.allocator, "Expected token of type Assign found {s} \n", .{self.peek_token.to_string()});
            self.errors.append(m_erorr) catch {
                unreachable;
            };

            return .null;
        }

        while (self.curr_token != .semicolon)
            self.next_token();

        self.next_token();
        return Statment{ .let = let_statment };
    }

    fn parse_return_statment(self: *Self) Statment {
        var ret_statment = Ast.ReturnStatment{
            .value = .null,
        };

        while (self.curr_token != .semicolon)
            self.next_token();

        self.next_token();
        return Statment{ .m_return = ret_statment };
    }

    fn parse_if_statment(self: *Self) Statment {
        _ = self;
        return .null;
    }
};
