<script lang="ts">
import { schema as loginSchema } from "$lib/components/forms/signIn/schema";
import * as Form from "$lib/components/ui/form";
import { Input } from "$lib/components/ui/input";

import { User } from "$lib/data/user.svelte";

import { type AxiosError } from "axios";

import { defaults, setMessage, superForm } from "sveltekit-superforms";
import SuperDebug from "sveltekit-superforms";
import { valibot } from "sveltekit-superforms/adapters";

const superForm_ = superForm(defaults(valibot(loginSchema)), {
  SPA: true,
  validators: valibot(loginSchema),
  async onUpdate({ form }) {
    if (!form.valid) return;

    try {
      const { email, password } = form.data;
      await User.SignIn(email, password);
    } catch (e) {
      const error = e as AxiosError;
      setMessage(form, error.message);
    }
  },
});

const { form, enhance, message } = superForm_;
</script>

<form method="POST" action="?signin" use:enhance>
  <Form.Field form={superForm_} name="email">
    <Form.Control>
      {#snippet children({ props })}
        <Form.Label>Email</Form.Label>
        <Input type="email" {...props} bind:value={$form.email} />
      {/snippet}
    </Form.Control>
    <Form.FieldErrors />
  </Form.Field>

  <Form.Field form={superForm_} name="password">
    <Form.Control>
      {#snippet children({ props })}
        <Form.Label>Password</Form.Label>
        <Input type="password" {...props} bind:value={$form.password} />
      {/snippet}
    </Form.Control>
    <Form.FieldErrors />
  </Form.Field>
  {#if $message}
    <div>Error: <span class="text-red-500 font-mono">{$message}</span></div>
  {/if}
  <Form.Button class="mt-2">Submit</Form.Button>
</form>

<div class="fixed bottom-0 right-0 w-96 translate-x-full scale-90 origin-bottom-left z-[9999]">
  <SuperDebug data={$form}/>
</div>
