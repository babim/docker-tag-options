## Kerio Connect 9 (lastest) on Docker
Run good on coreos. With MX from DNS localhost

tag: with and without kerberos.

Note: Your Linux OS maybe Freeze host, If you authen to AD over Kerberos (Freeze with RancherOS, Stable on Ubuntu)

```
$ sudo docker run -it --name=kerioconnect \
-h mail.domain.test -e DNSSERVER=192.168.1.2 \
-p 4040:4040 \
-p 22:22 -p 25:25 -p 465:465 -p 587:587 -p 110:110 -p 995:995 \
-p 143:143 -p 993:993 -p 119:119 -p 563:563 -p 389:389 -p 636:636 \
-p 80:80 -p 443:443 -p 5222:5222 -p 5223:5223 \
-v /keriomail:/opt/kerio babim/kerio-connect
```
## How to update ?

yeah, you can remove kerio files/folders in your volume but keep this follow files/folder:
- *.cfg
- mailserver/store
- mailserver/dbSSL
- mailserver/license
- mailserver/settings
- mailserver/sslca
- mailserver/sslcert
- mailserver/ldapmap

OK. when you pull new images and run. New container will copy new version files/folders of Kerio Connect to your volume but skip files/folders have your settings exists
