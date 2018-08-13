# LAN Cache

Lan Caching stack for gaming without a DNS container. You will be required to use and external DNS system (E.G. on your router). Check out https://github.com/uklans for a list of domains

## About this stack

This stack will configure a full LAN cache for your network or LAN event, Each caching server will require a unique IP Address on either the same host or on multiple hosts. The SNI-Proxy will allow HTTPS to bypass the caching altogether.

This stack does not have a DNS container

## Configuration

* Each caching service requires a unique IP Address
* A Cache root is required to store the cached data
* Configure your own DNS to point to the server hosting the caching stack

## More information

This Rancher catalogue is currently a work in progress, Please report all issues to https://github.com/steamcache/rancher-catalogue

## FAQ

1.) Why don't you include EPIC games?
  Currently we can not cache EPIC games as they distribute all files over HTTPS, Without distributing self-signed certificates to all hosts on the LAN, this will not be possible to cache at this time. Please pester EPIC Games to allow caching of their games services.

2.) I ran out of disk space, What should I do?
  Either delete some of the cache data, or put the caching services on a bigger disk

3.) The cache seems slow.
  If the cache seems slow, Check that you have enough memory on the system, The more memory you have the faster the cache will run as the caching system will cache data in to RAM. The cache can only deliver files as fast as it can read them from either the internet (if they're not yet cached) or from the disk if they are cached. Using faster disks/SSD can greatly improve the performance of the cache.
