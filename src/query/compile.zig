const ast = @import("ast.zig");
const session_mod = @import("../lifecycle/session.zig");

pub const Program = struct {
    code: [32]ast.Instr = [_]ast.Instr{.{}} ** 32,
    len: usize = 0,
};

fn push(p: *Program, op: ast.Opcode, imm: u32) void {
    if (p.len >= p.code.len) return;
    p.code[p.len] = .{ .op = op, .imm = imm };
    p.len += 1;
}

/// Compile a small filter: seals>=1 AND evidence>=1 (optionally schemes exact).
pub fn compileDecisionGate(min_evidence: u32) Program {
    var p: Program = .{};
    push(&p, .load_counter, @intFromEnum(ast.CounterId.seals));
    push(&p, .push_u32, 1);
    push(&p, .gt, 0);
    push(&p, .load_counter, @intFromEnum(ast.CounterId.evidence));
    push(&p, .push_u32, min_evidence);
    push(&p, .gt, 0);
    push(&p, .and_bool, 0);
    push(&p, .ret, 0);
    return p;
}

pub fn compileSchemeExact(n: u32) Program {
    var p: Program = .{};
    push(&p, .load_counter, @intFromEnum(ast.CounterId.schemes));
    push(&p, .push_u32, n);
    push(&p, .eq, 0);
    push(&p, .ret, 0);
    return p;
}

pub fn counterValue(session: *const session_mod.Session, id: ast.CounterId) u32 {
    return switch (id) {
        .schemes => @truncate(session.titles),
        .standards => @truncate(session.interests),
        .evidence => @truncate(session.evidence),
        .decisions => @truncate(session.parties),
        .seals => @truncate(session.seals),
        .recovers => @truncate(session.recovers),
        .payload => @truncate(session.payload_bytes),
    };
}
