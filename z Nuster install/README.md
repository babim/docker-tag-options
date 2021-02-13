# docker-nuster
Web cache server from HAproxy tech on docker

```
docker pull babim/nuster
docker run -d -v /path/to/nuster.cfg:/etc/nuster/nuster.cfg:ro -p 8080:8080 babim/nuster
```
or
```
docker run -d -v /path/to:/etc/nuster:ro -p 8080:8080 -p 80:80 -p 443:443 babim/nuster
```
## Config file looks like
```
global
    nuster cache on data-size 100m uri /_nuster
    nuster nosql on data-size 200m
defaults
    mode http
frontend fe
    bind *:8080
    #bind *:4433 ssl crt example.com.pem alpn h2,http/1.1
    use_backend be2 if { path_beg /_kv/ }
    default_backend be1
backend be1
    nuster cache on
    nuster rule img ttl 1d if { path_beg /img/ }
    nuster rule api ttl 30s if { path /api/some/api }
    server s1 127.0.0.1:8081
    server s2 127.0.0.1:8082
backend be2
    nuster nosql on
    nuster rule r1 ttl 3600
```
There are four basic sections: global, defaults, frontend and backend.

    global
        defines process-wide and often OS-specific parameters
        nuster cache on or nuster nosql on must be declared in this section in order to use cache or nosql functionality
    defaults
        defines default parameters for all other frontend, backend sections
        and can be overwritten in specific frontend or backend section
    frontend
        describes a set of listening sockets accepting client connections
    bankend
        describes a set of servers to which the proxy will connect to forward incoming connections
        nuster cache on or nuster nosql on must be declared in this section
        nuster rule must be declared here

You can define multiple frontend or backend sections.

## As TCP loader balancer
```
frontend mysql-lb
   bind *:3306
   mode tcp
   default_backend mysql-cluster
backend mysql-cluster
   balance roundrobin
   mode tcp
   server s1 10.0.0.101:3306
   server s2 10.0.0.102:3306
   server s3 10.0.0.103:3306
```
## As HTTP/HTTPS loader balancer
```
frontend web-lb
   bind *:80
   #bind *:443 ssl crt XXX.pem
   mode http
   default_backend apps
backend apps
   balance roundrobin
   mode http
   server s1 10.0.0.101:8080
   server s2 10.0.0.102:8080
   server s3 10.0.0.103:8080
   #server s4 10.0.0.101:8443 ssl verify none
```
## As HTTP cache server
```
global
    nuster cache on data-size 200m
frontend fe
    bind *:8080
    default_backend be
backend be
    nuster cache on
    nuster rule all
    server s1 127.0.0.1:8081
```
## As RESTful NoSQL cache server
```
global
    nuster nosql on data-size 200m
frontend fe
    bind *:8080
    default_backend be
backend be
    nuster nosql on
    nuster rule r1 ttl 3600
```