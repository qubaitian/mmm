import assert from "node:assert/strict";
import { test } from "node:test";
import { CombatCycle } from "../src/game/CombatCycle";

const close = (actual: number, expected: number) => assert.ok(Math.abs(actual - expected) < 1e-8, `${actual} != ${expected}`);

test("ready skills apply at once and use overpower before mortal strike", () => {
  const cycle = new CombatCycle(() => 1);
  assert.equal(cycle.charges, 2);
  assert.equal(cycle.advance(0, true)?.skill, "overpower");
  assert.equal(cycle.charges, 1);
  assert.equal(cycle.advance(1.49, true), undefined);
  assert.equal(cycle.advance(0.01, true)?.skill, "overpower");
  assert.equal(cycle.charges, 0);
  assert.equal(cycle.advance(1.5, true)?.skill, "mortal_strike");
  assert.equal(cycle.advance(1.5, true)?.skill, "overpower");
});

test("charges recover in order without restarting the current timer", () => {
  const cycle = new CombatCycle();
  cycle.advance(0, true);
  cycle.advance(1.5, true);
  close(cycle.rechargeRemaining, 3);
  cycle.advance(3, false);
  assert.equal(cycle.charges, 1);
  close(cycle.rechargeRemaining, 4.5);
  cycle.advance(4.49, false);
  assert.equal(cycle.charges, 1);
  cycle.advance(0.01, false);
  assert.equal(cycle.charges, 2);
  assert.equal(cycle.rechargeRemaining, 0);
});

test("out of range does not spend charges or start a cooldown and returning attacks at once", () => {
  const cycle = new CombatCycle(() => 1);
  cycle.advance(10, false);
  assert.equal(cycle.charges, 2);
  assert.equal(cycle.cooldownRemaining, 0);
  assert.equal(cycle.advance(0, true)?.skill, "overpower");
  cycle.advance(2, false);
  assert.equal(cycle.charges, 1);
  close(cycle.rechargeRemaining, 2.5);
  assert.equal(cycle.cooldownRemaining, 0);
  assert.equal(cycle.advance(0, true)?.skill, "overpower");
});

test("mortal strike refreshes below the 30 percent boundary and keeps recharge progress", () => {
  for (const [roll, refreshed] of [[0, true], [0.299999, true], [0.3, false], [0.99, false]] as const) {
    let rolls = 0;
    const cycle = new CombatCycle(() => { rolls++; return roll; });
    cycle.advance(0, true);
    cycle.advance(1.5, true);
    assert.equal(rolls, 0);
    const attack = cycle.advance(1.5, true)!;
    assert.equal(attack.skill, "mortal_strike");
    assert.equal(attack.refreshed, refreshed);
    assert.equal(rolls, 1);
    assert.equal(cycle.charges, refreshed ? 1 : 0);
    close(cycle.rechargeRemaining, 1.5);
    cycle.advance(1.5, false);
    assert.equal(cycle.charges, refreshed ? 2 : 1);
    cycle.advance(50, false);
    assert.equal(cycle.charges, 2);
  }
});

test("invalid time leaves combat unchanged and a delayed tick never bursts multiple attacks", () => {
  const cycle = new CombatCycle(() => 1);
  for (const seconds of [-1, NaN, Infinity]) assert.equal(cycle.advance(seconds, true), undefined);
  assert.equal(cycle.charges, 2);
  assert.equal(cycle.advance(100, true)?.skill, "overpower");
  assert.equal(cycle.charges, 1);
  assert.equal(cycle.advance(0, true), undefined);
});

test("mortal strike has its own 4.5 second cooldown and failed attempts do not restart it", () => {
  const cycle = new CombatCycle(() => 1);
  cycle.advance(0, true);
  cycle.advance(1.5, true);
  assert.equal(cycle.advance(1.5, true)?.skill, "mortal_strike");
  close(cycle.mortalRemaining, 4.5);
  assert.equal(cycle.advance(1.5, true)?.skill, "overpower");
  close(cycle.mortalRemaining, 3);
  assert.equal(cycle.advance(1.5, true), undefined);
  close(cycle.mortalRemaining, 1.5);
  close(cycle.cooldownRemaining, 0);
  assert.equal(cycle.advance(1.49, true), undefined);
  close(cycle.mortalRemaining, 0.01);
  assert.equal(cycle.advance(0.01, true)?.skill, "mortal_strike");
  close(cycle.mortalRemaining, 4.5);
});

test("mortal strike cooldown keeps running outside attack range", () => {
  const cycle = new CombatCycle(() => 1);
  cycle.advance(0, true);
  cycle.advance(1.5, true);
  cycle.advance(1.5, true);
  cycle.advance(1.5, true);
  assert.equal(cycle.advance(3, false), undefined);
  close(cycle.mortalRemaining, 0);
  assert.equal(cycle.advance(0, true)?.skill, "mortal_strike");
});
