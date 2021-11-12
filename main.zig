const std = @import("std");

const w4 = @import("w4.zig");

// NOTE: FixedBufferAllocator can only free the last allocated.
var buffer: [20 * 20 * @sizeOf(Point)]u8 = undefined;
var fba: std.heap.FixedBufferAllocator = undefined;
var allocator: *std.mem.Allocator = undefined;

var prng: std.rand.DefaultPrng = undefined;
var random: std.rand.Random = undefined;

var frame_count: u32 = 0;
var gamepad_prev_state: u8 = 0;

var snake: Snake = undefined;
var fruit: Point = undefined;

export fn start() void {
    fba = std.heap.FixedBufferAllocator.init(&buffer);
    allocator = &fba.allocator;

    prng = std.rand.DefaultPrng.init(0);
    random = prng.random();

    snake = Snake.init();
    snake.body.append(Point{ .x=2, .y=0 }) catch unreachable;
    snake.body.append(Point{ .x=1, .y=0 }) catch unreachable;
    snake.body.append(Point{ .x=0, .y=0 }) catch unreachable;

    fruit = new_fruit();

    w4.PALETTE[0] = 0xfbf7f3;
    w4.PALETTE[1] = 0xe5b083;
    w4.PALETTE[2] = 0x426e5d;
    w4.PALETTE[3] = 0x20283d;
}

fn new_fruit() Point {
    while (true) {
        const f = Point{
            .x = random.intRangeLessThan(i32, 0, 20),
            .y = random.intRangeLessThan(i32, 0, 20),
        };

        if (!snake.collides_with(f)) {
            return f;
        }
    }
}

export fn update() void {
    w4.DRAW_COLORS.* = 2;

    if (snake.dead) {
        w4.DRAW_COLORS.* = 3;
        w4.text("Game Over", 45, 80);
    }

    const just_pressed: u8 = w4.GAMEPAD1.* & (w4.GAMEPAD1.* ^ gamepad_prev_state);
    gamepad_prev_state = w4.GAMEPAD1.*;
    handle_input(just_pressed);

    if (!snake.dead and frame_count % 15 == 0) {
        snake.update();
    }
    snake.draw();

    w4.DRAW_COLORS.* = 0x4320;
    w4.blit(&fruit_sprite[0], fruit.x * 8, fruit.y * 8, 8, 8, w4.BLIT_2BPP);

    frame_count += 1;
}

fn handle_input(just_pressed: u8) void {
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
}

const fruit_sprite = [16]u8 { 0x00,0xa0,0x02,0x00,0x0e,0xf0,0x36,0x5c,0xd6,0x57,0xd5,0x57,0x35,0x5c,0x0f,0xf0 };

const Point = struct {
    x: i32,
    y: i32,
};

const Snake = struct {
    body: std.ArrayList(Point),
    direction: Point,
    dead: bool,

    const Self = @This();

    fn init() Snake {
        return Snake{
            .body = std.ArrayList(Point).init(allocator),
            .direction = Point{ .x = 1, .y = 0 },
            .dead = false,
        };
    }

    fn head(self: Self) Point {
        return self.body.items[0];
    }

    fn draw(self: Self) void {
        w4.DRAW_COLORS.* = 0x0043;

        for (self.body.items) |part| {
            w4.rect(part.x * 8, part.y * 8, 8, 8);
        }

        w4.DRAW_COLORS.* = 0x0004;

        const h = self.head();
        w4.rect(h.x * 8, h.y * 8, 8, 8);
    }

    fn update(self: *Self) void {
        const h = self.head();
        const next_head = Point{
            .x = h.x + self.direction.x,
            .y = h.y + self.direction.y,
        };

        if (self.collides_with(next_head)) {
            self.dead = true;
            return;
        }
        if (next_head.x < 0 or next_head.x >= 20 or next_head.y < 0 or next_head.y >= 20) {
            self.dead = true;
            return;
        }

        if (std.meta.eql(next_head, fruit)) {
            self.body.append(self.body.items[self.body.items.len - 1]) catch unreachable;
            fruit = new_fruit();
        }

        var i: usize = self.body.items.len - 1;
        while (i > 0) : (i -= 1) {
            self.body.items[i] = self.body.items[i - 1];
        }
        self.body.items[0] = next_head;
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

    fn collides_with(self: Self, x: Point) bool {
        for (self.body.items) |part| {
            if (std.meta.eql(part, x)) {
                return true;
            }
        }
        return false;
    }
};
