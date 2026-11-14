package app.urbana.juego;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Base64;
import android.view.View;
import android.view.WindowManager;
import android.webkit.JavascriptInterface;
import android.webkit.MimeTypeMap;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Map;

/** URBANA: el juego web completo adentro de la app, sin internet. */
public class MainActivity extends Activity {
    private static final String HOST = "urbana.app";
    private static final String HOME = "https://" + HOST + "/index.html";
    private static final int REQ_OPEN = 1, REQ_SAVE = 2;

    private WebView web;
    private ValueCallback<Uri[]> fileCb;
    private byte[] pendingBytes;
    private long lastBack;

    @Override
    protected void onCreate(Bundle state) {
        super.onCreate(state);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        if (Build.VERSION.SDK_INT >= 28) {
            WindowManager.LayoutParams lp = getWindow().getAttributes();
            lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
            getWindow().setAttributes(lp);
        }
        web = new WebView(this);
        web.setBackgroundColor(Color.rgb(20, 32, 27));
        web.setOverScrollMode(View.OVER_SCROLL_NEVER);
        web.setVerticalScrollBarEnabled(false);
        web.setHorizontalScrollBarEnabled(false);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setDatabaseEnabled(true);
        s.setMediaPlaybackRequiresUserGesture(false);
        s.setAllowFileAccess(false);
        s.setAllowContentAccess(false);
        s.setSupportZoom(false);
        s.setBuiltInZoomControls(false);
        s.setTextZoom(100);
        s.setUserAgentString(s.getUserAgentString() + " UrbanaApp/1");
        web.addJavascriptInterface(new Bridge(), "UrbanaApp");
        web.setWebViewClient(new WebViewClient() {
            @Override
            public WebResourceResponse shouldInterceptRequest(WebView v, WebResourceRequest r) {
                Uri u = r.getUrl();
                if (!HOST.equals(u.getHost())) return null;
                String path = u.getPath();
                if (path == null || path.equals("/") || path.isEmpty()) path = "/index.html";
                try {
                    InputStream in = getAssets().open("www" + path);
                    String ext = MimeTypeMap.getFileExtensionFromUrl(path);
                    String mime = "webmanifest".equals(ext) ? "application/manifest+json"
                            : "js".equals(ext) ? "text/javascript"
                            : MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext);
                    if (mime == null) mime = "application/octet-stream";
                    boolean text = mime.startsWith("text/") || mime.contains("json") || mime.contains("javascript");
                    WebResourceResponse res = new WebResourceResponse(mime, text ? "utf-8" : null, in);
                    Map<String, String> h = new HashMap<>();
                    h.put("Cache-Control", "no-cache");
                    res.setResponseHeaders(h);
                    return res;
                } catch (Exception e) {
                    return new WebResourceResponse("text/plain", "utf-8", 404, "Not Found", new HashMap<String, String>(), new java.io.ByteArrayInputStream(new byte[0]));
                }
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView v, WebResourceRequest r) {
                Uri u = r.getUrl();
                if (HOST.equals(u.getHost())) return false;
                try { startActivity(new Intent(Intent.ACTION_VIEW, u)); } catch (Exception e) { /* sin navegador */ }
                return true;
            }
        });
        web.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onConsoleMessage(android.webkit.ConsoleMessage m) {
                android.util.Log.i("URBANA-JS", m.messageLevel() + " " + m.message() + " (" + m.lineNumber() + ")");
                return true;
            }

