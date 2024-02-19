#include "webview.h"

namespace webview_ffi {

	class WebviewBrowserEngine : public webview::webview {
	public:
		WebviewBrowserEngine(bool withDevToolsEnabled, void* existingNativeWindow)
			: webview::webview(withDevToolsEnabled, existingNativeWindow) {
		}
		int step(int blocking) {
			return gtk_main_iteration_do(blocking);
		}

		void toggleFullScreen() {
			GtkWindow* gtkWindow = GTK_WINDOW(window());
			GdkWindow* gdkWindow = gtk_widget_get_window(GTK_WIDGET(gtkWindow));
			GdkWindowState state = gdk_window_get_state(gdkWindow);

			if(state & GDK_WINDOW_STATE_FULLSCREEN) gtk_window_unfullscreen(gtkWindow);
			else gtk_window_fullscreen(gtkWindow);
		}

		bool setAppIcon(const char* iconPath) {
			GError* error = NULL;
			GdkPixbuf* pixelBuffer = gdk_pixbuf_new_from_file(iconPath, &error);

			if(pixelBuffer != NULL) {
				gtk_window_set_icon(GTK_WINDOW(window()), pixelBuffer);
				g_object_unref(pixelBuffer);
				return true;
			} else {
				g_warning("Failed to set app icon: %s", error->message);
				g_error_free(error);
				return false;
			}
		}
	};
}