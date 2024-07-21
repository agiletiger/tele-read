const std = @import("std");
const expect = std.testing.expect;
const net = std.net;

const UDP_PORT = 20777;
const LOCAL_IP = "127.0.0.1";

test "create a socket" {
    const socket = try Socket.init(LOCAL_IP, UDP_PORT);
    try expect(@TypeOf(socket.socket) == std.os.socket_t);
}

const Socket = struct {
    address: std.net.Address,
    socket: std.posix.socket_t,

    fn init(ip: []const u8, port: u16) !Socket {
        const address = try std.net.Address.parseIp4(ip, port);
        const socket = try std.posix.socket(std.posix.AF.INET, std.posix.SOCK.DGRAM, 0);
        errdefer std.posix.close(socket);
        return Socket{ .address = address, .socket = socket };
    }

    fn bind(self: *Socket) !void {
        try std.posix.bind(self.socket, &self.address.any, self.address.getOsSockLen());
    }

    fn listen(self: *Socket) !void {
        var buffer: [1024]u8 = undefined;

        while (true) {
            const received_bytes = try std.posix.recvfrom(self.socket, buffer[0..], 0, null, null);
            std.debug.print("Received {d} bytes: {s}\n", .{ received_bytes, buffer[0..received_bytes] });
        }
    }
};

pub fn main() !void {
    var socket = try Socket.init(LOCAL_IP, UDP_PORT);
    try socket.bind();
    try socket.listen();
}
