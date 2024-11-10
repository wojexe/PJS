import { sveltekit } from "@sveltejs/kit/vite";
import { defineConfig } from "vite";
import { readFile } from "node:fs/promises";

export default defineConfig(async () => {
  return {
    plugins: [sveltekit()],
    server: {
      https: {
        key: process.env.KEY_PATH
          ? await readFile(process.env.KEY_PATH)
          : undefined,
        cert: process.env.CERT_PATH
          ? await readFile(process.env.CERT_PATH)
          : undefined,
      },
      proxy: {},
    },
  };
});
