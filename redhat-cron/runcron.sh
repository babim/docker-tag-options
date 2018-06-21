#!/bin/bash
service crond start
exec "$@"
