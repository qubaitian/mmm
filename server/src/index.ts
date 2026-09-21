import { defineRoom, defineServer } from "colyseus";
import { MovementRoom } from "./rooms/MovementRoom";

const port = Number(process.env.PORT || 2567);
const server = defineServer({ rooms: { movement: defineRoom(MovementRoom) } });

server.listen(port).then(() => {
  console.log(`mmm server listens on port ${port}`);
});
