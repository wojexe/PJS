<script lang="ts">
import ModeToggle from "$lib/components/ui/ModeToggle.svelte";
import "../app.css";

import { ModeWatcher } from "mode-watcher";

const { children } = $props();
</script>

<ModeWatcher />
<ModeToggle />
{@render children()}
