#!/bin/bash -x

bundle exec rspec spec
rake db:drop
bundle exec rake db:create:all --trace
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e  "ALTER DATABASE test$TEST_ENV_NUMBER CHARACTER SET utf8 COLLATE utf8_general_ci;"
bundle exec rake db:schema:load --trace
bundle exec rake db:migrate --trace

# This rune forces something to succeed. "|| :"
bundle exec cucumber -f progress -r features features/bookmarks -b || :
bundle exec cucumber -f progress -r features features/collections -b
bundle exec cucumber -f progress -r features features/comments_and_kudos -b
bundle exec cucumber -f progress -r features features/gift_exchanges -b
#bundle exec cucumber -f progress -r features features/importing -b || :
#bundle exec cucumber -f progress -r features features/other -b || :
bundle exec cucumber -f progress -r features features/prompt_memes -b
bundle exec cucumber -f progress -r features features/tags_and_wrangling -b
bundle exec cucumber -f progress -r features features/users -b
bundle exec cucumber -f progress -r features features/works -b
