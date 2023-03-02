package nl.bigo.pp;

import static org.junit.jupiter.api.Assertions.*;

import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Paths;

import org.junit.jupiter.api.Test;

/**
 * 
 * @author CGM
 *
 */
/*/
// @formatter:off
@SuppressWarnings({ // NOSONAR
    "PMD.AtLeastOneConstructor"
  , "PMD.CommentSize"
})
// @formatter:on
//*/
class StringUtilsTest {
    /** Path to parsed file with a chess game in PGN format. */
    private static final String PATH_FILE;

    static {
        final String fileName = "src/resources/Partida_08.pgn";
        PATH_FILE = Paths.get(fileName).toUri().toString();
    }

    @Test
    void testRecoverSpacesShort() throws IOException, URISyntaxException {
        final String pathFile = PATH_FILE;
        final String withSpaces = new StringUtils().recoverSpaces("{Lasblancastienendospiezasporlatorre,¡yelataque!}",
                pathFile);
        assertNotNull(withSpaces, "Comment not found...");
    }

    @Test
    void testRecoverSpacesNextLine() throws IOException, URISyntaxException {
        final String pathFile = PATH_FILE;
        final String withSpaces = new StringUtils().recoverSpaces(
                "{Unadelasrazonesqueexplicanlapopularidaddelasaperturasdepeóndedamaesquedesdelaprimerajugadapresentanproblemasaldefensor.Nohaymétodoalgunoporelquelasnegraspuedanapoderarsedelainiciativaosiquieraigualarrápidamente.",
                pathFile);
        assertNotNull(withSpaces, "Comment not found...");
    }

}
