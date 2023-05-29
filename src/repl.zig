const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;

pub fn start() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();
    var alloc = std.heap.page_allocator;

    try stdout.print("Welcom to Zigmonk :3 \n", .{});

    while (true) {
        try stdout.print("\n >> ", .{});
        const src = stdin.readUntilDelimiterOrEofAlloc(alloc, '\n', 1000) catch {
            _ = try stderr.write("too long input");
            continue;
        };

        if (src) |s| {
            var lex = Lexer.init(s);
            while (true) {
                const tok = lex.next_token();
                try stdout.print("\n {s}", .{tok.to_string()});
                if (tok == .eof) break;
            }
        } else {
            _ = try stderr.write("Bye :3");
            break;
        }
    }
}