<script lang="ts">
import ProductsGrid from "./_components/ProductsGrid.svelte";
import type { PageData, Snapshot } from "./$types";
import { getCurrentUser, setCurrentUser, User } from "$lib/data/user.svelte";
import { Cart } from "$lib/data/cart.svelte";
import type { Product } from "$lib/data/product.svelte";

const { data }: { data: PageData } = $props();
const products = data.products;

const user = $derived(getCurrentUser());

export const snapshot: Snapshot<Product[] | undefined> = {
  capture: () => {
    return $state.snapshot(user?.cart.products);
  },
  restore: (products) => {
    const cart = new Cart(products);

    if (user?.id != null && user?.email != null)
      setCurrentUser(new User(user?.id, user?.email, cart));
  },
};
</script>

<svelte:head>
  <title>products @ wojexe's store</title>
</svelte:head>

<!-- add basic selection of categories -->

{#if products == null}
  Failed to fetch products list
{:else}
  <ProductsGrid {products} />
{/if}
