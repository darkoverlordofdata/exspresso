# Exspresso v0.10.25

An MVC Web Framework written in CoffeeScript.


Exspresso uses adapter classes to wrap connect middleware

  * Runs on the connect.js http stack
  * Magic: Prototype Injection makes all controller members available in all libs, models, and views.
  * Multiple view formats
    * html
    * md (markdown)
    * eco (embedded coffee-script)
  * DB Drivers for
    * MySQL       - requires mysql
    * PostgreSQL  - requires pg
    * SQLite      - requires sqlite3

 [Live Demo!] (<http://exspresso.aws.cf.cm/>)



## Quick Start

### Install

```bash
$ sudo npm install exspresso -g
```


### Create a new application

```bash
exspresso new <appname>
cd <appname>
nmp install
npm start
```
and point your browser to http://localhost:53610

Look at <appname>/core/<Appname>Connect.coffee for an example
of how to extend exspresso.

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
