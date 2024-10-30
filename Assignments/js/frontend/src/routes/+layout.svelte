<script lang="ts">
import "../app.css";

import { ModeWatcher } from "mode-watcher";

import { NavigationBar } from "$lib/components/ui/navigation-bar";
import { Footer } from "$lib/components/ui/footer";

const { children } = $props();
</script>

<ModeWatcher />

<NavigationBar />

<div class="min-h-full p-6 flex flex-col">
  {@render children()}
</div>

<Footer />
