import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";

import { sessionMiddleware } from "../auth";
import { db } from "../db";

const app = new Hono();

app.use(sessionMiddleware);

app.get("products", (c) => {
  const categories = c.req.query("categories")?.split(",");

  let products: Array<unknown> = [];
  let query = `
SELECT products.*, categories.name as categories
FROM products
INNER JOIN products_categories as pc
	ON pc.product_id = products.id
INNER JOIN categories
  ON pc.category_id = categories.id`

  if (categories == null) {
    products = db.query(query).all();
  } else {
    const stringifiedCategories = `(${categories.map((x) => `"${x.toLowerCase()}"`).join(", ")})`;

    products = db
      .query(`
${query}
WHERE lower(categories.name) IN ${stringifiedCategories}
`)
      .all();
  }

  // dear god
  const mapping: any = new Map()
  for (const product of products) {
    const current: any = mapping.get(product.id);
    let next: any;
    if (current == null) {
      product.categories = [product.categories]
      next = product
    } else {
      current.categories.push(product.categories)
      next = current
    }
    mapping.set(product.id, next)
  }

  return c.json([...mapping.values()]);
});

app.get("categories", (c) => {
  const categories = db.query("SELECT * FROM categories;").all();
  return c.json(categories);
});

app.post("purchase", (_c) => {
  throw new HTTPException(501, {
    res: Response.json({ erorr: "Not implemented " }),
  });
});

export default app;
