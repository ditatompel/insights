---
title: "Public API Monero Remote Node List"
description: "API documentation to search for monitored Monero remote nodes on www.ditatompel.com. You can filter based on nettype, countries and more."
date: 2022-01-29T23:40:26+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
#  - 
tags:
  - Monero
  - API
images:
#  - 
# menu:
#   main:
#     weight: 100
#     params:
#       icon:
#         vendor: bs
#         name: book
#         color: '#e24d0e'
authors:
  - ditatompel
---

Since the Monero remote nodes that I monitor are increasing and my page that displays a list of Monero remote nodes **MAY** contains Google AdSense (where very likely track users behavior and interests), I decided to create an API endpoint so that power users / developers can use it without visiting my site.

<!--more-->

## Updates

### Update 2023-05-24
- I've add `cors` and `last_check_statuses` to nodes data record.

### Update 2022-05-10
- I've add `estimate_fee` to nodes data record which I get from [get_fee_estimate](https://www.getmonero.org/resources/developer-guides/daemon-rpc.html#get_fee_estimate) daemon RPC. This just fee estimation, moneromooo explain that malicious actors who running remote nodes [still can return high fee only when you about to create a transactions](monero-tx-fee-node.jpg).
- [selsta](https://github.com/selsta) create [pull request](https://github.com/monero-project/monero-gui/pull/3897) to add warning about high fee on official GUI conformation dialog.
- **The best and safest way is running your own node!**
- Nodes with 0% uptime within 1 month with more than 500 check attempt will be removed. You can always add your node again latter.

## Endpoint and Query Parameters
| Method | Endpoint                                          |
| ------ | ------------------------------------------------- |
| GET    | https://www.ditatompel.com/api/monero/remote-node |

The response will display all the Monero remote node sorted from the highest percentage of uptime.

Optional query string parameters:
- `protocol`: Available options:
    - `http`: Return node using http RPC (including Tor network).
    - `https`: Return nodes using https RPC.
    - `tor`: Return nodes on Tor network.
- `nettype`: Available options:
    - `mainnet`: Return mainnet nodes.
    - `stagenet`: Return stagenet nodes.
    - `testnet`: Return testnet nodes.
- `country`: Filter nodes from specific country. Please use two-letter [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code.
- `orderby`: Default sorted from highest percentage of uptime. Available options:
    - `uptime-asc`: sorted from lowest percentage of uptime.
    - `lastcheck-asc`: sorted from oldest checked node,
    - `lastcheck-desc`: sorted from newest checked node (recently checked).
- `limit`: How many records should be displayed.
- `cors`: Filter nodes that have `Access-Control-Allow-Origin` header or not. Options:
  - `true` or `1` or the `cors` query string **is set**: Return nodes that have `Access-Control-Allow-Origin` header.
  - `false` or `0`: Return nodes that does not have `Access-Control-Allow-Origin` header.

For example, if you want to **list CORS enabled Monero nodes using https from United States sorted from recently checked node**:
```shell
curl -sL 'https://www.ditatompel.com/api/monero/remote-node?cors=true&protocol=https&country=us&orderby=lastcheck-desc' | jq
```

## Response Header
The response header includes the **HTTP status code** and the `content-type`. Clients that receive a HTTP status code other than `200` and `content-type` other than `application/json` must back-off.

In addition, I added custom headers `x-ditatompel-rate-limit-*` to limit users from making excessive queries to the server.

- `x-ditatompel-rate-limit-limit`: Your IP address initial quota for given period.
- `x-ditatompel-rate-limit-remaining`: Approximate number of requests left to use.
- `x-ditatompel-rate-limit-reset`: Approximate number of seconds to end of period.

The ratelimits period is currently set to 1 hour and initial quota is 3600 requests. It means 1 request every second per IP (you won't get different result if you perform same API calls in short period of time anyway).

## Response Body
The response body includes the information of the query result, query status, and error messages, if available, and metadata for debugging purpose. In the example below, the response body of:

```shell
curl -sL 'https://www.ditatompel.com/api/monero/remote-node?protocol=https&country=id' | jq
```

```json
{
  "success": 1,
  "status": "ok",
  "message": "Query success",
  "data": [
    {
      "hostname": "xmrnode1.ditatompel.com",
      "port": 443,
      "ip_address": "103.244.206.102",
      "protocol": "https",
      "is_tor": false,
      "status": "online",
      "nettype": "mainnet",
      "last_height": 2892329,
      "adjusted_time": 1684869115,
      "database_size": 171798691840,
      "difficulty": 282381487137,
      "uptime": 99.49,
      "estimate_fee": 20000,
      "asn": 131759,
      "asn_name": "IDNIC-WDS-AS-ID",
      "country": "ID",
      "city": "Tangerang",
      "postal": 0,
      "last_checked": 1684869296,
      "cors": true,
      "last_check_statuses": [
        null,
        1,
        0,
        1,
        1
      ]
    }
  ],
  "@meta": {
    "cache": true,
    "ttl": 32,
    "response_time": 0.332
  }
}
```

- `success`: *unsigned int*, `1` means everything looks good.
- `status`: *string*, `ok` means everything looks good.
- `message`: *string*, Information related to your query, *success* or *error* message if any.
- `data`:  *array* of nodes structure as follows:
  - `hostname`: *string*, The hostname / nodes IP address.
  - `port`: *unsigned int*; TCP port the nodes is using to listen to RPC calls.
  - `protocol`: *string*, The protocol used by nodes to listen RPC calls. This can be `http`, `https` or `empty string`.
  - `is_tor`: *boolean*, whether the node is accessed through the Tor network.
  - `status`: *string*, General Monero daemon RPC status. `online` means everything looks good and nodes is syncronized to the network, `offline` means node wasn't ready or my bots can't connect to nodes RPC daemon.
  - `nettype`: *string*; Network type (one of `mainnet`, `stagenet` or `testnet`).
  - `last_height`: *unsigned int*; Current length of longest chain known to daemon.
  - `adjusted_time`: *unsigned int*; Current time approximated from chain data, as Unix time.
  - `database_size`: *unsigned int*; The size of the blockchain database, in bytes.
  - `difficulty`: *unsigned int*; Least-significant 64 bits of the 128-bit network difficulty.
  - `uptime`: *float*, Uptime percentage of nodes for last 1 month. This likely **not** the real uptime value since my bots may experiencing network problems (I set connection timeout for 10 seconds).
  - `estimate_fee`: *unsigned int*; Amount of fees estimated per byte in atomic units. This just fee estimation, Malicious actors who running remote nodes [still can return high fee only when you about to create a transactions](monero-tx-fee-node.jpg).
  - `asn`: *unsigned int*, The AS number that owns nodes IP address.
  - `asn_name`: *string*, The AS name that owns nodes IP address
  - `country`: *string*, two-letter ISO 3166-1 country code nodes location, empty string if no information available.
  - `city`: *string*, City location based on nodes IP address, empty string if no information available.
  - `postal`: *unsigned int*, Postal code based on nodes IP address, `0` if no information available.
  - `last_checked`: *unsigned int*, The Unix time when my bots check the nodes status.
  - `cors`: *boolean*, whether the node return with `Access-Control-Allow-Origin` header or not.
  - `last_check_statuses`: *array* (size: 5) of last node status avaibility status. Possible values:
    - `null` : not yet checked.
    - `0`: Offline
    - `1`: Online
- `@meta`: *object*, Additional information related to API calls for debuging purpose.

>  You will get `200` response code, `ok` status, and **empty array** of data even if your query return no data.

> _**NOTE**: My API endpoint is behind Cloudflare reverse proxy, so it's still cost your privacy. Monero community suggests to always run your own node to obtain the maximum possible privacy and to help decentralize the network._
