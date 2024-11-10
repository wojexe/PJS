import type { PageLoad } from "./$types";
import { PUBLIC_API_URL } from "$env/static/public";

import axios, { type AxiosError } from "axios";
import { Product } from "$lib/data/product.svelte";
import * as v from "valibot";

// Remove when using fetch
export const ssr = false;

const productSchema = v.strictObject({
  id: v.pipe(v.string(), v.uuid()),
  name: v.string(),
  description: v.string(),
  categories: v.array(v.string()),
  price: v.number(),
  quantity: v.pipe(v.number(), v.integer()),
});

export const load: PageLoad = async ({ parent }) => {
  const { user } = await parent();

  if (user == null) {
    return {};
  }

  let products = undefined;

  try {
    // TODO: filtering by category
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
    console.log(`[+page.ts] axios.get failed ${error.message}`);
    return {};
  }

  return { products };
};
