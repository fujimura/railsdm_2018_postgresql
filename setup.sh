#! /bin/sh
set -ex

[ -n "$PGHOST" ] || export PGHOST=localhost
[ -n "$PGUSER" ] || export PGUSER=postgres
[ -n "$PGDATABASE" ] || export PGDATABASE=railsdm

psql <<SQL
CREATE EXTENSION postgis;
CREATE EXTENSION btree_gist;
CREATE EXTENSION btree_gin;
CREATE EXTENSION pgcrypto;
SQL
