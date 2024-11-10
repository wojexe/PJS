import type { Handle } from "@sveltejs/kit";

import { User } from "$lib/data/user.svelte";

export const handle: Handle = async ({ event, resolve }) => {
  try {
    const me = await User.Me();

    if (me != null) {
      event.locals.user = me;
      console.log("You're logged in :)");
    } else {
      console.log("You're a guest!");
    }
  } catch (e) {
    console.error(e);
  }

  return await resolve(event);
};
