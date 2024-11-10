<script lang="ts">
import { Badge } from "$lib/components/ui/badge";
import { Button } from "$lib/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "$lib/components/ui/card";
import { Product } from "$lib/data/product.svelte";
import { getCurrentUser } from "$lib/data/user.svelte";

interface Props {
  products: Array<{
    id: string;
    name: string;
    description: string;
    categories: Array<string>;
    price: number;
    quantity: number;
  }>;
  [key: string]: unknown;
}

let { products }: Props = $props();

const user = $derived(getCurrentUser());
</script>

<main
  class="flex-grow max-w-screen grid grid-cols-[repeat(auto-fill,_minmax(260px,_1fr))] gap-6
         sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 xl:max-w-[96em] xl:place-self-center"
>
  {#each products as product}
    <Card class="flex flex-col">
      <CardHeader>
        <CardTitle>{product.name}</CardTitle>
        <CardDescription class="flex gap-2 flex-wrap ml-[-0.625rem]">
          {#each product.categories as category}
            <Badge variant="secondary" class="text-xs">{category}</Badge>
          {/each}
        </CardDescription>
      </CardHeader>
      <CardContent class="h-full">{product.description}</CardContent>
      <CardFooter>
        <Button
          class="flex w-full"
          onclick={() =>
            user?.addToCard(
              new Product(product.id, product.name, product.price)
            )}
        >
          Add to cart - ${product.price}
        </Button>
      </CardFooter>
    </Card>
  {/each}
</main>
