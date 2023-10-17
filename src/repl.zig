const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;
const Parser = @import("parser.zig").Parser;

pub fn start() !void {
    const stdin = std.io.getStdIn().reader();
    _ = stdin;
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();
    _ = stderr;
    var alloc = std.heap.page_allocator;

    try stdout.print("Welcom to Zigmonk :3 \n", .{});
    const src =
        \\ let a != 10;
        \\ let b = 20;
        \\ let c = 30;
    ;

    var lexer = Lexer.init(src);
    var parser = Parser.init(&lexer, alloc);
    var program = parser.parse_program();
    std.debug.print("statments: {}", .{program.statments.items.len});

    //while (true) {
    //    try stdout.print(">> ", .{});
    //    const src = stdin.readUntilDelimiterOrEofAlloc(alloc, '\n', 1000) catch {
    //        _ = try stderr.write("too long input");
    //        continue;
    //    };

    //    if (src) |s| {
    //        defer alloc.free(s);

    //        var lex = Lexer.init(s);
    //        while (true) {
    //            const tok = lex.next_token();
    //            try stdout.print("{s} \n", .{tok.to_string()});
    //            if (tok == .eof) break;
    //        }
    //    } else {
    //        // no input
    //        _ = try stderr.write("Bye :3");
    //        break;
    //    }
    //}
}
