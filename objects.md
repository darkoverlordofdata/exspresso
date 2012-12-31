### Globals

Globals in Exspresso are read only and immutable.
They are set once using 'define' and cannot be re-defined.
Constants from CodeIgniter and PHP only have been replicated.

    Constants           index.coffee
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
          MY_Server           application/core/AppServer.coffee
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

