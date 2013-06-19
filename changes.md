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
* Add x-powered by header: Exspresso/V0.10.13