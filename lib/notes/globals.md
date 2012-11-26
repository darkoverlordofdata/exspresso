# Globals in Exspresso

    Globals in Exspresso are read only and immutable. They are set once using 'define' and cannot be re-defined.


### Constants         index.coffee)

    APPPATH           path to the 'application' folder
    BASEPATH          path to the 'system' folder
    ENVIRONMENT       dev, test, prod
    EXT               default file extension '.coffee'
    FCPATH            path to the front end controller
    SYSDIR            name of the 'system' folder
    WEBROOT           path to the 'public' folder

### Common methods    system/core/Common.coffee)

    config_item       get a config item
    get_config        get a config record
    get_instance      get main controller instance
    is_loaded         list of loaded classes
    load_class        load a singleton
    load_new          instantiate a class
    log_message       write to the application log
    show_404          page not found
    show_error        internal application error

### Classes

    CI_Config         system/core/Config.coffee
    CI_Controller     system/core/Controller.coffee
    CI_Exceptions     system/core/Exceptions.coffee
    CI_Hooks          system/core/Hooks.coffee
    CI_Input          system/core/Input.coffee
    CI_Lang           system/core/Lang.coffee
    CI_Loader         system/core/Loader.coffee
    CI_Model          system/core/Model.coffee
    CI_Output         system/core/Output.coffee
    CI_Router         system/core/Router.coffee
    CI_Log            system/libraries/Log.coffee
    CI_Session        system/Libraries/Session.coffee
    MX_Config         application/Libraries/Config.coffee
    MX_Lang         application/Libraries/Config.coffee
    MX_Config         application/Libraries/Config.coffee
    MX_Config         application/Libraries/Config.coffee
    MX_Config         application/Libraries/Config.coffee


### PHP Compatability Lib (./lib/index.coffee)

    array_keys
    array_unique
    array_values
    array_merge
    array_shift
    array_slice
    array_splice
    array_unshift
    class_exists
    constant
    count
    current
    define
    defined
    die
    dirname
    end
    exit
    explode
    format_number
    file_exists
    implode
    in_array
    is_array
    is_bool
    is_dir
    is_null
    is_numeric
    is_object
    is_string
    ltrim
    microtime
    parse_str
    parse_url
    preg_match
    preg_replace
    rawurldecode
    realpath
    rtrim
    str_replace
    stristr
    strlen
    strncmp
    strpos
    strrchr
    strrpos
    strstr
    strtolower
    strtoupper
    substr
    trim
    ucfirst






