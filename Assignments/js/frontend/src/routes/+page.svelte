<script lang="ts">
import * as Select from "$lib/components/ui/select";
import { getCurrentUser } from "$lib/data/user.svelte";
import type { PageData } from "./$types";
import ProductsGrid from "./_components/ProductsGrid.svelte";

const { data }: { data: PageData } = $props();

const categories = $derived(data.categories);
const categoriesMap: { [key: string]: string } = $derived(
  (categories ?? [])?.reduce(
    // biome-ignore lint/performance/noAccumulatingSpread: temporary
    (mapping, category) => ({ ...mapping, [category.id]: category.name }),
    {},
  ),
);
const products = $derived(data.products);

const user = $derived(getCurrentUser());

let selectedCategories: string[] = $state([]);

const productsFilteredByCategory = $derived.by(() => {
  const result = [];

  for (const product of products ?? []) {
    for (const category of product.categories) {
      if (selectedCategories.includes(category.id)) {
        result.push(product);
        break;
      }
    }
  }

  return result;
});
</script>

<svelte:head>
  <title>products @ wojexe's store</title>
</svelte:head>

{#if categories == null}
  Failed to fetch categories list
{:else}
  <div class="flex justify-center pb-6">
    <Select.Root
      type="multiple"
      name="favoriteFruit"
      bind:value={selectedCategories}
    >
      <Select.Trigger class="flex min-w-96 w-fit justify-end">
        <div class="flex w-full">
          {selectedCategories.length === 0
            ? "Category"
            : selectedCategories
                .map((x) => categoriesMap?.[x] ?? "error")
                .join(" or ")}
        </div>
      </Select.Trigger>

      <Select.Content>
        <Select.Group>
          {#each categories as category}
            <Select.Item value={category.id} label={category.name}>
              {category.name}
            </Select.Item>
          {/each}
        </Select.Group>
      </Select.Content>
    </Select.Root>
  </div>
{/if}

{#if products == null}
  Failed to fetch products list
{:else}
  <ProductsGrid
    products={productsFilteredByCategory.length === 0
      ? products
      : productsFilteredByCategory}
  />
{/if}
