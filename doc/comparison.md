# Compare Exspresso to CodeIgniter

Exspresso was created to allow me to use a CodeIgniter style organization in my
coffee-script projects. But there are some differences.

## Server
CodeIgniter is written in PHP, and runs under a seperate server, typically Apache. Every page
has a boot and die sequence.

Exspresso runs in the same process with connect.js This is a huge change in the lifecycle.

## Routing
All url mapping is calculated during system load to integrate with connect's dispatching.
The requested class/method is searched for first in application/controllers. If not found
in application, then the requested  name/class/method is searched for in modules/<name>/controllers

All controller methods must end with an 'Action' suffix to be mapped. The method name is optional.
If there is no match for method, then the request is assumed to be for the default value 'indexAction'.

For example, 'http://localhost:300/admin' maps to the method Admin::indexAction
```CoffeeScript
exports['/admin'] = 'Admin/index'
```

## Magic
CodeIgniter uses PHP magic methods to dispatch missing method calls to the controller.
Exspresso uses prototype injection to emulate this behavior.

## Templates
Exspresso uses embedded coffee-script (*.eco) for all view files. All helpers, supplied data elements,
and controller members are available to the view as a member of this.
Additionaly, exspresso can use theming and layouts, organized similar to drupal folders.

## Config
Exspresso uses node modules to store config settings. Export properties are used in place of a
$config variable (See Routing, above). Unlike CodeIgniter, multiple configs cascade.

For example, when the Template lib is loaded, Exspresso first loads config/template.coffee. Next,
the config/ENVIRONMENT/template.coffee is loaded, if it exists, and merged. Finally, any config
options passed to load.library are then merged. The result is passed to the lib class constructor.

## Locale
CodeIgniters lang folder is replaced with an i18n structure. Subfolders of i18n correspond to
ISO 639-1 language abbreviations - en for English, and so on. Each subfolder contains *.json
files with language mappings.




