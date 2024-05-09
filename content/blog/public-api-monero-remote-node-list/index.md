---
title: "Public API Monero Remote Node List"
description: "API documentation to search for monitored Monero remote nodes on xmr.ditatompel.com. You can filter based on nettype, countries and more."
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

Since my main site that displays list of Monero remote nodes **MAY** contains Google AdSense (where very likely track users behavior and interests), I decided create dedicated subdomain for my Monero Remote Node pages and it's API endpoint. No Ads, no user tracking.

<!--more-->

- Web interface: [https://xmr.ditatompel.com/](https://xmr.ditatompel.com/).
- Source Code: Available for public soon.

## API Endpoint and Query Parameters

| Method | Endpoint                                  |
| ------ | ----------------------------------------- |
| GET    | `https://xmr.ditatompel.com/api/v1/nodes` |

The default response will display 10 records, sorted from `last_checked` node.

Optional query string parameters:
- `host`: Filter nodes based on hostname or IP address.
- `protocol`: Possible values:
    - `any` or _empty string_ or _not set_: Return nodes using any protocol.
    - `http`: Return node using http RPC (excluding Tor network).
    - `https`: Return nodes using https RPC.
    - `tor`: Return nodes on Tor network.
- `nettype`: Possible values:
    - `mainnet`: Return mainnet nodes.
    - `stagenet`: Return stagenet nodes.
    - `testnet`: Return testnet nodes.
    - `any` or _empty string_ or _not set_: No filtering based on nettype is applied.
- `cc`: Filter nodes from specific country. Please use two-letter [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code.
- `sort_by`: Default sorted by last check time. Possible values:
    - `last_checked`: sorted by last check time (default).
    - `uptime`: sorted by percentage of uptime.
- `sort_direction`: Possible values:
    - `desc`: descending (default).
    - `asc`: ascending.
- `status` Node status. Possible values :
    - `-1` or not set: both online and offline (default).
    - `1`: only online nodes.
    - `0`: only offline nodes.
- `limit`: How many records should be displayed.
- `page`: For paging porpose.
- `cors`: Filter nodes that have `Access-Control-Allow-Origin` header or not. Options:
    - `1`: Return nodes that have `Access-Control-Allow-Origin` header.
    - `-1`: No CORS filter is applied (default).

For example, if you want to **list CORS enabled Monero nodes using https from United States sorted from recently checked node**:
```shell
curl -sL 'https://xmr.ditatompel.com/api/v1/nodes?cors=1&protocol=https&country=us&sort_by=last_checked&sort_direction=desc' | jq
```

## Response Header
The response header includes the **HTTP status code** and the `content-type`. Clients that receive a HTTP status code other than `200` and `content-type` other than `application/json` must back-off.

## Response Body
The response body includes the information of the query result, query status, and response message. In the example below, the response body of:

```shell
curl -sL 'https://xmr.ditatompel.com/api/v1/nodes?country=SG' | jq
```

```json
{
  "status": "ok"
  "message": "Success",
  "data": {
    "total_rows": 1,
    "rows_per_page": 10,
    "items": [
      {
        "id": 3,
        "hostname": "xmr-node.cakewallet.com",
        "ip": "192.46.228.85",
        "port": 18081,
        "protocol": "http",
        "is_tor": false,
        "is_available": true,
        "nettype": "mainnet",
        "height": 3145189,
        "adjusted_time": 1715259907,
        "database_size": 209379655680,
        "difficulty": 243377341744,
        "version": "",
        "uptime": 100,
        "estimate_fee": 20000,
        "asn": 63949,
        "asn_name": "Akamai Connected Cloud",
        "cc": "SG",
        "country_name": "Singapore",
        "city": "Singapore",
        "latitude": 0,
        "longitude": 0,
        "date_entered": 1715009404,
        "last_checked": 1715259840,
        "last_check_statuses": [
          1,
          1,
          1,
          1,
          1
        ],
        "cors": false
      }
    ]
  },
}
```
- `status`: *string*, `ok` means everything looks good.
- `message`: *string*, Information related to your query, *success* or *error* message if any.
- `data`: *object*, Information related to your query.
  - `total_rows`: *unsigned int*; Total number of nodes found.
  - `rows_per_page`: *unsigned int*; Number of nodes per page.
  - `items`:  *array* of nodes or null if no nodes found. Each node has the structure as follows:
    - `id`: *unsigned int*; ID of the node.
    - `hostname`: *string*; The hostname / nodes IP address.
    - `ip`: *string*; The IP address of node, empty string if hostname is not resolveable (Eg.: TOR nodes)
    - `port`: *unsigned int*; TCP port the nodes is using to listen to RPC calls.
    - `protocol`: *string*; The protocol used by nodes to listen RPC calls. This can be `http`, `https` or `empty string`.
    - `is_tor`: *boolean*; whether the node is accessed through the Tor network.
    - `is_available`: *boolean*; whether the node is online or not. False may means node wasn't ready or my bots can't connect to nodes RPC daemon.
    - `nettype`: *string*; Network type (one of `mainnet`, `stagenet` or `testnet`).
    - `height`: *unsigned int*; Current length of longest chain known to daemon.
    - `adjusted_time`: *unsigned int*; Current time approximated from chain data, as Unix time.
    - `database_size`: *unsigned int*; The size of the blockchain database, in bytes.
    - `difficulty`: *unsigned int*; Least-significant 64 bits of the 128-bit network difficulty.
    - `version`: *string*; Vesion of remote monero node is running.
    - `uptime`: *float*; Uptime percentage of nodes for last 1 month. This likely **not** the real uptime value since my bots may experiencing network problems (I set connection timeout for 60 seconds).
    - `estimate_fee`: *unsigned int*; Amount of fees estimated per byte in atomic units. This just fee estimation, Malicious actors who running remote nodes [still can return high fee only when you about to create a transactions](monero-tx-fee-node.jpg).
    - `asn`: *unsigned int*; The AS number that owns nodes IP address, `0` if no information available.
    - `asn_name`: *string*; The AS name that owns nodes IP addres.
    - `cc`: *string*; two-letter ISO 3166-1 country code nodes location, empty string if no information available.
    - `country_name`: *string*; Country name based on nodes IP address, empty string if no information available.
    - `city`: *string*; City location based on nodes IP address, empty string if no information available.
    - `latitude`: *float*; Approx. latitude (geographic coordinate).
    - `longitude`: *float*; Approx. longitude (geographic coordinate).
    - `date_entered`: *unsigned int*, The Unix time when my bots start monitoring the node.
    - `last_checked`: *unsigned int*, The Unix time when was the last time my bot checked into a monero node.
    - `last_check_statuses`: *array* (size: `5`); last node avaibility status. Possible values:
      - `0`: Offline
      - `1`: Online
      - `2`: not yet checked.
    - `cors`: *boolean*, whether the node return with `Access-Control-Allow-Origin` header or not.

>  You will get `200` response code, `ok` status, and even if your query return no nodes (`null` value in `data.items` field).

> _**NOTE**: My API endpoint is behind Cloudflare reverse proxy, so it's still cost your privacy. Monero community suggests to always run your own node to obtain the maximum possible privacy and to help decentralize the network._

## Changelog

### Upcoming changes (2024-05-31, Breaking Changes)

- Web page UI moved from `https://www.ditatompel.com/monero/remote-node` to [https://xmr.ditatompel.com/remote-nodes/](https://xmr.ditatompel.com/remote-nodes/).
- API endpoint moved from `https://api.ditatompel.com/monero/remote-node` to `https://xmr.ditatompel.com/api/v1/nodes`.
- The source code will be available for public.
- The **default** response (without any query params) will display 10 records, sorted from `last_checked` node (previously it's sorted from the highest percentage of uptime).
- The json response structure has been changed, previously the array of nodes was in `data` field. Now, it's in `data.items`.
  - `id` field added to the array of nodes.
  - `last_height` field renamed to `height`.
  - `node_version` field renamed to `version`.
  - `country` field renamed to `cc`.
  - `country_name` field added to the array of nodes.
- `host` query string added.
- The `http` value from `protocol` query string only return nodes using HTTP RPC, **EXCLUDING** Tor network.
- The **country** query string filter changed from `country` to `cc`.
- The `orderby` query string changed to `sort_by` with this possible values:
  - `last_checked`: sorted by last check time (default).
  - `uptime`: sorted by percentage of uptime.
- `sort_direction` query string added to accomodate `sort_by` query string. Possible values:
  - `desc`: descending (default).
  - `asc`: ascending.
- `page` query string added to accomodate `limit` query string for paging purpose.
- `status` query string added. Possible values :
  - `-1` or not set: both online and offline (default).
  - `1`: only online nodes.
  - `0`: only offline nodes.
- `cors` query string only accept `1` or `-1` value (previously it's also accept _boolean_).

### Update 2024-01-31 (Breaking Changes)

- API endpoint moved from `https://www.ditatompel.com/api/monero/remote-node` to `https://api.ditatompel.com/monero/remote-node`.
- `x-ditatompel-rate-limit-*` headers removed, no rate limit for now.
- Indication "unchecked node statuses" in `data[].last_check_statuses[]` changed from `null` to `2`.
- Added into `json` field:
  - `data[].ip`, `data[].date_entered`, `data[].latitude`, and `data[].longitude`
- Removed from `json` field:
  - `success`
  - `data[].postal`

Diff: [013aa7d](https://github.com/ditatompel/insights/commit/013aa7db35edd28e72907d5786fcf8877a5a3e70#diff-a8f1b286fbca7e5d241e20d067c8b17a67b86cc142d10dc7cc23cbc9fcc0e332L139-L167).

Because I [refactoring my backend]({{< ref "/blog/rewriting-ditatompel-site-to-svelte-tailwind-and-go/index.md" >}}), there will most likely be another breaking changes in the near future.

### Update 2023-05-24
- I've add `cors` and `last_check_statuses` to nodes data record.

### Update 2022-05-10
- I've add `estimate_fee` to nodes data record which I get from [get_fee_estimate](https://www.getmonero.org/resources/developer-guides/daemon-rpc.html#get_fee_estimate) daemon RPC. This just fee estimation, moneromooo explain that malicious actors who running remote nodes [still can return high fee only when you about to create a transactions](monero-tx-fee-node.jpg).
- [selsta](https://github.com/selsta) create [pull request](https://github.com/monero-project/monero-gui/pull/3897) to add warning about high fee on official GUI conformation dialog.
- **The best and safest way is running your own node!**
- Nodes with 0% uptime within 1 month with more than 500 check attempt will be removed. You can always add your node again latter.

