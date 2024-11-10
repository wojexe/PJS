<script lang="ts">
import ProductsGrid from "./_components/ProductsGrid.svelte";
import type { PageData } from "./$types";

const { data }: { data: PageData } = $props();
const products = data.products;
</script>

<svelte:head>
  <title>products @ wojexe's store</title>
</svelte:head>

<!-- add basic selection of categories -->

<ProductsGrid {products} />
