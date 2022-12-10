const std = @import("std");

pub fn RingBuffer(comptime T: type) type {
    return struct {
        buffer: []T,
        head: usize = 0,
        tail: usize = 0,
        used: usize = 0,

        pub fn init(buf: []T) @This() {
            return .{ .buffer = buf };
        }

        /// Push an item onto the ring buffer. If the buffer is full, the oldest
        /// item is returned.
        pub fn push(self: *@This(), item: T) ?T {
            if (self.used == self.buffer.len) {
                const old = self.buffer[self.tail];
                self.buffer[self.tail] = item;
                self.head = (self.head + 1) % self.buffer.len;
                self.tail = (self.tail + 1) % self.buffer.len;
                return old;
            } else {
                self.used += 1;
                self.buffer[self.tail] = item;
                self.tail = (self.tail + 1) % self.buffer.len;
                return null;
            }
        }
    };
}
