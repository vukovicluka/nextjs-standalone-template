const nextConfig: import('next').NextConfig = {
  cacheHandler:
      process.env.NODE_ENV === "production"
          ? require.resolve("./cache-handler.mjs")
          : undefined,
  env: {
    NEXT_PUBLIC_REDIS_INSIGHT_URL:
        process.env.REDIS_INSIGHT_URL ?? "http://localhost:8001",
  },
  output: "standalone",
};

export default nextConfig;

