#+--------------------------------------------------------------------+
#| templates.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Exspresso is free software you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
# Templates
#
#   Scafolding script templates
#
#

ucfirst = ($str) -> $str[0].toUpperCase() + $str[1..]

#
# Fields
#
fields = ($fields) ->
  $str = '\n'
  for $field in $fields
    [$name, $type] = $field.split(':')
    $str += "        "+$name+":\n          type: '"+$type.toUpperCase()+"'\n"
  $str += "      $table.addData []\n"


module.exports =
  #
  # module.coffee
  #
  # @param [String] name  module name
  # @retun [String] code
  #
  module: ($name) ->
    """
    #+--------------------------------------------------------------------+
    #| #{ucfirst($name)}.coffee
    #+--------------------------------------------------------------------+
    #| Copyright DarkOverlordOfData (c) 2012 - 2013
    #+--------------------------------------------------------------------+
    #|
    #| This file is a part of Exspresso
    #|
    #| Exspresso is free software; you can copy, modify, and distribute
    #| it under the terms of the MIT License
    #|
    #+--------------------------------------------------------------------+

    #
    #	#{ucfirst($name)} Module
    #

    module.exports = class #{ucfirst($name)} extends system.core.Module

      name          : '#{ucfirst($name)}'
      description   : ''
      path          : __dirname
      active        : true

      #
      # Initialize the module
      #
      #   Install if needed
      #
      # @return [Void]
      #
      initialize: () ->

    """

  migrate: ($name) ->

    [
      "    @controller.load.model '#{ucfirst($name)}'"
      "    @controller.#{$name}.install() if @controller.install"
    ].join("\n")


  #
  # controller.coffee
  #
  # @param [String] module  module name
  # @param [String] name  controller name
  # @param [String] method  method name
  # @retun [String] code
  #
  controller: ($name, $method) ->
    """
    #+--------------------------------------------------------------------+
    #| #{ucfirst($name)}.coffee
    #+--------------------------------------------------------------------+
    #| Copyright DarkOverlordOfData (c) 2012 - 2013
    #+--------------------------------------------------------------------+
    #|
    #| This file is a part of Exspresso
    #|
    #| Exspresso is free software; you can copy, modify, and distribute
    #| it under the terms of the MIT License
    #|
    #+--------------------------------------------------------------------+

    #
    #	#{ucfirst($name)} Controller
    #

    module.exports = class #{ucfirst($name)} extends system.core.Controller

      #
      # #{ucfirst($method)}
      #
      # @access	public
      # @return [Void]
      #
      #{$method}Action: ->

        @load.view '#{$name}-#{$method}'

    """

  #
  # controller.coffee
  #
  # @param [String] module  module name
  # @param [String] name  controller name
  # @param [String] method  method name
  # @retun [String] code
  #
  method: ($name, $method) ->
    """
    #
    # #{ucfirst($name)}
    #
    # @access	public
    # @return [Void]
            #
    #{$name}Action: ->

      @load.view '#{$name}-#{$method}'

    """

  #
  # view.coffee
  #
  # @param [String] module  module name
  # @param [String] name  controller name
  # @param [String] method  method name
  # @retun [String] code
  #
  view: ($module, $name, $method) ->
    """
    """


  #
  # model.coffee
  #
  # @param [String] module  module name
  # @param [String] name  model name
  # @param [String] fields  model fields
  # @retun [String] code
  #
  model: ($module, $name, $fields) ->
    """
    #+--------------------------------------------------------------------+
    #| #{ucfirst($name)}.coffee
    #+--------------------------------------------------------------------+
    #| Copyright DarkOverlordOfData (c) 2012 - 2013
    #+--------------------------------------------------------------------+
    #|
    #| This file is a part of Exspresso
    #|
    #| Exspresso is free software; you can copy, modify, and distribute
    #| it under the terms of the MIT License
    #|
    #+--------------------------------------------------------------------+

    #
    #	Class #{ucfirst($name)}
    #
    module.exports = class modules.#{$module}.models.#{ucfirst($name)} extends system.core.Model

      table: '#{$name}'
      #
      # Initialize #{ucfirst($name)} Model
      #
      constructor: ($args...) ->

        super $args...
        log_message 'debug', '#{ucfirst($name)} Model Initialized'


      #
      # Install the #{ucfirst($name)} data
      #
      # @return [Void]
      #
      install: () ->

        @load.dbforge() unless @dbforge?
        @queue @install_#{$name}

      #
      # Create the #{$name} table
      #
      # @param  [Function]  next  async callback
      # @return [Void]
      #
      install_#{$name}: ($next) =>

        #
        # if table doesn't exist, create and load initial data
        #
        @dbforge.createTable @table, $next, ($table) ->
          $table.addKey 'id', true
          $table.addField
            id:
              type: 'INT', constraint: 5, unsigned: true, auto_increment: true
    """ + fields($fields)


