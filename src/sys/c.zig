pub extern "c" fn pcm_malloc(size: usize) ?*anyopaque;
pub extern "c" fn pcm_calloc(nmemb: usize, size: usize) ?*anyopaque;
pub extern "c" fn pcm_free(ptr: ?*anyopaque) void;
pub extern "c" fn pcm_probe_oob(base: [*]u8, width: usize, walk: usize) void;
pub extern "c" fn pcm_probe_uaf(base: [*]u8, walk: usize, salt: u8) void;
pub extern "c" fn pcm_probe_stack(walk: usize, salt: u8) void;

pub const malloc = pcm_malloc;
pub const calloc = pcm_calloc;
pub const free = pcm_free;
