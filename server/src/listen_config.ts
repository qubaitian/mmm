export function listenAddress(env: NodeJS.ProcessEnv | Record<string, string | undefined> = process.env) {
  return {
    host: env.HOST || "0.0.0.0",
    port: Number(env.PORT || 2567),
  };
}
