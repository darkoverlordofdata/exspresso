/*
+--------------------------------------------------------------------+
| Preview
+--------------------------------------------------------------------+
| Copyright DarkOverlordOfData (c) 2013
+--------------------------------------------------------------------+
|
| file is a part of Exspresso
|
| Exspresso is free software; you can copy, modify, and distribute
| it under the terms of the MIT License
|
+--------------------------------------------------------------------+
*
* @copyright	DarkOverlordOfData (c) 2013
* @author		BruceDavidson@darkoverlordofdata.com
*
*
* Class Preview
*
*  A WebKit client to preview the local server output
*
*
*/

using Gtk;
using WebKit;

public class Preview : Window {

    private const string TITLE = "Preview";
    private const int WIDTH = 1024;
    private const int HEIGHT = 768;
    
    private WebView webView;
    private ToolButton backButton;
    private ToolButton forwardButton;
    private ToolButton reloadButton;

    /*
     * Constructor
     */
    public Preview() {

        title = Preview.TITLE;
        set_default_size(Preview.WIDTH, Preview.HEIGHT);
        createWidgets();
        connectEvents();
    }

    /*
     * Create Widgets
     *
     * @return void
     *
     */
    private void createWidgets() {

        //  Make the toolbar
        var toolbar = new Toolbar();
        backButton = new ToolButton.from_stock(Stock.GO_BACK);
        forwardButton = new ToolButton.from_stock(Stock.GO_FORWARD);
        reloadButton = new ToolButton.from_stock(Stock.REFRESH);
        toolbar.add(backButton);
        toolbar.add(forwardButton);
        toolbar.add(reloadButton);

        //  Make the browser window
        webView = new WebView();
        var scrolled_window = new ScrolledWindow(null, null);
        scrolled_window.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scrolled_window.add(webView);


        //  Finish assebmling the gui components
        var vbox = new VBox(false, 0);
        vbox.pack_start(toolbar, false, true, 0);
        vbox.add(scrolled_window);
        add(vbox);
    }

    /*
     * Connect Events
     *
     * @return void
     *
     */
    private void connectEvents() {

        webView.title_changed.connect(

          /*
           * On Title Changed
           *
           * @param source
           * @param frame
           * @param title
           * @return void
           *
           */
          (source, frame, title) => {

              this.title = "%s - %s".printf(title, Preview.TITLE);
          });

        webView.load_committed.connect(

          /*
           * On Load Committed
           *
           * @param source
           * @param frame
           * @return void
           *
           */
          (source, frame) => {

              this.updateButtons();
          });

        // wire up the plumbing
        destroy.connect(Gtk.main_quit);
        backButton.clicked.connect(webView.go_back);
        forwardButton.clicked.connect(webView.go_forward);
        reloadButton.clicked.connect(webView.reload);
    }

    /*
     * Update Buttons
     *
     * @return void
     *
     */
    private void updateButtons() {

        backButton.sensitive = webView.can_go_back();
        forwardButton.sensitive = webView.can_go_forward();
    }


    /*
     * Start
     *
     * @param string  url the root url to start the client at
     * @return void
     *
     */
    public void start(string url) {

        show_all();
        webView.open(url);
    }

    /*
     * Main
     *
     * @param array<string>  args command line args
     * @return int  0 Success!
     *
     */
    public static int main(string[] args) {

        Gtk.init(ref args);
        var client = new Preview();
        client.start(args[1]);
        Gtk.main();
        return 0;
    }
}



