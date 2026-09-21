import { Schema, type, MapSchema } from "@colyseus/schema";

export class PlayerState extends Schema {
  @type("float32") x = 0;
  @type("float32") y = 0;
  @type("uint8") color = 0;
}

export class MovementState extends Schema {
  @type("uint8") tiles = 24;
  @type("uint8") tileSize = 64;
  @type({ map: PlayerState }) players = new MapSchema<PlayerState>();
}
