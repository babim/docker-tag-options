# Sonarqube in a Docker container
## (Thanks newtmitch dockerfile on github)

## Access
Using the official Sonar Qube Docker image:

```
docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 babim/sonarqube
docker run -ti -v $(pwd):/source --link sonarqube babim/sonarqube:scanner
```

Run this from the root of your source code directory, it'll scan everything below it.

This uses the latest Qube image - if you want LTS, use image name babim/sonarqube:lts

## -e environment default
```
	auser=daemon (user default to run)
	aguser=daemon
	SERVER=sonarqube (Sonarqube server address)
	SQLSERVER=sonarqube (SQL server address)
	SQLUSER=sonar (SQL user to connect)
	SQLTYPE=h2 or choice postgresql, mysql, oracle, sqlserver.
	PROJECTKEY=Test
	PROJECTNAMETest
	PROJECTVERSION=1
```
## Structure environment
```
sonar.jdbc.url=jdbc:${SQLTYPE}:${SQLOPTION1}${SQLSERVER}${SQLPORT}/${USER}${SQLOPTION2}
```
## example
```
----- PostgreSQL
sonar.jdbc.url=jdbc:postgresql://localhost/sonar

----- MySQL
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar?useUnicode=true&amp;characterEncoding=utf8

----- Oracle
sonar.jdbc.url=jdbc:oracle:thin:@localhost/XE

----- Microsoft SQLServer
sonar.jdbc.url=jdbc:jtds:sqlserver://localhost/sonar;SelectMethod=Cursor

 H2 database from Docker Sonar container
sonar.jdbc.url=jdbc:h2:tcp://sonarqube/sonar
```
