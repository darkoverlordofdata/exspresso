# [Exspresso v0.7.14] (https://github.com/darkoverlordofdata/exspresso)

 A CMS framework written in coffeescript, built using a port of the [CodeIgniter] (<http://codeigniter.com/>) framework.

    Exspresso features

      * HMVC architecture ported from Wiredesignz
      * embedded coffee-script (ECO) for views.
      * bootstrap css styles
      * DB Drivers for MySQL and PostgreSQL
      * Configuration inheritance
      * Themed templating engine
      * Per module migrations

 [Live Demo!](http://exspresso.herokuapp.com/)

  Exspresso uses [not-php] (http://github.com/darkoverlordofdata/not-php) v0.3.7 as a drop in
  replacement for many of the php api calls that were in the ported code.


## Quick Start

### Install

<code>$ npm install exspresso</code>

### Run on localhost

  <code>$ npm start</code><br />
  then point your browser to http://localhost:5000

  or preview in appjs (you need to have appjs installed)
  <br /><code>$ node app --preview</code>

### Globals

Globals in Exspresso are read only and immutable.
They are set once using 'define' and cannot be re-defined.

    Constants           index.coffee
    PHP api             lib/index.coffee
    Common Methods      system/core/Common.coffee
    stdio               application/config/constants.coffee

    singletons

          $APP              CI_Application  (appjs adapter)
          $CFG              CI_Config
          $EXT              CI_Hooks
          $LANG             CI_Lang
          $IN               CI_Input
          $OUT              CI_Output
          $RTR              CI_Router
          $SRV              CI_Server       (expressjs adapter)
          $URI              CI_URI

    Classes

          CI_Application      application/core/Application.coffee
          CI_Server           application/core/Server.coffee
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


### Component Status

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
