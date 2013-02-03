# Exspresso Coding Standards
---

## Tables

  * right align colons
  * prefer unquoted key values


    options =
      expires : expire_on
      domain  : ''
      path    : '/'
      secure  : true


## Classes

  * 1 public class per file
  * The public class is the exported class
  * Public classes may be defined global
  * Include private helper classes in the same file
  * Prefix protected member names with an undersocore
  * Initiale array and object members in the constructor. Set the prototype value to null
  * Define static members using this context

  Example MyBase.coffee:

    class global.MyBase

      @DEFAULT      = 0
      @READY        = 1

      _headers      : null
      cookie_path   : '/'

      constructor: () ->
        @_headers = []

      ...

    module.exports = MyBase

    class MyHelper

      ...


## Error Handling

  * In middleware, call the server next handler


    (req, res, next) ->
      try
        ...
        next()
      catch err
        next err

  * Use show_error to send error display to the browser
  * Use log_message to record the message for support


    return log_message('error', 'My message: %s', err) if show_error(err)

  * Use a short circuit evaluation to pass either error or result to template.view


    @db.get ($err, $data) =>

      @template.view "myview", $err || $data



