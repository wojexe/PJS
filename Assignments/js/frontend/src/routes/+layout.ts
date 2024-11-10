import { User } from "$lib/data/user.svelte";
import type { LayoutLoad } from "./$types";

export const load: LayoutLoad = ({ url }) => {
  const me = User.Me();
  return { user: me };
};
