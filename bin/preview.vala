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

  private const string ICON = "lib/application/assets/favicon.png";
  private const string TITLE = "Preview";
  private const int WIDTH = 1280;
  private const int HEIGHT = 1024;

  private WebView webView;

  /**
   * Constructor
   */
  public Preview(string url) {

    icon = new Gdk.Pixbuf.from_file(ICON);
    title = Preview.TITLE;
    set_default_size(Preview.WIDTH, Preview.HEIGHT);

    //  Make the client window
    webView = new WebView();
    var scrolledWindow = new ScrolledWindow(null, null);
    scrolledWindow.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
    scrolledWindow.add(webView);

    // Assemble the gui components
    var vbox = new VBox(false, 0);
    vbox.add(scrolledWindow);
    add(vbox);

    // Add inspector to the context menu
    WebSettings settings = webView.get_settings();
    settings.enable_developer_extras = true;
    webView.web_inspector.inspect_web_view.connect(getInspectorView);

    // Wire up the events
    destroy.connect(Gtk.main_quit);
    webView.title_changed.connect(titleChanged);

    // Display
    show_all();
    webView.open(url);
    webView.set_zoom_level((float)1.1);
    webView.zoom_in();

  }

  /**
   * titleChanged
   *
   * Set title from the html <title>...</title> tags
   *
   * @param source
   * @param frame
   * @param title
   * @return void
   *
   */
  public void titleChanged(Object source, Object frame, string title) {

    this.title = title ?? Preview.TITLE;
  }

  /**
   * getInspectorView
   *
   * @param WebView
   * @return uncounted ref
   *
   */
  public unowned WebView getInspectorView(WebView v) {

    unowned WebView result = (new Inspector(this)).webView;
    return result;
  }

  /**
   * Main
   *
   * @param array<string>  args command line args
   * @return int  0 Success!
   *
   */
  public static int main(string[] args) {

    Gtk.init(ref args);
    var client = new Preview(args[1]);
    Gtk.main();
    return 0;
  }

  /**
   *
   * Class Inspector
   *
   * Wrap the web_inspector in it's own window
   *
   */
  class Inspector : Window {

    public WebView webView;

    /**
     *  Display the web_inspector
     */
    public Inspector(Window parent) {

      icon = parent.icon;
      title = "Developer Tools - " + (parent.title ?? Preview.TITLE);
      set_default_size(Preview.WIDTH, Preview.HEIGHT);

      //  Make the client window
      webView = new WebView();
      var scrolledWindow = new ScrolledWindow(null, null);
      scrolledWindow.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
      scrolledWindow.add(webView);
      add(scrolledWindow);

      show_all();
    }

    /**
     *  Teardown
     */
    ~Inspector() {
      webView.web_inspector.close();
    }
  }
}


