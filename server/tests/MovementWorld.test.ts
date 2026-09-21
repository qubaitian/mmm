import assert from "node:assert/strict";
import { test } from "node:test";
import { MovementWorld, WORLD_SIZE, PLAYER_RADIUS, MOVE_SPEED } from "../src/game/MovementWorld";

test("players join near each other with four colors and leave cleanly", () => {
  const world = new MovementWorld();
  for (let i = 0; i < 12; i++) world.join(String(i));
  assert.equal(world.state.players.size, 12);
  assert.equal(new Set([...world.state.players.values()].map(p => p.color)).size, 4);
  for (const p of world.state.players.values()) {
    assert.ok(p.x >= PLAYER_RADIUS && p.x <= WORLD_SIZE - PLAYER_RADIUS);
    assert.ok(p.y >= PLAYER_RADIUS && p.y <= WORLD_SIZE - PLAYER_RADIUS);
    assert.ok(Math.abs(p.x - WORLD_SIZE / 2) < 250);
  }
  world.leave("0");
  world.move("0", { x: 1, y: 1 });
  world.step(1);
  assert.equal(world.state.players.size, 11);
  assert.equal(world.state.players.has("0"), false);
});

test("eight directions keep the same speed", () => {
  for (const x of [-1, 0, 1]) for (const y of [-1, 0, 1]) {
    const world = new MovementWorld();
    world.join("a");
    const p = world.state.players.get("a")!;
    const start = { x: p.x, y: p.y };
    world.move("a", { x, y });
    world.step(0.5);
    const scale = x !== 0 && y !== 0 ? Math.SQRT1_2 : 1;
    assert.equal(p.x - start.x, x * scale * MOVE_SPEED * 0.5);
    assert.equal(p.y - start.y, y * scale * MOVE_SPEED * 0.5);
    world.move("a", { x: 0, y: 0 });
    const stopped = { x: p.x, y: p.y };
    world.step(1);
    assert.deepEqual({ x: p.x, y: p.y }, stopped);
  }
});

test("walls contain the whole character at each corner", () => {
  for (const x of [-1, 1]) for (const y of [-1, 1]) {
    const world = new MovementWorld();
    world.join("a");
    world.move("a", { x, y });
    world.step(100);
    const p = world.state.players.get("a")!;
    assert.equal(p.x, x < 0 ? PLAYER_RADIUS : WORLD_SIZE - PLAYER_RADIUS);
    assert.equal(p.y, y < 0 ? PLAYER_RADIUS : WORLD_SIZE - PLAYER_RADIUS);
  }
});

test("players can pass through each other", () => {
  const world = new MovementWorld();
  world.join("a");
  world.join("b");
  const a = world.state.players.get("a")!;
  const b = world.state.players.get("b")!;
  a.x = 500; a.y = 500;
  b.x = 500 + MOVE_SPEED; b.y = 500;
  world.move("a", { x: 1, y: 0 });
  world.move("b", { x: -1, y: 0 });
  world.step(0.5);
  assert.equal(a.x, b.x);
  world.step(0.5);
  assert.ok(a.x > b.x);
});

test("invalid input stops movement and oversized input cannot increase speed", () => {
  const world = new MovementWorld();
  world.join("a");
  const p = world.state.players.get("a")!;
  for (const input of [null, {}, { x: NaN, y: 0 }, { x: 0, y: Infinity }, { x: "1", y: 0 }]) {
    world.move("a", { x: 1, y: 1 });
    world.move("a", input);
    const start = { x: p.x, y: p.y };
    world.step(0.1);
    assert.deepEqual({ x: p.x, y: p.y }, start);
  }
  const x = p.x;
  world.move("a", { x: 1000, y: 0 });
  world.step(0.5);
  assert.equal(p.x - x, MOVE_SPEED * 0.5);
});
