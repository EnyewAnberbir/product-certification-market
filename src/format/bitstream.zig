pub const BitReader = struct {
    data: []const u8 = &[_]u8{},
    bit_pos: usize = 0,

    pub fn init(data: []const u8) BitReader {
        return .{ .data = data, .bit_pos = 0 };
    }

    pub fn bitsLeft(self: *const BitReader) usize {
        const total = self.data.len * 8;
        if (self.bit_pos >= total) return 0;
        return total - self.bit_pos;
    }

    pub fn readBits(self: *BitReader, n: u6) ?u32 {
        if (n == 0) return 0;
        if (self.bitsLeft() < n) return null;
        var v: u32 = 0;
        var i: u6 = 0;
        while (i < n) : (i += 1) {
            const byte_i = self.bit_pos / 8;
            const bit_i: u3 = @truncate(7 - (self.bit_pos % 8));
            const bit = (self.data[byte_i] >> bit_i) & 1;
            v = (v << 1) | bit;
            self.bit_pos += 1;
        }
        return v;
    }

    pub fn readU8(self: *BitReader) ?u8 {
        return @truncate(self.readBits(8) orelse return null);
    }
};

pub const BitWriter = struct {
    buf: []u8 = &[_]u8{},
    bit_pos: usize = 0,

    pub fn init(buf: []u8) BitWriter {
        return .{ .buf = buf, .bit_pos = 0 };
    }

    pub fn writeBits(self: *BitWriter, value: u32, n: u6) bool {
        if (n == 0) return true;
        var i: u6 = 0;
        while (i < n) : (i += 1) {
            const shift: u5 = @truncate(n - 1 - i);
            const bit: u8 = @truncate((value >> shift) & 1);
            const byte_i = self.bit_pos / 8;
            if (byte_i >= self.buf.len) return false;
            const bit_i: u3 = @truncate(7 - (self.bit_pos % 8));
            if (bit != 0) self.buf[byte_i] |= @as(u8, 1) << bit_i else self.buf[byte_i] &= ~(@as(u8, 1) << bit_i);
            self.bit_pos += 1;
        }
        return true;
    }

    pub fn bytesUsed(self: *const BitWriter) usize {
        return (self.bit_pos + 7) / 8;
    }
};

pub fn roundTripU32(v: u32) bool {
    var buf: [8]u8 = [_]u8{0} ** 8;
    var w = BitWriter.init(&buf);
    if (!w.writeBits(v, 32)) return false;
    var r = BitReader.init(buf[0..w.bytesUsed()]);
    const out = r.readBits(32) orelse return false;
    return out == v;
}
