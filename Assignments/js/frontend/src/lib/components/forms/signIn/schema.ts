import * as v from "valibot";

export const schema = v.strictObject({
  email: v.pipe(v.string(), v.email(), v.maxLength(256)),
  // TODO: should probably include a minLength (backend side) :P
  password: v.pipe(v.string(), v.minLength(8), v.maxLength(256)),
});

export type FormSchema = v.InferOutput<typeof schema>;
