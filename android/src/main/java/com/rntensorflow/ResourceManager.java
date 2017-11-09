package com.rntensorflow;

import android.content.res.AssetManager;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

public class ResourceManager {

    private AssetManager assetManager;

    public ResourceManager(AssetManager assetManager) {
        this.assetManager = assetManager;
    }

    public InputStream loadResource(String resource) {
        try {
            return assetManager.open(resource);
        } catch (IOException e) {
            try {
                return new FileInputStream(resource);
            } catch (FileNotFoundException e1) {
                throw new IllegalArgumentException("Could not load resource");
            }
        }
    }
}
