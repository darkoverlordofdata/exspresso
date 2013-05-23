<div class="container">
    <p>{$notes}</p>
    <ul class="nav nav-tabs" id="katra-menu">
        <li class="active"><a href="#code" data-target="#katra-tab-code" data-toggle="tab">code</a></li>
        <li class="dropdown">
            <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                exec<b class="caret"></b>
            </a>
            <ul class="dropdown-menu">
                <li><a href="#" data-target="#katra-tab-exec" data-toggle="tab">view</a></li>
                <li><a href="#" data-target="#katra-tab-exec" data-toggle="tab" class="katra-run">run</a></li>
            </ul>
        </li>
        <li><a href="#log" data-target="#katra-tab-log" data-toggle="tab">log</a></li>
        <li><a href="#repl" data-target="#katra-tab-repl" data-toggle="tab">repl</a></li>
    </ul>

    <div class="tab-content">

        <div class="tab-pane active" id="katra-tab-code">
            <div class="katra-source-panel katra-border">
                <pre id="katra-source" class="katra-source prettyprint">{$code}</pre>
            </div>
        </div>

        <div class="tab-pane" id="katra-tab-exec">
            <div class="katra-output-panel katra-border"></div>
            <div class="katra-input-panel katra-border"></div>
        </div>

        <div class="tab-pane" id="katra-tab-log">
            <div class="katra-logger-panel katra-border"></div>
        </div>

        <div class="tab-pane" id="katra-tab-repl">
            <div class="katra-repl-panel katra-border"></div>
        </div>

    </div>
</div>