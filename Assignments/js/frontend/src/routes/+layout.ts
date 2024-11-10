import type { LayoutLoad } from "./$types";
import { User } from "$lib/data/user.svelte";

export const load: LayoutLoad = () => {
  const me = User.Me();
  return { user: me };
};
