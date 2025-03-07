import type { Serve } from "bun";

import { Hono } from "hono";
import { cors } from "hono/cors";
import { showRoutes } from "hono/dev";
import { logger } from "hono/logger";
import { prettyJSON } from "hono/pretty-json";

import store from "./api/store";
import { auth } from "./auth";

import hello from "../hello_there";

const app = new Hono();

const localhostRegex = /^https?:\/\/localhost(:\d+)?(\/.*)?$/g;

app.use(
  cors({
    origin: (origin, _) =>
      localhostRegex.test(origin) ? origin : "https://localhost:5173",
    allowMethods: ["GET", "POST", "HEAD", "OPTIONS"],
    allowHeaders: ["Authorization", "Content-Type"],
    credentials: true,
  }),
);

app.use(logger());
app.use(prettyJSON());

app.get("/", (c) => c.text(atob(atob(hello))));

app.route("auth", auth);
app.route("api/store", store);

app.get("ping", (c) => {
  return c.text("pong!\n");
});

showRoutes(app);

export default {
  fetch: app.fetch,
  tls: {
    cert: process.env.CERT_PATH ? Bun.file(process.env.CERT_PATH) : undefined,
    key: process.env.KEY_PATH ? Bun.file(process.env.KEY_PATH) : undefined,
  },
} satisfies Serve;
