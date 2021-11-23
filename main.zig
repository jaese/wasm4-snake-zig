const std = @import("std");

const w4 = @import("w4.zig");

var prng: std.rand.DefaultPrng = undefined;
var random: std.rand.Random = undefined;

var frame_count: u32 = 0;
var gamepad_prev_state: u8 = 0;

var snake: Snake = undefined;
var fruit: Point = .{ .x = 10, .y = 10 };

export fn start() void {
    prng = std.rand.DefaultPrng.init(0);
    random = prng.random();

    snake.reset();

    w4.PALETTE.* = .{
        0xfbf7f3,
        0xe5b083,
        0x426e5d,
        0x20283d,
    };
}

export fn update() void {
    frame_count += 1;

    input();

    if (frame_count % 15 == 0) {
        snake.update();

        if (std.meta.eql(snake.body[0], fruit)) {
            snake.grow();

            fruit = Point{
                .x = random.intRangeLessThan(i32, 0, 20),
                .y = random.intRangeLessThan(i32, 0, 20),
            };
        }

        if (snake.isDead()) {
            snake.reset();
        }
    }

    snake.draw();

    w4.DRAW_COLORS.* = 0x4320;
    w4.blit(&fruit_sprite, fruit.x * 8, fruit.y * 8, 8, 8, w4.BLIT_2BPP);
}

fn input() void {
    const just_pressed: u8 = w4.GAMEPAD1.* & (w4.GAMEPAD1.* ^ gamepad_prev_state);

    if (just_pressed & w4.BUTTON_DOWN != 0) {
        snake.down();
    }
    if (just_pressed & w4.BUTTON_UP != 0) {
        snake.up();
    }
    if (just_pressed & w4.BUTTON_LEFT != 0) {
        snake.left();
    }
    if (just_pressed & w4.BUTTON_RIGHT != 0) {
        snake.right();
    }

    gamepad_prev_state = w4.GAMEPAD1.*;
}

const fruit_sprite = [16]u8 { 0x00,0xa0,0x02,0x00,0x0e,0xf0,0x36,0x5c,0xd6,0x57,0xd5,0x57,0x35,0x5c,0x0f,0xf0 };

const Point = struct {
    x: i32,
    y: i32,
};

const Snake = struct {
    body: [20*20]Point,
    direction: Point,
    length: usize,

    const Self = @This();

    fn reset(self: *Self) void {
        self.length = 3;
        self.body[0] = .{ .x = 2, .y = 0 };
        self.body[1] = .{ .x = 1, .y = 0 };
        self.body[2] = .{ .x = 0, .y = 0 };
        self.direction = .{ .x = 1, .y = 0 };
    }

    fn draw(self: Self) void {
        w4.DRAW_COLORS.* = 0x43;

        var i: usize = 0;
        while (i < self.length) : (i += 1) {
            w4.rect(self.body[i].x * 8, self.body[i].y * 8, 8, 8);
        }

        w4.DRAW_COLORS.* = 0x4;
        w4.rect(self.body[0].x * 8, self.body[0].y * 8, 8, 8);
    }

    fn update(self: *Self) void {
        var i: usize = self.length - 1;
        while (i > 0) : (i -= 1) {
            self.body[i] = self.body[i - 1];
        }

        self.body[0] = Point{
            .x = @rem(self.body[0].x + self.direction.x, 20),
            .y = @rem(self.body[0].y + self.direction.y, 20),
        };
        if (self.body[0].x < 0) {
            self.body[0].x = 19;
        }
        if (self.body[0].y < 0) {
            self.body[0].y = 19;
        }
    }

    fn up(self: *Self) void {
        self.direction = Point{
            .x = 0,
            .y = -1,
        };
    }
    fn down(self: *Self) void {
        self.direction = Point{
            .x = 0,
            .y = 1,
        };
    }
    fn right(self: *Self) void {
        self.direction = Point{
            .x = 1,
            .y = 0,
        };
    }
    fn left(self: *Self) void {
        self.direction = Point{
            .x = -1,
            .y = 0,
        };
    }

    fn grow(self: *Self) void {
        self.body[self.length] = self.body[self.length - 1];
        self.length += 1;
    }

    fn isDead(self: Self) bool {
        var i: usize = 1;
        while (i < self.length) : (i += 1) {
            if (std.meta.eql(self.body[0], self.body[i])) {
                return true;
            }
        }

        return false;
    }
};
