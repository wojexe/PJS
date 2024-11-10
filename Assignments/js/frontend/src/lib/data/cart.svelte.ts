import type { Product } from "$lib/data/product.svelte";

class Cart {
  private _products: Array<Product>;
  public get products(): Array<Product> {
    return this._products;
  }

  constructor(products: Array<Product> | null) {
    this._products = products ?? [];
  }

  add(product: Product) {
    this._products.push(product);
  }
}

export { Cart };
