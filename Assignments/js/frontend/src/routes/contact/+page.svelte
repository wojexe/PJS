<script lang="ts">
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "$lib/components/ui/card";

const email = "wojciech@sierotowicz.com";
</script>

<svelte:head>
  <title>contact @ wojexe's shop</title>
</svelte:head>

<main class="contents">
  <Card class="self-center min-w-64">
    <CardHeader>
      <CardTitle>Contact</CardTitle>
    </CardHeader>
    <CardContent>
      Email: <a href={`mailto:${email}`} class="underline">{email}</a>
    </CardContent>
  </Card>
</main>
