# 🏪 Store - backend

## How to run

1. Install dependencies

```sh
bun install
```

2. Get locally trusted certificates into `./certs` folder (`cert.pem` and `key.pem`)

3. Run development server

```sh
bun run dev
```

4. The server will be running @ https://localhost:3000

## Available routes

To visit routes marked with 🔐, you need to be logged in (have the `user-session` token in your cookies).

```plaintext
GET   /
POST  /auth/login
POST  /auth/register
POST  /auth/logout 🔐
GET   /auth/me 🔐
GET   /api/store/products
GET   /api/store/categories
POST  /api/store/purchase 🔐
GET   /ping
```
