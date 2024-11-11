# Lua - Store in Lapis/Moonscript

The server was developed inside of a docker container specified by Dockerfile and started using the below command.

```sh
docker run -it --rm --name=lua-pjs -v ./server:/lua-pjs ubuntu-lua
```

To run the server inside of the container paste:

```sh
cd lua-pjs && moonc . && lapis server
```

