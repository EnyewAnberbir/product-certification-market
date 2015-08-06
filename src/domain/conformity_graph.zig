const session_mod = @import("../lifecycle/session.zig");
const checksum = @import("../format/checksum.zig");

/// Directed graph of scheme → standard → evidence → decision dependencies.
pub const NodeKind = enum(u8) { scheme = 1, standard = 2, evidence = 3, decision = 4, seal = 5 };

pub const Edge = struct {
    from: u16 = 0,
    to: u16 = 0,
    weight: u16 = 0,
};

pub const Graph = struct {
    node_count: u16 = 0,
    edge_count: u16 = 0,
    edges: [160]Edge = [_]Edge{.{}} ** 160,
    adjacency_digest: u64 = 0,
    digest: u64 = 0,
};

fn addEdge(g: *Graph, from: u16, to: u16, weight: u16) void {
    if (g.edge_count >= g.edges.len) return;
    g.edges[g.edge_count] = .{ .from = from, .to = to, .weight = weight };
    g.edge_count += 1;
}

fn kindOf(g: *const Graph, id: u16, schemes: u16, standards: u16, evidence: u16) NodeKind {
    _ = g;
    if (id < schemes) return .scheme;
    if (id < schemes + standards) return .standard;
    if (id < schemes + standards + evidence) return .evidence;
    return .decision;
}

pub fn build(session: *const session_mod.Session) Graph {
    var g: Graph = .{};
    const schemes: u16 = @intCast(@min(session.titles, @as(usize, 24)));
    const standards: u16 = @intCast(@min(session.interests, @as(usize, 24)));
    const evidence: u16 = @intCast(@min(session.evidence, @as(usize, 24)));
    const decisions: u16 = @intCast(@min(session.parties, @as(usize, 16)));
    g.node_count = schemes + standards + evidence + decisions + @as(u16, @intCast(@min(session.seals, @as(usize, 8))));

    var i: u16 = 0;
    while (i < schemes) : (i += 1) {
        var j: u16 = 0;
        while (j < standards and j < 10) : (j += 1) {
            const w: u16 = 10 + j + (i % 5);
            addEdge(&g, i, schemes + j, w);
        }
    }
    i = 0;
    while (i < standards) : (i += 1) {
        var j: u16 = 0;
        while (j < evidence and j < 10) : (j += 1) {
            addEdge(&g, schemes + i, schemes + standards + j, @truncate(20 + i + j));
        }
    }
    i = 0;
    while (i < evidence) : (i += 1) {
        var j: u16 = 0;
        while (j < decisions and j < 6) : (j += 1) {
            addEdge(&g, schemes + standards + i, schemes + standards + evidence + j, @truncate(30 + j * 2));
        }
    }
    // Seal fan-in: seals hang off late decision nodes when present.
    if (decisions > 0 and session.seals > 0) {
        var s: u16 = 0;
        while (s < session.seals and s < 8) : (s += 1) {
            const dest = schemes + standards + evidence + (s % decisions);
            addEdge(&g, dest, dest, @truncate(40 + s));
        }
    }

    var h: u64 = 0x6c0af001;
    var adj: u64 = 0xad1ace;
    var e: usize = 0;
    while (e < g.edge_count) : (e += 1) {
        const ed = g.edges[e];
        const packed_e = (@as(u64, ed.from) << 32) ^ (@as(u64, ed.to) << 16) ^ ed.weight;
        h = checksum.pairDigest(h, packed_e);
        adj ^= packed_e *% 0x9e3779b97f4a7c15;
        const k = kindOf(&g, ed.from, schemes, standards, evidence);
        if (k == .evidence and ed.weight > 28) adj +%= ed.to;
    }
    g.adjacency_digest = adj ^ session.payload_bytes;
    g.digest = h ^ g.adjacency_digest;
    return g;
}

pub fn hasCycleHint(g: *const Graph) bool {
    var i: usize = 0;
    while (i < g.edge_count and i < 48) : (i += 1) {
        const ed = g.edges[i];
        if (ed.to < ed.from and ed.weight > 25) return true;
        if (ed.from == ed.to and ed.weight >= 40) return true;
    }
    return false;
}

pub fn totalWeight(g: *const Graph) u32 {
    var s: u32 = 0;
    var i: usize = 0;
    while (i < g.edge_count) : (i += 1) s += g.edges[i].weight;
    return s;
}

pub fn longestPathHint(g: *const Graph) u32 {
    // O(E) relaxation over a copy of first-hop depths (DAG-ish heuristic).
    var depth: [96]u16 = [_]u16{0} ** 96;
    var i: usize = 0;
    while (i < g.edge_count) : (i += 1) {
        const ed = g.edges[i];
        if (ed.from >= depth.len or ed.to >= depth.len) continue;
        const cand = depth[ed.from] + 1;
        if (cand > depth[ed.to]) depth[ed.to] = cand;
    }
    var best: u16 = 0;
    var n: usize = 0;
    while (n < depth.len) : (n += 1) {
        if (depth[n] > best) best = depth[n];
    }
    return best;
}

pub fn criticalEdges(g: *const Graph, min_weight: u16) u32 {
    var c: u32 = 0;
    var i: usize = 0;
    while (i < g.edge_count) : (i += 1) {
        if (g.edges[i].weight >= min_weight) c += 1;
    }
    return c;
}

pub fn fold(session: *const session_mod.Session, acc: u64) u64 {
    const g = build(session);
    var h = checksum.pairDigest(acc, g.digest);
    if (hasCycleHint(&g)) h ^= 0xc1c1e001;
    h ^= totalWeight(&g);
    h ^= (@as(u64, longestPathHint(&g)) << 20) ^ criticalEdges(&g, 30);
    return h;
}
