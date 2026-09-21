import { MovementState, PlayerState } from "../schema/MovementState";

export const WORLD_SIZE = 24 * 64;
export const PLAYER_RADIUS = 22;
export const MOVE_SPEED = 240;

export class MovementWorld {
  readonly state = new MovementState();
  private inputs = new Map<string, { x: number; y: number }>();
  private nextSpawn = 0;

  join(id: string) {
    if (this.state.players.has(id)) return;
    const slot = this.nextSpawn++ % 12;
    const player = new PlayerState();
    player.x = WORLD_SIZE / 2 + (slot % 4 - 1.5) * 80;
    player.y = WORLD_SIZE / 2 + (Math.floor(slot / 4) - 1) * 80;
    player.color = slot % 4;
    this.state.players.set(id, player);
    this.inputs.set(id, { x: 0, y: 0 });
  }

  leave(id: string) {
    this.inputs.delete(id);
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

  step(seconds: number) {
    if (!Number.isFinite(seconds) || seconds <= 0) return;
    for (const [id, input] of this.inputs) {
      const player = this.state.players.get(id)!;
      const scale = input.x !== 0 && input.y !== 0 ? Math.SQRT1_2 : 1;
      player.x = this.contain(player.x + input.x * scale * MOVE_SPEED * seconds);
      player.y = this.contain(player.y + input.y * scale * MOVE_SPEED * seconds);
    }
  }

  private contain(value: number) {
    return Math.max(PLAYER_RADIUS, Math.min(WORLD_SIZE - PLAYER_RADIUS, value));
  }
}
