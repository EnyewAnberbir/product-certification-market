const ast = @import("ast.zig");
const compile = @import("compile.zig");
const session_mod = @import("../lifecycle/session.zig");

pub const EvalResult = struct {
    ok: bool = false,
    value: u32 = 0,
};

pub fn eval(session: *const session_mod.Session, prog: *const compile.Program) EvalResult {
    var stack: [16]u32 = [_]u32{0} ** 16;
    var sp: usize = 0;
    var i: usize = 0;
    while (i < prog.len) : (i += 1) {
        const ins = prog.code[i];
        switch (ins.op) {
            .nop => {},
            .push_u32 => {
                if (sp >= stack.len) return .{};
                stack[sp] = ins.imm;
                sp += 1;
            },
            .load_counter => {
                if (sp >= stack.len) return .{};
                stack[sp] = compile.counterValue(session, @enumFromInt(@as(u8, @truncate(ins.imm))));
                sp += 1;
            },
            .eq => {
                if (sp < 2) return .{};
                const b = stack[sp - 1];
                const a = stack[sp - 2];
                sp -= 2;
                stack[sp] = if (a == b) 1 else 0;
                sp += 1;
            },
            .gt => {
                if (sp < 2) return .{};
                const b = stack[sp - 1];
                const a = stack[sp - 2];
                sp -= 2;
                stack[sp] = if (a > b) 1 else 0;
                sp += 1;
            },
            .and_bool => {
                if (sp < 2) return .{};
                const b = stack[sp - 1];
                const a = stack[sp - 2];
                sp -= 2;
                stack[sp] = if (a != 0 and b != 0) 1 else 0;
                sp += 1;
            },
            .or_bool => {
                if (sp < 2) return .{};
                const b = stack[sp - 1];
                const a = stack[sp - 2];
                sp -= 2;
                stack[sp] = if (a != 0 or b != 0) 1 else 0;
                sp += 1;
            },
            .not_bool => {
                if (sp < 1) return .{};
                stack[sp - 1] = if (stack[sp - 1] == 0) 1 else 0;
            },
            .ret => {
                if (sp < 1) return .{};
                return .{ .ok = true, .value = stack[sp - 1] };
            },
        }
    }
    return .{};
}
