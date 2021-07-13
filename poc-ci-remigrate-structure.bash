#!/bin/bash

set -xeo pipefail

export RAILS_ENV=test
export FORCE_SINGLE_DB=true
export ENABLE_SPRING=0

echo Reverting schema...
rm -rf db/schema_migrations/ db/migrate/20211201000001_drop_ci_foreign_keys.rb
git checkout $(git merge-base origin/master HEAD) -- db/structure.sql
git checkout $(git merge-base origin/master HEAD) -- db/schema_migrations

echo Recreate migrations...
bin/rake db:drop db:create db:schema:load db:migrate

echo Recreate FKs drop...
bin/rails runner poc-ci-validate_all_fks.rb
bin/rake db:migrate

echo Recreate all DBs...
unset FORCE_SINGLE_DB
bin/rake db:drop db:create db:schema:load db:migrate
