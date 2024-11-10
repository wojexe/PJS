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
  products: Array<Product>;
}

let { products }: Props = $props();

const user = $derived(getCurrentUser());
const cart = $derived(user?.cart);
</script>

<main
  class="flex-grow max-w-screen grid grid-cols-[repeat(auto-fill,_minmax(260px,_1fr))] gap-6
         sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 xl:max-w-[96em] xl:place-self-center"
>
  {#each products as product}
    <Card class="flex flex-col">
      <CardHeader>
        <CardTitle class="relative w-full">
          {product.name}
          <Badge variant="outline" class="absolute right-0">{product.quantity}</Badge>
        </CardTitle>
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
            user?.addToCart(product)}
          disabled={!user?.canAddToCart(product)}
        >
          Add to cart - {Intl.NumberFormat("en-US", {
            style: "currency",
            currency: "USD",
          }).format(product.price)}
        </Button>
      </CardFooter>
    </Card>
  {/each}
</main>
