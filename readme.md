## Proxy Cache Server

Nginx Server with caching responses to redis.

```
openresty -s stop; openresty -p `pwd`/ -c conf/nginx.conf -e error.log
```

Application on `localhost:8080` is used as  upstream service and has to be running.


