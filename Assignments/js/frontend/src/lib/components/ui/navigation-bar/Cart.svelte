<script lang="ts">
import { cn } from "$lib/utils";
import { ShoppingCart, Trash } from "lucide-svelte";
import { Button, buttonVariants } from "../button";
import * as Dialog from "../dialog";

import type { User } from "$lib/data/user.svelte";
import Footer from "../footer/Footer.svelte";

const { user }: { user: User } = $props();
const cart = $derived(user.cart);
</script>

<Dialog.Root open>
  <Dialog.Trigger
    class={cn(buttonVariants({ size: "sm", variant: "outline" }))}
  >
    <ShoppingCart />
    <span class="sr-only">Cart</span>
  </Dialog.Trigger>
  <Dialog.Content>
    <Dialog.Header>
      <Dialog.Title>Cart</Dialog.Title>
      <Dialog.Description>Items you wanna buy :D</Dialog.Description>
    </Dialog.Header>

    {#if cart!.products.length > 0}
      <table class="table-fixed">
        <thead class="text-left">
          <tr>
            <th>Name</th>
            <th>Unit price</th>
            <th>Count</th>
            <th>Price</th>
          </tr>
        </thead>
        <tbody>
          {#each cart!.productsWithQuantities as {product, quantity}}
            <tr>
              <td class="border-r-2 border-t-2 pl-2">{product.name}</td>
              <td class="border-r-2 border-t-2 pl-2 font-mono"
                >{Intl.NumberFormat("en-US", {
                  style: "currency",
                  currency: "USD",
                }).format(product.price)}</td
              >
              <td class="border-r-2 border-t-2 pl-2 font-mono">{quantity}</td>
              <td class="border-t-2 pl-2 font-mono">{Intl.NumberFormat("en-US", {
                style: "currency",
                currency: "USD",
              }).format(product.price * quantity)}</td>
            </tr>
          {/each}
        </tbody>
      </table>

      <Dialog.Footer>
        <Button class="relative" onclick={() => cart.order()}>
          Purchase - {Intl.NumberFormat("en-US", {
            style: "currency",
            currency: "USD",
          }).format(cart.total)}
          <span class="text-[0.5em] italic absolute right-1 bottom-0">(you'll not be charged :P)</span>
        </Button>
        <Button variant="destructive" onclick={()=>cart.clear()}><Trash /></Button>
      </Dialog.Footer>
    {:else}
      <div
        class="place-center text-center uppercase text-gray-400 tracking-[0.5em]"
      >
        Empty
      </div>
    {/if}
  </Dialog.Content>
</Dialog.Root>
