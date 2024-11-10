import { Hono } from "hono";
import { getCookie, setCookie } from "hono/cookie";
import { createMiddleware } from "hono/factory";
import { HTTPException } from "hono/http-exception";
import { auth } from "hono/utils/basic-auth";

import { vValidator } from "@hono/valibot-validator";
import * as v from "valibot";

import { addWeeks } from "date-fns";

import type { SQLiteError } from "bun:sqlite";
import { db } from "./db";

const sessionMiddleware = createMiddleware<{
  Variables: {
    userSession: string;
    userID: string;
  };
}>(async (c, next) => {
  const userSession = getCookie(c, "user-session");

  if (userSession == null) {
    throw new HTTPException(401, {
      res: Response.json({ error: "Unauthorized" }),
    });
  }

  const maybeUserID = db
    .query(
      "SELECT user_id as userID FROM sessions WHERE session_id = ? AND datetime('now') < datetime(expires_at);",
    )
    .get(userSession);

  if (maybeUserID == null) {
    throw new HTTPException(401, {
      res: Response.json({ error: "Invalid session" }),
    });
  }

  const { userID } = maybeUserID as { userID: string };

  db.query(
    `UPDATE sessions SET expires_at=datetime('now', '+7 days') WHERE user_id = ?`,
  ).run(userID as string);

  c.set("userSession", userSession);
  c.set("userID", userID);

  await next();
});

const app = new Hono();

app.post("login", async (c) => {
  const maybeCredentials = auth(c.req.raw);

  if (maybeCredentials === undefined) {
    throw new HTTPException(400, {
      res: Response.json({ error: "Unable to read credentials" }),
    });
  }

  const { username: email, password } = maybeCredentials;

  const maybeDBCredentials = db
    .query(
      "SELECT id as userID, password as passwordDB FROM users WHERE email = ? LIMIT 1;",
    )
    .get(email) as { userID: string; passwordDB: string };

  if (maybeDBCredentials === null) {
    throw new HTTPException(400, {
      res: Response.json({ error: "Wrong email or password" }),
    });
  }

  const { userID, passwordDB } = maybeDBCredentials;
  const passwordMatch = await Bun.password.verify(password, passwordDB);

  if (passwordMatch === false) {
    throw new HTTPException(400, {
      res: Response.json({ error: "Wrong email or password" }),
    });
  }

  const sessionID = crypto.randomUUID();

  setCookie(c, "user-session", sessionID);
  db.query("INSERT INTO sessions VALUES (?, ?, ?);").run(
    sessionID,
    userID,
    addWeeks(new Date(), 1).toISOString(),
  );

  c.status(200);
  return c.json({ success: true, userID });
});

app.post(
  "register",
  vValidator(
    "json",
    v.strictObject({
      email: v.pipe(v.string(), v.email(), v.maxLength(256)),
      password: v.pipe(v.string(), v.minLength(8), v.maxLength(256)),
    }),
    (res, c) => {
      if (res.issues != null && res.issues.length >= 0) {
        throw new HTTPException(400, {
          res: Response.json({
            error: "Validation error",
            issues: res.issues.map((issue) => issue.message),
          }),
        });
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
          throw new HTTPException(400, {
            res: Response.json({ error: "Email already taken" }),
          });
        default:
          throw new HTTPException(400, {
            res: Response.json({ error: "Error creating account" }),
          });
      }
    }

    const sessionID = crypto.randomUUID();

    setCookie(c, "user-session", sessionID);
    db.query("INSERT INTO sessions VALUES (?, ?, ?)").run(
      sessionID,
      userID,
      addWeeks(new Date(), 1).toISOString(),
    );

    c.status(201);
    return c.json({ userID });
  },
);

app.post("logout", sessionMiddleware, (c) => {
  const userSession = c.var.userSession;
  db.query("DELETE FROM sessions WHERE session_id = ?").run(userSession);

  c.status(200);
  return c.json({ success: true });
});

app.get("me", sessionMiddleware, (c) => {
  const userID = c.var.userID;

  const maybeEmail = db
    .query("SELECT email FROM users WHERE id = ?")
    .get(userID);

  if (maybeEmail == null) {
    throw new HTTPException(500, {
      res: Response.json({ error: "Invalid state" }),
    });
  }

  const { email } = maybeEmail as { email: string };

  c.status(200);
  return c.json({ success: true, userID, email });
});

export { app as auth, sessionMiddleware };
