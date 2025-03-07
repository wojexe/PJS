<script lang="ts">
import "../app.css";

import { ModeWatcher } from "mode-watcher";

import { Footer } from "$lib/components/ui/footer";
import { NavigationBar } from "$lib/components/ui/navigation-bar";

import { Cart } from "$lib/data/cart.svelte";
import type { Product } from "$lib/data/product.svelte";
import { User, getCurrentUser, setCurrentUser } from "$lib/data/user.svelte";
import type { Snapshot } from "./$types";

const { children } = $props();

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

<ModeWatcher />

<NavigationBar />

<div class="min-h-full p-6 flex flex-col">
  {@render children()}
</div>

<Footer />
