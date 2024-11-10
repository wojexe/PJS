import type { Product } from "$lib/data/product.svelte";

import { SvelteMap } from "svelte/reactivity";

class Cart {
  private _products: Map<string, Product> = new SvelteMap();
  private _quantities: Map<string, number> = new SvelteMap();

  public get products(): Array<Product> {
    return [...this._products.values()].flatMap((product) => {
      const quantity = this._quantities.get(product.id);
      if (quantity == null) throw new Error("Product without quantity");
      return Array(quantity).fill(product);
    });
  }

  public get productsWithQuantities() {
    return [...this._products.values()].map((product) => ({
      product: product,
      quantity:
        this._quantities.get(product.id) ??
        (() => {
          throw new Error("Product without quantity");
        })(),
    }));
  }

  public get total(): number {
    return this.products.reduce((sum, product) => sum + product.price, 0);
  }

  constructor(products?: Array<Product>) {
    for (const product of products ?? []) {
      this.add(product);
    }
  }

  add(product: Product) {
    const quantity = this._quantities.get(product.id) ?? 0;

    if (quantity >= product.quantity)
      throw new Error("No more available products");

    this._products.set(product.id, product);
    this._quantities.set(product.id, quantity + 1);
  }

  canAdd(product: Product) {
    const quantity = this._quantities.get(product.id) ?? 0;

    if (quantity >= product.quantity) return false;

    return true;
  }

  order() {
    console.log(
      "posting an order for: ",
      $state.snapshot(this._products),
      $state.snapshot(this._quantities),
    );

    this.clear();
  }

  clear() {
    this._products.clear();
    this._quantities.clear();
  }
}

export { Cart };
