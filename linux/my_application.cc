#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  GtkHeaderBar* header_bar;
  GtkCssProvider* css_provider;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)


// Update header bar color from Flutter
static void update_header_bar_color(MyApplication* self, int r, int g, int b, int a) {
  if (!self->header_bar || !self->css_provider) {
    return;
  }
  
  // Calculate perceived brightness (0-255)
  double brightness = (r * 0.299 + g * 0.587 + b * 0.114);
  gboolean is_light = brightness > 128;
  
  // Update window's prefer-dark-theme based on background brightness
  GtkSettings* settings = gtk_settings_get_default();
  g_object_set(settings, "gtk-application-prefer-dark-theme", !is_light, nullptr);
  
  // Convert RGBA to CSS color string
  double alpha = a / 255.0;
  gchar* css = g_strdup_printf(
      "headerbar { "
      "  min-height: 40px; "
      "  padding: 0px; "
      "  background-color: rgba(%d, %d, %d, %.2f); "
      "  background-image: none; "
      "  box-shadow: none; "
      "  border-bottom: 1px solid rgba(%d, %d, %d, 0.1); "
      "  color: %s; "
      "}",
      r, g, b, alpha,
      is_light ? 0 : 255, is_light ? 0 : 255, is_light ? 0 : 255,  // Border color
      is_light ? "#000000" : "#ffffff"   // Title text color
  );
  
  gtk_css_provider_load_from_data(self->css_provider, css, -1, nullptr);
  g_free(css);
}

struct MethodCallData {
  MyApplication* app;
  GtkWidget* loading_box;
};

