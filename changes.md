# change history

### Version 0.10.x (6/1/13)
* In preperation for repelase, the Exspresso core was split off by itself,
with the demo as a seperate module with a dependancy on this one.

### Version 0.10.10 (6/11/13)
* Remove db/Driver dependancy on the package version (broken with module separation)
* Remove non-essential modules from package.json

### Version 0.10.11 (6/12/13)
* Remove webview to seperate project

### Version 0.10.12 (6/17/13)
* Refactor system.core.Connect to use template pattern for initialization. This allows
a subclass hook before & after each initializtion step. Driven by asset management. No changes
were made to logic, this only exposes the interface.

### Version 0.10.13 (6/18/13)
* Update documentation.

### Version 0.10.14 (6/19/13)
* Add x-powered by header: Exspresso/Vx.y.z
* Refactor system.core.Connect initialize to integrate system.core.Render.

### Version 0.10.15 (6/27/13)
* Check for process.env.NODE_ENV in addition to process.env.ENVIRONMENT.
* Remove references to application namespace.
* Refactor db.Driver::query to clean up async logic.
* Refactor core.Object::run to clean up async logic.

### Version 0.10.16 (6/28/13)
* Bind db.Driver::query & db.Driver::simpleQuery so that queued queries run in context.

### Version 0.10.17 (6/29/13)
* Fix db.Driver::query: pg client does not return metadata

### Version 0.10.18 (6/30/13)
* Set config overrides: ./index.coffee.
* Refactor folders. Expresso doesn't use ./lib.

### Version 0.10.19 (7/5/13)
* Clean up front end logic: ./index.coffee.

### Version 0.10.20 (7/6/13)
* Start bin/exspresso.

### Version 0.10.21 (7/6/13)
* Command exspresso new <appname>.

### Version 0.10.22 (7/6/13)
* Command exspresso new <appname>.

### Version 0.10.23 (7/8/13)
* Add scaffolding commands.

### Version 0.10.24 (7/9/13)
* Fix scaffold routing.

### Version 0.10.25 (8/21/13)
* Adjust links to darkoverlordofdata domain.
* Add .openshift config (https://github.com/openshift-quickstart/nodejs-custom-version-openshift)
