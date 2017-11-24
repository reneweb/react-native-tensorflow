package com.rntensorflow;

import android.content.res.AssetManager;
import android.webkit.URLUtil;
import com.facebook.react.modules.network.OkHttpClientProvider;
import okhttp3.Request;
import okhttp3.Response;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

public class ResourceManager {

    private AssetManager assetManager;

    public ResourceManager(AssetManager assetManager) {
        this.assetManager = assetManager;
    }

    public String loadResourceAsString(String resource) {
        return new String(loadResource(resource));
    }

    public byte[] loadResource(String resource) {
        if(URLUtil.isValidUrl(resource)) {
            return loadFromUrl(resource);
        } else {
            return loadFromLocal(resource);
        }
    }

    private byte[] loadFromLocal(String resource) {
        try {
            InputStream inputStream = assetManager.open(resource);
            byte[] b = new byte[inputStream.available()];
            inputStream.read(b);
            return b;
        } catch (IOException e) {
            try {
                InputStream inputStream = new FileInputStream(resource);
                byte[] b = new byte[inputStream.available()];
                inputStream.read(b);
                return b;
            } catch (IOException e1) {
                throw new IllegalArgumentException("Could not load resource");
            }
        }
    }

    private byte[] loadFromUrl(String url) {
        try {
            Request request = new Request.Builder().url(url).get().build();
            Response response = OkHttpClientProvider.createClient().newCall(request).execute();
            return response.body().bytes();
        } catch (IOException e) {
            throw new IllegalStateException("Could not fetch data from url " + url);
        }
    }
}
