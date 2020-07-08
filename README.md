## aptplatforms/unifi

### Docker image

[![][microbadger-img]](https://microbadger.com/images/aptplatforms/unifi:latest)
[![][shields-automated-img]](https://hub.docker.com/r/aptplatforms/unifi/builds/)
[![][shields-pulls-img]](https://hub.docker.com/r/aptplatforms/unifi/)
[![][shields-stars-img]](https://hub.docker.com/r/aptplatforms/unifi/)


[Ubiquiti UniFi Controller] in a Docker container. Features include:

- As small as possible and as large as necessary.
- `FROM` [debian:9-slim]
- Uses [Tr&aelig;fik] with [Let's Encrypt] to provide HTTPS for both the
  Controller interface and the builtin Captive Portal.
- Allows reuse of an existing Tr&aelig;fik configuration instead of a
  dedicated UniFi controller host.

### Summary

- [Docker Tags](#docker-tags)
- [Prerequisites](#prerequisites)
- [Installation](#installation)


### Docker Tags

- 5.13.32 (latest) &rarr; [Release Notice 5.13.32]
    - `docker pull aptplatforms/unifi:5.13.32`

- 5.11.50 &rarr; [Release Notice 5.11.50]
    - `docker pull aptplatforms/unifi:5.11.50`

- 5.11.46 &rarr; [Release Notice 5.11.46]
    - `docker pull aptplatforms/unifi:5.11.46`

- 5.10.25 &rarr; [Release Notice 5.10.25]
    - `docker pull aptplatforms/unifi:5.10.25`

- 5.10.21 &rarr; [Release Notice 5.10.21]
    - `docker pull aptplatforms/unifi:5.10.21`

- 5.10.19 &rarr; [Release Notice 5.10.19]
    - `docker pull aptplatforms/unifi:5.10.19`

- 5.10.17 &rarr; [Release Notice 5.10.17]
    - `docker pull aptplatforms/unifi:5.10.17`

- 5.9.29 &rarr; [Release Notice 5.9.29]
    - `docker pull aptplatforms/unifi:5.9.29`

- 5.8.30 &rarr; [Release Notice 5.8.30]
    - `docker pull aptplatforms/unifi:5.8.30`

- 5.8.28 &rarr; [Release Notice 5.8.28]
    - `docker pull aptplatforms/unifi:5.8.28`

- 5.8.24 &rarr; [Release Notice 5.8.24]
    - `docker pull aptplatforms/unifi:5.8.24`

- 5.7.23 &rarr; [Release Notice 5.7.23]
    - `docker pull aptplatforms/unifi:5.7.23`
    - 5.7.23 is deprecated and probably won't work with the Tr&aelig;fik
      configuration unless you want to change `docker-entrypoint.sh` yourself and build a new image.

### Prerequisites

#### Ports

If you have a firewall, unblock the following ports, according to your needs :

| Service | Container | Protocol | Port | Description |
| ------- | --------- | -------- | ---- | ----------- |
| unifi.http.port | unifi | TCP | 8080 | UAP Inform port. Open to wherever your UniFi devices are installed. |
| STUN | unifi | TCP | 3478 | [Session Traversal Utilities for NAT]. Open to wherever your UniFi devices are installed. |
| HTTP | Tr&aelig;fik | TCP | 80 | Open to 0.0.0.0/0 for [Let's Encrypt] |
| HTTPS | Tr&aelig;fik | TCP | 443 | Open to 0.0.0.0/0 for [Let's Encrypt] |

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

:bulb: The reverse proxy used in this setup is [Tr&aelig;fik], but you can use the solution of your choice (Nginx, Apache, Haproxy, Caddy, H2O...etc).

:warning: This docker image may not work with some hardened Linux distribution using security-enhancing kernel patches like GrSecurity, please use a [supported platform].

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

Start all services.

```bash
docker-compose up -d
```

Visit <https://traefik.example.com/> to see the Tr&aelig;fik dashboard.

#### 4 - Configure the controller

- Visit <https://unifi.example.com/> to login to your controller.
- After configuring standard controller settings, set:
    - `Guest Control` &rarr; `Guest Portal` &rarr; `Enable Guest Portal = True`.
    - `Guest Control` &rarr; `Redirection` &rarr; `Use Secure Portal = True`.
    - `Guest Control` &rarr; `Redirection` &rarr; `Redirect using hostname = portal.example.com`.

[microbadger-img]: https://images.microbadger.com/badges/image/aptplatforms/unifi:latest.svg
[shields-automated-img]: https://img.shields.io/docker/automated/aptplatforms/unifi.svg
[shields-pulls-img]: https://img.shields.io/docker/pulls/aptplatforms/unifi.svg
[shields-stars-img]: https://img.shields.io/docker/stars/aptplatforms/unifi.svg

[debian:9-slim]: https://hub.docker.com/\_/debian/
[Tr&aelig;fik]: https://traefik.io/
[Let's Encrypt]: https://letsencrypt.org/
[Session Traversal Utilities for NAT]: https://help.ubnt.com/hc/en-us/articles/115015457668-UniFi-Troubleshooting-STUN-Communication-Errors#whatisstun
[supported platform]: https://docs.docker.com/install/#supported-platforms

[Ubiquiti UniFi Controller]: https://www.ui.com/download/unifi/default/default/unifi-network-controller-51332-debianubuntu-linux-and-unifi-cloud-key
[Release Notice 5.13.32]: https://community.ui.com/releases/UniFi-Network-Controller-5-13-32/85eee834-c987-4875-8de2-51c6842d7bd3
[Release Notice 5.11.50]: https://community.ui.com/releases/UniFi-Network-Controller-5-11-50/1728a1f1-f0a8-45dd-a2e2-95abcfc50dab
[Release Notice 5.11.46]: https://community.ui.com/releases/UniFi-Network-Controller-5-11-46/1984aaf0-7243-4257-af83-70126714613e
[Release Notice 5.10.25]: https://community.ui.com/releases/UniFi-Network-Controller-Stable-5-10-25/fc76945d-c918-4d8d-8cd1-094d05287f45
[Release Notice 5.10.21]: https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-Network-Controller-5-10-21-Stable-has-been-released/ba-p/2741854
[Release Notice 5.10.19]: https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-Network-Controller-5-10-19-Stable-has-been-released/ba-p/2695209
[Release Notice 5.10.17]: https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-Network-Controller-5-10-17-Stable-has-been-released/ba-p/2676018
[Release Notice 5.9.29]: https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-SDN-Controller-5-9-29-Stable-has-been-released/ba-p/2516852
[Release Notice 5.8.30]: https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-SDN-Controller-5-8-30-Stable-has-been-released/ba-p/2489957
[Release Notice 5.8.28]: https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-SDN-Controller-5-8-28-Stable-has-been-released/ba-p/2449036
[Release Notice 5.8.24]: https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-SDN-Controller-5-8-24-Stable-has-been-released/ba-p/2404580
[Release Notice 5.7.23]: https://community.ubnt.com/t5/UniFi-Updates-Blog/UniFi-5-7-23-Stable-has-been-released/ba-p/2318813
