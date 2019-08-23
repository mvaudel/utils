package no.uib.marc.utils.svg;

import java.io.File;
import java.util.ArrayList;
import java.util.TreeMap;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import no.uib.marc.utils.io.SimpleFileReader;
import no.uib.marc.utils.io.SimpleFileWriter;

/**
 * This script merges svg images as produced by the R gtable package.
 *
 * @author Marc Vaudel
 */
public class MergeSvg {

    /**
     * The ids to extend.
     */
    public final String[] keyWords = new String[]{
        "glyph",
        "clip"
    };
    /**
     * The prefix of the ids.
     */
    public final String[] prefixes = new String[]{
        "\"",
        "#"
    };

    /**
     * Main method.
     *
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        
        MergeSvg instance = new MergeSvg();
        
        String destinationPath = args[0];
        
        ArrayList<String> svgs = IntStream.range(1, args.length)
                .mapToObj(i -> args[i])
                .collect(Collectors.toCollection(ArrayList::new));
        
        instance.mergeSvgs(destinationPath, svgs);

    }

    /**
     * Merges multiple svgs in a single svg. If files end with ".gz", they will
     * be handled as gzipped files. The first file is completed with graphics
     * from the others after updating of ids.
     *
     * @param svgFilePath the path to the file to write
     * @param svgFilesPaths the path to the files to merge
     */
    public void mergeSvgs(String svgFilePath, ArrayList<String> svgFilesPaths) {

        File svgFile = new File(svgFilePath);

        try (SimpleFileWriter writer = new SimpleFileWriter(svgFile, svgFilePath.endsWith(".gz"))) {

            TreeMap<String, SimpleFileReader> readers = svgFilesPaths.stream()
                    .collect(
                            Collectors.toMap(
                                    filePath -> (new File(filePath))
                                            .getName()
                                            .replace('.', '_'),
                                    filePath -> SimpleFileReader.getFileReader(new File(filePath)),
                                    (a, b) -> a,
                                    TreeMap::new
                            )
                    );

            String firstFile = readers.firstKey();

            // Header
            readers.entrySet()
                    .forEach(
                            entry -> writeHeader(
                                    entry.getValue(),
                                    writer,
                                    firstFile.equals(entry.getKey())
                            )
                    );

            // Defs
            writer.write("<defs>", true);
            readers.entrySet()
                    .forEach(
                            entry -> writeDefs(
                                    entry.getKey(),
                                    entry.getValue(),
                                    writer
                            )
                    );
            writer.write("</defs>", true);

            // Surface
            readers.entrySet()
                    .forEach(
                            entry -> writeSurface(
                                    entry.getValue(),
                                    writer,
                                    firstFile.equals(entry.getKey())
                            )
                    );

            // gs
            readers.entrySet()
                    .forEach(
                            entry -> writeGs(
                                    entry.getKey(),
                                    entry.getValue(),
                                    writer
                            )
                    );
            writer.write("</g>", true);
            writer.write("</svg>", true);

            // Close readers
            readers.values()
                    .forEach(
                            SimpleFileReader::close
                    );

        }
    }

    /**
     * Moves the reader to the line after the defs tag. If the reader is the
     * first, writes the content.
     *
     * @param reader the reader
     * @param writer the writer
     * @param firstFile a boolean indicating whether this is the first file
     */
    private void writeHeader(SimpleFileReader reader, SimpleFileWriter writer, boolean firstFile) {

        String line;

        while (!(line = reader.readLine()).equals("<defs>")) {

            if (firstFile) {

                writer.writeLine(line);

            }
        }
    }

    /**
     * Writes the defs.
     *
     * @param reader the reader
     * @param writer the writer
     */
    private void writeDefs(String fileKey, SimpleFileReader reader, SimpleFileWriter writer) {

        String line;

        while (!(line = reader.readLine()).equals("</defs>")) {

            writer.writeLine(
                    replaceIds(line, fileKey)
            );

        }
    }

    /**
     * Moves the reader to the line after the surface tag. If the reader is the
     * first, writes the content.
     *
     * @param reader the reader
     * @param writer the writer
     * @param firstFile a boolean indicating whether this is the first file
     */
    private void writeSurface(SimpleFileReader reader, SimpleFileWriter writer, boolean firstFile) {

        String line;

        while (!(line = reader.readLine()).contains("rect")) {

            if (firstFile) {

                writer.writeLine(line);

            }
        }

        if (firstFile) {

            writer.writeLine(line);

        }
    }

    /**
     * Writes the defs.
     *
     * @param reader the reader
     * @param writer the writer
     */
    private void writeGs(String fileKey, SimpleFileReader reader, SimpleFileWriter writer) {

        String line, lastLine = "bla";

        while (!(line = reader.readLine()).equals("</g>") || !lastLine.equals("</g>")) {

            writer.writeLine(
                    replaceIds(line, fileKey)
            );
            
            lastLine = line;

        }
    }

    /**
     * Replaces the ids in the line by file specific ids.
     *
     * @param line the original line
     * @param fileKey the key of the file
     *
     * @return the line with renamed ids.
     */
    public String replaceIds(String line, String fileKey) {

        for (String keyWord : keyWords) {

            for (String prefix : prefixes) {

                String value = String.join("", prefix, keyWord);

                String[] lineSplit = line.split(value);

                if (lineSplit.length > 1) {

                    String newValue = String.join(
                            "",
                            prefix,
                            String.join(
                                    "_",
                                    fileKey,
                                    keyWord
                            )
                    );
                    line = String.join(newValue, lineSplit);

                }
            }
        }

        return line;

    }
}
