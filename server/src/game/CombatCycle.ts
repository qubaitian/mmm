export type Skill = "overpower" | "mortal_strike";
export interface Attack {
  skill: Skill;
  refreshed: boolean;
}

export const RELEASE_INTERVAL = 1.5;
export const RECHARGE_INTERVAL = 4.5;
export const MORTAL_COOLDOWN = 4.5;
const EPSILON = 1e-9;

export class CombatCycle {
  private chargeCount = 2;
  private rechargeElapsed = 0;
  private cooldown = 0;
  private mortalCooldown = 0;

  constructor(private readonly random: () => number = Math.random) {}

  get charges() { return this.chargeCount; }
  get cooldownRemaining() { return this.cooldown; }
  get mortalRemaining() { return this.mortalCooldown; }
  get rechargeRemaining() {
    return this.chargeCount === 2 ? 0 : RECHARGE_INTERVAL - this.rechargeElapsed;
  }

  advance(seconds: number, inRange: boolean): Attack | undefined {
    if (!Number.isFinite(seconds) || seconds < 0) return;
    this.cooldown = Math.max(0, this.cooldown - seconds);
    this.mortalCooldown = Math.max(0, this.mortalCooldown - seconds);
    if (this.chargeCount < 2) {
      this.rechargeElapsed += seconds;
      while (this.chargeCount < 2 && this.rechargeElapsed + EPSILON >= RECHARGE_INTERVAL) {
        this.chargeCount++;
        this.rechargeElapsed = Math.max(0, this.rechargeElapsed - RECHARGE_INTERVAL);
      }
      if (this.chargeCount === 2) this.rechargeElapsed = 0;
    }
    if (!inRange || this.cooldown > EPSILON) return;

    if (this.chargeCount > 0) {
      this.cooldown = RELEASE_INTERVAL;
      this.chargeCount--;
      return { skill: "overpower", refreshed: false };
    }
    if (this.mortalCooldown > EPSILON) return;
    this.cooldown = RELEASE_INTERVAL;
    this.mortalCooldown = MORTAL_COOLDOWN;
    const refreshed = this.random() < 0.3;
    if (refreshed) this.chargeCount = Math.min(2, this.chargeCount + 1);
    return { skill: "mortal_strike", refreshed };
  }
}
