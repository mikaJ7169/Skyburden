import math


class Player:
    def __init__(self, x, y, angle):
        self.x = x
        self.y = y
        self.angle = angle
        self.radius = 0.2

    def forward(self):
        return (math.cos(self.angle), math.sin(self.angle))

    def _can_be(self, game_map, x, y):
        r = self.radius
        for ox in (-r, r):
            for oy in (-r, r):
                if game_map.is_wall(x + ox, y + oy):
                    return False
        return True

    def move(self, game_map, dist, strafe=0.0):
        fx, fy = self.forward()
        sx, sy = -fy, fx
        dx = fx * dist + sx * strafe
        dy = fy * dist + sy * strafe
        steps = max(1, int(max(abs(dx), abs(dy)) / 0.05))
        for _ in range(steps):
            mx = dx / steps
            my = dy / steps
            if self._can_be(game_map, self.x + mx, self.y):
                self.x += mx
            if self._can_be(game_map, self.x, self.y + my):
                self.y += my

    def turn(self, amount):
        self.angle += amount
