import type { PageLoad } from "./$types";
import { PUBLIC_API_URL } from "$env/static/public";

import axios, { type AxiosError } from "axios";

// Remove when using fetch
export const ssr = false;

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
    products = await response.data;
  } catch (e) {
    const error = e as AxiosError;
    console.log(`[+page.ts] axios.get failed ${error.message}`);
    return {};
  }

  return { products };
};
