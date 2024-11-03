<script lang="ts">
import { schema as loginSchema } from "$lib/components/forms/signIn/schema";
import * as Form from "$lib/components/ui/form";
import { Input } from "$lib/components/ui/input";
import axios from "axios";
import { defaults, superForm } from "sveltekit-superforms";
import SuperDebug from "sveltekit-superforms";
import { valibot } from "sveltekit-superforms/adapters";

const superForm_ = superForm(defaults(valibot(loginSchema)), {
  SPA: true,
  validators: valibot(loginSchema),
  async onUpdate({ form }) {
    console.log("onUpdate");
    if (!form.valid) return;

    const response = await axios.post(
      "https://localhost:3000/auth/login",
      null,
      {
        withCredentials: true,
        auth: { username: form.data.email, password: form.data.password },
      },
    );
  },
});

const { form, enhance } = superForm_;
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
  <Form.Button class="mt-2">Submit</Form.Button>
</form>

<div class="fixed bottom-0 right-0 w-96 translate-x-full scale-90 origin-bottom-left z-[9999]">
  <SuperDebug data={$form}/>
</div>
