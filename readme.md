# Exspresso


### Exspresso is ...

  The CodeIgniter (<http://codeigniter.com/>) MVC framework ported to coffee-script and wrapped around the Express core.


## Status


* Welcome page - working
* Cache - use express
* Common - working
* Config - working
* Controller - working
* Database - mysql & postgresql
    * DB_active_rec - working
    * DB_cache      - in progress
    * DB_driver     - working
    * DB_forge      - testing mysql
    * DB_result     - working
    * DB_utility    - in progress
* Exceptions - working
* Hooks - in progres
* Input - working
* Lang - testing
* Loader - working
* Model - working
* Output - working
* Router - working
* Migrations class - working
* Parser class - in progress
* Session class - working
* Form_validation class - testing
* form_helper - testing
* url_helper - testing

  In general, files with an extension of .php are not yet ported, and files with an extension of .php.coffee are in progress.

## Features

* Eco templating engine
* CodeIgniter style ActiveRecord
* Port of HMVC extension by Wiredesignz
* Edit configuration defaults in application/config/config.coffee
* Php2coffee command line port tool


## PHP2Coffee

  Requires Zend compatible php runtime:s

    Usage: bin/php2coffee [OPTIONS] PATH [DESTINATION]

      -h, --help          display this help
      -j. --javascript    compiles resulting .coffee file
      -r, --recursive     recurse source path
      -t, --trace         trace output
      -T, --tabs          use tab character in output (default is spaces)
      -d, --dump          dump of tokens


## lib

  Ported code uses lib.coffee, a php compatability layer.
  A group of helper functions that mimic the php api.
  Use cake test to test lib.






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
