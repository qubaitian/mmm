import { MovementState, PlayerState } from "../schema/MovementState";
import { Attack, CombatCycle } from "./CombatCycle";

export const WORLD_SIZE = 24 * 64;
export const PLAYER_RADIUS = 22;
export const MOVE_SPEED = 240;
export const ATTACK_GAP = PLAYER_RADIUS * 2;

export interface WorldAttack extends Attack {
  playerId: string;
  sequence: number;
  x: number;
  y: number;
  targetX: number;
  targetY: number;
}

export class MovementWorld {
  readonly state = new MovementState();
  private inputs = new Map<string, { x: number; y: number }>();
  private nextSpawn = 0;
  private combat = new Map<string, CombatCycle>();

  constructor(private readonly random: () => number = Math.random) {
    this.state.dummy.x = WORLD_SIZE / 2;
    this.state.dummy.y = WORLD_SIZE / 2;
    this.state.dummy.radius = PLAYER_RADIUS * 2;
  }

  join(id: string) {
    if (this.state.players.has(id)) return;
    const slot = this.nextSpawn++ % 12;
    const player = new PlayerState();
    player.x = WORLD_SIZE / 2 + (slot % 4 - 1.5) * 80;
    player.y = WORLD_SIZE / 2 + (Math.floor(slot / 4) - 1) * 80;
    player.color = slot % 4;
    this.pushOutsideDummy(player);
    this.state.players.set(id, player);
    this.inputs.set(id, { x: 0, y: 0 });
    this.combat.set(id, new CombatCycle(this.random));
  }

  leave(id: string) {
    this.inputs.delete(id);
    this.combat.delete(id);
    this.state.players.delete(id);
  }

  move(id: string, data: unknown) {
    if (!this.inputs.has(id)) return;
    const input = data as { x?: unknown; y?: unknown } | null;
    const valid = typeof input?.x === "number" && Number.isFinite(input.x)
      && typeof input?.y === "number" && Number.isFinite(input.y);
    this.inputs.set(id, valid
      ? { x: Math.sign(input!.x as number), y: Math.sign(input!.y as number) }
      : { x: 0, y: 0 });
  }

  step(seconds: number): WorldAttack[] {
    const attacks: WorldAttack[] = [];
    if (!Number.isFinite(seconds) || seconds <= 0) return attacks;
    for (const [id, input] of this.inputs) {
      const player = this.state.players.get(id)!;
      const scale = input.x !== 0 && input.y !== 0 ? Math.SQRT1_2 : 1;
      this.moveAroundDummy(player, input.x * scale * MOVE_SPEED * seconds, input.y * scale * MOVE_SPEED * seconds);
      const dummy = this.state.dummy;
      const inRange = Math.hypot(player.x - dummy.x, player.y - dummy.y)
        <= PLAYER_RADIUS + dummy.radius + ATTACK_GAP + 1e-8;
      const cycle = this.combat.get(id)!;
      const attack = cycle.advance(seconds, inRange);
      player.charges = cycle.charges;
      player.rechargeRemaining = cycle.rechargeRemaining;
      player.releaseRemaining = cycle.cooldownRemaining;
      player.mortalRemaining = cycle.mortalRemaining;
      if (attack) {
        player.attackSequence++;
        attacks.push({ ...attack, playerId: id, sequence: player.attackSequence,
          x: player.x, y: player.y, targetX: dummy.x, targetY: dummy.y });
      }
    }
    return attacks;
  }

  private pushOutsideDummy(player: PlayerState) {
    const dummy = this.state.dummy;
    const x = player.x - dummy.x;
    const y = player.y - dummy.y;
    const distance = Math.hypot(x, y);
    const radius = PLAYER_RADIUS + dummy.radius;
    if (distance >= radius) return;
    player.x = dummy.x + (distance > 0 ? x / distance : 1) * radius;
    player.y = dummy.y + (distance > 0 ? y / distance : 0) * radius;
  }

  private moveAroundDummy(player: PlayerState, dx: number, dy: number) {
    this.pushOutsideDummy(player);
    const dummy = this.state.dummy;
    const x = player.x - dummy.x;
    const y = player.y - dummy.y;
    const radius = PLAYER_RADIUS + dummy.radius;
    const a = dx * dx + dy * dy;
    const b = x * dx + y * dy;
    const c = Math.max(0, x * x + y * y - radius * radius);
    const discriminant = b * b - a * c;
    if (a > 0 && b < 0 && discriminant >= 0) {
      const hit = (-b - Math.sqrt(discriminant)) / a;
      if (hit >= 0 && hit <= 1) {
        const nx = (x + dx * hit) / radius;
        const ny = (y + dy * hit) / radius;
        const inward = (dx * nx + dy * ny) * (1 - hit);
        dx -= nx * Math.min(0, inward);
        dy -= ny * Math.min(0, inward);
      }
    }
    player.x = this.contain(player.x + dx);
    player.y = this.contain(player.y + dy);
    this.pushOutsideDummy(player);
  }

  private contain(value: number) {
    return Math.max(PLAYER_RADIUS, Math.min(WORLD_SIZE - PLAYER_RADIUS, value));
  }
}
