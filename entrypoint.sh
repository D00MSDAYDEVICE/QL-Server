#!/usr/bin/env bash
redis-server &
exec "$@"