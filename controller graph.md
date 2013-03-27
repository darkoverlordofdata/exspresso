   ------------------------------------------------------------------------
 
    Graph of a sample web page controller object model, Home:
 
    -----------------     -----------------     -----------------     -----------------
    | Home          | --> | Home.prototype| --> | Controller.pro| --> | Object.prototy| --> null
    -----------------     -----------------     -----------------     -----------------
    | Config        | --> | Config.prototy| --> | Object.prototy| --> null
    -----------------     -----------------     -----------------     -----------------
    | Server        | --> | Server.prototy| --> | Express.protot| --> | Object.prototy| --> null
    -----------------     -----------------     -----------------     -----------------
    | Router        | --> | Router.prototy| --> | Object.prototy| --> null
    -----------------     -----------------     -----------------
    | Lang          | --> | Lang.prototype| --> | Object.prototy| --> null
    -----------------     -----------------     -----------------
    | Loader        | --> | Loader.prototy| --> | Home ...      |
    -----------------     -----------------     -----------------
    | URI           | --> | URI.prototype | --> | Home ...      |
    -----------------     -----------------     -----------------
    | Input         | --> | Input.prototyp| --> | Home ...      |
    -----------------     -----------------     -----------------
    | Output        | --> | Output.prototy| --> | Home ...      |
    -----------------     =================     -----------------     -----------------
                        . | Render method |     | $DATA param   | --> | Home ...      |
                          -----------------     -----------------     -----------------
    -----------------     -----------------     -----------------     -----------------     -----------------
    | DB            | --> | ActiveRec.prot| --> | dbdriver.proto| --> | mysql.prototyp| --> | Home ...      |
    -----------------     -----------------     -----------------     -----------------     -----------------
    | Session       | --> | Session.protot| --> | Driver.prototy| --> | Home ...      |
    -----------------     -----------------     -----------------     -----------------
    | Theme         | --> | Theme.prototyp| --> | Home ...      |
    -----------------     -----------------     -----------------
    | Template      | --> | Template.proto| --> | Home ...      |
    -----------------     -----------------     -----------------
 
 
    -->   represents the .__proto__ field of the object
    ...   represends a cyclic limk back to the controller instance
 