<script lang="ts">
import {
	Card,
	CardHeader,
	CardTitle,
	CardContent,
} from "$lib/components/ui/card";

const email = "wojciech@sierotowicz.com";
</script>

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
