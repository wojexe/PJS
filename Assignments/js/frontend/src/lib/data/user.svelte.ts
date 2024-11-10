import axios from "axios";

import { Cart } from "$lib/data/cart.svelte";

import { PUBLIC_API_URL } from "$env/static/public";
import type { Product } from "./product.svelte";

class User {
  id: string;
  email: string;
  cart: Cart;

  constructor(id: string, email: string) {
    this.id = id;
    this.email = email;
    this.cart = new Cart(null);
  }

  static async SignIn(email: string, password: string) {
    const response = await axios.post(
      new URL("auth/login", PUBLIC_API_URL).toString(),
      null,
      {
        withCredentials: true,
        auth: { username: email, password },
      },
    );

    if (response.status === 200) {
      currentUser = new User(response.data.userID, email);
      console.log("Sign in successful!");
    } else {
      throw new Error("[User.SignIn] Werid that we got here...");
    }
  }

  static async SignUp(email: string, password: string) {
    const response = await axios.post(
      new URL("auth/register", PUBLIC_API_URL).toString(),
      { email, password },
    );

    if (response.status === 201) {
      currentUser = new User(response.data.userID, email);
      console.log("Sign up successful!");
    } else {
      throw new Error("[User.SignUp] Werid that we got here...");
    }
  }

  static async SignOut() {
    const response = await axios.post(
      new URL("auth/logout", PUBLIC_API_URL).toString(),
      null,
      {
        withCredentials: true,
      },
    );

    if (response.status === 200) {
      currentUser = null;
      console.log("Sign out successful!");
    } else {
      throw new Error("[User.SingOut] Werid that we got here...");
    }
  }

  static async Me() {
    const response = await axios.get<{ userID: string; email: string }>(
      new URL("auth/me", PUBLIC_API_URL).toString(),
      { withCredentials: true },
    );

    if (response.status === 200) {
      const { userID, email } = response.data;
      currentUser = new User(userID, email);

      console.log("You're logged in!");

      return { id: userID, email };
    }

    console.log("You're a guest!");
    return null;
  }

  addToCard(product: Product) {
    this.cart.add(product);
    console.log(this.cart.products);
  }
}

let currentUser = $state.raw<User | null>(null);

const getCurrentUser = () => currentUser;

/** **Use with caution!** */
const setCurrentUser = (user: User) => {
  currentUser = user;
};

export { User, getCurrentUser, setCurrentUser };
