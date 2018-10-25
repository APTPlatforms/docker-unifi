## aptplatforms/unifi

### Docker image

[![](https://images.microbadger.com/badges/image/aptplatforms/unifi:latest.svg)](https://microbadger.com/images/aptplatforms/unifi:latest) [![](https://img.shields.io/docker/automated/aptplatforms/unifi.svg)](https://hub.docker.com/r/aptplatforms/unifi/builds/) [![](https://img.shields.io/docker/pulls/aptplatforms/unifi.svg)](https://hub.docker.com/r/aptplatforms/unifi/) [![](https://img.shields.io/docker/stars/aptplatforms/unifi.svg)](https://hub.docker.com/r/aptplatforms/unifi/)

[Ubiquiti UniFi Controller](https://www.ubnt.com/download/unifi/default/default/unifi-sdn-controller-5828-debianubuntu-linux) in a Docker container. Features include:

- As small as possible and as large as necessary.
- FROM [Debian 9](https://hub.docker.com/\_/debian/)
- Uses [Tr&aelig;fik](https://traefik.io/) with [Let's Encrypt](https://letsencrypt.org/) to provide HTTPS for both the Controller interface and the builtin Captive Portal.
- Allows reuse of an existing Tr&aelig;fik configuration instead of a
  dedicated UniFi controller host.

### Summary

- [Docker Tags](#docker-tags)
- [Prerequisites](#prerequisites)
- [Installation](#installation)


### Docker Tags

- 5.9.29 (latest) &rarr; [Release Notes](https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-SDN-Controller-5-9-29-Stable-has-been-released/ba-p/2516852)
    - `docker pull aptplatforms/unifi:5.9.29`

- 5.8.30 &rarr; [Release Notes](https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-SDN-Controller-5-8-30-Stable-has-been-released/ba-p/2489957)
    - `docker pull aptplatforms/unifi:5.8.30`

- 5.8.28 &rarr; [Release Notes](https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-SDN-Controller-5-8-28-Stable-has-been-released/ba-p/2449036)
    - `docker pull aptplatforms/unifi:5.8.28`

- 5.8.24 &rarr; [Release Notes](https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-SDN-Controller-5-8-24-Stable-has-been-released/ba-p/2404580)
    - `docker pull aptplatforms/unifi:5.8.24`

- 5.7.23 &rarr; [Release Notes](https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-5-7-23-Stable-has-been-released/ba-p/2318813)
    - `docker pull aptplatforms/unifi:5.7.23`
    - 5.7.23 is deprecated and probably won't work with the Tr&aelig;fik configuration unless you want to change docker-entrypoint.sh yourself and build a new image.

### Prerequisites

#### Ports

If you have a firewall, unblock the following ports, according to your needs :

| Service | Container | Protocol | Port | Description |
| ------- | --------- | -------- | ---- | ----------- |
| unifi.http.port | unifi | TCP | 8080 | UAP Inform port. Open to wherever your UniFi devices are installed. |
| STUN | unifi | TCP | 3478 | [Session Traversal Utilities for NAT](https://help.ubnt.com/hc/en-us/articles/115015457668-UniFi-Troubleshooting-STUN-Communication-Errors#whatisstun). Open to wherever your UniFi devices are installed. |
| HTTP | Tr&aelig;fik | TCP | 80 | Open to 0.0.0.0/0 for Let's Encrypt |
| HTTPS | Tr&aelig;fik | TCP | 443 | Open to 0.0.0.0/0 for Let's Encrypt |

#### DNS records

A correct DNS setup is required. The Tr&aelig;fik configuration relies on
forward DNS lookups (from the Host header) to correctly resolve each service.
Since we're running all services on the same host, we need the same IP address
for each.

You can use A records like this :

| Hostname | Class | Type | Priority | Value |
| -------- | ----- | ---- | -------- | ----- |
| unifi | IN | A | any | 1.2.3.4 |
| portal | IN | A | any | 1.2.3.4 |
| traefik | IN | A | any | 1.2.3.4 |

Or you can use CNAME records like this :

| Hostname | Class | Type | Priority | Value |
| -------- | ----- | ---- | -------- | ----- |
| unifi | IN | A | any | 1.2.3.4 |
| portal | IN | CNAME | any | unifi.example.com. |
| traefik | IN | CNAME | any | unifi.example.com. |

### Installation

#### 1 - Prepare your environment

:bulb: The reverse proxy used in this setup is [Tr&aelig;fik](https://traefik.io/), but you can use the solution of your choice (Nginx, Apache, Haproxy, Caddy, H2O...etc).

:warning: This docker image may not work with some hardened Linux distribution using security-enhancing kernel patches like GrSecurity, please use a [supported platform](https://docs.docker.com/install/#supported-platforms).

```bash
# Create a new docker network for Traefik (IPv4 only)
docker network create public_network

# Create the required folders and files
mkdir -p traefik/acme unifi/backup \
&& curl https://raw.githubusercontent.com/APTPlatforms/docker-unifi/master/docker-compose.sample.yml -o docker-compose.yml \
&& curl https://raw.githubusercontent.com/APTPlatforms/docker-unifi/master/sample.env -o .env \
&& curl https://raw.githubusercontent.com/APTPlatforms/docker-unifi/master/traefik.sample.toml -o traefik/traefik.toml \
&& touch traefik/acme/acme.json \
&& chmod 00600 docker-compose.yml .env traefik/traefik.toml traefik/acme/acme.json
```

#### 2 - Edit configuration files

Edit `docker-compose.yml` and `.env` and `traefik.toml`, adapt to your needs.

#### 3 - Start services

Start all services :

```
docker-compose up -d
```

Visit <https://traefik.example.com/> to see the Tr&aelig;fik dashboard.

#### 4 - Configure the controller

- Visit <https://unifi.example.com/> to login to your controller.
- After configuring standard controller settings, set:
    - `Guest Control` &rarr; `Guest Portal` &rarr; `Enable Guest Portal = True`.
    - `Guest Control` &rarr; `Redirection` &rarr; `Use Secure Portal = True`.
    - `Guest Control` &rarr; `Redirection` &rarr; `Redirect using hostname = portal.example.com`.
