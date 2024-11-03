import { Hono } from "hono";
import { getCookie, setCookie } from "hono/cookie";
import { createMiddleware } from "hono/factory";
import { auth } from "hono/utils/basic-auth";

import { vValidator } from "@hono/valibot-validator";
import * as v from "valibot";

import { addWeeks } from "date-fns";

import type { SQLiteError } from "bun:sqlite";
import { db } from "./db";

const sessionMiddleware = createMiddleware(async (c, next) => {
  const userSession = getCookie(c, "user-session");

  if (userSession == null) {
    c.status(401);
    return c.json({ error: "Unauthorized" });
  }
  const userId = db
    .query(
      "SELECT user_id FROM sessions WHERE session_id = ? AND datetime('now') < datetime(expires_at);",
    )
    .get(userSession);

  if (userId == null) {
    c.status(401);
    return c.json({ error: "Unauthorized" });
  }

  db.query(
    `UPDATE sessions SET expires_at=datetime('now', '+7 days') WHERE user_id = ?`,
  ).run(userId as string);

  await next();
});

const app = new Hono();

app.post("login", async (c) => {
  const maybeCredentials = auth(c.req.raw);

  if (maybeCredentials === undefined) {
    c.status(401);
    return c.json({ error: "Unable to read credentials" });
  }

  const { username: email, password } = maybeCredentials;

  const maybeDBCredentials = db
    .query(
      "SELECT id as userID, password as passwordDB FROM users WHERE email = ? LIMIT 1;",
    )
    .get(email) as { userID: string; passwordDB: string };

  if (maybeDBCredentials === null) {
    c.status(401);
    return c.json({ error: "Wrong email or password" });
  }

  const { userID, passwordDB } = maybeDBCredentials;
  const passwordMatch = await Bun.password.verify(password, passwordDB);

  if (passwordMatch === false) {
    c.status(401);
    return c.json({ error: "Wrong email or password" });
  }

  const sessionID = crypto.randomUUID();

  setCookie(c, "user-session", sessionID);
  db.query("INSERT INTO sessions VALUES (?, ?, ?);").run(
    sessionID,
    userID,
    addWeeks(new Date(), 1).toISOString(),
  );

  c.status(200);
  return c.json({ success: true });
});

app.post(
  "register",
  vValidator(
    "json",
    v.strictObject({
      email: v.pipe(v.string(), v.email(), v.maxLength(256)),
      password: v.pipe(v.string(), v.maxLength(256)),
    }),
    (res, c) => {
      if (res.issues != null && res.issues.length >= 0) {
        c.status(400);
        return c.json({ issues: res.issues.map((issue) => issue.message) });
      }
    },
  ),
  async (c) => {
    const { email, password } = c.req.valid("json");

    const passwordDB = await Bun.password.hash(password);

    const userID = crypto.randomUUID();

    try {
      db.query("INSERT INTO users VALUES (?, ?, ?)").run(
        userID,
        email,
        passwordDB,
      );
    } catch (e: unknown) {
      const error = e as SQLiteError;

      switch (error.code) {
        case "SQLITE_CONSTRAINT_UNIQUE":
          c.status(400);
          return c.json({ error: "Email already taken" });
        default:
          c.status(400);
          return c.json({ error: "Error creating account" });
      }
    }

    c.status(201);
    return c.json({ userID });
  },
);

export { app as auth, sessionMiddleware };
