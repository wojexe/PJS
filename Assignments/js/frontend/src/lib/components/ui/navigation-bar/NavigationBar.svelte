<script lang="ts">
import { SignIn } from "$lib/components/forms/signIn";
import { Button, buttonVariants } from "$lib/components/ui/button";
import * as Dialog from "$lib/components/ui/dialog";
import { cn } from "$lib/utils";

import { getCurrentUser } from "$lib/data/user.svelte";
const currentUser = $derived(getCurrentUser());
const signedIn = $derived(!!currentUser);
const cart = $derived(currentUser?.cart);

import { ShoppingCart, Store } from "lucide-svelte";
import SignUp from "$lib/components/forms/signUp/SignUp.svelte";
</script>

<nav
  class="sticky inset-x-0 top-0 z-50 w-full h-14 px-4 grid grid-cols-3 place-items-center bg-white/80 dark:bg-neutral-950/80 backdrop-blur border-b"
>
  <a href="/" class="justify-self-start flex">
    <Store class="h-6 w-6" />
    <span class="sr-only">wojexe's store</span>
  </a>

  <nav class="hidden md:flex gap-4">
    <a
      href="/"
      class="font-medium flex items-center text-sm transition-colors hover:underline"
    >
      Shop
    </a>
    <a
      href="contact"
      class="font-medium flex items-center text-sm transition-colors hover:underline"
    >
      Contact
    </a>
  </nav>

  <div class="justify-self-end flex gap-4">
    {#if !signedIn}
      <Dialog.Root>
        <Dialog.Trigger class={buttonVariants({ variant: "outline", size: "sm"})}>
          Sign in
        </Dialog.Trigger>
        <Dialog.Content>
          <Dialog.Header>
            <Dialog.Title>Sign in</Dialog.Title>
          </Dialog.Header>
          <SignIn />
        </Dialog.Content>
      </Dialog.Root>

      <Dialog.Root>
        <Dialog.Trigger class={buttonVariants({ size: "sm"})}>
          Sign up
        </Dialog.Trigger>
        <Dialog.Content>
          <Dialog.Header>
            <Dialog.Title>Sign up</Dialog.Title>
          </Dialog.Header>
           <SignUp />
        </Dialog.Content>
      </Dialog.Root>
    {:else}
      <Dialog.Root>
        <Dialog.Trigger class={cn(buttonVariants({ size: "sm", variant: "outline" }))}>
          <ShoppingCart />
          <span class="sr-only">Cart</span>
        </Dialog.Trigger>
        <Dialog.Content>
          <Dialog.Header>
            <Dialog.Title>Cart</Dialog.Title>
            <Dialog.Description>Items you wanna buy :D</Dialog.Description>
          </Dialog.Header>
           <!-- TODO: make better -->
          <ul>
            {#each cart!.products as product}
              <li>{product.name}, {product.price}</li>
            {/each}
          </ul>
          {#if cart!.products.length > 0}
            <Button class="relative">Purchase<span class="text-xs italic absolute right-1 bottom-1">(it does nothing)</span></Button>
          {/if}
        </Dialog.Content>
      </Dialog.Root>
    {/if}
  </div>
</nav>
