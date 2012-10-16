#+--------------------------------------------------------------------+
#| config.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#

exports['redis_url'] = process.env.REDISTOGO_URL ? 'redis://localhost:6379'
exports['mysql_url'] = process.env.CLEARDB_DATABASE_URL ? "mysql://demo:demo@localhost:3306/demo"
exports['pg_url'] = process.env.HEROKU_POSTGRESQL_ROSE_URL ? "postgres://tagsobe:tagsobe@localhost:5432/tagsobe"
exports['db_url'] = process.env.HEROKU_POSTGRESQL_ROSE_URL ? "postgres://tagsobe:tagsobe@localhost:5432/tagsobe"
#exports['db_url'] = "sqlite:///tagsobe"


#

# End of file config.coffee
# Location: .application/config/development/config.coffee