#  fields = ($fields) ->
#    $str = ''
#    for $field in $fields
#      [$name, $type] = $field.split(':')
#      $str += field_coffee($name, $type)
#    return $str
#
#  field = ($name, $type) ->
#    """
#            #{$name}:
#              type: '#{$type.toUpperCase()}'
#    """



  routes: ($name, $method) ->
    """
    module.exports =
      #----------------------------------------------------------------------
      #          Route                                 Controller URI
      #----------------------------------------------------------------------
      '/#{$name}'                               : '#{ucfirst($name)}/#{$method}'
    """

  route: ($name, $method) ->
    """
      '/#{$name}'                               : '#{ucfirst($name)}/#{$method}'
    """



  #
  # index.coffee
  #
  # @param [String] app appname
  # @retun [String] code
  #
  run: ($app) ->
    $dst = process.cwd()+'/'+$app
    """
    module.exports =

      #
      # Run Exspresso
      #
      # Set the MODPATH and DOCPATH globals and boot exspresso.
      #
      # @param [Object] config  sets the expresso paths
      # @return none
      #
      run: ($config = {}) ->

        $config['APPPATH'] = __dirname + "/#{$app}"
        $config['MODPATH'] = __dirname + "/modules" unless $config['MODPATH']?

        require('exspresso').run $config
    """

  #
  # index.js
  #
  # @param [String] app appname
  # @retun [String] code
  #
  index: ($app) ->
    """
    /*
     *
     *	Reference #{$app}
     *
     */
    require('coffee-script');
    module.exports = require('./index.coffee');
    """

  #
  # license.md
  #
  # @param [String] app appname
  # @retun [String] license text
  #
  license: ($app) ->
    """
    # MIT License

    Copyright (c) 2012 - 2013 Bruce Davidson &lt;darkoverlordofdata@gmail.com&gt;

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    'Software'), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    """

  #
  # package.json
  #
  # @param [String] app appname
  # @retun [String] npm config
  #
  package: ($app) ->
    """
    {
      "name": "#{$app}",
      "version": "0.0.1",
      "description": "#{$app}",
      "author": "myname <myname@gmail.com>",
      "dependencies": {
        "coffee-script": "*",
        "exspresso": "*"
      },
      "scripts": {
        "start": "node #{$app}.js"
      },
      "license": "MIT"
    }
    """

  #
  # Procfile
  #
  # @param [String] app appname
  # @retun [String] command line for Heroku
  #
  Procfile: ($app) ->
    """
    web: node index --install
    """

  #
  # readme.md
  #
  # @param [String] app appname
  # @retun [String] documentation
  #
  readme: ($app) ->
    """
    # #{$app}

    """

  #
  # projects.js
  #
  # @param [String] app appname
  # @retun [String] code
  #
  project: ($app) ->
    """
    /*
     *
     *	Boot #{$app}
     *
     */
    require('coffee-script');
    require('./index.coffee').run();

    """

  #
  # config/config.coffee
  #
  # @param [String] app appname
  # @retun [String] code
  #
  config: ($app) ->
    """
    module.exports =

      #|
      #|--------------------------------------------------------------------------
      #| Google Analytics Parameters
      #|--------------------------------------------------------------------------
      #|
      #| Enter your GA account and domain info:
      #|
      #|
      ga_account: ''
      ga_domain: ''
      #|
      #|--------------------------------------------------------------------------
      #| Site Name
      #|--------------------------------------------------------------------------
      #|
      #| Title for your site
      #|
      #|
      site_name: '#{$app}'

      #|
      #|--------------------------------------------------------------------------
      #| Site Slogan
      #|--------------------------------------------------------------------------
      #|
      #| A Catchy Jingle
      #|
      site_slogan: ""

      #|
      #|--------------------------------------------------------------------------
      #| Logo
      #|--------------------------------------------------------------------------
      #|
      #| The image to display with site name
      #|
      #|
      logo: "/images/logo.png"

      #|
      #|--------------------------------------------------------------------------
      #| Favicon
      #|--------------------------------------------------------------------------
      #|
      #| For the browser or desktop
      #|
      #|
      favicon: 'favicon.png'

      #|
      #|--------------------------------------------------------------------------
      #| HTTP Port
      #|--------------------------------------------------------------------------
      #|
      #| The http port to use
      #|
      #|
      http_port: process.env.PORT ? 0xd16a

      #|
      #|--------------------------------------------------------------------------
      #| Base Site URL
      #|--------------------------------------------------------------------------
      #|
      #| URL to your Exspresso root. Typically this will be your base URL,
      #| WITH a trailing slash:
      #|
      #|	http://example.com/
      #|
      #| If this is not set then Exspresso will guess the protocol, domain and
      #| path to your installation.
      #|
      #|
      base_url: ''

      #|
      #|--------------------------------------------------------------------------
      #| Index File
      #|--------------------------------------------------------------------------
      #|
      #| Typically this will be your index.coffee file, unless you've renamed it to
      #| something else. If you are using mod_rewrite to remove the page set this
      #| variable so that it is blank.
      #|
      #|
      index_page: ''

      #|
      #|--------------------------------------------------------------------------
      #| URL suffix
      #|--------------------------------------------------------------------------
      #|
      #| This option allows you to add a suffix to all URLs generated by exspresso.
      #|
      #|
      url_suffix: ''

      #|
      #|--------------------------------------------------------------------------
      #| Default Language
      #|--------------------------------------------------------------------------
      #|
      #| This determines which set of i18n files should be used. Make sure
      #| there is an available translation if you intend to use something other
      #| than english.
      #|
      #|
      language: 'en'

      #|
      #|--------------------------------------------------------------------------
      #| Default Character Set
      #|--------------------------------------------------------------------------
      #|
      #| This determines which character set is used by default in various methods
      #| that require a character set to be provided.
      #|
      #|
      charset: 'UTF-8'
      encoding: 'utf8'

      #|
      #|--------------------------------------------------------------------------
      #| Enable/Disable System Hooks
      #|--------------------------------------------------------------------------
      #|
      #| Enable the 'hooks' feature.
      #|
      #|
      enable_hooks: false

      #|
      #|--------------------------------------------------------------------------
      #| Class Extension Prefix
      #|--------------------------------------------------------------------------
      #|
      #| This item allows you to set the filename/classname prefix when extending
      #| native libraries.
      #|
      #|
      subclass_prefix: '#{ucfirst($app)}'

      #|
      #|--------------------------------------------------------------------------
      #| Allow Get Array
      #|--------------------------------------------------------------------------
      #|
      #| Set to false to disallow the $req.query array
      #|
      #|
      allow_get_array: true

      #|
      #|--------------------------------------------------------------------------
      #| Logging
      #|--------------------------------------------------------------------------
      #|
      #| Logging Options
      #|
      #|
      log_path: ''
      log_date_format: 'YYYY-MM-DD HH:mm:ss'
      log_threshold: 3
      #|	               0        Disables logging, Error logging TURNED OFF
      #|	               1        Error Messages (including PHP errors)
      #|	               2        Debug Messages
      #|	               3        All Messages
      #|
      log_http: 'tiny'
      #|                 default  Verbose output
      #|                 short    Consise output
      #|                 tiny     Terse output
      #|                 dev      Colorized version of tiny
      #|

      #|
      #|--------------------------------------------------------------------------
      #| Cacheing
      #|--------------------------------------------------------------------------
      #|
      #| Leave this BLANK unless you would like to set something other than the default
      #| system/cache/ folder.  Use a full server path with trailing slash.
      #|
      #|
      cache_path: ''
      cache_rules:
        '/welcome': 43200 # 1 month = 30 days * 24 hrs * 60 min
        '.*': 0

      #|
      #|--------------------------------------------------------------------------
      #| Encryption Key
      #|--------------------------------------------------------------------------
      #|
      #| If you use the Encryption class or the Session class you
      #| MUST set an encryption key.  See the user guide for info.
      #|
      #|
      encryption_key: process.env.CLIENT_SECRET ? 'ZAHvYIu8u1iRS6Hox7jADpnCMYKf57ex0BEWc8bM0/4='

      #|
      #|--------------------------------------------------------------------------
      #| Session Variables
      #|--------------------------------------------------------------------------
      #|
      #| 'sess_cookie_name'		    = cookie name
      #| 'sess_expiration'			  = seconds the session will last.
      #|                            by default sessions last 7200 seconds (two hours).
      #|                            Set to zero for no expiration.
      #| 'sess_expire_on_close'	  = true/false True causes the session to expire automatically
      #|                            when the browser window is closed
      #| 'sess_encrypt_cookie'		= true/false Encrypt the cookie?
      #| 'sess_use_database'		  = true/false Persist the session data to a database
      #| 'sess_table_name'			  = Session database table name
      #| 'sess_match_ip'			    = true/false Match the user's IP address when reading the session data?
      #| 'sess_match_useragent'	  = true/false Match the User Agent when reading the session data?
      #| 'sess_time_to_update'		= Seconds between refresh of session data
      #|
      sess_driver: 'sql'
      sess_cookie_name: 'sid'
      sess_expiration: 7200*60
      sess_expire_on_close: false
      sess_encrypt_cookie: false
      sess_use_database: true
      sess_table_name: 'sessions'
      sess_match_ip: false
      sess_match_useragent: true
      sess_time_to_update: 300

      #|
      #|--------------------------------------------------------------------------
      #| Cookie Related Variables
      #|--------------------------------------------------------------------------
      #|
      #| 'cookie_prefix' = Set a prefix if you need to avoid collisions
      #| 'cookie_domain' = Set to .your-domain.com for site-wide cookies
      #| 'cookie_path'   =  Typically will be a forward slash
      #| 'cookie_secure' =  Cookies will only be set if a secure HTTPS connection exists.
      #|
      #|
      cookie_prefix: "connect."
      cookie_domain: ""
      cookie_path: "/"
      cookie_secure: false

      #|
      #|--------------------------------------------------------------------------
      #| Global XSS Filtering
      #|--------------------------------------------------------------------------
      #|
      #| Determines whether the XSS filter is always active when GET, POST or
      #| COOKIE data is encountered
      #|
      #|
      global_xss_filtering: false

      #|
      #|--------------------------------------------------------------------------
      #| Cross Site Request Forgery
      #|--------------------------------------------------------------------------
      #| Enables a CSRF cookie token to be set. When set to TRUE, token will be
      #| checked on a submitted form. If you are accepting user data, it is strongly
      #| recommended CSRF protection be enabled.
      #|
      #| 'csrf_token_name' = The token name
      #| 'csrf_cookie_name' = The cookie name
      #| 'csrf_expire' = The number in seconds the token should expire.
      #|
      csrf_protection: false
      csrf_token_name: 'csrf_test_name'
      csrf_cookie_name: 'csrf_cookie_name'
      csrf_expire: 7200

      #|
      #|--------------------------------------------------------------------------
      #| Output Compression
      #|--------------------------------------------------------------------------
      #|
      #| Enables Gzip output compression.
      #|
      #|
      compress_output: false

      #|
      #|--------------------------------------------------------------------------
      #| Master Time Reference
      #|--------------------------------------------------------------------------
      #|
      #| Options are 'local' or 'gmt'.
      #|
      #|
      time_reference: 'local'

      #|
      #|--------------------------------------------------------------------------
      #| Reverse Proxy IPs
      #|--------------------------------------------------------------------------
      #|
      #| If your server is behind a reverse proxy, you must whitelist the proxy IP
      #| addresses from which Exspresso should trust the HTTP_X_FORWARDED_FOR
      #| header in order to properly identify the visitor's IP address.
      #| Comma-delimited, e.g. '10.0.1.200,10.0.1.201'
      #|
      #|
      proxy_ips: ''

      #|
      #|--------------------------------------------------------------------------
      #| Module paths
      #|--------------------------------------------------------------------------
      #|
      #| Paths where modules are found
      #|
      #|
      module_paths: [
        APPPATH+'modules/'
        MODPATH
      ]

      #|
      #|--------------------------------------------------------------------------
      #| Classpaths
      #|--------------------------------------------------------------------------
      #|
      #| Classpaths used to search when loading classes are stored in a hash.
      #| The key is the programatic namespace root, and the value is the
      #| corresponding path to anchor searches at.
      #|
      #|
      classpaths:
        system    : SYSPATH
        #{$app}   : APPPATH
        modules   : MODPATH

      #|
      #|--------------------------------------------------------------------------
      #| MVC paths
      #|--------------------------------------------------------------------------
      #|
      #| Paths where models/views/controllers are found
      #|
      #|
      model_paths: [
        APPPATH
      ]
      view_paths: [
        APPPATH
      ]
      controller_paths: [
        APPPATH
        SYSPATH
      ]

      #|
      #|--------------------------------------------------------------------------
      #| View Extension
      #|--------------------------------------------------------------------------
      #|
      #| The default view filetype that is loaded when no extension is specified
      #|
      #|
      view_ext: '.eco'

    """

  extend: ($app) ->
    """
    #+--------------------------------------------------------------------+
    #| #{ucfirst($app)}Connect.coffee
    #+--------------------------------------------------------------------+
    #| Copyright DarkOverlordOfData (c) 2012 - 2013
    #+--------------------------------------------------------------------+
    #|
    #| This file is a part of Exspresso
    #|
    #| Exspresso is free software; you can copy, modify, and distribute
    #| it under the terms of the MIT License
    #|
    #+--------------------------------------------------------------------+

    #
    #	#{ucfirst($app)}Connect
    #
    #   An adapter to the connect server instance
    #
    #   This extension allows us to use assets from the exspresso component
    #
    module.exports = class #{$app}.core.#{ucfirst($app)}Connect extends system.core.Connect

      #
      # Initialize the assets
      #
      #   Use the assets from the exspresso component
      #
      # @param  [Object]  driver  the instantiated express driver
      # @return [Void]
      #
      initialize_assets:($driver, $render) =>

        @app.use $driver.static("node_modules/exspresso/application/assets/")
        super $driver, $render


    """

