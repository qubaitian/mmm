import assert from "node:assert/strict";
import { test } from "node:test";
import { listenAddress } from "../src/listen_config";

test("server listens on all interfaces by default", () => {
  const { host, port } = listenAddress({});
  assert.equal(host, "0.0.0.0");
  assert.equal(port, 2567);
});

test("server host and port come from env", () => {
  const { host, port } = listenAddress({ HOST: "127.0.0.1", PORT: "3000" });
  assert.equal(host, "127.0.0.1");
  assert.equal(port, 3000);
});
