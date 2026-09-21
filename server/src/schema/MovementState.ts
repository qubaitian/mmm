import { Schema, type, MapSchema } from "@colyseus/schema";

export class PlayerState extends Schema {
  @type("float32") x = 0;
  @type("float32") y = 0;
  @type("uint8") color = 0;
  @type("uint8") charges = 2;
  @type("float32") rechargeRemaining = 0;
  @type("float32") releaseRemaining = 0;
  @type("float32") mortalRemaining = 0;
  @type("uint32") attackSequence = 0;
}

export class DummyState extends Schema {
  @type("float32") x = 0;
  @type("float32") y = 0;
  @type("float32") radius = 44;
}

export class MovementState extends Schema {
  @type("uint8") tiles = 24;
  @type("uint8") tileSize = 64;
  @type({ map: PlayerState }) players = new MapSchema<PlayerState>();
  @type(DummyState) dummy = new DummyState();
}
