import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";

import { sessionMiddleware } from "../auth";
import { db } from "../db";

import { vValidator } from "@hono/valibot-validator";
import * as v from "valibot";

const app = new Hono();

type Product = {
  id: string;
  name: string;
  description: string;
  quantity: number;
  price: number;
  categories: Array<{
    id: string;
    name: string;
  }>;
};

app.get("products", (c) => {
  const categories = c.req.query("categories")?.split(",");

  let products: Array<unknown> = [];
  const query = `
SELECT products.*, categories.id as categoryId, categories.name as categoryName
FROM products
INNER JOIN products_categories as pc
	ON pc.product_id = products.id
INNER JOIN categories
  ON pc.category_id = categories.id`;

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

  type ProductDB = Array<{
    id: string;
    name: string;
    description: string;
    quantity: number;
    price: number;
    categoryId?: string;
    categoryName?: string;
  }>;

  products = (products as ProductDB).map((x) => {
    const categories = [{ id: x.categoryId, name: x.categoryName }];
    x.categoryId = undefined;
    x.categoryName = undefined;
    return { ...x, categories } as unknown as Product; // 🤝
  }) as Array<Product>;

  // dear god
  const mapping: Map<string, Product> = new Map();
  for (const product of products as Array<Product>) {
    const current = mapping.get(product.id);
    let next: Product;
    if (current == null) {
      next = product;
    } else {
      current.categories.push(product.categories[0]);
      next = current;
    }
    mapping.set(product.id, next);
  }

  return c.json([...mapping.values()]);
});

app.get("categories", (c) => {
  const categories = db.query("SELECT * FROM categories;").all();
  return c.json(categories);
});

app.use("purchase", sessionMiddleware);
app.post(
  "purchase",
  vValidator(
    "json",
    v.strictObject({
      /* Order JSON validation */
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
  (c) => {
    const maybeOrder = c.req.valid("json");

    if (maybeOrder == null) {
      throw new HTTPException(400, {
        res: Response.json({ erorr: "Invalid JSON" }),
      });
    }

    throw new HTTPException(501, {
      res: Response.json({ erorr: "Not implemented" }),
    });
  },
);

export default app;
