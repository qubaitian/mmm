import { defineRoom, defineServer } from "colyseus";
import { MovementRoom } from "./rooms/MovementRoom";
import { listenAddress } from "./listen_config";

const { host, port } = listenAddress();
const server = defineServer({ rooms: { movement: defineRoom(MovementRoom) } });

server.listen(port, host).then(() => {
  console.log(`mmm server listens on ${host}:${port}`);
});
