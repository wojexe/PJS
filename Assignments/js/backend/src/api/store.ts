import { Hono } from "hono";
import { sessionMiddleware } from "../auth";

import { db } from "../db";

const app = new Hono();

app.use(sessionMiddleware);

app.get("products", (c) => {
  const categories = c.req.query("categories")?.split(",");

  let products: Array<unknown> = [];
  if (categories == null) {
    products = db.query("SELECT * FROM products;").all();
  } else {
    const stringifiedCategories = `(${categories.map((x) => `"${x.toLowerCase()}"`).join(", ")})`;

    products = db
      .query(`
SELECT products.*, categories.name as category
FROM products
INNER JOIN products_categories as pc
	ON pc.product_id = products.id
INNER JOIN categories
  ON pc.category_id = categories.id
WHERE lower(categories.name) IN ${stringifiedCategories}`)
      .all();
  }

  return c.json(products);
});

app.get("categories", (c) => {
  const categories = db.query("SELECT * FROM categories;").all();
  return c.json(categories);
});

app.post("purchase", (c) => {
  c.status(501);
  return c.json({ error: "Not implemented" });
});

export default app;
