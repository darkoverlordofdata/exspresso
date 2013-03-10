# Exspresso Coding Standards
---

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


## Classes

  * 1 public class per file
  * The public class is the exported class
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


module.exports = application.lib.MyBase
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
      pagination:   @pagination
    }
```




