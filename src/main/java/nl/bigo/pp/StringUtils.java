package nl.bigo.pp;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

import org.apache.commons.text.similarity.LevenshteinDistance;

import lombok.extern.slf4j.Slf4j;

/**
 * 
 * @author CGM
 *
 */
/*/
// @formatter:off
@SuppressWarnings({ // NOSONAR
    "PMD.LawOfDemeter"
  , "PMD.DataflowAnomalyAnalysis"
  , "PMD.AtLeastOneConstructor"
  , "PMD.CommentSize"
})
// @formatter:on
//*/
@Slf4j
public class StringUtils {
    /** Helper to find most similar line. */
    private static final LevenshteinDistance LEVENSHTEIN = LevenshteinDistance.getDefaultInstance();
    /** Comment close symbol. */
    private static final char RIGHT_PARENTHESIS = '}';

    /**
     * Recovers spaces in comments, removed during the parsing process.
     *
     * @param parsedComment Comment as retrieved from parsing process.
     * @param pathFile      Path to the PGN parsed file.
     * @return
     * @throws IOException
     * @throws URISyntaxException
     */
    public String recoverSpaces(final String parsedComment, final String pathFile)
            throws IOException, URISyntaxException {
        final List<String> lines = Files.readAllLines(Paths.get(new URI(pathFile)));
        final int lineIndex = findIndexOfMostSimilarLine(parsedComment, lines);
        final String initialGuess = lines.get(lineIndex);
        final String guess = makeGuess(parsedComment, initialGuess);
        log.debug("Retrieved comment is:\n{}", guess);
        return guess;
    }

    // Find the index of the most similar line to parsed comment
    // in original file lines.
    private int findIndexOfMostSimilarLine(final String parsedComment, final List<String> lines) {
        final int numLines = lines.size();
        int distance;
        long min = Long.MAX_VALUE;
        int lineIndex = -1;
        for (int i = 0; i < numLines; i++) {
            final String line = lines.get(i);
            distance = LEVENSHTEIN.apply(parsedComment, line);
            log.trace("{}", distance);
            if (distance < min) {
                min = distance;
                lineIndex = i;
            }
        }
        log.trace("lineIndex {}", lineIndex);
        return lineIndex;
    }

    private String makeGuess(final String parsedComment, final String initialGuess) {
        String guess = initialGuess;
        boolean equals = parsedComment.replace(" ", "").equals(guess.replace(" ", ""));
        log.trace("Same? {}", equals);
        final int lastIndexOf = guess.lastIndexOf(RIGHT_PARENTHESIS);
        if (!equals && lastIndexOf != -1) {
            guess = guess.substring(0, lastIndexOf + 1);
            equals = parsedComment.replace(" ", "").equals(guess.replace(" ", ""));
        }
        log.trace("Same? {}", equals);
        return guess;
    }

}
