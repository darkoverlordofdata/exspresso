# [Exspresso v0.8.1] (https://github.com/darkoverlordofdata/exspresso)

 A framework for coffee-script, based on the [CodeIgniter] (<http://codeigniter.com/>) framework, v2.1.

    Exspresso features

      * HMVC architecture ported from Wiredesignz
      * embedded coffee-script (ECO) for views.
      * bootstrap css styles
      * DB Drivers for MySQL and PostgreSQL
      * Configuration inheritance
      * Themed templating engine
      * Per module migrations

 [Live Demo!](http://exspresso.herokuapp.com/)

  Exspresso uses [not-php] (http://github.com/darkoverlordofdata/not-php) v0.3.9 as a drop in
  replacement for many of the php api calls that were in the ported code.


## Quick Start

### Install

<code>$ npm install exspresso</code>

### Run on localhost

  <code>$ npm start</code><br />
  and point your browser to http://localhost:5000

    usage:

    node [--harmony] index <appjs|connect|express> <mvc|hmvc> [--option]

     options:
     --cache
     --csrf
     --preview
     --profile
     --nocache
     --nocsrf
     --noprofile
     --db <mysql|postgres>

    examples:
     node --harmony index appjs
     node index connect
     node index express



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