// Handle method calls from Flutter
static void method_call_handler(FlMethodChannel* channel,
                                FlMethodCall* method_call,
                                gpointer user_data) {
  struct MethodCallData* call_data = (struct MethodCallData*)user_data;
  MyApplication* self = call_data->app;
  const gchar* method = fl_method_call_get_name(method_call);
  
  if (strcmp(method, "updateHeaderBarColor") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    
    int r = fl_value_get_int(fl_value_lookup_string(args, "r"));
    int g = fl_value_get_int(fl_value_lookup_string(args, "g"));
    int b = fl_value_get_int(fl_value_lookup_string(args, "b"));
    int a = fl_value_get_int(fl_value_lookup_string(args, "a"));
    
    update_header_bar_color(self, r, g, b, a);
    
    fl_method_call_respond_success(method_call, nullptr, nullptr);
  } else if (strcmp(method, "flutterReady") == 0) {
    // Hide loading when Flutter notifies it's ready
    if (call_data->loading_box && GTK_IS_WIDGET(call_data->loading_box)) {
      gtk_widget_destroy(call_data->loading_box);
      call_data->loading_box = nullptr;
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  
  // Detect system theme using gsettings
  gboolean prefer_dark = FALSE;
  GSettings* interface_settings = g_settings_new("org.gnome.desktop.interface");
  if (interface_settings) {
    gchar* color_scheme = g_settings_get_string(interface_settings, "color-scheme");
    if (color_scheme) {
      prefer_dark = (g_strcmp0(color_scheme, "prefer-dark") == 0);
      g_free(color_scheme);
    }
    g_object_unref(interface_settings);
  }
  
  // Set background color based on theme
  const gchar* bg_color = prefer_dark ? "#2d2d2d" : "#fafafa";
  
  // Set GTK theme preference to match background for correct icon colors
  GtkSettings* gtk_settings = gtk_settings_get_default();
  g_object_set(gtk_settings, "gtk-application-prefer-dark-theme", prefer_dark, nullptr);
  
  // Apply window background color
  gchar* window_css = g_strdup_printf("window { background-color: %s; }", bg_color);
  GtkCssProvider* window_provider = gtk_css_provider_new();
  gtk_css_provider_load_from_data(window_provider, window_css, -1, nullptr);
  g_free(window_css);
  
  gtk_style_context_add_provider_for_screen(
      gdk_screen_get_default(),
      GTK_STYLE_PROVIDER(window_provider),
      GTK_STYLE_PROVIDER_PRIORITY_USER);
  g_object_unref(window_provider);
  
  gtk_window_set_title(window, "SkorionOS Tool");
  gtk_window_set_default_size(window, 800, 550);

  // Create a minimal header bar with native buttons
  GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
  gtk_header_bar_set_title(header_bar, "SkorionOS Tool");
  gtk_header_bar_set_show_close_button(header_bar, TRUE);
  
  // Apply initial header bar styling
  GtkCssProvider* css_provider = gtk_css_provider_new();
  const gchar* initial_css;
  if (prefer_dark) {
    initial_css = 
      "headerbar { "
      "  min-height: 40px; "
      "  padding: 0px; "
      "  background-color: #2d2d2d; "
      "  background-image: none; "
      "  box-shadow: none; "
      "  border-bottom: 1px solid rgba(255, 255, 255, 0.1); "
      "  color: #ffffff; "
      "}";
  } else {
    initial_css = 
      "headerbar { "
      "  min-height: 40px; "
      "  padding: 0px; "
      "  background-color: #fafafa; "
      "  background-image: none; "
      "  box-shadow: none; "
      "  border-bottom: 1px solid rgba(0, 0, 0, 0.1); "
      "  color: #000000; "
      "}";
  }
  gtk_css_provider_load_from_data(css_provider, initial_css, -1, nullptr);
  
  GtkStyleContext* context = gtk_widget_get_style_context(GTK_WIDGET(header_bar));
  gtk_style_context_add_provider(context,
                                   GTK_STYLE_PROVIDER(css_provider),
                                   GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
  gtk_widget_show(GTK_WIDGET(header_bar));
  gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  
  // Store references for dynamic theme updates
  self->header_bar = header_bar;
  self->css_provider = css_provider;
  
  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  // Create overlay for loading indicator
  GtkWidget* overlay = gtk_overlay_new();
  
  FlView* view = fl_view_new(project);
  
  // Set FlView background color to match theme
  GdkRGBA rgba_color;
  gdk_rgba_parse(&rgba_color, bg_color);
  fl_view_set_background_color(view, &rgba_color);
  
  gtk_container_add(GTK_CONTAINER(overlay), GTK_WIDGET(view));
  
  // Create loading indicator
  GtkWidget* loading_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 12);
  gtk_widget_set_halign(loading_box, GTK_ALIGN_CENTER);
  gtk_widget_set_valign(loading_box, GTK_ALIGN_CENTER);
  
  GtkWidget* spinner = gtk_spinner_new();
  gtk_spinner_start(GTK_SPINNER(spinner));
  gtk_widget_set_size_request(spinner, 48, 48);
  gtk_box_pack_start(GTK_BOX(loading_box), spinner, FALSE, FALSE, 0);
  
  GtkWidget* label = gtk_label_new("Loading...");
  gtk_box_pack_start(GTK_BOX(loading_box), label, FALSE, FALSE, 0);
  
  gtk_overlay_add_overlay(GTK_OVERLAY(overlay), loading_box);
  
  gtk_widget_show_all(GTK_WIDGET(view));
  gtk_widget_show_all(loading_box);
  gtk_widget_show(overlay);
  
  gtk_container_add(GTK_CONTAINER(window), overlay);
  gtk_widget_show(GTK_WIDGET(window));
  

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));
  
  // Set up method channel for theme sync
  FlEngine* engine = fl_view_get_engine(view);
  FlBinaryMessenger* messenger = fl_engine_get_binary_messenger(engine);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      messenger,
      "sk_chos_tool/theme",
      FL_METHOD_CODEC(codec));
  // Pass both app and loading_box to method handler
  struct MethodCallData* call_data = g_new(struct MethodCallData, 1);
  call_data->app = self;
  call_data->loading_box = loading_box;
  
  fl_method_channel_set_method_call_handler(
      channel,
      method_call_handler,
      call_data,
      nullptr);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  //MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  //MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  if (self->css_provider) {
    g_object_unref(self->css_provider);
    self->css_provider = nullptr;
  }
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}
