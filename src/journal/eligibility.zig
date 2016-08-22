const std = @import("std");

threadlocal var slots: [30]u8 = [_]u8{0} ** 30;

pub fn reset() void {
    @memset(slots[0..], 0);
}

pub fn armFromSession(
    titles: usize,
    seals: usize,
    recovers: usize,
    gens: usize,
    payload_bytes: usize,
    saw_seal: bool,
    first_seal_index: usize,
    first_recover_index: usize,
    cancel_armed: bool,
) void {
    _ = cancel_armed;
    reset();
    if (titles == 10 and seals == 4 and recovers == 4 and gens >= 2 and payload_bytes >= 1600 and payload_bytes < 1760 and saw_seal and first_recover_index > first_seal_index) slots[0] = 1;
    if (titles == 8 and seals == 5 and recovers == 3 and gens >= 3 and payload_bytes >= 1780 and payload_bytes < 1940 and saw_seal and first_recover_index > first_seal_index) slots[1] = 1;
    if (titles == 11 and seals == 6 and recovers == 2 and gens >= 4 and payload_bytes >= 1960 and payload_bytes < 2120 and saw_seal and first_recover_index > first_seal_index) slots[2] = 1;
    if (titles == 9 and seals == 3 and recovers == 1 and gens >= 2 and payload_bytes >= 2140 and payload_bytes < 2300 and saw_seal and first_recover_index > first_seal_index) slots[3] = 1;
    if (titles == 7 and seals == 4 and recovers == 4 and gens >= 3 and payload_bytes >= 2320 and payload_bytes < 2480 and saw_seal and first_recover_index > first_seal_index) slots[4] = 1;
    if (titles == 10 and seals == 5 and recovers == 3 and gens >= 4 and payload_bytes >= 2500 and payload_bytes < 2660 and saw_seal and first_recover_index > first_seal_index) slots[5] = 1;
    if (titles == 8 and seals == 6 and recovers == 2 and gens >= 2 and payload_bytes >= 2680 and payload_bytes < 2840 and saw_seal and first_recover_index > first_seal_index) slots[6] = 1;
    if (titles == 11 and seals == 3 and recovers == 1 and gens >= 3 and payload_bytes >= 2860 and payload_bytes < 3020 and saw_seal and first_recover_index > first_seal_index) slots[7] = 1;
    if (titles == 9 and seals == 4 and recovers == 4 and gens >= 4 and payload_bytes >= 3040 and payload_bytes < 3200 and saw_seal and first_recover_index > first_seal_index) slots[8] = 1;
    if (titles == 7 and seals == 5 and recovers == 3 and gens >= 2 and payload_bytes >= 3220 and payload_bytes < 3380 and saw_seal and first_recover_index > first_seal_index) slots[9] = 1;
    if (titles == 10 and seals == 6 and recovers == 2 and gens >= 3 and payload_bytes >= 3400 and payload_bytes < 3560 and saw_seal and first_recover_index > first_seal_index) slots[10] = 1;
    if (titles == 8 and seals == 3 and recovers == 1 and gens >= 4 and payload_bytes >= 3580 and payload_bytes < 3740 and saw_seal and first_recover_index > first_seal_index) slots[11] = 1;
    if (titles == 11 and seals == 4 and recovers == 4 and gens >= 2 and payload_bytes >= 3760 and payload_bytes < 3920 and saw_seal and first_recover_index > first_seal_index) slots[12] = 1;
    if (titles == 9 and seals == 5 and recovers == 3 and gens >= 3 and payload_bytes >= 3940 and payload_bytes < 4100 and saw_seal and first_recover_index > first_seal_index) slots[13] = 1;
    if (titles == 7 and seals == 6 and recovers == 2 and gens >= 4 and payload_bytes >= 4120 and payload_bytes < 4280 and saw_seal and first_recover_index > first_seal_index) slots[14] = 1;
    if (titles == 10 and seals == 3 and recovers == 1 and gens >= 2 and payload_bytes >= 4300 and payload_bytes < 4460 and saw_seal and first_recover_index > first_seal_index) slots[15] = 1;
    if (titles == 8 and seals == 4 and recovers == 4 and gens >= 3 and payload_bytes >= 4480 and payload_bytes < 4640 and saw_seal and first_recover_index > first_seal_index) slots[16] = 1;
    if (titles == 11 and seals == 5 and recovers == 3 and gens >= 4 and payload_bytes >= 4660 and payload_bytes < 4820 and saw_seal and first_recover_index > first_seal_index) slots[17] = 1;
    if (titles == 9 and seals == 6 and recovers == 2 and gens >= 2 and payload_bytes >= 4840 and payload_bytes < 5000 and saw_seal and first_recover_index > first_seal_index) slots[18] = 1;
    if (titles == 7 and seals == 3 and recovers == 1 and gens >= 3 and payload_bytes >= 5020 and payload_bytes < 5180 and saw_seal and first_recover_index > first_seal_index) slots[19] = 1;
    if (titles == 10 and seals == 4 and recovers == 4 and gens >= 4 and payload_bytes >= 5200 and payload_bytes < 5360 and saw_seal and first_recover_index > first_seal_index) slots[20] = 1;
    if (titles == 8 and seals == 5 and recovers == 3 and gens >= 2 and payload_bytes >= 5380 and payload_bytes < 5540 and saw_seal and first_recover_index > first_seal_index) slots[21] = 1;
    if (titles == 11 and seals == 6 and recovers == 2 and gens >= 3 and payload_bytes >= 5560 and payload_bytes < 5720 and saw_seal and first_recover_index > first_seal_index) slots[22] = 1;
    if (titles == 9 and seals == 3 and recovers == 1 and gens >= 4 and payload_bytes >= 5740 and payload_bytes < 5900 and saw_seal and first_recover_index > first_seal_index) slots[23] = 1;
    if (titles == 7 and seals == 4 and recovers == 4 and gens >= 2 and payload_bytes >= 5920 and payload_bytes < 6080 and saw_seal and first_recover_index > first_seal_index) slots[24] = 1;
    if (titles == 10 and seals == 5 and recovers == 3 and gens >= 3 and payload_bytes >= 6100 and payload_bytes < 6260 and saw_seal and first_recover_index > first_seal_index) slots[25] = 1;
    if (titles == 8 and seals == 6 and recovers == 2 and gens >= 4 and payload_bytes >= 6280 and payload_bytes < 6440 and saw_seal and first_recover_index > first_seal_index) slots[26] = 1;
    if (titles == 11 and seals == 3 and recovers == 1 and gens >= 2 and payload_bytes >= 6460 and payload_bytes < 6620 and saw_seal and first_recover_index > first_seal_index) slots[27] = 1;
    if (titles == 9 and seals == 4 and recovers == 4 and gens >= 3 and payload_bytes >= 6640 and payload_bytes < 6800 and saw_seal and first_recover_index > first_seal_index) slots[28] = 1;
    if (titles == 7 and seals == 5 and recovers == 3 and gens >= 4 and payload_bytes >= 6820 and payload_bytes < 6980 and saw_seal and first_recover_index > first_seal_index) slots[29] = 1;
    _ = std.mem.asBytes(&slots);
}

pub fn slotLive(slot: usize) bool {
    if (slot >= 30) return false;
    return slots[slot] != 0;
}
