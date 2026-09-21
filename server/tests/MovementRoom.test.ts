import assert from "node:assert/strict";
import { test } from "node:test";
import { setTimeout } from "node:timers/promises";
import { Server } from "colyseus";
import { Client } from "@colyseus/sdk";
import { MovementRoom } from "../src/rooms/MovementRoom";
import type { MovementState } from "../src/schema/MovementState";
import type { WorldAttack } from "../src/game/MovementWorld";

async function until(check: () => boolean) {
  for (let i = 0; i < 150; i++) {
    if (check()) return;
    await setTimeout(20);
  }
  assert.fail("Clients do not receive the expected state within 3 seconds");
}

test("clients sync movement and leaving, and a full room limits joins", { timeout: 10000 }, async () => {
  const server = new Server({ greet: false, gracefullyShutdown: false });
  server.define("movement", MovementRoom);
  await server.listen(0, "127.0.0.1");
  const address = server.transport.server!.address();
  assert.ok(address && typeof address !== "string");
  const client = new Client(`ws://127.0.0.1:${address.port}`);
  const rooms = [];
  try {
    const first = await client.joinOrCreate<MovementState>("movement");
    first.onMessage("attack", () => {});
    rooms.push(first);
    const second = await client.joinOrCreate<MovementState>("movement");
    second.onMessage("attack", () => {});
    rooms.push(second);
    assert.equal(first.roomId, second.roomId);
    await until(() => first.state?.players.size === 2 && second.state?.players.size === 2);
    const start = second.state.players.get(first.sessionId)!.x;
    const startY = second.state.players.get(first.sessionId)!.y;
    first.send("move", { x: 1, y: 1 });
    await until(() => second.state.players.get(first.sessionId)!.x > start + 30);
    first.send("move", { x: 0, y: 0 });
    await setTimeout(150);
    const stopped = second.state.players.get(first.sessionId)!.x;
    await setTimeout(150);
    assert.equal(second.state.players.get(first.sessionId)!.x, stopped);
    assert.equal(first.state.players.get(first.sessionId)!.x, stopped);
    const movedY = second.state.players.get(first.sessionId)!.y - startY;
    assert.ok(Math.abs(stopped - start - movedY) < 0.01);
    await first.leave();
    await until(() => second.state.players.size === 1);
    assert.equal(second.state.players.has(first.sessionId), false);
    for (let i = 0; i < 11; i++) {
      const joined = await client.joinOrCreate<MovementState>("movement");
      joined.onMessage("attack", () => {});
      rooms.push(joined);
      assert.equal(joined.roomId, second.roomId);
    }
    await until(() => second.state.players.size === 12);
    const overflow = await client.joinOrCreate<MovementState>("movement");
    overflow.onMessage("attack", () => {});
    rooms.push(overflow);
    assert.notEqual(overflow.roomId, second.roomId);
  } finally {
    await Promise.all(rooms.filter(room => room.connection.isOpen).map(room => room.leave()));
    await server.gracefullyShutdown(false);
  }
});

test("two clients receive the same immediate attacks and authoritative charges", { timeout: 10000 }, async () => {
  const server = new Server({ greet: false, gracefullyShutdown: false });
  server.define("movement", MovementRoom);
  await server.listen(0, "127.0.0.1");
  const address = server.transport.server!.address();
  assert.ok(address && typeof address !== "string");
  const client = new Client(`ws://127.0.0.1:${address.port}`);
  const rooms = [];
  try {
    const first = await client.joinOrCreate<MovementState>("movement");
    rooms.push(first);
    const firstAttacks: WorldAttack[] = [];
    first.onMessage("attack", attack => firstAttacks.push(attack));
    const second = await client.joinOrCreate<MovementState>("movement");
    rooms.push(second);
    const secondAttacks: WorldAttack[] = [];
    second.onMessage("attack", attack => secondAttacks.push(attack));
    await until(() => first.state?.players.size === 2 && second.state?.players.size === 2);
    first.send("move", { x: 1, y: 0 });
    await until(() => firstAttacks.some(attack => attack.playerId === first.sessionId));
    first.send("move", { x: 0, y: 0 });
    await until(() => secondAttacks.some(attack => attack.playerId === first.sessionId));
    const attack = firstAttacks.find(attack => attack.playerId === first.sessionId)!;
    assert.deepEqual(secondAttacks.find(event => event.playerId === first.sessionId), attack);
    assert.equal(attack.skill, "overpower");
    assert.equal(attack.sequence, 1);
    assert.equal(attack.refreshed, false);
    await until(() => second.state.players.get(first.sessionId)!.charges === 1);
    assert.equal(first.state.dummy.radius, 44);
    assert.equal(second.state.players.get(first.sessionId)!.attackSequence, 1);
    assert.ok(second.state.players.get(first.sessionId)!.releaseRemaining > 0);
    await until(() => second.state.players.get(first.sessionId)!.attackSequence >= 2);
    await until(() => secondAttacks.some(event => event.playerId === first.sessionId && event.skill === "mortal_strike"));
    assert.ok(second.state.players.get(first.sessionId)!.mortalRemaining > 4);
    assert.ok(second.state.players.get(first.sessionId)!.mortalRemaining <= 4.5);
  } finally {
    await Promise.all(rooms.filter(room => room.connection.isOpen).map(room => room.leave()));
    await server.gracefullyShutdown(false);
  }
});
