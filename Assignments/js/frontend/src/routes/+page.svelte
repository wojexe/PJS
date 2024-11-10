<script lang="ts">
import ProductsGrid from "./_components/ProductsGrid.svelte";
import type { PageData, Snapshot } from "./$types";
import { getCurrentUser, setCurrentUser, User } from "$lib/data/user.svelte";
import { Cart } from "$lib/data/cart.svelte";
import type { Product } from "$lib/data/product.svelte";
import * as Select from "$lib/components/ui/select";

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

// TODO: use real categories
let value: string[] | undefined = $state();
const fruits = [
  { value: "apple", label: "Apple" },
  { value: "banana", label: "Banana" },
  { value: "blueberry", label: "Blueberry" },
  { value: "grapes", label: "Grapes" },
  { value: "pineapple", label: "Pineapple" },
];
</script>

<svelte:head>
  <title>products @ wojexe's store</title>
</svelte:head>

<div class="flex justify-center pb-6">
<Select.Root type="multiple" name="favoriteFruit" bind:value>
  <Select.Trigger class="flex min-w-96 w-fit justify-end">
    <div class="flex w-full">{value}</div>
  </Select.Trigger>

  <Select.Content>
    <Select.Group>
      <Select.GroupHeading>Fruits</Select.GroupHeading>
      {#each fruits as fruit}
        <Select.Item value={fruit.value} label={fruit.label}
          >{fruit.label}</Select.Item
        >
      {/each}
    </Select.Group>
  </Select.Content>
</Select.Root>
</div>

{#if products == null}
  Failed to fetch products list
{:else}
  <ProductsGrid {products} />
{/if}
