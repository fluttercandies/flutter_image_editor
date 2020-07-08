package top.kikt.flutter_image_editor.common.font;

import android.graphics.Typeface;
import android.os.Build;

import androidx.annotation.RequiresApi;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.io.EOFException;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class FontUtils {
    private static int fontIndex = -1;
    private static Map<String, Typeface> map = new HashMap<>();

    public static String registerFont(String path) throws IOException {
        String fontName = null;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            fontName = parseFontName(new ReusableBufferedInputStream(new FileInputStream(path), 4096));
        }

        if (fontName == null) {
            fontIndex++;
            fontName = String.valueOf(fontIndex);
        }

        if (map.containsKey(fontName)) {
            return fontName;
        }

        Typeface typeface = Typeface.createFromFile(new File(path));
        map.put(fontName, typeface);
        return fontName;
    }


    @SuppressWarnings("ResultOfMethodCallIgnored")
    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    public static String parseFontName(ReusableBufferedInputStream bin) throws IOException {
        bin.skip(4);
        int numOfTables = readShort(bin);
        bin.skip(6);
        boolean found = false;
        byte[] buff = new byte[4];
        for (int i = 0; i < numOfTables; i++) {
            bin.read(buff, 0, 4);
            int offset = readInt(bin);
            String tname = new String(buff, StandardCharsets.UTF_8);
            if ("name".equalsIgnoreCase(tname)) {
                int now = 12 + 16 * (i + 1);
                int toSkip = offset - now;
                if (toSkip >= 0) {
                    while (toSkip > 0) {
                        toSkip -= bin.skip(toSkip);
                    }
                    int nRCount = readShort(bin);
                    int storageOffset = readShort(bin);
                    for (int j = 0; j < nRCount; j++) {
                        int platformID = readShort(bin);
                        int encodingID = readShort(bin);
                        int nameID = readShort(bin);
                        int stringLength = readShort(bin);
                        int stringOffset = readShort(bin);
                        //1 says that this is font name. 0 for example determines copyright info
                        if (nameID == 1) {
                            //byte[] bf = bin.getBytes();
                            byte[] bf = new byte[stringLength];
                            offset = now + stringOffset + storageOffset;
                            now = now + 3 * 2 + 6 * 2 * (j + 1);
                            toSkip = offset - now;
                            //CMN.Log("font name found!!!", stringLength, offset, now, toSkip);
                            if (toSkip >= 0) {
                                while (toSkip > 0) {
                                    toSkip -= bin.skip(toSkip);
                                }
                                bin.read(bf, 0, stringLength);
                                boolean utf8 = platformID == 3 && (encodingID == 0 || encodingID == 1 || encodingID == 10) || platformID == 0 && encodingID >= 0 && encodingID <= 4;
                                //CMN.Log(platformID, encodingID, utf8);
                                return new String(bf, 0, stringLength, utf8 ? StandardCharsets.UTF_16 : StandardCharsets.UTF_8);
                            }
                            break;
                        }
                    }
                }
                break;
            } else if (tname.length() == 0) {
                break;
            }
        }
        return null;
    }

    private static int readInt(InputStream bin) throws IOException {
        int ch1 = bin.read();
        int ch2 = bin.read();
        int ch3 = bin.read();
        int ch4 = bin.read();
        if ((ch1 | ch2 | ch3 | ch4) < 0)
            throw new EOFException();
        return ((ch1 << 24) + (ch2 << 16) + (ch3 << 8) + (ch4));
    }

    private static int readShort(InputStream bin) throws IOException {
        int ch1 = bin.read();
        int ch2 = bin.read();
        if ((ch1 | ch2) < 0)
            throw new EOFException();
        return (short) ((ch1 << 8) + (ch2));
    }

    @Nullable
    public static Typeface getFont(@NotNull String fontName) {
        return map.get(fontName);
    }
}
