import { PUBLIC_API_URL } from "$env/static/public";
import type { PageLoad } from "./$types";

import { Product } from "$lib/data/product.svelte";
import axios, { type AxiosError } from "axios";
import * as v from "valibot";

// Remove when using fetch
export const ssr = false;

const categorySchema = v.strictObject({
  id: v.pipe(v.string(), v.uuid()),
  name: v.string(),
});

const productSchema = v.strictObject({
  id: v.pipe(v.string(), v.uuid()),
  name: v.string(),
  description: v.string(),
  categories: v.array(categorySchema),
  price: v.number(),
  quantity: v.pipe(v.number(), v.integer()),
});

export const load: PageLoad = async ({ parent }) => {
  const { user } = await parent();

  if (user == null) {
    return {};
  }

  let products = undefined;
  let categories = undefined;

  try {
    const response = await axios.get(
      new URL("api/store/categories", PUBLIC_API_URL).toString(),
      { withCredentials: true },
    );
    const parsedCategories = v.parse(v.array(categorySchema), response.data);
    categories = parsedCategories;
  } catch (e) {
    const error = e as AxiosError;
    console.log(`[+page.ts] axios.get categories failed ${error.message}`);
    return {};
  }

  try {
    const response = await axios.get(
      new URL("api/store/products", PUBLIC_API_URL).toString(),
      { withCredentials: true },
    );
    const parsedProducts = v.parse(v.array(productSchema), response.data);

    products = parsedProducts.map(
      (product) =>
        new Product(
          product.id,
          product.name,
          product.description,
          product.categories,
          product.price,
          product.quantity,
        ),
    );
  } catch (e) {
    const error = e as AxiosError;
    console.log(`[+page.ts] axios.get products failed ${error.message}`);
    return {};
  }

  return { products, categories };
};
