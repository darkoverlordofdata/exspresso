# [Exspresso v0.7.11] (https://github.com/darkoverlordofdata/exspresso)

  A CMS framework built on a port of the [CodeIgniter] (<http://codeigniter.com/>) framework ported to coffee-script.

    Exspresso is opinionated -

      * express.js core is exposed via the CodeIgniter framework api
      * embedded coffee-script (ECO) for views.
      * twitter bootstrap css styles
      * HMVC architecture ported from Wiredesignz
      * DB Drivers for MySQL and PostgreSQL

    New in Exspresso
      * Configuration inheritance
      * Themed templating engine
      * Per module migrations

 [Live Demo!] (http://exspresso.herokuapp.com/)

## PHP api (formerly not-php)

  lib/index.coffee, a php compatability layer used by the ported code,
  is a group of helper functions that mimic the php api.
  Use cake test to test.


## PHP2Coffee

  Use the Php2coffee command line port tool to kick start php ports.

  Requires Zend compatible php runtime

    Usage: bin/php2coffee [OPTIONS] PATH [DESTINATION]

      -h, --help          display this help
      -j. --javascript    compiles resulting .coffee file
      -r, --recursive     recurse source path
      -t, --trace         trace output
      -T, --tabs          use tab character in output (default is spaces)
      -d, --dump          dump of tokens


### Globals

Globals in Exspresso are read only and immutable.
They are set once using 'define' and cannot be re-defined.

    Constants           index.coffee
    PHP api             lib/index.coffee
    Common Methods      system/core/Common.coffee
    stdio               application/config/constants.coffee

    singletons

          $CFG              CI_Config
          $EXT              CI_Hooks
          $LANG             CI_Lang
          $IN               CI_Input
          $OUT              CI_Output
          $RTR              CI_Router
          $SRV              CI_Server
          $URI              CI_URI

    Classes

          CI_Benchmark        system/core/Benchmark.coffee
          CI_Config           system/core/Config.coffee
          CI_Controller       system/core/Controller.coffee
          CI_Exceptions       system/core/Exceptions.coffee
          CI_Input            system/core/Input.coffee
          CI_Lang             system/core/Lang.coffee
          CI_Loader           system/core/Loader.coffee
          CI_Model            system/core/Model.coffee
          CI_Output           system/core/Output.coffee
          CI_Router           system/core/Router.coffee
          CI_URI              system/core/URI.coffee
          CI_Form_validation  system/libraries/Form_validation.coffee
          CI_Log              system/libraries/Log.coffee
          CI_Migration        system/libraries/Migration.coffee
          CI_Parse            system/libraries/Parser.coffee
          CI_Profiler         system/libraries/Profiler.coffee
          CI_Session          system/libraries/Sesion/Session.coffee
          CI                  application/libraries/MX/Ci.coffee
          MX_Config           application/Libraries/MX/Config.coffee
          MX_Lang             application/Libraries/MX/Lang.coffee
          MX_Loader           application/Libraries/MX/Loader.coffee
          MX_Modules          application/Libraries/MX/Modules.coffee
          MX_Router           application/Libraries/MX/Router.coffee
          MY_Controller       application/core/Controller.coffee
          MY_Loader           application/core/Loader.coffee
          MY_Router           application/core/Router.coffee
          MY_Profiler         application/libraries/MY_Profiler.coffee
          Template            application/libraries/Template.coffee
          Theme               application/libraries/Theme.coffee




## Status

Unstable.

    - unfinished
    ? untested
    X in use


    CI System Framework files
    -----------------------------------------------------------
    * Core
        * Benchmark             X
        * Cache                 ?
        * Common                X
        * Config                X
        * Controller            X
        * Exceptions            X
        * Hooks                 ?
        * Input                 X
        * Lang                  X
        * Loader                X
        * Model                 X
        * Output                X
        * Router                X
        * Security              ?
        * URI                   X
    * Database                  mysql   postgresql
        * DB_active_rec         X       X
        * DB_cache              ?       ?
        * DB_driver             X       X
        * DB_forge              X       ?
        * DB_result             X       X
        * DB_utility            X       ?
    * Helpers
        * array_helper          ?
        * captcha_helper        ?
        * cookie_helper         ?
        * date_helper           ?
        * directory_helper      ?
        * download_helper       ?
        * email_helper          ?
        * file_helper           ?
        * form_helper           X
        * inflector_helper      ?
        * language_heler        X
        * number_helper         ?
        * path_helper           ?
        * security_helper       -
        * smiley_helper         -
        * string_helper         ?
        * text_helper           X
        * typography_helper     ?
        * url_helper            X
        * xml_helper            X
    * Libraries
        * Calendar              ?
        * Cart                  ?
        * Driver                -
        * Email                 X
        * Encrypt               -
        * Form_validation       X
        * Ftp                   -
        * Image_lib             -
        * Javascript            -
        * Log                   X
        * Migration             X
        * Pagination            ?
        * Parser                ?
        * Profiler              X
        * Session               X
        * Sha1                  Not required
        * Table                 -
        * Trackback             -
        * Typography            ?
        * Unit_test             ?
        * Upload                ?
        * User_agent            X
        * Xmlrpc                -
        * Zip                   -






## License

(The MIT License)

Copyright (c) 2012 Bruce Davidson &lt;darkoverlordofdata@gmail.com&gt;

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
