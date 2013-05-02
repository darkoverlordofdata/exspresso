# Exspresso Coding Standards
---

## Classes

  * 1 public class per file
  * The public class is the exported class
  * Controller methods mapped to uri's shall end with the 'Action' suffix to avoid name collisions
  * Public classes may be defined in a namespace
  * Include private helper classes in the same file
  * Prefix protected member names with an undersocore
  * Initialize array and object members in the constructor. Set the prototype value to null
  * Define static members using 'this' context
  * Public properties shall be camelCase
  * Protected or private properties shall be _snake_case

  Example MyBase.coffee:

```CoffeeScript
class application.lib.MyBase

  @DEFAULT      = 0
  @READY        = 1

  _headers      : null
  cookie_path   : '/'

  constructor: () ->
    @_headers = []

  indexAction: () ->


module.exports = application.lib.MyBase
```


## Tables

  * right align colons
  * prefer unquoted key values

```CoffeeScript
options =
  expires : expire_on
  domain  : ''
  path    : '/'
  secure  : true
```


## Error Handling

  * From middleware, call the next handler

```CoffeeScript
  (req, res, next) ->
    try
      ...
      next()
    catch err
      next err
```

  * Use show_error or show_404 to send error display to the browser
  * Use log_message to record the message for support
  * Chain calls in a 'return if' style


```CoffeeScript
  return log_message('error', 'My message: %s', err) if show_error(err)
```

  * Use a short circuit evaluation to pass either error or result to template.view


```CoffeeScript
  @db.from 'hotel'
  @db.like 'name', "%#{$searchString}%"
  @db.limit $pageSize, $start
  @db.get ($err, $hotels) =>

    @template.view "travel/hotels", $err || {
      hotels:       $hotels.result()
      searchString: $searchString
      pageSize:     $pageSize
    }
```


## Sprintf Style Messages

  * When displaying flash and log messages, you can use a sprinf style call

```CoffeeScript
  @session.setFlashdata 'info', 'Blog entry %s deleted', id

  log_mesage 'debug', 'Blog entry %s deleted', id
```

## Using DB Forge

  * Pass a callback as the 3rd argument to be processed prior to creating the table. This
    callback can be used to set the table attributes and initial data load.

```CoffeeScript
  @dbforge.createTable 'category', next, (t) ->

    t.addKey 'id', true
    t.addField
      id:
        type: 'INT', constraint: 5, unsigned: true, auto_increment: true
      name:
        type: 'VARCHAR', constraint: 255

    t.addData id: 1, name: "Article"
```


