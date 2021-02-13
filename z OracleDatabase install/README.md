# Install Oracle Database
(C) AQ.jsc Viet Nam (https://matmagoc.com)

## install depend
`apt-get install wget bash -y`

## install oracledatabase
`wget -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20OracleDatabase%20install/oracledatabase_install.sh | bash`

## Set environment
```
ENV VERSION 12cr2 #or 12cr1 or 18c
ENV PRODUCT EE #EE = enterprise, SE = Standard
```

## Required files

Download the Oracle Instant Client 12.2 RPMs from OTN:

http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html

The following three RPMs are required:

- `oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm`
- `oracle-instantclient12.2-devel-12.2.0.1.0-1.x86_64.rpm`
- `oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm`

## Building

Place the downloaded Oracle Instant Client RPMs (from the previous step) in the
same directory as the `Dockerfile` and run:

```
docker build -t oracle/instantclient:12.2.0.1 .
```

## Usage

You can run a container interactively to execute ad-hoc SQL and PL/SQL statements in SQL*Plus:

```
docker run -ti --rm babim/oracledatabase:client sqlplus hr/welcome@example.com/pdborcl
```

## Adding Oracle Database Drivers

To extend the image with optional Oracle Database drivers, follow your desired driver installation steps.  The Instant Client libraries are in `/usr/lib/oracle/12.2/client64/lib` and the Instant Client headers are in `/usr/include/oracle/12.2/client64/`.

The Instant Client libraries are in the default library search path.