            @Override
            public boolean onShowFileChooser(WebView v, ValueCallback<Uri[]> cb, FileChooserParams p) {
                if (fileCb != null) fileCb.onReceiveValue(null);
                fileCb = cb;
                Intent i = new Intent(Intent.ACTION_GET_CONTENT);
                i.addCategory(Intent.CATEGORY_OPENABLE);
                i.setType("*/*");
                try {
                    startActivityForResult(Intent.createChooser(i, "Elegí el archivo"), REQ_OPEN);
                } catch (Exception e) {
                    fileCb = null;
                    cb.onReceiveValue(null);
                }
                return true;
            }
        });
        setContentView(web);
        hideBars();
        if (state != null) web.restoreState(state);
        if (web.getUrl() == null) web.loadUrl(HOME);
    }

    private void hideBars() {
        web.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_FULLSCREEN
                | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
    }

    @Override
    public void onWindowFocusChanged(boolean focus) {
        super.onWindowFocusChanged(focus);
        if (focus) hideBars();
    }

    @Override
    protected void onPause() {
        // guarda antes de quedar en segundo plano
        web.evaluateJavascript("try{window.__urbanaSave&&window.__urbanaSave()}catch(e){}", null);
        web.onPause();
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        web.onResume();
        hideBars();
    }

    @Override
    protected void onDestroy() {
        if (web != null) { web.stopLoading(); web.destroy(); web = null; }
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {
        // primero cierra lo que esté abierto en el juego; si no hay nada, dos veces para salir
        web.evaluateJavascript("(function(){try{return !!(window.__urbanaBack&&window.__urbanaBack())}catch(e){return false}})()", new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String r) {
                if ("true".equals(r)) return;
                long now = System.currentTimeMillis();
                if (now - lastBack < 2200) { moveTaskToBack(true); return; }
                lastBack = now;
                Toast.makeText(MainActivity.this, "Tocá atrás otra vez para salir", Toast.LENGTH_SHORT).show();
            }
        });
    }

    @Override
    protected void onActivityResult(int req, int res, Intent data) {
        super.onActivityResult(req, res, data);
        if (req == REQ_OPEN) {
            if (fileCb != null) {
                Uri u = res == RESULT_OK && data != null ? data.getData() : null;
                fileCb.onReceiveValue(u != null ? new Uri[]{u} : null);
                fileCb = null;
            }
        } else if (req == REQ_SAVE) {
            byte[] b = pendingBytes;
            pendingBytes = null;
            if (res == RESULT_OK && data != null && data.getData() != null && b != null) {
                try (OutputStream out = getContentResolver().openOutputStream(data.getData())) {
                    out.write(b);
                    Toast.makeText(this, "Archivo guardado", Toast.LENGTH_SHORT).show();
                } catch (Exception e) {
                    Toast.makeText(this, "No se pudo guardar el archivo", Toast.LENGTH_LONG).show();
                }
            }
        }
    }

    private class Bridge {
        /** El juego pide guardar un archivo (copia de la ciudad o foto): Android pregunta dónde. */
        @JavascriptInterface
        public void saveFile(final String name, final String mime, final String base64) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        pendingBytes = Base64.decode(base64, Base64.DEFAULT);
                        Intent i = new Intent(Intent.ACTION_CREATE_DOCUMENT);
                        i.addCategory(Intent.CATEGORY_OPENABLE);
                        i.setType(mime == null || mime.isEmpty() ? "application/octet-stream" : mime);
                        i.putExtra(Intent.EXTRA_TITLE, name);
                        startActivityForResult(i, REQ_SAVE);
                    } catch (Exception e) {
                        pendingBytes = null;
                        Toast.makeText(MainActivity.this, "No se pudo guardar el archivo", Toast.LENGTH_LONG).show();
                    }
                }
            });
        }

        /** Compartir un texto (por ejemplo el código de la ciudad) con otra app. */
        @JavascriptInterface
        public void shareText(final String title, final String text) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        Intent i = new Intent(Intent.ACTION_SEND);
                        i.setType("text/plain");
                        i.putExtra(Intent.EXTRA_SUBJECT, title);
                        i.putExtra(Intent.EXTRA_TEXT, text);
                        startActivity(Intent.createChooser(i, title));
                    } catch (Exception e) { /* nada con qué compartir */ }
                }
            });
        }

        @JavascriptInterface
        public String version() { return "VERSION_NAME"; }
    }
}
