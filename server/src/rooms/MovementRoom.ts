import { Room, Client } from "colyseus";
import { MovementWorld } from "../game/MovementWorld";

export class MovementRoom extends Room {
  maxClients = 12;
  private world = new MovementWorld();
  state = this.world.state;

  onCreate() {
    this.onMessage("move", (client, data: unknown) => this.world.move(client.sessionId, data));
    this.setSimulationInterval((delta) => {
      for (const attack of this.world.step(delta / 1000)) {
        this.broadcast("attack", attack, { afterNextPatch: true });
      }
    }, 1000 / 30);
    this.setPatchRate(1000 / 30);
  }

  onJoin(client: Client) {
    this.world.join(client.sessionId);
  }

  onLeave(client: Client) {
    this.world.leave(client.sessionId);
  }
}
