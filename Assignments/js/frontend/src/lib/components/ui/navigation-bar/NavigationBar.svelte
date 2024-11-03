<script lang="ts">
import { Button, buttonVariants } from "$lib/components/ui/button";
import * as Dialog from "$lib/components/ui/dialog";
import { cn } from "$lib/utils";

import { ShoppingCart, Store } from "lucide-svelte";

const signedIn = false;
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
    {#if signedIn === false}
      <Dialog.Root>
        <Dialog.Trigger>
          <Button variant="outline" size="sm">Sign in</Button>
        </Dialog.Trigger>
        <Dialog.Content>
          <Dialog.Header>
            <Dialog.Title>Sign in</Dialog.Title>
          </Dialog.Header>
          <!-- TODO: Sign in form content -->
        </Dialog.Content>
      </Dialog.Root>

      <Dialog.Root>
        <Dialog.Trigger>
          <Button size="sm">Sign up</Button>
        </Dialog.Trigger>
        <Dialog.Content>
          <Dialog.Header>
            <Dialog.Title>Sign up</Dialog.Title>
          </Dialog.Header>
          <!-- TODO: Sign up form content -->
        </Dialog.Content>
      </Dialog.Root>
    {:else}
      <!-- TODO: cart handling -->
      <a
        href="cart"
        class={cn(buttonVariants({ size: "sm", variant: "outline" }))}
      >
        <ShoppingCart />
        <span class="sr-only">Cart</span>
      </a>
    {/if}
  </div>
</nav>
