export const escapeApostrophes = (x: unknown) => {
  if (typeof x === "string") {
    return x.split("'").join("''");
  }
  return x;
};

export const quoteString = (x: unknown) => {
  if (typeof x === "string") {
    return `'${x}'`;
  }
  return x;
};
