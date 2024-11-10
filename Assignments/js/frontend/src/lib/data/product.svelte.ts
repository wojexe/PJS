class Product {
  id: string;
  name: string;
  description: string;
  categories: Array<{ id: string; name: string }>;
  price: number;
  quantity: number;

  constructor(
    id: string,
    name: string,
    description: string,
    categories: Array<{ id: string; name: string }>,
    price: number,
    quantity: number,
  ) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.categories = categories;
    this.price = price;
    this.quantity = quantity;
  }
}

export { Product };
