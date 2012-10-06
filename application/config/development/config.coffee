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

exports['mysql_url'] = process.env.CLEARDB_DATABASE_URL ? "mysql://tagsobe:tagsobe@localhost:3306/tagsobe"
exports['db_url'] = process.env.HEROKU_POSTGRESQL_ROSE_URL ? "postgres://tagsobe:tagsobe@localhost:5432/tagsobe"
#exports['db_url'] = "sqlite:///tagsobe"


#

# End of file config.coffee
# Location: .application/config/development/config.coffee