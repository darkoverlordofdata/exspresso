using Gtk;
using WebKit;

public class ValaBrowser : Window {

    private const string TITLE = "Preview";
    private const int WIDTH = 1024;
    private const int HEIGHT = 768;
    
    private WebView web_view;
    private Label status_bar;
    private ToolButton back_button;
    private ToolButton forward_button;
    private ToolButton reload_button;

    public ValaBrowser() {
        this.title = ValaBrowser.TITLE;
        set_default_size(ValaBrowser.WIDTH, ValaBrowser.HEIGHT);
        create_widgets();
        connect_signals();
    }

    private void create_widgets() {
        var toolbar = new Toolbar();
        this.back_button = new ToolButton.from_stock(Stock.GO_BACK);
        this.forward_button = new ToolButton.from_stock(Stock.GO_FORWARD);
        this.reload_button = new ToolButton.from_stock(Stock.REFRESH);
        toolbar.add(this.back_button);
        toolbar.add(this.forward_button);
        toolbar.add(this.reload_button);

        this.web_view = new WebView();
        var scrolled_window = new ScrolledWindow(null, null);
        scrolled_window.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scrolled_window.add(this.web_view);
        this.status_bar = new Label("");
        this.status_bar.xalign = 0;
        var vbox = new VBox(false, 0);
        vbox.pack_start(toolbar, false, true, 0);
        vbox.add(scrolled_window);
        vbox.pack_start(this.status_bar, false, true, 0);
        add(vbox);
    }

    private void connect_signals() {
        this.destroy.connect(Gtk.main_quit);
        this.web_view.title_changed.connect((source, frame, title) => {
            this.title = "%s - %s".printf(title, ValaBrowser.TITLE);
        });
        this.web_view.load_committed.connect((source, frame) => {
            this.status_bar.label = frame.get_uri();
            update_buttons();
        });
        this.back_button.clicked.connect(this.web_view.go_back);
        this.forward_button.clicked.connect(this.web_view.go_forward);
        this.reload_button.clicked.connect(this.web_view.reload);
    }

    private void update_buttons() {
        this.back_button.sensitive = this.web_view.can_go_back();
        this.forward_button.sensitive = this.web_view.can_go_forward();
    }


    public void start(string url) {
        show_all();
        this.web_view.open(url);
    }

    public static int main(string[] args) {
        Gtk.init(ref args);
        var browser = new ValaBrowser();
        browser.start(args[1]);
        Gtk.main();
        return 0;
    }
}



