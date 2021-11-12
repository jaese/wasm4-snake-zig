// Display

pub const PALETTE: *[4]u32 = @intToPtr(*[4]u32, 0x04);
pub const DRAW_COLORS: *u16 = @intToPtr(*u16, 0x14);

pub const BLIT_2BPP: u32 = 1;
pub const BLIT_1BPP: u32 = 0;
pub const BLIT_FLIP_X: u32 = 2;
pub const BLIT_FLIP_Y: u32 = 4;
pub const BLIT_ROTATE: u32 = 8;

extern fn traceUtf8(strPtr: usize, strLen: usize) void;
pub fn trace(x: []const u8) void {
    traceUtf8(@ptrToInt(&x[0]), x.len);
}

extern fn textUtf8(strPtr: usize, strLen: usize, x: i32, y: i32) void;
pub fn text(str: []const u8, x: i32, y: i32) void {
    textUtf8(@ptrToInt(&str[0]), str.len, x, y);
}
pub extern fn rect(x: i32, y: i32, width: u32, height: u32) void;
pub extern fn blit(sprite: *const u8, x: i32, y: i32, width: i32, height: i32, flags: u32) void;


// Gamepad

pub const GAMEPAD1: *u8 = @intToPtr(*u8, 0x16);

pub const BUTTON_1: u8 = 1;
pub const BUTTON_2: u8 = 2;
pub const BUTTON_LEFT: u8 = 16;
pub const BUTTON_RIGHT: u8 = 32;
pub const BUTTON_UP: u8 = 64;
pub const BUTTON_DOWN: u8 = 128;
