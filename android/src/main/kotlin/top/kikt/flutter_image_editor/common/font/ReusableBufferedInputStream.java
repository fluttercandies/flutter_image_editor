package top.kikt.flutter_image_editor.common.font;

import org.jetbrains.annotations.NotNull;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;

public class ReusableBufferedInputStream extends BufferedInputStream {
    public ReusableBufferedInputStream(@NotNull InputStream in, int size) {
        super(in, size);
    }

    public void reset(InputStream in) throws IOException {
        this.in = in;
        pos = 0;
        markpos = -1;
        count = 0;
    }

    public byte[] getBytes(){
        return buf;
    }
}
