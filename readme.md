# [Exspresso v0.9.2] (https://github.com/darkoverlordofdata/exspresso)

 A CoffeeScript framework inspired by [CodeIgniter] (<http://codeigniter.com/>)

    Exspresso Features:

      * Runs on the connect.js stack
      * HMVC architecture
      * Magic: controller members are available to all libs, models, and views.
      * Embedded coffee-script (*.eco) views.
      * DB Drivers for
        * MySQL       - requires mysql
        * PostgreSQL  - requires pg
        * SQLite      - requires sqlite3
      * Cascading configuration
      * Themed templating engine
      * Bootstrap css styles
      * Run as a desktop application in dedicated webkit window (requires vala)

 [Live Demo!](http://exspresso.herokuapp.com/) on heroku using postgesql database.



## Quick Start

### Install

```bash
$ npm install exspresso
```


### Run on localhost

```bash
$ node exspresso.js --db sqlite --install
$ node exspresso.js --db sqlite --install --subclass Express
```
and point your browser to http://localhost:5000

```bash
Usage: node exspresso [--option]

Options:
 --cache
 --csrf
 --desktop
 --preview
 --profile
 --subclass <Express>
 --nocache
 --nocsrf
 --noprofile
 --db <mysql|postgres|sqlite>
```

To use the -- preview or --desktop options, you will need to build the excutable.
note - valac required.
```bash
$ sudo apt-get install valac
$ cake build:preview
```

```bash
$ sudo apt-get install valac
$ cake build:desktop
```

### More...

  * [Compare](/comparison.md) Compare Exspresso to CodeIgniter
  * [Magic](/magic.md) Inheritance injection
  * [Coding](/coding%20standards.md) Exspresso coding standards
  * [Status](/class%20status.md) Component status
  * [Todo](/todo.md) Wish list

## License

(The MIT License)

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
