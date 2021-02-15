## IceWarp 13 (lastest) on Docker
Run good on coreos. With MX from DNS localhost

```
$ sudo docker run -it --name=icewarp \
-h mail.domain.test -e DNSSERVER=192.168.1.2 \
-p 4040:4040 \
-p 22:22 -p 25:25 -p 465:465 -p 587:587 -p 110:110 -p 995:995 \
-p 143:143 -p 993:993 -p 5060:5060 -p 5061:5061 -p 5269:5269 -p 1080:1080 \
-p 80:80 -p 443:443 -p 5222:5222 -p 5223:5223 -p 5229:5229 \
-v /icewarp:/opt/icewarp babim/icewarp
```

