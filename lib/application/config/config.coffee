module.exports =

  #|
  #|--------------------------------------------------------------------------
  #| Site Name
  #|--------------------------------------------------------------------------
  #|
  #| Title for your site
  #|
  #|
  site_name: 'Exspresso'

  #|
  #|--------------------------------------------------------------------------
  #| Site Slogan
  #|--------------------------------------------------------------------------
  #|
  #| A Catchy Jingle
  #|
  site_slogan: "CoffeeScript Web Framework"

  #|
  #|--------------------------------------------------------------------------
  #| Logo
  #|--------------------------------------------------------------------------
  #|
  #| The image to display with site name
  #|
  #|
  logo: "//d16acdn.aws.af.cm/images/exspresso.png"

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
  #| Set to 'Express' to use APPPATH+'core/ExpressConnect.coffee'
  #| as a subclass of SYSPATH+'core/Connect.coffee'
  #|
  subclass_prefix: 'My'

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
  sess_use_database: false
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
    MODPATH
    APPPATH+'modules/'
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
    system            : SYSPATH
    application       : APPPATH
    modules           : MODPATH

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
