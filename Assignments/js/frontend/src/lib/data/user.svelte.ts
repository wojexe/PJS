import axios from "axios";

import { Cart } from "$lib/data/cart.svelte";

import { PUBLIC_API_URL } from "$env/static/public";
import type { Product } from "./product.svelte";

class User {
  id: string;
  email: string;
  cart: Cart = $state(new Cart(undefined));

  constructor(id: string, email: string, cart?: Cart) {
    this.id = id;
    this.email = email;
    this.cart = cart ?? new Cart(undefined);
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

  static async Me() {
    try {
      const response = await axios.get<{ userID: string; email: string }>(
        new URL("auth/me", PUBLIC_API_URL).toString(),
        { withCredentials: true },
      );

      if (response.status === 200) {
        const { userID, email } = response.data;
        currentUser = new User(userID, email);

        return { id: userID, email };
      }
    } catch (e) {}

    console.log("You're a guest!");
    currentUser = null;
    return null;
  }

  async signOut() {
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

  addToCart = (product: Product) => this.cart.add(product);
  canAddToCart = (product: Product) => this.cart.canAdd(product);
}

let currentUser = $state.raw<User | null>(null);

const getCurrentUser = () => currentUser;

/** **Use with caution!** */
const setCurrentUser = (user: User) => {
  currentUser = user;
};

export { User, getCurrentUser, setCurrentUser };
