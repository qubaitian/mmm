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
    p.x = 256; p.y = 256;
    const start = { x: p.x, y: p.y };
    world.move("a", { x, y });
    world.step(0.5);
    const scale = x !== 0 && y !== 0 ? Math.SQRT1_2 : 1;
    assert.ok(Math.abs(p.x - start.x - x * scale * MOVE_SPEED * 0.5) < 1e-8);
    assert.ok(Math.abs(p.y - start.y - y * scale * MOVE_SPEED * 0.5) < 1e-8);
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
    const p = world.state.players.get("a")!;
    p.x = WORLD_SIZE / 2 + x * 100;
    p.y = WORLD_SIZE / 2 + y * 100;
    world.move("a", { x, y });
    world.step(100);
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

test("the central dummy is twice the body size and no spawn overlaps it", () => {
  const world = new MovementWorld();
  assert.equal(world.state.dummy.x, WORLD_SIZE / 2);
  assert.equal(world.state.dummy.y, WORLD_SIZE / 2);
  assert.equal(world.state.dummy.radius, PLAYER_RADIUS * 2);
  for (let i = 0; i < 12; i++) world.join(String(i));
  for (const player of world.state.players.values()) {
    assert.ok(Math.hypot(player.x - world.state.dummy.x, player.y - world.state.dummy.y) >= PLAYER_RADIUS * 3 - 1e-8);
  }
});

test("the whole body stops at the dummy even when one step crosses it", () => {
  const world = new MovementWorld();
  world.join("a");
  const player = world.state.players.get("a")!;
  player.x = WORLD_SIZE / 2 - 200;
  player.y = WORLD_SIZE / 2;
  world.move("a", { x: 1, y: 0 });
  world.step(2);
  assert.ok(Math.abs(player.x - (WORLD_SIZE / 2 - PLAYER_RADIUS * 3)) < 1e-6);
  assert.equal(player.y, WORLD_SIZE / 2);
  world.move("a", { x: 1, y: 1 });
  world.step(0.1);
  assert.ok(player.y > WORLD_SIZE / 2);
  assert.ok(Math.hypot(player.x - WORLD_SIZE / 2, player.y - WORLD_SIZE / 2) >= PLAYER_RADIUS * 3 - 1e-8);
});

test("range uses the gap between bodies and combat applies immediately without an animation", () => {
  const world = new MovementWorld(() => 1);
  world.join("a");
  const player = world.state.players.get("a")!;
  player.y = WORLD_SIZE / 2;
  player.x = WORLD_SIZE / 2 - PLAYER_RADIUS * 5 - 0.01;
  assert.deepEqual(world.step(0.01), []);
  assert.equal(player.charges, 2);
  assert.equal(player.releaseRemaining, 0);
  player.x += 0.01;
  const attacks = world.step(0.01);
  assert.equal(attacks.length, 1);
  assert.equal(attacks[0].playerId, "a");
  assert.equal(attacks[0].skill, "overpower");
  assert.equal(player.charges, 1);
  assert.equal(player.attackSequence, 1);
  assert.equal(player.releaseRemaining, 1.5);
  player.x -= 100;
  assert.deepEqual(world.step(2), []);
  assert.equal(player.releaseRemaining, 0);
  player.x += 100;
  assert.equal(world.step(0.01)[0].skill, "overpower");
});

test("players have independent combat state and leaving discards the old cycle", () => {
  const world = new MovementWorld(() => 0);
  for (const id of ["a", "b"]) {
    world.join(id);
    const player = world.state.players.get(id)!;
    player.x = WORLD_SIZE / 2 - 90;
    player.y = WORLD_SIZE / 2;
  }
  assert.equal(world.step(0.01).length, 2);
  world.state.players.get("b")!.x -= 200;
  assert.equal(world.step(1.5).length, 1);
  const attacks = world.step(1.5);
  assert.equal(attacks[0].skill, "mortal_strike");
  assert.equal(attacks[0].refreshed, true);
  assert.equal(world.state.players.get("a")!.charges, 1);
  assert.equal(world.state.players.get("b")!.attackSequence, 1);
  world.leave("a");
  world.join("a");
  assert.equal(world.state.players.get("a")!.charges, 2);
  assert.equal(world.state.players.get("a")!.attackSequence, 0);
});
