# Wireguard Docker Demo

Simple test-bed for launching dockerized instances of wireguard.

## How To Use

Clone this repository and enter the directory
```
git clone *repository url*
cd wireguard-docker-demo
```

Start a new docker instance for the client and server.
*Make sure that you have docker installed.*
```
In terminal A:
./start.sh server # Launches instance with 'server' folder mounted.

In terminal B:
./start.sh client # Launches instance with 'client' folder mounted.

You can launch as many terminals and instances as you like.
./start.sh name_of_local_folder

See ./start.sh -h for more options.
```

Use `ifconfig eth0` to see the IP address for each container.

Use `wg genkey | tee privatekey | wg pubkey > publickey` in order to generate a private and public key-pair for each instance. Paste these keys into the `wg0.conf` located in each folder (client and server).

Once configured, use `wg-quick up wg0` within each terminal in order to bring up wireguard with your configuration.

## Resources

Official Wireguard Guide
https://www.wireguard.com/quickstart

Unofficial Wireguard Docs
https://github.com/pirate/wireguard-docs

Wireguard-tools Manual Page
https://git.zx2c4.com/wireguard-tools/about/src/man/wg.8

Wireguard Config Generator
https://www.wireguardconfig.com/
