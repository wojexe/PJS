<script lang="ts">
import { faker } from "@faker-js/faker";
import ProductsGrid from "./_components/ProductsGrid.svelte";

// TODO: fetch real data
const generateProduct = () => {
  return {
    name: faker.commerce.product(),
    description: faker.commerce.productDescription(),
    categories: Array(1 + Math.floor(Math.random() * 3))
      .fill(0)
      .map(() => faker.commerce.productAdjective()),
  };
};

const products = $state(
  Array(14)
    .fill(0)
    .map(() => generateProduct()),
);
</script>

<svelte:head>
  <title>products @ wojexe's store</title>
</svelte:head>

<ProductsGrid {products} />
