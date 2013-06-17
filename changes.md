# change history

### Version 0.10.x (6/1/13)
* In preperation for repelase, the Exspresso core was split off by itself,
with the demo as a seperate module with a dependancy on this one.

### Version 0.10.10 (6/11/13)
* Remove db/Driver dependancy on the package version (broken with module separation)
* Cache the current context in $data.$this when calling the rendering engine. This is a
fix for swig, and other rendering engines that don't remember the context like ECO.
* Remove non-essential modules from package.json
* Remove webview to seperate project

### Version 0.10.11 (6/17/13)
* Refactor system.core.Connect to use template pattern for initialization. This allows
a subclass hook before & after each initializtion step. Driven by asset management. No changes
were made to logic, this only exposes the interface.