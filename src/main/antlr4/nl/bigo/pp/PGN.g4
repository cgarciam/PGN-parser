/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 by Bart Kiers
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * Project      : A Portable Game Notation (PGN) ANTLR 4 grammar
 *                and parser.
 * Developed by : Bart Kiers, bart@big-o.nl
 *                César García Mauricio, gamo7ster@gmail.com
 */

//
// A Portable Game Notation (PGN) grammar based on:
// http://www.thechessdrum.net/PGN_Reference.txt
//
// The inline comments starting with "///" in this grammar are direct 
// copy-pastes from the PGN reference linked above.
//
grammar PGN;

// The entry point of the grammar.
parse
 : pgn_database EOF
 ;

/// <PGN-database> ::= <PGN-game> <PGN-database>
///                    <empty>
pgn_database
 : pgn_game*
 ;

/// <PGN-game> ::= <tag-section> <movetext-section>
pgn_game
 : tag_section movetext_section
 ;

/// <tag-section> ::= <tag-pair> <tag-section>
///                   <empty>
tag_section
 : tag_pair*
 ;

/// <tag-pair> ::= [ <tag-name> <tag-value> ]
tag_pair
 : LEFT_BRACKET tag_name tag_value RIGHT_BRACKET
 ;

/// <tag-name> ::= <identifier>
tag_name
 : SYMBOL
 ;

/// <tag-value> ::= <string>
tag_value
 : STRING
 ;
 
/// <movetext-section> ::= <element-sequence> <game-termination>
movetext_section
 : element_sequence game_termination
 ;

/// <element-sequence> ::= <element> <element-sequence>
///                        <recursive-variation> <element-sequence>
///                        <empty>
element_sequence
 : (element | recursive_variation)*
 ;

/// <element> ::= <move-number-indication>
///               <SAN-move>
///               <numeric-annotation-glyph>
element
 : move_number_indication
 | san_move
 | NUMERIC_ANNOTATION_GLYPH
 ;

move_number_indication
 : INTEGER PERIOD?
 | INTEGER PERIOD PERIOD PERIOD
 ;

san_move
 : SAN_SYMBOL SAN_SYMBOL?
 ;

/// <recursive-variation> ::= ( <element-sequence> )
recursive_variation
 : LEFT_PARENTHESIS element_sequence RIGHT_PARENTHESIS
 ;

/// <game-termination> ::= 1-0
///                        0-1
///                        1/2-1/2
///                        *
game_termination
 : WHITE_WINS
 | BLACK_WINS
 | DRAWN_GAME
 | ASTERISK
 ;

WHITE_WINS
 : '1-0'
 ;

BLACK_WINS
 : '0-1'
 ;

DRAWN_GAME
 : '1/2-1/2'
 ;

/// Comment text may appear in PGN data.  There are two kinds of comments.  The
/// first kind is the "rest of line" comment; this comment type starts with a
/// semicolon character and continues to the end of the line.  The second kind
/// starts with a left brace character and continues to the next right brace
/// character.  Comments cannot appear inside any token.
REST_OF_LINE_COMMENT
 : ';' ~[\r\n]* -> skip
 ;

/// Brace comments do not nest; a left brace character appearing in a brace comment
/// loses its special meaning and is ignored.  A semicolon appearing inside of a
/// brace comment loses its special meaning and is ignored.  Braces appearing
/// inside of a semicolon comments lose their special meaning and are ignored.
BRACE_COMMENT
 : '{' ~'}'* '}' -> skip
 ;

/// There is a special escape mechanism for PGN data.  This mechanism is triggered
/// by a percent sign character ("%") appearing in the first column of a line; the
/// data on the rest of the line is ignored by publicly available PGN scanning
/// software.  This escape convention is intended for the private use of software
/// developers and researchers to embed non-PGN commands and data in PGN streams.
///
/// A percent sign appearing in any other place other than the first position in a
/// line does not trigger the escape mechanism.
ESCAPE
 : {getCharPositionInLine() == 0}? '%' ~[\r\n]* -> skip
 ;

SPACES
 : [ \t\r\n]+ -> skip
 ;

SAN_SYMBOL
 : ( CASTLING | PAWN_MOVE | PIECE_MOVE ) ( ['+','#'] )? ( COMMENT )?
 ;

COMMENT : '!' | '!!' | '!?' | '?!' | '?' | '??';

CASTLING
 : 'O-O' | 'O-O-O' | 'o-o' | 'o-o-o' | '0-0' | '0-0-0'
 ;

PAWN_MOVE :
    'a2' | 'a3' | 'a4' | 'a5' | 'a6' | 'a7' |
    'b2' | 'b3' | 'b4' | 'b5' | 'b6' | 'b7' |
    'c2' | 'c3' | 'c4' | 'c5' | 'c6' | 'c7' |
    'd2' | 'd3' | 'd4' | 'd5' | 'd6' | 'd7' |
    'e2' | 'e3' | 'e4' | 'e5' | 'e6' | 'e7' |
    'f2' | 'f3' | 'f4' | 'f5' | 'f6' | 'f7' |
    'g2' | 'g3' | 'g4' | 'g5' | 'g6' | 'g7' |
    'h2' | 'h3' | 'h4' | 'h5' | 'h6' | 'h7' |
    'axb2' | 'axb3' | 'axb4' | 'axb5' | 'axb6' | 'axb7' |
    'bxa2' | 'bxa3' | 'bxa4' | 'bxa5' | 'bxa6' | 'bxa7' |
    'bxc2' | 'bxc3' | 'bxc4' | 'bxc5' | 'bxc6' | 'bxc7' |
    'cxb2' | 'cxb3' | 'cxb4' | 'cxb5' | 'cxb6' | 'cxb7' |
    'cxd2' | 'cxd3' | 'cxd4' | 'cxd5' | 'cxd6' | 'cxd7' |
    'dxc2' | 'dxc3' | 'dxc4' | 'dxc5' | 'dxc6' | 'dxc7' |
    'dxe2' | 'dxe3' | 'dxe4' | 'dxe5' | 'dxe6' | 'dxe7' |
    'exd2' | 'exd3' | 'exd4' | 'exd5' | 'exd6' | 'exd7' |
    'exf2' | 'exf3' | 'exf4' | 'exf5' | 'exf6' | 'exf7' |
    'fxe2' | 'fxe3' | 'fxe4' | 'fxe5' | 'fxe6' | 'fxe7' |
    'fxg2' | 'fxg3' | 'fxg4' | 'fxg5' | 'fxg6' | 'fxg7' |
    'gxf2' | 'gxf3' | 'gxf4' | 'gxf5' | 'gxf6' | 'gxf7' |
    'gxh2' | 'gxh3' | 'gxh4' | 'gxh5' | 'gxh6' | 'gxh7' |
    'hxg2' | 'hxg3' | 'hxg4' | 'hxg5' | 'hxg6' | 'hxg7' |
    'a8=Q' | 'a8=R' | 'a8=B' | 'a8=N' |
    'b8=Q' | 'b8=R' | 'b8=B' | 'b8=N' |
    'c8=Q' | 'c8=R' | 'c8=B' | 'c8=N' |
    'd8=Q' | 'd8=R' | 'd8=B' | 'd8=N' |
    'e8=Q' | 'e8=R' | 'e8=B' | 'e8=N' |
    'f8=Q' | 'f8=R' | 'f8=B' | 'f8=N' |
    'g8=Q' | 'g8=R' | 'g8=B' | 'g8=N' |
    'h8=Q' | 'h8=R' | 'h8=B' | 'h8=N' |
    'a1=Q' | 'a1=R' | 'a1=B' | 'a1=N' |
    'b1=Q' | 'b1=R' | 'b1=B' | 'b1=N' |
    'c1=Q' | 'c1=R' | 'c1=B' | 'c1=N' |
    'd1=Q' | 'd1=R' | 'd1=B' | 'd1=N' |
    'e1=Q' | 'e1=R' | 'e1=B' | 'e1=N' |
    'f1=Q' | 'f1=R' | 'f1=B' | 'f1=N' |
    'g1=Q' | 'g1=R' | 'g1=B' | 'g1=N' |
    'h1=Q' | 'h1=R' | 'h1=B' | 'h1=N' |
    'axb8=Q' | 'axb8=R' | 'axb8=B' | 'axb8=N' |
    'bxa8=Q' | 'bxa8=R' | 'bxa8=B' | 'bxa8=N' |
    'bxc8=Q' | 'bxc8=R' | 'bxc8=B' | 'bxc8=N' |
    'cxb8=Q' | 'cxb8=R' | 'cxb8=B' | 'cxb8=N' |
    'cxd8=Q' | 'cxd8=R' | 'cxd8=B' | 'cxd8=N' |
    'dxc8=Q' | 'dxc8=R' | 'dxc8=B' | 'dxc8=N' |
    'dxe8=Q' | 'dxe8=R' | 'dxe8=B' | 'dxe8=N' |
    'exd8=Q' | 'exd8=R' | 'exd8=B' | 'exd8=N' |
    'exf8=Q' | 'exf8=R' | 'exf8=B' | 'exf8=N' |
    'fxe8=Q' | 'fxe8=R' | 'fxe8=B' | 'fxe8=N' |
    'fxg8=Q' | 'fxg8=R' | 'fxg8=B' | 'fxg8=N' |
    'gxf8=Q' | 'gxf8=R' | 'gxf8=B' | 'gxf8=N' |
    'gxh8=Q' | 'gxh8=R' | 'gxh8=B' | 'gxh8=N' |
    'hxg8=Q' | 'hxg8=R' | 'hxg8=B' | 'hxg8=N' |
    'axb1=Q' | 'axb1=R' | 'axb1=B' | 'axb1=N' |
    'bxa1=Q' | 'bxa1=R' | 'bxa1=B' | 'bxa1=N' |
    'bxc1=Q' | 'bxc1=R' | 'bxc1=B' | 'bxc1=N' |
    'cxb1=Q' | 'cxb1=R' | 'cxb1=B' | 'cxb1=N' |
    'cxd1=Q' | 'cxd1=R' | 'cxd1=B' | 'cxd1=N' |
    'dxc1=Q' | 'dxc1=R' | 'dxc1=B' | 'dxc1=N' |
    'dxe1=Q' | 'dxe1=R' | 'dxe1=B' | 'dxe1=N' |
    'exd1=Q' | 'exd1=R' | 'exd1=B' | 'exd1=N' |
    'exf1=Q' | 'exf1=R' | 'exf1=B' | 'exf1=N' |
    'fxe1=Q' | 'fxe1=R' | 'fxe1=B' | 'fxe1=N' |
    'fxg1=Q' | 'fxg1=R' | 'fxg1=B' | 'fxg1=N' |
    'gxf1=Q' | 'gxf1=R' | 'gxf1=B' | 'gxf1=N' |
    'gxh1=Q' | 'gxh1=R' | 'gxh1=B' | 'gxh1=N' |
    'hxg1=Q' | 'hxg1=R' | 'hxg1=B' | 'hxg1=N';

PIECE_MOVE : KNIGHT_MOVE | BISHOP_MOVE | ROOK_MOVE | QUEEN_MOVE | KING_MOVE;

KNIGHT_MOVE:
        'N1a1' | 'N2a1' | 'N3a1' | 'N4a1' | 'N5a1' | 'N6a1' | 'N7a1' | 'N8a1' |
        'N1a2' | 'N2a2' | 'N3a2' | 'N4a2' | 'N5a2' | 'N6a2' | 'N7a2' | 'N8a2' |
        'N1a3' | 'N2a3' | 'N3a3' | 'N4a3' | 'N5a3' | 'N6a3' | 'N7a3' | 'N8a3' |
        'N1a4' | 'N2a4' | 'N3a4' | 'N4a4' | 'N5a4' | 'N6a4' | 'N7a4' | 'N8a4' |
        'N1a5' | 'N2a5' | 'N3a5' | 'N4a5' | 'N5a5' | 'N6a5' | 'N7a5' | 'N8a5' |
        'N1a6' | 'N2a6' | 'N3a6' | 'N4a6' | 'N5a6' | 'N6a6' | 'N7a6' | 'N8a6' |
        'N1a7' | 'N2a7' | 'N3a7' | 'N4a7' | 'N5a7' | 'N6a7' | 'N7a7' | 'N8a7' |
        'N1a8' | 'N2a8' | 'N3a8' | 'N4a8' | 'N5a8' | 'N6a8' | 'N7a8' | 'N8a8' | // 64
        'N1b1' | 'N2b1' | 'N3b1' | 'N4b1' | 'N5b1' | 'N6b1' | 'N7b1' | 'N8b1' |
        'N1b2' | 'N2b2' | 'N3b2' | 'N4b2' | 'N5b2' | 'N6b2' | 'N7b2' | 'N8b2' |
        'N1b3' | 'N2b3' | 'N3b3' | 'N4b3' | 'N5b3' | 'N6b3' | 'N7b3' | 'N8b3' |
        'N1b4' | 'N2b4' | 'N3b4' | 'N4b4' | 'N5b4' | 'N6b4' | 'N7b4' | 'N8b4' |
        'N1b5' | 'N2b5' | 'N3b5' | 'N4b5' | 'N5b5' | 'N6b5' | 'N7b5' | 'N8b5' |
        'N1b6' | 'N2b6' | 'N3b6' | 'N4b6' | 'N5b6' | 'N6b6' | 'N7b6' | 'N8b6' |
        'N1b7' | 'N2b7' | 'N3b7' | 'N4b7' | 'N5b7' | 'N6b7' | 'N7b7' | 'N8b7' |
        'N1b8' | 'N2b8' | 'N3b8' | 'N4b8' | 'N5b8' | 'N6b8' | 'N7b8' | 'N8b8' | // 64
        'N1c1' | 'N2c1' | 'N3c1' | 'N4c1' | 'N5c1' | 'N6c1' | 'N7c1' | 'N8c1' |
        'N1c2' | 'N2c2' | 'N3c2' | 'N4c2' | 'N5c2' | 'N6c2' | 'N7c2' | 'N8c2' |
        'N1c3' | 'N2c3' | 'N3c3' | 'N4c3' | 'N5c3' | 'N6c3' | 'N7c3' | 'N8c3' |
        'N1c4' | 'N2c4' | 'N3c4' | 'N4c4' | 'N5c4' | 'N6c4' | 'N7c4' | 'N8c4' |
        'N1c5' | 'N2c5' | 'N3c5' | 'N4c5' | 'N5c5' | 'N6c5' | 'N7c5' | 'N8c5' |
        'N1c6' | 'N2c6' | 'N3c6' | 'N4c6' | 'N5c6' | 'N6c6' | 'N7c6' | 'N8c6' |
        'N1c7' | 'N2c7' | 'N3c7' | 'N4c7' | 'N5c7' | 'N6c7' | 'N7c7' | 'N8c7' |
        'N1c8' | 'N2c8' | 'N3c8' | 'N4c8' | 'N5c8' | 'N6c8' | 'N7c8' | 'N8c8' | // 64
        'N1d1' | 'N2d1' | 'N3d1' | 'N4d1' | 'N5d1' | 'N6d1' | 'N7d1' | 'N8d1' |
        'N1d2' | 'N2d2' | 'N3d2' | 'N4d2' | 'N5d2' | 'N6d2' | 'N7d2' | 'N8d2' |
        'N1d3' | 'N2d3' | 'N3d3' | 'N4d3' | 'N5d3' | 'N6d3' | 'N7d3' | 'N8d3' |
        'N1d4' | 'N2d4' | 'N3d4' | 'N4d4' | 'N5d4' | 'N6d4' | 'N7d4' | 'N8d4' |
        'N1d5' | 'N2d5' | 'N3d5' | 'N4d5' | 'N5d5' | 'N6d5' | 'N7d5' | 'N8d5' |
        'N1d6' | 'N2d6' | 'N3d6' | 'N4d6' | 'N5d6' | 'N6d6' | 'N7d6' | 'N8d6' |
        'N1d7' | 'N2d7' | 'N3d7' | 'N4d7' | 'N5d7' | 'N6d7' | 'N7d7' | 'N8d7' |
        'N1d8' | 'N2d8' | 'N3d8' | 'N4d8' | 'N5d8' | 'N6d8' | 'N7d8' | 'N8d8' | // 64
        'N1e1' | 'N2e1' | 'N3e1' | 'N4e1' | 'N5e1' | 'N6e1' | 'N7e1' | 'N8e1' |
        'N1e2' | 'N2e2' | 'N3e2' | 'N4e2' | 'N5e2' | 'N6e2' | 'N7e2' | 'N8e2' |
        'N1e3' | 'N2e3' | 'N3e3' | 'N4e3' | 'N5e3' | 'N6e3' | 'N7e3' | 'N8e3' |
        'N1e4' | 'N2e4' | 'N3e4' | 'N4e4' | 'N5e4' | 'N6e4' | 'N7e4' | 'N8e4' |
        'N1e5' | 'N2e5' | 'N3e5' | 'N4e5' | 'N5e5' | 'N6e5' | 'N7e5' | 'N8e5' |
        'N1e6' | 'N2e6' | 'N3e6' | 'N4e6' | 'N5e6' | 'N6e6' | 'N7e6' | 'N8e6' |
        'N1e7' | 'N2e7' | 'N3e7' | 'N4e7' | 'N5e7' | 'N6e7' | 'N7e7' | 'N8e7' |
        'N1e8' | 'N2e8' | 'N3e8' | 'N4e8' | 'N5e8' | 'N6e8' | 'N7e8' | 'N8e8' | // 64
        'N1f1' | 'N2f1' | 'N3f1' | 'N4f1' | 'N5f1' | 'N6f1' | 'N7f1' | 'N8f1' |
        'N1f2' | 'N2f2' | 'N3f2' | 'N4f2' | 'N5f2' | 'N6f2' | 'N7f2' | 'N8f2' |
        'N1f3' | 'N2f3' | 'N3f3' | 'N4f3' | 'N5f3' | 'N6f3' | 'N7f3' | 'N8f3' |
        'N1f4' | 'N2f4' | 'N3f4' | 'N4f4' | 'N5f4' | 'N6f4' | 'N7f4' | 'N8f4' |
        'N1f5' | 'N2f5' | 'N3f5' | 'N4f5' | 'N5f5' | 'N6f5' | 'N7f5' | 'N8f5' |
        'N1f6' | 'N2f6' | 'N3f6' | 'N4f6' | 'N5f6' | 'N6f6' | 'N7f6' | 'N8f6' |
        'N1f7' | 'N2f7' | 'N3f7' | 'N4f7' | 'N5f7' | 'N6f7' | 'N7f7' | 'N8f7' |
        'N1f8' | 'N2f8' | 'N3f8' | 'N4f8' | 'N5f8' | 'N6f8' | 'N7f8' | 'N8f8' | // 64
        'N1g1' | 'N2g1' | 'N3g1' | 'N4g1' | 'N5g1' | 'N6g1' | 'N7g1' | 'N8g1' |
        'N1g2' | 'N2g2' | 'N3g2' | 'N4g2' | 'N5g2' | 'N6g2' | 'N7g2' | 'N8g2' |
        'N1g3' | 'N2g3' | 'N3g3' | 'N4g3' | 'N5g3' | 'N6g3' | 'N7g3' | 'N8g3' |
        'N1g4' | 'N2g4' | 'N3g4' | 'N4g4' | 'N5g4' | 'N6g4' | 'N7g4' | 'N8g4' |
        'N1g5' | 'N2g5' | 'N3g5' | 'N4g5' | 'N5g5' | 'N6g5' | 'N7g5' | 'N8g5' |
        'N1g6' | 'N2g6' | 'N3g6' | 'N4g6' | 'N5g6' | 'N6g6' | 'N7g6' | 'N8g6' |
        'N1g7' | 'N2g7' | 'N3g7' | 'N4g7' | 'N5g7' | 'N6g7' | 'N7g7' | 'N8g7' |
        'N1g8' | 'N2g8' | 'N3g8' | 'N4g8' | 'N5g8' | 'N6g8' | 'N7g8' | 'N8g8' | // 64
        'N1h1' | 'N2h1' | 'N3h1' | 'N4h1' | 'N5h1' | 'N6h1' | 'N7h1' | 'N8h1' |
        'N1h2' | 'N2h2' | 'N3h2' | 'N4h2' | 'N5h2' | 'N6h2' | 'N7h2' | 'N8h2' |
        'N1h3' | 'N2h3' | 'N3h3' | 'N4h3' | 'N5h3' | 'N6h3' | 'N7h3' | 'N8h3' |
        'N1h4' | 'N2h4' | 'N3h4' | 'N4h4' | 'N5h4' | 'N6h4' | 'N7h4' | 'N8h4' |
        'N1h5' | 'N2h5' | 'N3h5' | 'N4h5' | 'N5h5' | 'N6h5' | 'N7h5' | 'N8h5' |
        'N1h6' | 'N2h6' | 'N3h6' | 'N4h6' | 'N5h6' | 'N6h6' | 'N7h6' | 'N8h6' |
        'N1h7' | 'N2h7' | 'N3h7' | 'N4h7' | 'N5h7' | 'N6h7' | 'N7h7' | 'N8h7' |
        'N1h8' | 'N2h8' | 'N3h8' | 'N4h8' | 'N5h8' | 'N6h8' | 'N7h8' | 'N8h8' | // 64

        'Naa1' | 'Naa2' | 'Naa3' | 'Naa4' | 'Naa5' | 'Naa6' | 'Naa7' | 'Naa8' |
        'Nab1' | 'Nab2' | 'Nab3' | 'Nab4' | 'Nab5' | 'Nab6' | 'Nab7' | 'Nab8' |
        'Nac1' | 'Nac2' | 'Nac3' | 'Nac4' | 'Nac5' | 'Nac6' | 'Nac7' | 'Nac8' |
        'Nad1' | 'Nad2' | 'Nad3' | 'Nad4' | 'Nad5' | 'Nad6' | 'Nad7' | 'Nad8' |
        'Nae1' | 'Nae2' | 'Nae3' | 'Nae4' | 'Nae5' | 'Nae6' | 'Nae7' | 'Nae8' |
        'Naf1' | 'Naf2' | 'Naf3' | 'Naf4' | 'Naf5' | 'Naf6' | 'Naf7' | 'Naf8' |
        'Nag1' | 'Nag2' | 'Nag3' | 'Nag4' | 'Nag5' | 'Nag6' | 'Nag7' | 'Nag8' |
        'Nah1' | 'Nah2' | 'Nah3' | 'Nah4' | 'Nah5' | 'Nah6' | 'Nah7' | 'Nah8' | // 64

        'Nba1' | 'Nba2' | 'Nba3' | 'Nba4' | 'Nba5' | 'Nba6' | 'Nba7' | 'Nba8' |
        'Nbb1' | 'Nbb2' | 'Nbb3' | 'Nbb4' | 'Nbb5' | 'Nbb6' | 'Nbb7' | 'Nbb8' |
        'Nbc1' | 'Nbc2' | 'Nbc3' | 'Nbc4' | 'Nbc5' | 'Nbc6' | 'Nbc7' | 'Nbc8' |
        'Nbd1' | 'Nbd2' | 'Nbd3' | 'Nbd4' | 'Nbd5' | 'Nbd6' | 'Nbd7' | 'Nbd8' |
        'Nbe1' | 'Nbe2' | 'Nbe3' | 'Nbe4' | 'Nbe5' | 'Nbe6' | 'Nbe7' | 'Nbe8' |
        'Nbf1' | 'Nbf2' | 'Nbf3' | 'Nbf4' | 'Nbf5' | 'Nbf6' | 'Nbf7' | 'Nbf8' |
        'Nbg1' | 'Nbg2' | 'Nbg3' | 'Nbg4' | 'Nbg5' | 'Nbg6' | 'Nbg7' | 'Nbg8' |
        'Nbh1' | 'Nbh2' | 'Nbh3' | 'Nbh4' | 'Nbh5' | 'Nbh6' | 'Nbh7' | 'Nbh8' | // 64

        'Nca1' | 'Nca2' | 'Nca3' | 'Nca4' | 'Nca5' | 'Nca6' | 'Nca7' | 'Nca8' |
        'Ncb1' | 'Ncb2' | 'Ncb3' | 'Ncb4' | 'Ncb5' | 'Ncb6' | 'Ncb7' | 'Ncb8' |
        'Ncc1' | 'Ncc2' | 'Ncc3' | 'Ncc4' | 'Ncc5' | 'Ncc6' | 'Ncc7' | 'Ncc8' |
        'Ncd1' | 'Ncd2' | 'Ncd3' | 'Ncd4' | 'Ncd5' | 'Ncd6' | 'Ncd7' | 'Ncd8' |
        'Nce1' | 'Nce2' | 'Nce3' | 'Nce4' | 'Nce5' | 'Nce6' | 'Nce7' | 'Nce8' |
        'Ncf1' | 'Ncf2' | 'Ncf3' | 'Ncf4' | 'Ncf5' | 'Ncf6' | 'Ncf7' | 'Ncf8' |
        'Ncg1' | 'Ncg2' | 'Ncg3' | 'Ncg4' | 'Ncg5' | 'Ncg6' | 'Ncg7' | 'Ncg8' |
        'Nch1' | 'Nch2' | 'Nch3' | 'Nch4' | 'Nch5' | 'Nch6' | 'Nch7' | 'Nch8' | // 64

        'Nda1' | 'Nda2' | 'Nda3' | 'Nda4' | 'Nda5' | 'Nda6' | 'Nda7' | 'Nda8' |
        'Ndb1' | 'Ndb2' | 'Ndb3' | 'Ndb4' | 'Ndb5' | 'Ndb6' | 'Ndb7' | 'Ndb8' |
        'Ndc1' | 'Ndc2' | 'Ndc3' | 'Ndc4' | 'Ndc5' | 'Ndc6' | 'Ndc7' | 'Ndc8' |
        'Ndd1' | 'Ndd2' | 'Ndd3' | 'Ndd4' | 'Ndd5' | 'Ndd6' | 'Ndd7' | 'Ndd8' |
        'Nde1' | 'Nde2' | 'Nde3' | 'Nde4' | 'Nde5' | 'Nde6' | 'Nde7' | 'Nde8' |
        'Ndf1' | 'Ndf2' | 'Ndf3' | 'Ndf4' | 'Ndf5' | 'Ndf6' | 'Ndf7' | 'Ndf8' |
        'Ndg1' | 'Ndg2' | 'Ndg3' | 'Ndg4' | 'Ndg5' | 'Ndg6' | 'Ndg7' | 'Ndg8' |
        'Ndh1' | 'Ndh2' | 'Ndh3' | 'Ndh4' | 'Ndh5' | 'Ndh6' | 'Ndh7' | 'Ndh8' | // 64

        'Nea1' | 'Nea2' | 'Nea3' | 'Nea4' | 'Nea5' | 'Nea6' | 'Nea7' | 'Nea8' |
        'Neb1' | 'Neb2' | 'Neb3' | 'Neb4' | 'Neb5' | 'Neb6' | 'Neb7' | 'Neb8' |
        'Nec1' | 'Nec2' | 'Nec3' | 'Nec4' | 'Nec5' | 'Nec6' | 'Nec7' | 'Nec8' |
        'Ned1' | 'Ned2' | 'Ned3' | 'Ned4' | 'Ned5' | 'Ned6' | 'Ned7' | 'Ned8' |
        'Nee1' | 'Nee2' | 'Nee3' | 'Nee4' | 'Nee5' | 'Nee6' | 'Nee7' | 'Nee8' |
        'Nef1' | 'Nef2' | 'Nef3' | 'Nef4' | 'Nef5' | 'Nef6' | 'Nef7' | 'Nef8' |
        'Neg1' | 'Neg2' | 'Neg3' | 'Neg4' | 'Neg5' | 'Neg6' | 'Neg7' | 'Neg8' |
        'Neh1' | 'Neh2' | 'Neh3' | 'Neh4' | 'Neh5' | 'Neh6' | 'Neh7' | 'Neh8' | // 64

        'Nfa1' | 'Nfa2' | 'Nfa3' | 'Nfa4' | 'Nfa5' | 'Nfa6' | 'Nfa7' | 'Nfa8' |
        'Nfb1' | 'Nfb2' | 'Nfb3' | 'Nfb4' | 'Nfb5' | 'Nfb6' | 'Nfb7' | 'Nfb8' |
        'Nfc1' | 'Nfc2' | 'Nfc3' | 'Nfc4' | 'Nfc5' | 'Nfc6' | 'Nfc7' | 'Nfc8' |
        'Nfd1' | 'Nfd2' | 'Nfd3' | 'Nfd4' | 'Nfd5' | 'Nfd6' | 'Nfd7' | 'Nfd8' |
        'Nfe1' | 'Nfe2' | 'Nfe3' | 'Nfe4' | 'Nfe5' | 'Nfe6' | 'Nfe7' | 'Nfe8' |
        'Nff1' | 'Nff2' | 'Nff3' | 'Nff4' | 'Nff5' | 'Nff6' | 'Nff7' | 'Nff8' |
        'Nfg1' | 'Nfg2' | 'Nfg3' | 'Nfg4' | 'Nfg5' | 'Nfg6' | 'Nfg7' | 'Nfg8' |
        'Nfh1' | 'Nfh2' | 'Nfh3' | 'Nfh4' | 'Nfh5' | 'Nfh6' | 'Nfh7' | 'Nfh8' | // 64

        'Nga1' | 'Nga2' | 'Nga3' | 'Nga4' | 'Nga5' | 'Nga6' | 'Nga7' | 'Nga8' |
        'Ngb1' | 'Ngb2' | 'Ngb3' | 'Ngb4' | 'Ngb5' | 'Ngb6' | 'Ngb7' | 'Ngb8' |
        'Ngc1' | 'Ngc2' | 'Ngc3' | 'Ngc4' | 'Ngc5' | 'Ngc6' | 'Ngc7' | 'Ngc8' |
        'Ngd1' | 'Ngd2' | 'Ngd3' | 'Ngd4' | 'Ngd5' | 'Ngd6' | 'Ngd7' | 'Ngd8' |
        'Nge1' | 'Nge2' | 'Nge3' | 'Nge4' | 'Nge5' | 'Nge6' | 'Nge7' | 'Nge8' |
        'Ngf1' | 'Ngf2' | 'Ngf3' | 'Ngf4' | 'Ngf5' | 'Ngf6' | 'Ngf7' | 'Ngf8' |
        'Ngg1' | 'Ngg2' | 'Ngg3' | 'Ngg4' | 'Ngg5' | 'Ngg6' | 'Ngg7' | 'Ngg8' |
        'Ngh1' | 'Ngh2' | 'Ngh3' | 'Ngh4' | 'Ngh5' | 'Ngh6' | 'Ngh7' | 'Ngh8' | // 64

        'Nha1' | 'Nha2' | 'Nha3' | 'Nha4' | 'Nha5' | 'Nha6' | 'Nha7' | 'Nha8' |
        'Nhb1' | 'Nhb2' | 'Nhb3' | 'Nhb4' | 'Nhb5' | 'Nhb6' | 'Nhb7' | 'Nhb8' |
        'Nhc1' | 'Nhc2' | 'Nhc3' | 'Nhc4' | 'Nhc5' | 'Nhc6' | 'Nhc7' | 'Nhc8' |
        'Nhd1' | 'Nhd2' | 'Nhd3' | 'Nhd4' | 'Nhd5' | 'Nhd6' | 'Nhd7' | 'Nhd8' |
        'Nhe1' | 'Nhe2' | 'Nhe3' | 'Nhe4' | 'Nhe5' | 'Nhe6' | 'Nhe7' | 'Nhe8' |
        'Nhf1' | 'Nhf2' | 'Nhf3' | 'Nhf4' | 'Nhf5' | 'Nhf6' | 'Nhf7' | 'Nhf8' |
        'Nhg1' | 'Nhg2' | 'Nhg3' | 'Nhg4' | 'Nhg5' | 'Nhg6' | 'Nhg7' | 'Nhg8' |
        'Nhh1' | 'Nhh2' | 'Nhh3' | 'Nhh4' | 'Nhh5' | 'Nhh6' | 'Nhh7' | 'Nhh8' | // 64

        'Naxa1' | 'Naxa2' | 'Naxa3' | 'Naxa4' | 'Naxa5' | 'Naxa6' | 'Naxa7' | 'Naxa8' |
        'Naxb1' | 'Naxb2' | 'Naxb3' | 'Naxb4' | 'Naxb5' | 'Naxb6' | 'Naxb7' | 'Naxb8' |
        'Naxc1' | 'Naxc2' | 'Naxc3' | 'Naxc4' | 'Naxc5' | 'Naxc6' | 'Naxc7' | 'Naxc8' |
        'Naxd1' | 'Naxd2' | 'Naxd3' | 'Naxd4' | 'Naxd5' | 'Naxd6' | 'Naxd7' | 'Naxd8' |
        'Naxe1' | 'Naxe2' | 'Naxe3' | 'Naxe4' | 'Naxe5' | 'Naxe6' | 'Naxe7' | 'Naxe8' |
        'Naxf1' | 'Naxf2' | 'Naxf3' | 'Naxf4' | 'Naxf5' | 'Naxf6' | 'Naxf7' | 'Naxf8' |
        'Naxg1' | 'Naxg2' | 'Naxg3' | 'Naxg4' | 'Naxg5' | 'Naxg6' | 'Naxg7' | 'Naxg8' |
        'Naxh1' | 'Naxh2' | 'Naxh3' | 'Naxh4' | 'Naxh5' | 'Naxh6' | 'Naxh7' | 'Naxh8' | // 64

        'Nbxa1' | 'Nbxa2' | 'Nbxa3' | 'Nbxa4' | 'Nbxa5' | 'Nbxa6' | 'Nbxa7' | 'Nbxa8' |
        'Nbxb1' | 'Nbxb2' | 'Nbxb3' | 'Nbxb4' | 'Nbxb5' | 'Nbxb6' | 'Nbxb7' | 'Nbxb8' |
        'Nbxc1' | 'Nbxc2' | 'Nbxc3' | 'Nbxc4' | 'Nbxc5' | 'Nbxc6' | 'Nbxc7' | 'Nbxc8' |
        'Nbxd1' | 'Nbxd2' | 'Nbxd3' | 'Nbxd4' | 'Nbxd5' | 'Nbxd6' | 'Nbxd7' | 'Nbxd8' |
        'Nbxe1' | 'Nbxe2' | 'Nbxe3' | 'Nbxe4' | 'Nbxe5' | 'Nbxe6' | 'Nbxe7' | 'Nbxe8' |
        'Nbxf1' | 'Nbxf2' | 'Nbxf3' | 'Nbxf4' | 'Nbxf5' | 'Nbxf6' | 'Nbxf7' | 'Nbxf8' |
        'Nbxg1' | 'Nbxg2' | 'Nbxg3' | 'Nbxg4' | 'Nbxg5' | 'Nbxg6' | 'Nbxg7' | 'Nbxg8' |
        'Nbxh1' | 'Nbxh2' | 'Nbxh3' | 'Nbxh4' | 'Nbxh5' | 'Nbxh6' | 'Nbxh7' | 'Nbxh8' | // 64

        'Ncxa1' | 'Ncxa2' | 'Ncxa3' | 'Ncxa4' | 'Ncxa5' | 'Ncxa6' | 'Ncxa7' | 'Ncxa8' |
        'Ncxb1' | 'Ncxb2' | 'Ncxb3' | 'Ncxb4' | 'Ncxb5' | 'Ncxb6' | 'Ncxb7' | 'Ncxb8' |
        'Ncxc1' | 'Ncxc2' | 'Ncxc3' | 'Ncxc4' | 'Ncxc5' | 'Ncxc6' | 'Ncxc7' | 'Ncxc8' |
        'Ncxd1' | 'Ncxd2' | 'Ncxd3' | 'Ncxd4' | 'Ncxd5' | 'Ncxd6' | 'Ncxd7' | 'Ncxd8' |
        'Ncxe1' | 'Ncxe2' | 'Ncxe3' | 'Ncxe4' | 'Ncxe5' | 'Ncxe6' | 'Ncxe7' | 'Ncxe8' |
        'Ncxf1' | 'Ncxf2' | 'Ncxf3' | 'Ncxf4' | 'Ncxf5' | 'Ncxf6' | 'Ncxf7' | 'Ncxf8' |
        'Ncxg1' | 'Ncxg2' | 'Ncxg3' | 'Ncxg4' | 'Ncxg5' | 'Ncxg6' | 'Ncxg7' | 'Ncxg8' |
        'Ncxh1' | 'Ncxh2' | 'Ncxh3' | 'Ncxh4' | 'Ncxh5' | 'Ncxh6' | 'Ncxh7' | 'Ncxh8' | // 64

        'Ndxa1' | 'Ndxa2' | 'Ndxa3' | 'Ndxa4' | 'Ndxa5' | 'Ndxa6' | 'Ndxa7' | 'Ndxa8' |
        'Ndxb1' | 'Ndxb2' | 'Ndxb3' | 'Ndxb4' | 'Ndxb5' | 'Ndxb6' | 'Ndxb7' | 'Ndxb8' |
        'Ndxc1' | 'Ndxc2' | 'Ndxc3' | 'Ndxc4' | 'Ndxc5' | 'Ndxc6' | 'Ndxc7' | 'Ndxc8' |
        'Ndxd1' | 'Ndxd2' | 'Ndxd3' | 'Ndxd4' | 'Ndxd5' | 'Ndxd6' | 'Ndxd7' | 'Ndxd8' |
        'Ndxe1' | 'Ndxe2' | 'Ndxe3' | 'Ndxe4' | 'Ndxe5' | 'Ndxe6' | 'Ndxe7' | 'Ndxe8' |
        'Ndxf1' | 'Ndxf2' | 'Ndxf3' | 'Ndxf4' | 'Ndxf5' | 'Ndxf6' | 'Ndxf7' | 'Ndxf8' |
        'Ndxg1' | 'Ndxg2' | 'Ndxg3' | 'Ndxg4' | 'Ndxg5' | 'Ndxg6' | 'Ndxg7' | 'Ndxg8' |
        'Ndxh1' | 'Ndxh2' | 'Ndxh3' | 'Ndxh4' | 'Ndxh5' | 'Ndxh6' | 'Ndxh7' | 'Ndxh8' | // 64

        'Nexa1' | 'Nexa2' | 'Nexa3' | 'Nexa4' | 'Nexa5' | 'Nexa6' | 'Nexa7' | 'Nexa8' |
        'Nexb1' | 'Nexb2' | 'Nexb3' | 'Nexb4' | 'Nexb5' | 'Nexb6' | 'Nexb7' | 'Nexb8' |
        'Nexc1' | 'Nexc2' | 'Nexc3' | 'Nexc4' | 'Nexc5' | 'Nexc6' | 'Nexc7' | 'Nexc8' |
        'Nexd1' | 'Nexd2' | 'Nexd3' | 'Nexd4' | 'Nexd5' | 'Nexd6' | 'Nexd7' | 'Nexd8' |
        'Nexe1' | 'Nexe2' | 'Nexe3' | 'Nexe4' | 'Nexe5' | 'Nexe6' | 'Nexe7' | 'Nexe8' |
        'Nexf1' | 'Nexf2' | 'Nexf3' | 'Nexf4' | 'Nexf5' | 'Nexf6' | 'Nexf7' | 'Nexf8' |
        'Nexg1' | 'Nexg2' | 'Nexg3' | 'Nexg4' | 'Nexg5' | 'Nexg6' | 'Nexg7' | 'Nexg8' |
        'Nexh1' | 'Nexh2' | 'Nexh3' | 'Nexh4' | 'Nexh5' | 'Nexh6' | 'Nexh7' | 'Nexh8' | // 64

        'Nfxa1' | 'Nfxa2' | 'Nfxa3' | 'Nfxa4' | 'Nfxa5' | 'Nfxa6' | 'Nfxa7' | 'Nfxa8' |
        'Nfxb1' | 'Nfxb2' | 'Nfxb3' | 'Nfxb4' | 'Nfxb5' | 'Nfxb6' | 'Nfxb7' | 'Nfxb8' |
        'Nfxc1' | 'Nfxc2' | 'Nfxc3' | 'Nfxc4' | 'Nfxc5' | 'Nfxc6' | 'Nfxc7' | 'Nfxc8' |
        'Nfxd1' | 'Nfxd2' | 'Nfxd3' | 'Nfxd4' | 'Nfxd5' | 'Nfxd6' | 'Nfxd7' | 'Nfxd8' |
        'Nfxe1' | 'Nfxe2' | 'Nfxe3' | 'Nfxe4' | 'Nfxe5' | 'Nfxe6' | 'Nfxe7' | 'Nfxe8' |
        'Nfxf1' | 'Nfxf2' | 'Nfxf3' | 'Nfxf4' | 'Nfxf5' | 'Nfxf6' | 'Nfxf7' | 'Nfxf8' |
        'Nfxg1' | 'Nfxg2' | 'Nfxg3' | 'Nfxg4' | 'Nfxg5' | 'Nfxg6' | 'Nfxg7' | 'Nfxg8' |
        'Nfxh1' | 'Nfxh2' | 'Nfxh3' | 'Nfxh4' | 'Nfxh5' | 'Nfxh6' | 'Nfxh7' | 'Nfxh8' | // 64

        'Ngxa1' | 'Ngxa2' | 'Ngxa3' | 'Ngxa4' | 'Ngxa5' | 'Ngxa6' | 'Ngxa7' | 'Ngxa8' |
        'Ngxb1' | 'Ngxb2' | 'Ngxb3' | 'Ngxb4' | 'Ngxb5' | 'Ngxb6' | 'Ngxb7' | 'Ngxb8' |
        'Ngxc1' | 'Ngxc2' | 'Ngxc3' | 'Ngxc4' | 'Ngxc5' | 'Ngxc6' | 'Ngxc7' | 'Ngxc8' |
        'Ngxd1' | 'Ngxd2' | 'Ngxd3' | 'Ngxd4' | 'Ngxd5' | 'Ngxd6' | 'Ngxd7' | 'Ngxd8' |
        'Ngxe1' | 'Ngxe2' | 'Ngxe3' | 'Ngxe4' | 'Ngxe5' | 'Ngxe6' | 'Ngxe7' | 'Ngxe8' |
        'Ngxf1' | 'Ngxf2' | 'Ngxf3' | 'Ngxf4' | 'Ngxf5' | 'Ngxf6' | 'Ngxf7' | 'Ngxf8' |
        'Ngxg1' | 'Ngxg2' | 'Ngxg3' | 'Ngxg4' | 'Ngxg5' | 'Ngxg6' | 'Ngxg7' | 'Ngxg8' |
        'Ngxh1' | 'Ngxh2' | 'Ngxh3' | 'Ngxh4' | 'Ngxh5' | 'Ngxh6' | 'Ngxh7' | 'Ngxh8' | // 64

        'Nhxa1' | 'Nhxa2' | 'Nhxa3' | 'Nhxa4' | 'Nhxa5' | 'Nhxa6' | 'Nhxa7' | 'Nhxa8' |
        'Nhxb1' | 'Nhxb2' | 'Nhxb3' | 'Nhxb4' | 'Nhxb5' | 'Nhxb6' | 'Nhxb7' | 'Nhxb8' |
        'Nhxc1' | 'Nhxc2' | 'Nhxc3' | 'Nhxc4' | 'Nhxc5' | 'Nhxc6' | 'Nhxc7' | 'Nhxc8' |
        'Nhxd1' | 'Nhxd2' | 'Nhxd3' | 'Nhxd4' | 'Nhxd5' | 'Nhxd6' | 'Nhxd7' | 'Nhxd8' |
        'Nhxe1' | 'Nhxe2' | 'Nhxe3' | 'Nhxe4' | 'Nhxe5' | 'Nhxe6' | 'Nhxe7' | 'Nhxe8' |
        'Nhxf1' | 'Nhxf2' | 'Nhxf3' | 'Nhxf4' | 'Nhxf5' | 'Nhxf6' | 'Nhxf7' | 'Nhxf8' |
        'Nhxg1' | 'Nhxg2' | 'Nhxg3' | 'Nhxg4' | 'Nhxg5' | 'Nhxg6' | 'Nhxg7' | 'Nhxg8' |
        'Nhxh1' | 'Nhxh2' | 'Nhxh3' | 'Nhxh4' | 'Nhxh5' | 'Nhxh6' | 'Nhxh7' | 'Nhxh8' | // 64

        'Na1' | 'Na2' | 'Na3' | 'Na4' | 'Na5' | 'Na6' | 'Na7' | 'Na8' |
        'Nb1' | 'Nb2' | 'Nb3' | 'Nb4' | 'Nb5' | 'Nb6' | 'Nb7' | 'Nb8' |
        'Nc1' | 'Nc2' | 'Nc3' | 'Nc4' | 'Nc5' | 'Nc6' | 'Nc7' | 'Nc8' |
        'Nd1' | 'Nd2' | 'Nd3' | 'Nd4' | 'Nd5' | 'Nd6' | 'Nd7' | 'Nd8' |
        'Ne1' | 'Ne2' | 'Ne3' | 'Ne4' | 'Ne5' | 'Ne6' | 'Ne7' | 'Ne8' |
        'Nf1' | 'Nf2' | 'Nf3' | 'Nf4' | 'Nf5' | 'Nf6' | 'Nf7' | 'Nf8' |
        'Ng1' | 'Ng2' | 'Ng3' | 'Ng4' | 'Ng5' | 'Ng6' | 'Ng7' | 'Ng8' |
        'Nh1' | 'Nh2' | 'Nh3' | 'Nh4' | 'Nh5' | 'Nh6' | 'Nh7' | 'Nh8' | // 64

        'Nxa1' | 'Nxa2' | 'Nxa3' | 'Nxa4' | 'Nxa5' | 'Nxa6' | 'Nxa7' | 'Nxa8' |
        'Nxb1' | 'Nxb2' | 'Nxb3' | 'Nxb4' | 'Nxb5' | 'Nxb6' | 'Nxb7' | 'Nxb8' |
        'Nxc1' | 'Nxc2' | 'Nxc3' | 'Nxc4' | 'Nxc5' | 'Nxc6' | 'Nxc7' | 'Nxc8' |
        'Nxd1' | 'Nxd2' | 'Nxd3' | 'Nxd4' | 'Nxd5' | 'Nxd6' | 'Nxd7' | 'Nxd8' |
        'Nxe1' | 'Nxe2' | 'Nxe3' | 'Nxe4' | 'Nxe5' | 'Nxe6' | 'Nxe7' | 'Nxe8' |
        'Nxf1' | 'Nxf2' | 'Nxf3' | 'Nxf4' | 'Nxf5' | 'Nxf6' | 'Nxf7' | 'Nxf8' |
        'Nxg1' | 'Nxg2' | 'Nxg3' | 'Nxg4' | 'Nxg5' | 'Nxg6' | 'Nxg7' | 'Nxg8' |
        'Nxh1' | 'Nxh2' | 'Nxh3' | 'Nxh4' | 'Nxh5' | 'Nxh6' | 'Nxh7' | 'Nxh8' | // 64

        'N1xa1' | 'N1xa2' | 'N1xa3' | 'N1xa4' | 'N1xa5' | 'N1xa6' | 'N1xa7' | 'N1xa8' |
        'N1xb1' | 'N1xb2' | 'N1xb3' | 'N1xb4' | 'N1xb5' | 'N1xb6' | 'N1xb7' | 'N1xb8' |
        'N1xc1' | 'N1xc2' | 'N1xc3' | 'N1xc4' | 'N1xc5' | 'N1xc6' | 'N1xc7' | 'N1xc8' |
        'N1xd1' | 'N1xd2' | 'N1xd3' | 'N1xd4' | 'N1xd5' | 'N1xd6' | 'N1xd7' | 'N1xd8' |
        'N1xe1' | 'N1xe2' | 'N1xe3' | 'N1xe4' | 'N1xe5' | 'N1xe6' | 'N1xe7' | 'N1xe8' |
        'N1xf1' | 'N1xf2' | 'N1xf3' | 'N1xf4' | 'N1xf5' | 'N1xf6' | 'N1xf7' | 'N1xf8' |
        'N1xg1' | 'N1xg2' | 'N1xg3' | 'N1xg4' | 'N1xg5' | 'N1xg6' | 'N1xg7' | 'N1xg8' |
        'N1xh1' | 'N1xh2' | 'N1xh3' | 'N1xh4' | 'N1xh5' | 'N1xh6' | 'N1xh7' | 'N1xh8' | // 64

        'N2xa1' | 'N2xa2' | 'N2xa3' | 'N2xa4' | 'N2xa5' | 'N2xa6' | 'N2xa7' | 'N2xa8' |
        'N2xb1' | 'N2xb2' | 'N2xb3' | 'N2xb4' | 'N2xb5' | 'N2xb6' | 'N2xb7' | 'N2xb8' |
        'N2xc1' | 'N2xc2' | 'N2xc3' | 'N2xc4' | 'N2xc5' | 'N2xc6' | 'N2xc7' | 'N2xc8' |
        'N2xd1' | 'N2xd2' | 'N2xd3' | 'N2xd4' | 'N2xd5' | 'N2xd6' | 'N2xd7' | 'N2xd8' |
        'N2xe1' | 'N2xe2' | 'N2xe3' | 'N2xe4' | 'N2xe5' | 'N2xe6' | 'N2xe7' | 'N2xe8' |
        'N2xf1' | 'N2xf2' | 'N2xf3' | 'N2xf4' | 'N2xf5' | 'N2xf6' | 'N2xf7' | 'N2xf8' |
        'N2xg1' | 'N2xg2' | 'N2xg3' | 'N2xg4' | 'N2xg5' | 'N2xg6' | 'N2xg7' | 'N2xg8' |
        'N2xh1' | 'N2xh2' | 'N2xh3' | 'N2xh4' | 'N2xh5' | 'N2xh6' | 'N2xh7' | 'N2xh8' | // 64

        'N3xa1' | 'N3xa2' | 'N3xa3' | 'N3xa4' | 'N3xa5' | 'N3xa6' | 'N3xa7' | 'N3xa8' |
        'N3xb1' | 'N3xb2' | 'N3xb3' | 'N3xb4' | 'N3xb5' | 'N3xb6' | 'N3xb7' | 'N3xb8' |
        'N3xc1' | 'N3xc2' | 'N3xc3' | 'N3xc4' | 'N3xc5' | 'N3xc6' | 'N3xc7' | 'N3xc8' |
        'N3xd1' | 'N3xd2' | 'N3xd3' | 'N3xd4' | 'N3xd5' | 'N3xd6' | 'N3xd7' | 'N3xd8' |
        'N3xe1' | 'N3xe2' | 'N3xe3' | 'N3xe4' | 'N3xe5' | 'N3xe6' | 'N3xe7' | 'N3xe8' |
        'N3xf1' | 'N3xf2' | 'N3xf3' | 'N3xf4' | 'N3xf5' | 'N3xf6' | 'N3xf7' | 'N3xf8' |
        'N3xg1' | 'N3xg2' | 'N3xg3' | 'N3xg4' | 'N3xg5' | 'N3xg6' | 'N3xg7' | 'N3xg8' |
        'N3xh1' | 'N3xh2' | 'N3xh3' | 'N3xh4' | 'N3xh5' | 'N3xh6' | 'N3xh7' | 'N3xh8' | // 64

        'N4xa1' | 'N4xa2' | 'N4xa3' | 'N4xa4' | 'N4xa5' | 'N4xa6' | 'N4xa7' | 'N4xa8' |
        'N4xb1' | 'N4xb2' | 'N4xb3' | 'N4xb4' | 'N4xb5' | 'N4xb6' | 'N4xb7' | 'N4xb8' |
        'N4xc1' | 'N4xc2' | 'N4xc3' | 'N4xc4' | 'N4xc5' | 'N4xc6' | 'N4xc7' | 'N4xc8' |
        'N4xd1' | 'N4xd2' | 'N4xd3' | 'N4xd4' | 'N4xd5' | 'N4xd6' | 'N4xd7' | 'N4xd8' |
        'N4xe1' | 'N4xe2' | 'N4xe3' | 'N4xe4' | 'N4xe5' | 'N4xe6' | 'N4xe7' | 'N4xe8' |
        'N4xf1' | 'N4xf2' | 'N4xf3' | 'N4xf4' | 'N4xf5' | 'N4xf6' | 'N4xf7' | 'N4xf8' |
        'N4xg1' | 'N4xg2' | 'N4xg3' | 'N4xg4' | 'N4xg5' | 'N4xg6' | 'N4xg7' | 'N4xg8' |
        'N4xh1' | 'N4xh2' | 'N4xh3' | 'N4xh4' | 'N4xh5' | 'N4xh6' | 'N4xh7' | 'N4xh8' | // 64

        'N5xa1' | 'N5xa2' | 'N5xa3' | 'N5xa4' | 'N5xa5' | 'N5xa6' | 'N5xa7' | 'N5xa8' |
        'N5xb1' | 'N5xb2' | 'N5xb3' | 'N5xb4' | 'N5xb5' | 'N5xb6' | 'N5xb7' | 'N5xb8' |
        'N5xc1' | 'N5xc2' | 'N5xc3' | 'N5xc4' | 'N5xc5' | 'N5xc6' | 'N5xc7' | 'N5xc8' |
        'N5xd1' | 'N5xd2' | 'N5xd3' | 'N5xd4' | 'N5xd5' | 'N5xd6' | 'N5xd7' | 'N5xd8' |
        'N5xe1' | 'N5xe2' | 'N5xe3' | 'N5xe4' | 'N5xe5' | 'N5xe6' | 'N5xe7' | 'N5xe8' |
        'N5xf1' | 'N5xf2' | 'N5xf3' | 'N5xf4' | 'N5xf5' | 'N5xf6' | 'N5xf7' | 'N5xf8' |
        'N5xg1' | 'N5xg2' | 'N5xg3' | 'N5xg4' | 'N5xg5' | 'N5xg6' | 'N5xg7' | 'N5xg8' |
        'N5xh1' | 'N5xh2' | 'N5xh3' | 'N5xh4' | 'N5xh5' | 'N5xh6' | 'N5xh7' | 'N5xh8' | // 64

        'N6xa1' | 'N6xa2' | 'N6xa3' | 'N6xa4' | 'N6xa5' | 'N6xa6' | 'N6xa7' | 'N6xa8' |
        'N6xb1' | 'N6xb2' | 'N6xb3' | 'N6xb4' | 'N6xb5' | 'N6xb6' | 'N6xb7' | 'N6xb8' |
        'N6xc1' | 'N6xc2' | 'N6xc3' | 'N6xc4' | 'N6xc5' | 'N6xc6' | 'N6xc7' | 'N6xc8' |
        'N6xd1' | 'N6xd2' | 'N6xd3' | 'N6xd4' | 'N6xd5' | 'N6xd6' | 'N6xd7' | 'N6xd8' |
        'N6xe1' | 'N6xe2' | 'N6xe3' | 'N6xe4' | 'N6xe5' | 'N6xe6' | 'N6xe7' | 'N6xe8' |
        'N6xf1' | 'N6xf2' | 'N6xf3' | 'N6xf4' | 'N6xf5' | 'N6xf6' | 'N6xf7' | 'N6xf8' |
        'N6xg1' | 'N6xg2' | 'N6xg3' | 'N6xg4' | 'N6xg5' | 'N6xg6' | 'N6xg7' | 'N6xg8' |
        'N6xh1' | 'N6xh2' | 'N6xh3' | 'N6xh4' | 'N6xh5' | 'N6xh6' | 'N6xh7' | 'N6xh8' | // 64

        'N7xa1' | 'N7xa2' | 'N7xa3' | 'N7xa4' | 'N7xa5' | 'N7xa6' | 'N7xa7' | 'N7xa8' |
        'N7xb1' | 'N7xb2' | 'N7xb3' | 'N7xb4' | 'N7xb5' | 'N7xb6' | 'N7xb7' | 'N7xb8' |
        'N7xc1' | 'N7xc2' | 'N7xc3' | 'N7xc4' | 'N7xc5' | 'N7xc6' | 'N7xc7' | 'N7xc8' |
        'N7xd1' | 'N7xd2' | 'N7xd3' | 'N7xd4' | 'N7xd5' | 'N7xd6' | 'N7xd7' | 'N7xd8' |
        'N7xe1' | 'N7xe2' | 'N7xe3' | 'N7xe4' | 'N7xe5' | 'N7xe6' | 'N7xe7' | 'N7xe8' |
        'N7xf1' | 'N7xf2' | 'N7xf3' | 'N7xf4' | 'N7xf5' | 'N7xf6' | 'N7xf7' | 'N7xf8' |
        'N7xg1' | 'N7xg2' | 'N7xg3' | 'N7xg4' | 'N7xg5' | 'N7xg6' | 'N7xg7' | 'N7xg8' |
        'N7xh1' | 'N7xh2' | 'N7xh3' | 'N7xh4' | 'N7xh5' | 'N7xh6' | 'N7xh7' | 'N7xh8' | // 64

        'N8xa1' | 'N8xa2' | 'N8xa3' | 'N8xa4' | 'N8xa5' | 'N8xa6' | 'N8xa7' | 'N8xa8' |
        'N8xb1' | 'N8xb2' | 'N8xb3' | 'N8xb4' | 'N8xb5' | 'N8xb6' | 'N8xb7' | 'N8xb8' |
        'N8xc1' | 'N8xc2' | 'N8xc3' | 'N8xc4' | 'N8xc5' | 'N8xc6' | 'N8xc7' | 'N8xc8' |
        'N8xd1' | 'N8xd2' | 'N8xd3' | 'N8xd4' | 'N8xd5' | 'N8xd6' | 'N8xd7' | 'N8xd8' |
        'N8xe1' | 'N8xe2' | 'N8xe3' | 'N8xe4' | 'N8xe5' | 'N8xe6' | 'N8xe7' | 'N8xe8' |
        'N8xf1' | 'N8xf2' | 'N8xf3' | 'N8xf4' | 'N8xf5' | 'N8xf6' | 'N8xf7' | 'N8xf8' |
        'N8xg1' | 'N8xg2' | 'N8xg3' | 'N8xg4' | 'N8xg5' | 'N8xg6' | 'N8xg7' | 'N8xg8' |
        'N8xh1' | 'N8xh2' | 'N8xh3' | 'N8xh4' | 'N8xh5' | 'N8xh6' | 'N8xh7' | 'N8xh8' ; // 64

BISHOP_MOVE :
        'B1a1' | 'B2a1' | 'B3a1' | 'B4a1' | 'B5a1' | 'B6a1' | 'B7a1' | 'B8a1' |
        'B1a2' | 'B2a2' | 'B3a2' | 'B4a2' | 'B5a2' | 'B6a2' | 'B7a2' | 'B8a2' |
        'B1a3' | 'B2a3' | 'B3a3' | 'B4a3' | 'B5a3' | 'B6a3' | 'B7a3' | 'B8a3' |
        'B1a4' | 'B2a4' | 'B3a4' | 'B4a4' | 'B5a4' | 'B6a4' | 'B7a4' | 'B8a4' |
        'B1a5' | 'B2a5' | 'B3a5' | 'B4a5' | 'B5a5' | 'B6a5' | 'B7a5' | 'B8a5' |
        'B1a6' | 'B2a6' | 'B3a6' | 'B4a6' | 'B5a6' | 'B6a6' | 'B7a6' | 'B8a6' |
        'B1a7' | 'B2a7' | 'B3a7' | 'B4a7' | 'B5a7' | 'B6a7' | 'B7a7' | 'B8a7' |
        'B1a8' | 'B2a8' | 'B3a8' | 'B4a8' | 'B5a8' | 'B6a8' | 'B7a8' | 'B8a8' | // 64
        'B1b1' | 'B2b1' | 'B3b1' | 'B4b1' | 'B5b1' | 'B6b1' | 'B7b1' | 'B8b1' |
        'B1b2' | 'B2b2' | 'B3b2' | 'B4b2' | 'B5b2' | 'B6b2' | 'B7b2' | 'B8b2' |
        'B1b3' | 'B2b3' | 'B3b3' | 'B4b3' | 'B5b3' | 'B6b3' | 'B7b3' | 'B8b3' |
        'B1b4' | 'B2b4' | 'B3b4' | 'B4b4' | 'B5b4' | 'B6b4' | 'B7b4' | 'B8b4' |
        'B1b5' | 'B2b5' | 'B3b5' | 'B4b5' | 'B5b5' | 'B6b5' | 'B7b5' | 'B8b5' |
        'B1b6' | 'B2b6' | 'B3b6' | 'B4b6' | 'B5b6' | 'B6b6' | 'B7b6' | 'B8b6' |
        'B1b7' | 'B2b7' | 'B3b7' | 'B4b7' | 'B5b7' | 'B6b7' | 'B7b7' | 'B8b7' |
        'B1b8' | 'B2b8' | 'B3b8' | 'B4b8' | 'B5b8' | 'B6b8' | 'B7b8' | 'B8b8' | // 64
        'B1c1' | 'B2c1' | 'B3c1' | 'B4c1' | 'B5c1' | 'B6c1' | 'B7c1' | 'B8c1' |
        'B1c2' | 'B2c2' | 'B3c2' | 'B4c2' | 'B5c2' | 'B6c2' | 'B7c2' | 'B8c2' |
        'B1c3' | 'B2c3' | 'B3c3' | 'B4c3' | 'B5c3' | 'B6c3' | 'B7c3' | 'B8c3' |
        'B1c4' | 'B2c4' | 'B3c4' | 'B4c4' | 'B5c4' | 'B6c4' | 'B7c4' | 'B8c4' |
        'B1c5' | 'B2c5' | 'B3c5' | 'B4c5' | 'B5c5' | 'B6c5' | 'B7c5' | 'B8c5' |
        'B1c6' | 'B2c6' | 'B3c6' | 'B4c6' | 'B5c6' | 'B6c6' | 'B7c6' | 'B8c6' |
        'B1c7' | 'B2c7' | 'B3c7' | 'B4c7' | 'B5c7' | 'B6c7' | 'B7c7' | 'B8c7' |
        'B1c8' | 'B2c8' | 'B3c8' | 'B4c8' | 'B5c8' | 'B6c8' | 'B7c8' | 'B8c8' | // 64
        'B1d1' | 'B2d1' | 'B3d1' | 'B4d1' | 'B5d1' | 'B6d1' | 'B7d1' | 'B8d1' |
        'B1d2' | 'B2d2' | 'B3d2' | 'B4d2' | 'B5d2' | 'B6d2' | 'B7d2' | 'B8d2' |
        'B1d3' | 'B2d3' | 'B3d3' | 'B4d3' | 'B5d3' | 'B6d3' | 'B7d3' | 'B8d3' |
        'B1d4' | 'B2d4' | 'B3d4' | 'B4d4' | 'B5d4' | 'B6d4' | 'B7d4' | 'B8d4' |
        'B1d5' | 'B2d5' | 'B3d5' | 'B4d5' | 'B5d5' | 'B6d5' | 'B7d5' | 'B8d5' |
        'B1d6' | 'B2d6' | 'B3d6' | 'B4d6' | 'B5d6' | 'B6d6' | 'B7d6' | 'B8d6' |
        'B1d7' | 'B2d7' | 'B3d7' | 'B4d7' | 'B5d7' | 'B6d7' | 'B7d7' | 'B8d7' |
        'B1d8' | 'B2d8' | 'B3d8' | 'B4d8' | 'B5d8' | 'B6d8' | 'B7d8' | 'B8d8' | // 64
        'B1e1' | 'B2e1' | 'B3e1' | 'B4e1' | 'B5e1' | 'B6e1' | 'B7e1' | 'B8e1' |
        'B1e2' | 'B2e2' | 'B3e2' | 'B4e2' | 'B5e2' | 'B6e2' | 'B7e2' | 'B8e2' |
        'B1e3' | 'B2e3' | 'B3e3' | 'B4e3' | 'B5e3' | 'B6e3' | 'B7e3' | 'B8e3' |
        'B1e4' | 'B2e4' | 'B3e4' | 'B4e4' | 'B5e4' | 'B6e4' | 'B7e4' | 'B8e4' |
        'B1e5' | 'B2e5' | 'B3e5' | 'B4e5' | 'B5e5' | 'B6e5' | 'B7e5' | 'B8e5' |
        'B1e6' | 'B2e6' | 'B3e6' | 'B4e6' | 'B5e6' | 'B6e6' | 'B7e6' | 'B8e6' |
        'B1e7' | 'B2e7' | 'B3e7' | 'B4e7' | 'B5e7' | 'B6e7' | 'B7e7' | 'B8e7' |
        'B1e8' | 'B2e8' | 'B3e8' | 'B4e8' | 'B5e8' | 'B6e8' | 'B7e8' | 'B8e8' | // 64
        'B1f1' | 'B2f1' | 'B3f1' | 'B4f1' | 'B5f1' | 'B6f1' | 'B7f1' | 'B8f1' |
        'B1f2' | 'B2f2' | 'B3f2' | 'B4f2' | 'B5f2' | 'B6f2' | 'B7f2' | 'B8f2' |
        'B1f3' | 'B2f3' | 'B3f3' | 'B4f3' | 'B5f3' | 'B6f3' | 'B7f3' | 'B8f3' |
        'B1f4' | 'B2f4' | 'B3f4' | 'B4f4' | 'B5f4' | 'B6f4' | 'B7f4' | 'B8f4' |
        'B1f5' | 'B2f5' | 'B3f5' | 'B4f5' | 'B5f5' | 'B6f5' | 'B7f5' | 'B8f5' |
        'B1f6' | 'B2f6' | 'B3f6' | 'B4f6' | 'B5f6' | 'B6f6' | 'B7f6' | 'B8f6' |
        'B1f7' | 'B2f7' | 'B3f7' | 'B4f7' | 'B5f7' | 'B6f7' | 'B7f7' | 'B8f7' |
        'B1f8' | 'B2f8' | 'B3f8' | 'B4f8' | 'B5f8' | 'B6f8' | 'B7f8' | 'B8f8' | // 64
        'B1g1' | 'B2g1' | 'B3g1' | 'B4g1' | 'B5g1' | 'B6g1' | 'B7g1' | 'B8g1' |
        'B1g2' | 'B2g2' | 'B3g2' | 'B4g2' | 'B5g2' | 'B6g2' | 'B7g2' | 'B8g2' |
        'B1g3' | 'B2g3' | 'B3g3' | 'B4g3' | 'B5g3' | 'B6g3' | 'B7g3' | 'B8g3' |
        'B1g4' | 'B2g4' | 'B3g4' | 'B4g4' | 'B5g4' | 'B6g4' | 'B7g4' | 'B8g4' |
        'B1g5' | 'B2g5' | 'B3g5' | 'B4g5' | 'B5g5' | 'B6g5' | 'B7g5' | 'B8g5' |
        'B1g6' | 'B2g6' | 'B3g6' | 'B4g6' | 'B5g6' | 'B6g6' | 'B7g6' | 'B8g6' |
        'B1g7' | 'B2g7' | 'B3g7' | 'B4g7' | 'B5g7' | 'B6g7' | 'B7g7' | 'B8g7' |
        'B1g8' | 'B2g8' | 'B3g8' | 'B4g8' | 'B5g8' | 'B6g8' | 'B7g8' | 'B8g8' | // 64
        'B1h1' | 'B2h1' | 'B3h1' | 'B4h1' | 'B5h1' | 'B6h1' | 'B7h1' | 'B8h1' |
        'B1h2' | 'B2h2' | 'B3h2' | 'B4h2' | 'B5h2' | 'B6h2' | 'B7h2' | 'B8h2' |
        'B1h3' | 'B2h3' | 'B3h3' | 'B4h3' | 'B5h3' | 'B6h3' | 'B7h3' | 'B8h3' |
        'B1h4' | 'B2h4' | 'B3h4' | 'B4h4' | 'B5h4' | 'B6h4' | 'B7h4' | 'B8h4' |
        'B1h5' | 'B2h5' | 'B3h5' | 'B4h5' | 'B5h5' | 'B6h5' | 'B7h5' | 'B8h5' |
        'B1h6' | 'B2h6' | 'B3h6' | 'B4h6' | 'B5h6' | 'B6h6' | 'B7h6' | 'B8h6' |
        'B1h7' | 'B2h7' | 'B3h7' | 'B4h7' | 'B5h7' | 'B6h7' | 'B7h7' | 'B8h7' |
        'B1h8' | 'B2h8' | 'B3h8' | 'B4h8' | 'B5h8' | 'B6h8' | 'B7h8' | 'B8h8' | // 64

        'Baa1' | 'Baa2' | 'Baa3' | 'Baa4' | 'Baa5' | 'Baa6' | 'Baa7' | 'Baa8' |
        'Bab1' | 'Bab2' | 'Bab3' | 'Bab4' | 'Bab5' | 'Bab6' | 'Bab7' | 'Bab8' |
        'Bac1' | 'Bac2' | 'Bac3' | 'Bac4' | 'Bac5' | 'Bac6' | 'Bac7' | 'Bac8' |
        'Bad1' | 'Bad2' | 'Bad3' | 'Bad4' | 'Bad5' | 'Bad6' | 'Bad7' | 'Bad8' |
        'Bae1' | 'Bae2' | 'Bae3' | 'Bae4' | 'Bae5' | 'Bae6' | 'Bae7' | 'Bae8' |
        'Baf1' | 'Baf2' | 'Baf3' | 'Baf4' | 'Baf5' | 'Baf6' | 'Baf7' | 'Baf8' |
        'Bag1' | 'Bag2' | 'Bag3' | 'Bag4' | 'Bag5' | 'Bag6' | 'Bag7' | 'Bag8' |
        'Bah1' | 'Bah2' | 'Bah3' | 'Bah4' | 'Bah5' | 'Bah6' | 'Bah7' | 'Bah8' | // 64

        'Bba1' | 'Bba2' | 'Bba3' | 'Bba4' | 'Bba5' | 'Bba6' | 'Bba7' | 'Bba8' |
        'Bbb1' | 'Bbb2' | 'Bbb3' | 'Bbb4' | 'Bbb5' | 'Bbb6' | 'Bbb7' | 'Bbb8' |
        'Bbc1' | 'Bbc2' | 'Bbc3' | 'Bbc4' | 'Bbc5' | 'Bbc6' | 'Bbc7' | 'Bbc8' |
        'Bbd1' | 'Bbd2' | 'Bbd3' | 'Bbd4' | 'Bbd5' | 'Bbd6' | 'Bbd7' | 'Bbd8' |
        'Bbe1' | 'Bbe2' | 'Bbe3' | 'Bbe4' | 'Bbe5' | 'Bbe6' | 'Bbe7' | 'Bbe8' |
        'Bbf1' | 'Bbf2' | 'Bbf3' | 'Bbf4' | 'Bbf5' | 'Bbf6' | 'Bbf7' | 'Bbf8' |
        'Bbg1' | 'Bbg2' | 'Bbg3' | 'Bbg4' | 'Bbg5' | 'Bbg6' | 'Bbg7' | 'Bbg8' |
        'Bbh1' | 'Bbh2' | 'Bbh3' | 'Bbh4' | 'Bbh5' | 'Bbh6' | 'Bbh7' | 'Bbh8' | // 64

        'Bca1' | 'Bca2' | 'Bca3' | 'Bca4' | 'Bca5' | 'Bca6' | 'Bca7' | 'Bca8' |
        'Bcb1' | 'Bcb2' | 'Bcb3' | 'Bcb4' | 'Bcb5' | 'Bcb6' | 'Bcb7' | 'Bcb8' |
        'Bcc1' | 'Bcc2' | 'Bcc3' | 'Bcc4' | 'Bcc5' | 'Bcc6' | 'Bcc7' | 'Bcc8' |
        'Bcd1' | 'Bcd2' | 'Bcd3' | 'Bcd4' | 'Bcd5' | 'Bcd6' | 'Bcd7' | 'Bcd8' |
        'Bce1' | 'Bce2' | 'Bce3' | 'Bce4' | 'Bce5' | 'Bce6' | 'Bce7' | 'Bce8' |
        'Bcf1' | 'Bcf2' | 'Bcf3' | 'Bcf4' | 'Bcf5' | 'Bcf6' | 'Bcf7' | 'Bcf8' |
        'Bcg1' | 'Bcg2' | 'Bcg3' | 'Bcg4' | 'Bcg5' | 'Bcg6' | 'Bcg7' | 'Bcg8' |
        'Bch1' | 'Bch2' | 'Bch3' | 'Bch4' | 'Bch5' | 'Bch6' | 'Bch7' | 'Bch8' | // 64

        'Bda1' | 'Bda2' | 'Bda3' | 'Bda4' | 'Bda5' | 'Bda6' | 'Bda7' | 'Bda8' |
        'Bdb1' | 'Bdb2' | 'Bdb3' | 'Bdb4' | 'Bdb5' | 'Bdb6' | 'Bdb7' | 'Bdb8' |
        'Bdc1' | 'Bdc2' | 'Bdc3' | 'Bdc4' | 'Bdc5' | 'Bdc6' | 'Bdc7' | 'Bdc8' |
        'Bdd1' | 'Bdd2' | 'Bdd3' | 'Bdd4' | 'Bdd5' | 'Bdd6' | 'Bdd7' | 'Bdd8' |
        'Bde1' | 'Bde2' | 'Bde3' | 'Bde4' | 'Bde5' | 'Bde6' | 'Bde7' | 'Bde8' |
        'Bdf1' | 'Bdf2' | 'Bdf3' | 'Bdf4' | 'Bdf5' | 'Bdf6' | 'Bdf7' | 'Bdf8' |
        'Bdg1' | 'Bdg2' | 'Bdg3' | 'Bdg4' | 'Bdg5' | 'Bdg6' | 'Bdg7' | 'Bdg8' |
        'Bdh1' | 'Bdh2' | 'Bdh3' | 'Bdh4' | 'Bdh5' | 'Bdh6' | 'Bdh7' | 'Bdh8' | // 64

        'Bea1' | 'Bea2' | 'Bea3' | 'Bea4' | 'Bea5' | 'Bea6' | 'Bea7' | 'Bea8' |
        'Beb1' | 'Beb2' | 'Beb3' | 'Beb4' | 'Beb5' | 'Beb6' | 'Beb7' | 'Beb8' |
        'Bec1' | 'Bec2' | 'Bec3' | 'Bec4' | 'Bec5' | 'Bec6' | 'Bec7' | 'Bec8' |
        'Bed1' | 'Bed2' | 'Bed3' | 'Bed4' | 'Bed5' | 'Bed6' | 'Bed7' | 'Bed8' |
        'Bee1' | 'Bee2' | 'Bee3' | 'Bee4' | 'Bee5' | 'Bee6' | 'Bee7' | 'Bee8' |
        'Bef1' | 'Bef2' | 'Bef3' | 'Bef4' | 'Bef5' | 'Bef6' | 'Bef7' | 'Bef8' |
        'Beg1' | 'Beg2' | 'Beg3' | 'Beg4' | 'Beg5' | 'Beg6' | 'Beg7' | 'Beg8' |
        'Beh1' | 'Beh2' | 'Beh3' | 'Beh4' | 'Beh5' | 'Beh6' | 'Beh7' | 'Beh8' | // 64

        'Bfa1' | 'Bfa2' | 'Bfa3' | 'Bfa4' | 'Bfa5' | 'Bfa6' | 'Bfa7' | 'Bfa8' |
        'Bfb1' | 'Bfb2' | 'Bfb3' | 'Bfb4' | 'Bfb5' | 'Bfb6' | 'Bfb7' | 'Bfb8' |
        'Bfc1' | 'Bfc2' | 'Bfc3' | 'Bfc4' | 'Bfc5' | 'Bfc6' | 'Bfc7' | 'Bfc8' |
        'Bfd1' | 'Bfd2' | 'Bfd3' | 'Bfd4' | 'Bfd5' | 'Bfd6' | 'Bfd7' | 'Bfd8' |
        'Bfe1' | 'Bfe2' | 'Bfe3' | 'Bfe4' | 'Bfe5' | 'Bfe6' | 'Bfe7' | 'Bfe8' |
        'Bff1' | 'Bff2' | 'Bff3' | 'Bff4' | 'Bff5' | 'Bff6' | 'Bff7' | 'Bff8' |
        'Bfg1' | 'Bfg2' | 'Bfg3' | 'Bfg4' | 'Bfg5' | 'Bfg6' | 'Bfg7' | 'Bfg8' |
        'Bfh1' | 'Bfh2' | 'Bfh3' | 'Bfh4' | 'Bfh5' | 'Bfh6' | 'Bfh7' | 'Bfh8' | // 64

        'Bga1' | 'Bga2' | 'Bga3' | 'Bga4' | 'Bga5' | 'Bga6' | 'Bga7' | 'Bga8' |
        'Bgb1' | 'Bgb2' | 'Bgb3' | 'Bgb4' | 'Bgb5' | 'Bgb6' | 'Bgb7' | 'Bgb8' |
        'Bgc1' | 'Bgc2' | 'Bgc3' | 'Bgc4' | 'Bgc5' | 'Bgc6' | 'Bgc7' | 'Bgc8' |
        'Bgd1' | 'Bgd2' | 'Bgd3' | 'Bgd4' | 'Bgd5' | 'Bgd6' | 'Bgd7' | 'Bgd8' |
        'Bge1' | 'Bge2' | 'Bge3' | 'Bge4' | 'Bge5' | 'Bge6' | 'Bge7' | 'Bge8' |
        'Bgf1' | 'Bgf2' | 'Bgf3' | 'Bgf4' | 'Bgf5' | 'Bgf6' | 'Bgf7' | 'Bgf8' |
        'Bgg1' | 'Bgg2' | 'Bgg3' | 'Bgg4' | 'Bgg5' | 'Bgg6' | 'Bgg7' | 'Bgg8' |
        'Bgh1' | 'Bgh2' | 'Bgh3' | 'Bgh4' | 'Bgh5' | 'Bgh6' | 'Bgh7' | 'Bgh8' | // 64

        'Bha1' | 'Bha2' | 'Bha3' | 'Bha4' | 'Bha5' | 'Bha6' | 'Bha7' | 'Bha8' |
        'Bhb1' | 'Bhb2' | 'Bhb3' | 'Bhb4' | 'Bhb5' | 'Bhb6' | 'Bhb7' | 'Bhb8' |
        'Bhc1' | 'Bhc2' | 'Bhc3' | 'Bhc4' | 'Bhc5' | 'Bhc6' | 'Bhc7' | 'Bhc8' |
        'Bhd1' | 'Bhd2' | 'Bhd3' | 'Bhd4' | 'Bhd5' | 'Bhd6' | 'Bhd7' | 'Bhd8' |
        'Bhe1' | 'Bhe2' | 'Bhe3' | 'Bhe4' | 'Bhe5' | 'Bhe6' | 'Bhe7' | 'Bhe8' |
        'Bhf1' | 'Bhf2' | 'Bhf3' | 'Bhf4' | 'Bhf5' | 'Bhf6' | 'Bhf7' | 'Bhf8' |
        'Bhg1' | 'Bhg2' | 'Bhg3' | 'Bhg4' | 'Bhg5' | 'Bhg6' | 'Bhg7' | 'Bhg8' |
        'Bhh1' | 'Bhh2' | 'Bhh3' | 'Bhh4' | 'Bhh5' | 'Bhh6' | 'Bhh7' | 'Bhh8' | // 64

        'Baxa1' | 'Baxa2' | 'Baxa3' | 'Baxa4' | 'Baxa5' | 'Baxa6' | 'Baxa7' | 'Baxa8' |
        'Baxb1' | 'Baxb2' | 'Baxb3' | 'Baxb4' | 'Baxb5' | 'Baxb6' | 'Baxb7' | 'Baxb8' |
        'Baxc1' | 'Baxc2' | 'Baxc3' | 'Baxc4' | 'Baxc5' | 'Baxc6' | 'Baxc7' | 'Baxc8' |
        'Baxd1' | 'Baxd2' | 'Baxd3' | 'Baxd4' | 'Baxd5' | 'Baxd6' | 'Baxd7' | 'Baxd8' |
        'Baxe1' | 'Baxe2' | 'Baxe3' | 'Baxe4' | 'Baxe5' | 'Baxe6' | 'Baxe7' | 'Baxe8' |
        'Baxf1' | 'Baxf2' | 'Baxf3' | 'Baxf4' | 'Baxf5' | 'Baxf6' | 'Baxf7' | 'Baxf8' |
        'Baxg1' | 'Baxg2' | 'Baxg3' | 'Baxg4' | 'Baxg5' | 'Baxg6' | 'Baxg7' | 'Baxg8' |
        'Baxh1' | 'Baxh2' | 'Baxh3' | 'Baxh4' | 'Baxh5' | 'Baxh6' | 'Baxh7' | 'Baxh8' | // 64

        'Bbxa1' | 'Bbxa2' | 'Bbxa3' | 'Bbxa4' | 'Bbxa5' | 'Bbxa6' | 'Bbxa7' | 'Bbxa8' |
        'Bbxb1' | 'Bbxb2' | 'Bbxb3' | 'Bbxb4' | 'Bbxb5' | 'Bbxb6' | 'Bbxb7' | 'Bbxb8' |
        'Bbxc1' | 'Bbxc2' | 'Bbxc3' | 'Bbxc4' | 'Bbxc5' | 'Bbxc6' | 'Bbxc7' | 'Bbxc8' |
        'Bbxd1' | 'Bbxd2' | 'Bbxd3' | 'Bbxd4' | 'Bbxd5' | 'Bbxd6' | 'Bbxd7' | 'Bbxd8' |
        'Bbxe1' | 'Bbxe2' | 'Bbxe3' | 'Bbxe4' | 'Bbxe5' | 'Bbxe6' | 'Bbxe7' | 'Bbxe8' |
        'Bbxf1' | 'Bbxf2' | 'Bbxf3' | 'Bbxf4' | 'Bbxf5' | 'Bbxf6' | 'Bbxf7' | 'Bbxf8' |
        'Bbxg1' | 'Bbxg2' | 'Bbxg3' | 'Bbxg4' | 'Bbxg5' | 'Bbxg6' | 'Bbxg7' | 'Bbxg8' |
        'Bbxh1' | 'Bbxh2' | 'Bbxh3' | 'Bbxh4' | 'Bbxh5' | 'Bbxh6' | 'Bbxh7' | 'Bbxh8' | // 64

        'Bcxa1' | 'Bcxa2' | 'Bcxa3' | 'Bcxa4' | 'Bcxa5' | 'Bcxa6' | 'Bcxa7' | 'Bcxa8' |
        'Bcxb1' | 'Bcxb2' | 'Bcxb3' | 'Bcxb4' | 'Bcxb5' | 'Bcxb6' | 'Bcxb7' | 'Bcxb8' |
        'Bcxc1' | 'Bcxc2' | 'Bcxc3' | 'Bcxc4' | 'Bcxc5' | 'Bcxc6' | 'Bcxc7' | 'Bcxc8' |
        'Bcxd1' | 'Bcxd2' | 'Bcxd3' | 'Bcxd4' | 'Bcxd5' | 'Bcxd6' | 'Bcxd7' | 'Bcxd8' |
        'Bcxe1' | 'Bcxe2' | 'Bcxe3' | 'Bcxe4' | 'Bcxe5' | 'Bcxe6' | 'Bcxe7' | 'Bcxe8' |
        'Bcxf1' | 'Bcxf2' | 'Bcxf3' | 'Bcxf4' | 'Bcxf5' | 'Bcxf6' | 'Bcxf7' | 'Bcxf8' |
        'Bcxg1' | 'Bcxg2' | 'Bcxg3' | 'Bcxg4' | 'Bcxg5' | 'Bcxg6' | 'Bcxg7' | 'Bcxg8' |
        'Bcxh1' | 'Bcxh2' | 'Bcxh3' | 'Bcxh4' | 'Bcxh5' | 'Bcxh6' | 'Bcxh7' | 'Bcxh8' | // 64

        'Bdxa1' | 'Bdxa2' | 'Bdxa3' | 'Bdxa4' | 'Bdxa5' | 'Bdxa6' | 'Bdxa7' | 'Bdxa8' |
        'Bdxb1' | 'Bdxb2' | 'Bdxb3' | 'Bdxb4' | 'Bdxb5' | 'Bdxb6' | 'Bdxb7' | 'Bdxb8' |
        'Bdxc1' | 'Bdxc2' | 'Bdxc3' | 'Bdxc4' | 'Bdxc5' | 'Bdxc6' | 'Bdxc7' | 'Bdxc8' |
        'Bdxd1' | 'Bdxd2' | 'Bdxd3' | 'Bdxd4' | 'Bdxd5' | 'Bdxd6' | 'Bdxd7' | 'Bdxd8' |
        'Bdxe1' | 'Bdxe2' | 'Bdxe3' | 'Bdxe4' | 'Bdxe5' | 'Bdxe6' | 'Bdxe7' | 'Bdxe8' |
        'Bdxf1' | 'Bdxf2' | 'Bdxf3' | 'Bdxf4' | 'Bdxf5' | 'Bdxf6' | 'Bdxf7' | 'Bdxf8' |
        'Bdxg1' | 'Bdxg2' | 'Bdxg3' | 'Bdxg4' | 'Bdxg5' | 'Bdxg6' | 'Bdxg7' | 'Bdxg8' |
        'Bdxh1' | 'Bdxh2' | 'Bdxh3' | 'Bdxh4' | 'Bdxh5' | 'Bdxh6' | 'Bdxh7' | 'Bdxh8' | // 64

        'Bexa1' | 'Bexa2' | 'Bexa3' | 'Bexa4' | 'Bexa5' | 'Bexa6' | 'Bexa7' | 'Bexa8' |
        'Bexb1' | 'Bexb2' | 'Bexb3' | 'Bexb4' | 'Bexb5' | 'Bexb6' | 'Bexb7' | 'Bexb8' |
        'Bexc1' | 'Bexc2' | 'Bexc3' | 'Bexc4' | 'Bexc5' | 'Bexc6' | 'Bexc7' | 'Bexc8' |
        'Bexd1' | 'Bexd2' | 'Bexd3' | 'Bexd4' | 'Bexd5' | 'Bexd6' | 'Bexd7' | 'Bexd8' |
        'Bexe1' | 'Bexe2' | 'Bexe3' | 'Bexe4' | 'Bexe5' | 'Bexe6' | 'Bexe7' | 'Bexe8' |
        'Bexf1' | 'Bexf2' | 'Bexf3' | 'Bexf4' | 'Bexf5' | 'Bexf6' | 'Bexf7' | 'Bexf8' |
        'Bexg1' | 'Bexg2' | 'Bexg3' | 'Bexg4' | 'Bexg5' | 'Bexg6' | 'Bexg7' | 'Bexg8' |
        'Bexh1' | 'Bexh2' | 'Bexh3' | 'Bexh4' | 'Bexh5' | 'Bexh6' | 'Bexh7' | 'Bexh8' | // 64

        'Bfxa1' | 'Bfxa2' | 'Bfxa3' | 'Bfxa4' | 'Bfxa5' | 'Bfxa6' | 'Bfxa7' | 'Bfxa8' |
        'Bfxb1' | 'Bfxb2' | 'Bfxb3' | 'Bfxb4' | 'Bfxb5' | 'Bfxb6' | 'Bfxb7' | 'Bfxb8' |
        'Bfxc1' | 'Bfxc2' | 'Bfxc3' | 'Bfxc4' | 'Bfxc5' | 'Bfxc6' | 'Bfxc7' | 'Bfxc8' |
        'Bfxd1' | 'Bfxd2' | 'Bfxd3' | 'Bfxd4' | 'Bfxd5' | 'Bfxd6' | 'Bfxd7' | 'Bfxd8' |
        'Bfxe1' | 'Bfxe2' | 'Bfxe3' | 'Bfxe4' | 'Bfxe5' | 'Bfxe6' | 'Bfxe7' | 'Bfxe8' |
        'Bfxf1' | 'Bfxf2' | 'Bfxf3' | 'Bfxf4' | 'Bfxf5' | 'Bfxf6' | 'Bfxf7' | 'Bfxf8' |
        'Bfxg1' | 'Bfxg2' | 'Bfxg3' | 'Bfxg4' | 'Bfxg5' | 'Bfxg6' | 'Bfxg7' | 'Bfxg8' |
        'Bfxh1' | 'Bfxh2' | 'Bfxh3' | 'Bfxh4' | 'Bfxh5' | 'Bfxh6' | 'Bfxh7' | 'Bfxh8' | // 64

        'Bgxa1' | 'Bgxa2' | 'Bgxa3' | 'Bgxa4' | 'Bgxa5' | 'Bgxa6' | 'Bgxa7' | 'Bgxa8' |
        'Bgxb1' | 'Bgxb2' | 'Bgxb3' | 'Bgxb4' | 'Bgxb5' | 'Bgxb6' | 'Bgxb7' | 'Bgxb8' |
        'Bgxc1' | 'Bgxc2' | 'Bgxc3' | 'Bgxc4' | 'Bgxc5' | 'Bgxc6' | 'Bgxc7' | 'Bgxc8' |
        'Bgxd1' | 'Bgxd2' | 'Bgxd3' | 'Bgxd4' | 'Bgxd5' | 'Bgxd6' | 'Bgxd7' | 'Bgxd8' |
        'Bgxe1' | 'Bgxe2' | 'Bgxe3' | 'Bgxe4' | 'Bgxe5' | 'Bgxe6' | 'Bgxe7' | 'Bgxe8' |
        'Bgxf1' | 'Bgxf2' | 'Bgxf3' | 'Bgxf4' | 'Bgxf5' | 'Bgxf6' | 'Bgxf7' | 'Bgxf8' |
        'Bgxg1' | 'Bgxg2' | 'Bgxg3' | 'Bgxg4' | 'Bgxg5' | 'Bgxg6' | 'Bgxg7' | 'Bgxg8' |
        'Bgxh1' | 'Bgxh2' | 'Bgxh3' | 'Bgxh4' | 'Bgxh5' | 'Bgxh6' | 'Bgxh7' | 'Bgxh8' | // 64

        'Bhxa1' | 'Bhxa2' | 'Bhxa3' | 'Bhxa4' | 'Bhxa5' | 'Bhxa6' | 'Bhxa7' | 'Bhxa8' |
        'Bhxb1' | 'Bhxb2' | 'Bhxb3' | 'Bhxb4' | 'Bhxb5' | 'Bhxb6' | 'Bhxb7' | 'Bhxb8' |
        'Bhxc1' | 'Bhxc2' | 'Bhxc3' | 'Bhxc4' | 'Bhxc5' | 'Bhxc6' | 'Bhxc7' | 'Bhxc8' |
        'Bhxd1' | 'Bhxd2' | 'Bhxd3' | 'Bhxd4' | 'Bhxd5' | 'Bhxd6' | 'Bhxd7' | 'Bhxd8' |
        'Bhxe1' | 'Bhxe2' | 'Bhxe3' | 'Bhxe4' | 'Bhxe5' | 'Bhxe6' | 'Bhxe7' | 'Bhxe8' |
        'Bhxf1' | 'Bhxf2' | 'Bhxf3' | 'Bhxf4' | 'Bhxf5' | 'Bhxf6' | 'Bhxf7' | 'Bhxf8' |
        'Bhxg1' | 'Bhxg2' | 'Bhxg3' | 'Bhxg4' | 'Bhxg5' | 'Bhxg6' | 'Bhxg7' | 'Bhxg8' |
        'Bhxh1' | 'Bhxh2' | 'Bhxh3' | 'Bhxh4' | 'Bhxh5' | 'Bhxh6' | 'Bhxh7' | 'Bhxh8' | // 64

        'Ba1' | 'Ba2' | 'Ba3' | 'Ba4' | 'Ba5' | 'Ba6' | 'Ba7' | 'Ba8' |
        'Bb1' | 'Bb2' | 'Bb3' | 'Bb4' | 'Bb5' | 'Bb6' | 'Bb7' | 'Bb8' |
        'Bc1' | 'Bc2' | 'Bc3' | 'Bc4' | 'Bc5' | 'Bc6' | 'Bc7' | 'Bc8' |
        'Bd1' | 'Bd2' | 'Bd3' | 'Bd4' | 'Bd5' | 'Bd6' | 'Bd7' | 'Bd8' |
        'Be1' | 'Be2' | 'Be3' | 'Be4' | 'Be5' | 'Be6' | 'Be7' | 'Be8' |
        'Bf1' | 'Bf2' | 'Bf3' | 'Bf4' | 'Bf5' | 'Bf6' | 'Bf7' | 'Bf8' |
        'Bg1' | 'Bg2' | 'Bg3' | 'Bg4' | 'Bg5' | 'Bg6' | 'Bg7' | 'Bg8' |
        'Bh1' | 'Bh2' | 'Bh3' | 'Bh4' | 'Bh5' | 'Bh6' | 'Bh7' | 'Bh8' | // 64

        'Bxa1' | 'Bxa2' | 'Bxa3' | 'Bxa4' | 'Bxa5' | 'Bxa6' | 'Bxa7' | 'Bxa8' |
        'Bxb1' | 'Bxb2' | 'Bxb3' | 'Bxb4' | 'Bxb5' | 'Bxb6' | 'Bxb7' | 'Bxb8' |
        'Bxc1' | 'Bxc2' | 'Bxc3' | 'Bxc4' | 'Bxc5' | 'Bxc6' | 'Bxc7' | 'Bxc8' |
        'Bxd1' | 'Bxd2' | 'Bxd3' | 'Bxd4' | 'Bxd5' | 'Bxd6' | 'Bxd7' | 'Bxd8' |
        'Bxe1' | 'Bxe2' | 'Bxe3' | 'Bxe4' | 'Bxe5' | 'Bxe6' | 'Bxe7' | 'Bxe8' |
        'Bxf1' | 'Bxf2' | 'Bxf3' | 'Bxf4' | 'Bxf5' | 'Bxf6' | 'Bxf7' | 'Bxf8' |
        'Bxg1' | 'Bxg2' | 'Bxg3' | 'Bxg4' | 'Bxg5' | 'Bxg6' | 'Bxg7' | 'Bxg8' |
        'Bxh1' | 'Bxh2' | 'Bxh3' | 'Bxh4' | 'Bxh5' | 'Bxh6' | 'Bxh7' | 'Bxh8' ; // 64

QUEEN_MOVE :
        'Q1a1' | 'Q2a1' | 'Q3a1' | 'Q4a1' | 'Q5a1' | 'Q6a1' | 'Q7a1' | 'Q8a1' |
        'Q1a2' | 'Q2a2' | 'Q3a2' | 'Q4a2' | 'Q5a2' | 'Q6a2' | 'Q7a2' | 'Q8a2' |
        'Q1a3' | 'Q2a3' | 'Q3a3' | 'Q4a3' | 'Q5a3' | 'Q6a3' | 'Q7a3' | 'Q8a3' |
        'Q1a4' | 'Q2a4' | 'Q3a4' | 'Q4a4' | 'Q5a4' | 'Q6a4' | 'Q7a4' | 'Q8a4' |
        'Q1a5' | 'Q2a5' | 'Q3a5' | 'Q4a5' | 'Q5a5' | 'Q6a5' | 'Q7a5' | 'Q8a5' |
        'Q1a6' | 'Q2a6' | 'Q3a6' | 'Q4a6' | 'Q5a6' | 'Q6a6' | 'Q7a6' | 'Q8a6' |
        'Q1a7' | 'Q2a7' | 'Q3a7' | 'Q4a7' | 'Q5a7' | 'Q6a7' | 'Q7a7' | 'Q8a7' |
        'Q1a8' | 'Q2a8' | 'Q3a8' | 'Q4a8' | 'Q5a8' | 'Q6a8' | 'Q7a8' | 'Q8a8' | // 64
        'Q1b1' | 'Q2b1' | 'Q3b1' | 'Q4b1' | 'Q5b1' | 'Q6b1' | 'Q7b1' | 'Q8b1' |
        'Q1b2' | 'Q2b2' | 'Q3b2' | 'Q4b2' | 'Q5b2' | 'Q6b2' | 'Q7b2' | 'Q8b2' |
        'Q1b3' | 'Q2b3' | 'Q3b3' | 'Q4b3' | 'Q5b3' | 'Q6b3' | 'Q7b3' | 'Q8b3' |
        'Q1b4' | 'Q2b4' | 'Q3b4' | 'Q4b4' | 'Q5b4' | 'Q6b4' | 'Q7b4' | 'Q8b4' |
        'Q1b5' | 'Q2b5' | 'Q3b5' | 'Q4b5' | 'Q5b5' | 'Q6b5' | 'Q7b5' | 'Q8b5' |
        'Q1b6' | 'Q2b6' | 'Q3b6' | 'Q4b6' | 'Q5b6' | 'Q6b6' | 'Q7b6' | 'Q8b6' |
        'Q1b7' | 'Q2b7' | 'Q3b7' | 'Q4b7' | 'Q5b7' | 'Q6b7' | 'Q7b7' | 'Q8b7' |
        'Q1b8' | 'Q2b8' | 'Q3b8' | 'Q4b8' | 'Q5b8' | 'Q6b8' | 'Q7b8' | 'Q8b8' | // 64
        'Q1c1' | 'Q2c1' | 'Q3c1' | 'Q4c1' | 'Q5c1' | 'Q6c1' | 'Q7c1' | 'Q8c1' |
        'Q1c2' | 'Q2c2' | 'Q3c2' | 'Q4c2' | 'Q5c2' | 'Q6c2' | 'Q7c2' | 'Q8c2' |
        'Q1c3' | 'Q2c3' | 'Q3c3' | 'Q4c3' | 'Q5c3' | 'Q6c3' | 'Q7c3' | 'Q8c3' |
        'Q1c4' | 'Q2c4' | 'Q3c4' | 'Q4c4' | 'Q5c4' | 'Q6c4' | 'Q7c4' | 'Q8c4' |
        'Q1c5' | 'Q2c5' | 'Q3c5' | 'Q4c5' | 'Q5c5' | 'Q6c5' | 'Q7c5' | 'Q8c5' |
        'Q1c6' | 'Q2c6' | 'Q3c6' | 'Q4c6' | 'Q5c6' | 'Q6c6' | 'Q7c6' | 'Q8c6' |
        'Q1c7' | 'Q2c7' | 'Q3c7' | 'Q4c7' | 'Q5c7' | 'Q6c7' | 'Q7c7' | 'Q8c7' |
        'Q1c8' | 'Q2c8' | 'Q3c8' | 'Q4c8' | 'Q5c8' | 'Q6c8' | 'Q7c8' | 'Q8c8' | // 64
        'Q1d1' | 'Q2d1' | 'Q3d1' | 'Q4d1' | 'Q5d1' | 'Q6d1' | 'Q7d1' | 'Q8d1' |
        'Q1d2' | 'Q2d2' | 'Q3d2' | 'Q4d2' | 'Q5d2' | 'Q6d2' | 'Q7d2' | 'Q8d2' |
        'Q1d3' | 'Q2d3' | 'Q3d3' | 'Q4d3' | 'Q5d3' | 'Q6d3' | 'Q7d3' | 'Q8d3' |
        'Q1d4' | 'Q2d4' | 'Q3d4' | 'Q4d4' | 'Q5d4' | 'Q6d4' | 'Q7d4' | 'Q8d4' |
        'Q1d5' | 'Q2d5' | 'Q3d5' | 'Q4d5' | 'Q5d5' | 'Q6d5' | 'Q7d5' | 'Q8d5' |
        'Q1d6' | 'Q2d6' | 'Q3d6' | 'Q4d6' | 'Q5d6' | 'Q6d6' | 'Q7d6' | 'Q8d6' |
        'Q1d7' | 'Q2d7' | 'Q3d7' | 'Q4d7' | 'Q5d7' | 'Q6d7' | 'Q7d7' | 'Q8d7' |
        'Q1d8' | 'Q2d8' | 'Q3d8' | 'Q4d8' | 'Q5d8' | 'Q6d8' | 'Q7d8' | 'Q8d8' | // 64
        'Q1e1' | 'Q2e1' | 'Q3e1' | 'Q4e1' | 'Q5e1' | 'Q6e1' | 'Q7e1' | 'Q8e1' |
        'Q1e2' | 'Q2e2' | 'Q3e2' | 'Q4e2' | 'Q5e2' | 'Q6e2' | 'Q7e2' | 'Q8e2' |
        'Q1e3' | 'Q2e3' | 'Q3e3' | 'Q4e3' | 'Q5e3' | 'Q6e3' | 'Q7e3' | 'Q8e3' |
        'Q1e4' | 'Q2e4' | 'Q3e4' | 'Q4e4' | 'Q5e4' | 'Q6e4' | 'Q7e4' | 'Q8e4' |
        'Q1e5' | 'Q2e5' | 'Q3e5' | 'Q4e5' | 'Q5e5' | 'Q6e5' | 'Q7e5' | 'Q8e5' |
        'Q1e6' | 'Q2e6' | 'Q3e6' | 'Q4e6' | 'Q5e6' | 'Q6e6' | 'Q7e6' | 'Q8e6' |
        'Q1e7' | 'Q2e7' | 'Q3e7' | 'Q4e7' | 'Q5e7' | 'Q6e7' | 'Q7e7' | 'Q8e7' |
        'Q1e8' | 'Q2e8' | 'Q3e8' | 'Q4e8' | 'Q5e8' | 'Q6e8' | 'Q7e8' | 'Q8e8' | // 64
        'Q1f1' | 'Q2f1' | 'Q3f1' | 'Q4f1' | 'Q5f1' | 'Q6f1' | 'Q7f1' | 'Q8f1' |
        'Q1f2' | 'Q2f2' | 'Q3f2' | 'Q4f2' | 'Q5f2' | 'Q6f2' | 'Q7f2' | 'Q8f2' |
        'Q1f3' | 'Q2f3' | 'Q3f3' | 'Q4f3' | 'Q5f3' | 'Q6f3' | 'Q7f3' | 'Q8f3' |
        'Q1f4' | 'Q2f4' | 'Q3f4' | 'Q4f4' | 'Q5f4' | 'Q6f4' | 'Q7f4' | 'Q8f4' |
        'Q1f5' | 'Q2f5' | 'Q3f5' | 'Q4f5' | 'Q5f5' | 'Q6f5' | 'Q7f5' | 'Q8f5' |
        'Q1f6' | 'Q2f6' | 'Q3f6' | 'Q4f6' | 'Q5f6' | 'Q6f6' | 'Q7f6' | 'Q8f6' |
        'Q1f7' | 'Q2f7' | 'Q3f7' | 'Q4f7' | 'Q5f7' | 'Q6f7' | 'Q7f7' | 'Q8f7' |
        'Q1f8' | 'Q2f8' | 'Q3f8' | 'Q4f8' | 'Q5f8' | 'Q6f8' | 'Q7f8' | 'Q8f8' | // 64
        'Q1g1' | 'Q2g1' | 'Q3g1' | 'Q4g1' | 'Q5g1' | 'Q6g1' | 'Q7g1' | 'Q8g1' |
        'Q1g2' | 'Q2g2' | 'Q3g2' | 'Q4g2' | 'Q5g2' | 'Q6g2' | 'Q7g2' | 'Q8g2' |
        'Q1g3' | 'Q2g3' | 'Q3g3' | 'Q4g3' | 'Q5g3' | 'Q6g3' | 'Q7g3' | 'Q8g3' |
        'Q1g4' | 'Q2g4' | 'Q3g4' | 'Q4g4' | 'Q5g4' | 'Q6g4' | 'Q7g4' | 'Q8g4' |
        'Q1g5' | 'Q2g5' | 'Q3g5' | 'Q4g5' | 'Q5g5' | 'Q6g5' | 'Q7g5' | 'Q8g5' |
        'Q1g6' | 'Q2g6' | 'Q3g6' | 'Q4g6' | 'Q5g6' | 'Q6g6' | 'Q7g6' | 'Q8g6' |
        'Q1g7' | 'Q2g7' | 'Q3g7' | 'Q4g7' | 'Q5g7' | 'Q6g7' | 'Q7g7' | 'Q8g7' |
        'Q1g8' | 'Q2g8' | 'Q3g8' | 'Q4g8' | 'Q5g8' | 'Q6g8' | 'Q7g8' | 'Q8g8' | // 64
        'Q1h1' | 'Q2h1' | 'Q3h1' | 'Q4h1' | 'Q5h1' | 'Q6h1' | 'Q7h1' | 'Q8h1' |
        'Q1h2' | 'Q2h2' | 'Q3h2' | 'Q4h2' | 'Q5h2' | 'Q6h2' | 'Q7h2' | 'Q8h2' |
        'Q1h3' | 'Q2h3' | 'Q3h3' | 'Q4h3' | 'Q5h3' | 'Q6h3' | 'Q7h3' | 'Q8h3' |
        'Q1h4' | 'Q2h4' | 'Q3h4' | 'Q4h4' | 'Q5h4' | 'Q6h4' | 'Q7h4' | 'Q8h4' |
        'Q1h5' | 'Q2h5' | 'Q3h5' | 'Q4h5' | 'Q5h5' | 'Q6h5' | 'Q7h5' | 'Q8h5' |
        'Q1h6' | 'Q2h6' | 'Q3h6' | 'Q4h6' | 'Q5h6' | 'Q6h6' | 'Q7h6' | 'Q8h6' |
        'Q1h7' | 'Q2h7' | 'Q3h7' | 'Q4h7' | 'Q5h7' | 'Q6h7' | 'Q7h7' | 'Q8h7' |
        'Q1h8' | 'Q2h8' | 'Q3h8' | 'Q4h8' | 'Q5h8' | 'Q6h8' | 'Q7h8' | 'Q8h8' | // 64

        'Qaa1' | 'Qaa2' | 'Qaa3' | 'Qaa4' | 'Qaa5' | 'Qaa6' | 'Qaa7' | 'Qaa8' |
        'Qab1' | 'Qab2' | 'Qab3' | 'Qab4' | 'Qab5' | 'Qab6' | 'Qab7' | 'Qab8' |
        'Qac1' | 'Qac2' | 'Qac3' | 'Qac4' | 'Qac5' | 'Qac6' | 'Qac7' | 'Qac8' |
        'Qad1' | 'Qad2' | 'Qad3' | 'Qad4' | 'Qad5' | 'Qad6' | 'Qad7' | 'Qad8' |
        'Qae1' | 'Qae2' | 'Qae3' | 'Qae4' | 'Qae5' | 'Qae6' | 'Qae7' | 'Qae8' |
        'Qaf1' | 'Qaf2' | 'Qaf3' | 'Qaf4' | 'Qaf5' | 'Qaf6' | 'Qaf7' | 'Qaf8' |
        'Qag1' | 'Qag2' | 'Qag3' | 'Qag4' | 'Qag5' | 'Qag6' | 'Qag7' | 'Qag8' |
        'Qah1' | 'Qah2' | 'Qah3' | 'Qah4' | 'Qah5' | 'Qah6' | 'Qah7' | 'Qah8' | // 64

        'Qba1' | 'Qba2' | 'Qba3' | 'Qba4' | 'Qba5' | 'Qba6' | 'Qba7' | 'Qba8' |
        'Qbb1' | 'Qbb2' | 'Qbb3' | 'Qbb4' | 'Qbb5' | 'Qbb6' | 'Qbb7' | 'Qbb8' |
        'Qbc1' | 'Qbc2' | 'Qbc3' | 'Qbc4' | 'Qbc5' | 'Qbc6' | 'Qbc7' | 'Qbc8' |
        'Qbd1' | 'Qbd2' | 'Qbd3' | 'Qbd4' | 'Qbd5' | 'Qbd6' | 'Qbd7' | 'Qbd8' |
        'Qbe1' | 'Qbe2' | 'Qbe3' | 'Qbe4' | 'Qbe5' | 'Qbe6' | 'Qbe7' | 'Qbe8' |
        'Qbf1' | 'Qbf2' | 'Qbf3' | 'Qbf4' | 'Qbf5' | 'Qbf6' | 'Qbf7' | 'Qbf8' |
        'Qbg1' | 'Qbg2' | 'Qbg3' | 'Qbg4' | 'Qbg5' | 'Qbg6' | 'Qbg7' | 'Qbg8' |
        'Qbh1' | 'Qbh2' | 'Qbh3' | 'Qbh4' | 'Qbh5' | 'Qbh6' | 'Qbh7' | 'Qbh8' | // 64

        'Qca1' | 'Qca2' | 'Qca3' | 'Qca4' | 'Qca5' | 'Qca6' | 'Qca7' | 'Qca8' |
        'Qcb1' | 'Qcb2' | 'Qcb3' | 'Qcb4' | 'Qcb5' | 'Qcb6' | 'Qcb7' | 'Qcb8' |
        'Qcc1' | 'Qcc2' | 'Qcc3' | 'Qcc4' | 'Qcc5' | 'Qcc6' | 'Qcc7' | 'Qcc8' |
        'Qcd1' | 'Qcd2' | 'Qcd3' | 'Qcd4' | 'Qcd5' | 'Qcd6' | 'Qcd7' | 'Qcd8' |
        'Qce1' | 'Qce2' | 'Qce3' | 'Qce4' | 'Qce5' | 'Qce6' | 'Qce7' | 'Qce8' |
        'Qcf1' | 'Qcf2' | 'Qcf3' | 'Qcf4' | 'Qcf5' | 'Qcf6' | 'Qcf7' | 'Qcf8' |
        'Qcg1' | 'Qcg2' | 'Qcg3' | 'Qcg4' | 'Qcg5' | 'Qcg6' | 'Qcg7' | 'Qcg8' |
        'Qch1' | 'Qch2' | 'Qch3' | 'Qch4' | 'Qch5' | 'Qch6' | 'Qch7' | 'Qch8' | // 64

        'Qda1' | 'Qda2' | 'Qda3' | 'Qda4' | 'Qda5' | 'Qda6' | 'Qda7' | 'Qda8' |
        'Qdb1' | 'Qdb2' | 'Qdb3' | 'Qdb4' | 'Qdb5' | 'Qdb6' | 'Qdb7' | 'Qdb8' |
        'Qdc1' | 'Qdc2' | 'Qdc3' | 'Qdc4' | 'Qdc5' | 'Qdc6' | 'Qdc7' | 'Qdc8' |
        'Qdd1' | 'Qdd2' | 'Qdd3' | 'Qdd4' | 'Qdd5' | 'Qdd6' | 'Qdd7' | 'Qdd8' |
        'Qde1' | 'Qde2' | 'Qde3' | 'Qde4' | 'Qde5' | 'Qde6' | 'Qde7' | 'Qde8' |
        'Qdf1' | 'Qdf2' | 'Qdf3' | 'Qdf4' | 'Qdf5' | 'Qdf6' | 'Qdf7' | 'Qdf8' |
        'Qdg1' | 'Qdg2' | 'Qdg3' | 'Qdg4' | 'Qdg5' | 'Qdg6' | 'Qdg7' | 'Qdg8' |
        'Qdh1' | 'Qdh2' | 'Qdh3' | 'Qdh4' | 'Qdh5' | 'Qdh6' | 'Qdh7' | 'Qdh8' | // 64

        'Qea1' | 'Qea2' | 'Qea3' | 'Qea4' | 'Qea5' | 'Qea6' | 'Qea7' | 'Qea8' |
        'Qeb1' | 'Qeb2' | 'Qeb3' | 'Qeb4' | 'Qeb5' | 'Qeb6' | 'Qeb7' | 'Qeb8' |
        'Qec1' | 'Qec2' | 'Qec3' | 'Qec4' | 'Qec5' | 'Qec6' | 'Qec7' | 'Qec8' |
        'Qed1' | 'Qed2' | 'Qed3' | 'Qed4' | 'Qed5' | 'Qed6' | 'Qed7' | 'Qed8' |
        'Qee1' | 'Qee2' | 'Qee3' | 'Qee4' | 'Qee5' | 'Qee6' | 'Qee7' | 'Qee8' |
        'Qef1' | 'Qef2' | 'Qef3' | 'Qef4' | 'Qef5' | 'Qef6' | 'Qef7' | 'Qef8' |
        'Qeg1' | 'Qeg2' | 'Qeg3' | 'Qeg4' | 'Qeg5' | 'Qeg6' | 'Qeg7' | 'Qeg8' |
        'Qeh1' | 'Qeh2' | 'Qeh3' | 'Qeh4' | 'Qeh5' | 'Qeh6' | 'Qeh7' | 'Qeh8' | // 64

        'Qfa1' | 'Qfa2' | 'Qfa3' | 'Qfa4' | 'Qfa5' | 'Qfa6' | 'Qfa7' | 'Qfa8' |
        'Qfb1' | 'Qfb2' | 'Qfb3' | 'Qfb4' | 'Qfb5' | 'Qfb6' | 'Qfb7' | 'Qfb8' |
        'Qfc1' | 'Qfc2' | 'Qfc3' | 'Qfc4' | 'Qfc5' | 'Qfc6' | 'Qfc7' | 'Qfc8' |
        'Qfd1' | 'Qfd2' | 'Qfd3' | 'Qfd4' | 'Qfd5' | 'Qfd6' | 'Qfd7' | 'Qfd8' |
        'Qfe1' | 'Qfe2' | 'Qfe3' | 'Qfe4' | 'Qfe5' | 'Qfe6' | 'Qfe7' | 'Qfe8' |
        'Qff1' | 'Qff2' | 'Qff3' | 'Qff4' | 'Qff5' | 'Qff6' | 'Qff7' | 'Qff8' |
        'Qfg1' | 'Qfg2' | 'Qfg3' | 'Qfg4' | 'Qfg5' | 'Qfg6' | 'Qfg7' | 'Qfg8' |
        'Qfh1' | 'Qfh2' | 'Qfh3' | 'Qfh4' | 'Qfh5' | 'Qfh6' | 'Qfh7' | 'Qfh8' | // 64

        'Qga1' | 'Qga2' | 'Qga3' | 'Qga4' | 'Qga5' | 'Qga6' | 'Qga7' | 'Qga8' |
        'Qgb1' | 'Qgb2' | 'Qgb3' | 'Qgb4' | 'Qgb5' | 'Qgb6' | 'Qgb7' | 'Qgb8' |
        'Qgc1' | 'Qgc2' | 'Qgc3' | 'Qgc4' | 'Qgc5' | 'Qgc6' | 'Qgc7' | 'Qgc8' |
        'Qgd1' | 'Qgd2' | 'Qgd3' | 'Qgd4' | 'Qgd5' | 'Qgd6' | 'Qgd7' | 'Qgd8' |
        'Qge1' | 'Qge2' | 'Qge3' | 'Qge4' | 'Qge5' | 'Qge6' | 'Qge7' | 'Qge8' |
        'Qgf1' | 'Qgf2' | 'Qgf3' | 'Qgf4' | 'Qgf5' | 'Qgf6' | 'Qgf7' | 'Qgf8' |
        'Qgg1' | 'Qgg2' | 'Qgg3' | 'Qgg4' | 'Qgg5' | 'Qgg6' | 'Qgg7' | 'Qgg8' |
        'Qgh1' | 'Qgh2' | 'Qgh3' | 'Qgh4' | 'Qgh5' | 'Qgh6' | 'Qgh7' | 'Qgh8' | // 64

        'Qha1' | 'Qha2' | 'Qha3' | 'Qha4' | 'Qha5' | 'Qha6' | 'Qha7' | 'Qha8' |
        'Qhb1' | 'Qhb2' | 'Qhb3' | 'Qhb4' | 'Qhb5' | 'Qhb6' | 'Qhb7' | 'Qhb8' |
        'Qhc1' | 'Qhc2' | 'Qhc3' | 'Qhc4' | 'Qhc5' | 'Qhc6' | 'Qhc7' | 'Qhc8' |
        'Qhd1' | 'Qhd2' | 'Qhd3' | 'Qhd4' | 'Qhd5' | 'Qhd6' | 'Qhd7' | 'Qhd8' |
        'Qhe1' | 'Qhe2' | 'Qhe3' | 'Qhe4' | 'Qhe5' | 'Qhe6' | 'Qhe7' | 'Qhe8' |
        'Qhf1' | 'Qhf2' | 'Qhf3' | 'Qhf4' | 'Qhf5' | 'Qhf6' | 'Qhf7' | 'Qhf8' |
        'Qhg1' | 'Qhg2' | 'Qhg3' | 'Qhg4' | 'Qhg5' | 'Qhg6' | 'Qhg7' | 'Qhg8' |
        'Qhh1' | 'Qhh2' | 'Qhh3' | 'Qhh4' | 'Qhh5' | 'Qhh6' | 'Qhh7' | 'Qhh8' | // 64

        'Qaxa1' | 'Qaxa2' | 'Qaxa3' | 'Qaxa4' | 'Qaxa5' | 'Qaxa6' | 'Qaxa7' | 'Qaxa8' |
        'Qaxb1' | 'Qaxb2' | 'Qaxb3' | 'Qaxb4' | 'Qaxb5' | 'Qaxb6' | 'Qaxb7' | 'Qaxb8' |
        'Qaxc1' | 'Qaxc2' | 'Qaxc3' | 'Qaxc4' | 'Qaxc5' | 'Qaxc6' | 'Qaxc7' | 'Qaxc8' |
        'Qaxd1' | 'Qaxd2' | 'Qaxd3' | 'Qaxd4' | 'Qaxd5' | 'Qaxd6' | 'Qaxd7' | 'Qaxd8' |
        'Qaxe1' | 'Qaxe2' | 'Qaxe3' | 'Qaxe4' | 'Qaxe5' | 'Qaxe6' | 'Qaxe7' | 'Qaxe8' |
        'Qaxf1' | 'Qaxf2' | 'Qaxf3' | 'Qaxf4' | 'Qaxf5' | 'Qaxf6' | 'Qaxf7' | 'Qaxf8' |
        'Qaxg1' | 'Qaxg2' | 'Qaxg3' | 'Qaxg4' | 'Qaxg5' | 'Qaxg6' | 'Qaxg7' | 'Qaxg8' |
        'Qaxh1' | 'Qaxh2' | 'Qaxh3' | 'Qaxh4' | 'Qaxh5' | 'Qaxh6' | 'Qaxh7' | 'Qaxh8' | // 64

        'Qbxa1' | 'Qbxa2' | 'Qbxa3' | 'Qbxa4' | 'Qbxa5' | 'Qbxa6' | 'Qbxa7' | 'Qbxa8' |
        'Qbxb1' | 'Qbxb2' | 'Qbxb3' | 'Qbxb4' | 'Qbxb5' | 'Qbxb6' | 'Qbxb7' | 'Qbxb8' |
        'Qbxc1' | 'Qbxc2' | 'Qbxc3' | 'Qbxc4' | 'Qbxc5' | 'Qbxc6' | 'Qbxc7' | 'Qbxc8' |
        'Qbxd1' | 'Qbxd2' | 'Qbxd3' | 'Qbxd4' | 'Qbxd5' | 'Qbxd6' | 'Qbxd7' | 'Qbxd8' |
        'Qbxe1' | 'Qbxe2' | 'Qbxe3' | 'Qbxe4' | 'Qbxe5' | 'Qbxe6' | 'Qbxe7' | 'Qbxe8' |
        'Qbxf1' | 'Qbxf2' | 'Qbxf3' | 'Qbxf4' | 'Qbxf5' | 'Qbxf6' | 'Qbxf7' | 'Qbxf8' |
        'Qbxg1' | 'Qbxg2' | 'Qbxg3' | 'Qbxg4' | 'Qbxg5' | 'Qbxg6' | 'Qbxg7' | 'Qbxg8' |
        'Qbxh1' | 'Qbxh2' | 'Qbxh3' | 'Qbxh4' | 'Qbxh5' | 'Qbxh6' | 'Qbxh7' | 'Qbxh8' | // 64

        'Qcxa1' | 'Qcxa2' | 'Qcxa3' | 'Qcxa4' | 'Qcxa5' | 'Qcxa6' | 'Qcxa7' | 'Qcxa8' |
        'Qcxb1' | 'Qcxb2' | 'Qcxb3' | 'Qcxb4' | 'Qcxb5' | 'Qcxb6' | 'Qcxb7' | 'Qcxb8' |
        'Qcxc1' | 'Qcxc2' | 'Qcxc3' | 'Qcxc4' | 'Qcxc5' | 'Qcxc6' | 'Qcxc7' | 'Qcxc8' |
        'Qcxd1' | 'Qcxd2' | 'Qcxd3' | 'Qcxd4' | 'Qcxd5' | 'Qcxd6' | 'Qcxd7' | 'Qcxd8' |
        'Qcxe1' | 'Qcxe2' | 'Qcxe3' | 'Qcxe4' | 'Qcxe5' | 'Qcxe6' | 'Qcxe7' | 'Qcxe8' |
        'Qcxf1' | 'Qcxf2' | 'Qcxf3' | 'Qcxf4' | 'Qcxf5' | 'Qcxf6' | 'Qcxf7' | 'Qcxf8' |
        'Qcxg1' | 'Qcxg2' | 'Qcxg3' | 'Qcxg4' | 'Qcxg5' | 'Qcxg6' | 'Qcxg7' | 'Qcxg8' |
        'Qcxh1' | 'Qcxh2' | 'Qcxh3' | 'Qcxh4' | 'Qcxh5' | 'Qcxh6' | 'Qcxh7' | 'Qcxh8' | // 64

        'Qdxa1' | 'Qdxa2' | 'Qdxa3' | 'Qdxa4' | 'Qdxa5' | 'Qdxa6' | 'Qdxa7' | 'Qdxa8' |
        'Qdxb1' | 'Qdxb2' | 'Qdxb3' | 'Qdxb4' | 'Qdxb5' | 'Qdxb6' | 'Qdxb7' | 'Qdxb8' |
        'Qdxc1' | 'Qdxc2' | 'Qdxc3' | 'Qdxc4' | 'Qdxc5' | 'Qdxc6' | 'Qdxc7' | 'Qdxc8' |
        'Qdxd1' | 'Qdxd2' | 'Qdxd3' | 'Qdxd4' | 'Qdxd5' | 'Qdxd6' | 'Qdxd7' | 'Qdxd8' |
        'Qdxe1' | 'Qdxe2' | 'Qdxe3' | 'Qdxe4' | 'Qdxe5' | 'Qdxe6' | 'Qdxe7' | 'Qdxe8' |
        'Qdxf1' | 'Qdxf2' | 'Qdxf3' | 'Qdxf4' | 'Qdxf5' | 'Qdxf6' | 'Qdxf7' | 'Qdxf8' |
        'Qdxg1' | 'Qdxg2' | 'Qdxg3' | 'Qdxg4' | 'Qdxg5' | 'Qdxg6' | 'Qdxg7' | 'Qdxg8' |
        'Qdxh1' | 'Qdxh2' | 'Qdxh3' | 'Qdxh4' | 'Qdxh5' | 'Qdxh6' | 'Qdxh7' | 'Qdxh8' | // 64

        'Qexa1' | 'Qexa2' | 'Qexa3' | 'Qexa4' | 'Qexa5' | 'Qexa6' | 'Qexa7' | 'Qexa8' |
        'Qexb1' | 'Qexb2' | 'Qexb3' | 'Qexb4' | 'Qexb5' | 'Qexb6' | 'Qexb7' | 'Qexb8' |
        'Qexc1' | 'Qexc2' | 'Qexc3' | 'Qexc4' | 'Qexc5' | 'Qexc6' | 'Qexc7' | 'Qexc8' |
        'Qexd1' | 'Qexd2' | 'Qexd3' | 'Qexd4' | 'Qexd5' | 'Qexd6' | 'Qexd7' | 'Qexd8' |
        'Qexe1' | 'Qexe2' | 'Qexe3' | 'Qexe4' | 'Qexe5' | 'Qexe6' | 'Qexe7' | 'Qexe8' |
        'Qexf1' | 'Qexf2' | 'Qexf3' | 'Qexf4' | 'Qexf5' | 'Qexf6' | 'Qexf7' | 'Qexf8' |
        'Qexg1' | 'Qexg2' | 'Qexg3' | 'Qexg4' | 'Qexg5' | 'Qexg6' | 'Qexg7' | 'Qexg8' |
        'Qexh1' | 'Qexh2' | 'Qexh3' | 'Qexh4' | 'Qexh5' | 'Qexh6' | 'Qexh7' | 'Qexh8' | // 64

        'Qfxa1' | 'Qfxa2' | 'Qfxa3' | 'Qfxa4' | 'Qfxa5' | 'Qfxa6' | 'Qfxa7' | 'Qfxa8' |
        'Qfxb1' | 'Qfxb2' | 'Qfxb3' | 'Qfxb4' | 'Qfxb5' | 'Qfxb6' | 'Qfxb7' | 'Qfxb8' |
        'Qfxc1' | 'Qfxc2' | 'Qfxc3' | 'Qfxc4' | 'Qfxc5' | 'Qfxc6' | 'Qfxc7' | 'Qfxc8' |
        'Qfxd1' | 'Qfxd2' | 'Qfxd3' | 'Qfxd4' | 'Qfxd5' | 'Qfxd6' | 'Qfxd7' | 'Qfxd8' |
        'Qfxe1' | 'Qfxe2' | 'Qfxe3' | 'Qfxe4' | 'Qfxe5' | 'Qfxe6' | 'Qfxe7' | 'Qfxe8' |
        'Qfxf1' | 'Qfxf2' | 'Qfxf3' | 'Qfxf4' | 'Qfxf5' | 'Qfxf6' | 'Qfxf7' | 'Qfxf8' |
        'Qfxg1' | 'Qfxg2' | 'Qfxg3' | 'Qfxg4' | 'Qfxg5' | 'Qfxg6' | 'Qfxg7' | 'Qfxg8' |
        'Qfxh1' | 'Qfxh2' | 'Qfxh3' | 'Qfxh4' | 'Qfxh5' | 'Qfxh6' | 'Qfxh7' | 'Qfxh8' | // 64

        'Qgxa1' | 'Qgxa2' | 'Qgxa3' | 'Qgxa4' | 'Qgxa5' | 'Qgxa6' | 'Qgxa7' | 'Qgxa8' |
        'Qgxb1' | 'Qgxb2' | 'Qgxb3' | 'Qgxb4' | 'Qgxb5' | 'Qgxb6' | 'Qgxb7' | 'Qgxb8' |
        'Qgxc1' | 'Qgxc2' | 'Qgxc3' | 'Qgxc4' | 'Qgxc5' | 'Qgxc6' | 'Qgxc7' | 'Qgxc8' |
        'Qgxd1' | 'Qgxd2' | 'Qgxd3' | 'Qgxd4' | 'Qgxd5' | 'Qgxd6' | 'Qgxd7' | 'Qgxd8' |
        'Qgxe1' | 'Qgxe2' | 'Qgxe3' | 'Qgxe4' | 'Qgxe5' | 'Qgxe6' | 'Qgxe7' | 'Qgxe8' |
        'Qgxf1' | 'Qgxf2' | 'Qgxf3' | 'Qgxf4' | 'Qgxf5' | 'Qgxf6' | 'Qgxf7' | 'Qgxf8' |
        'Qgxg1' | 'Qgxg2' | 'Qgxg3' | 'Qgxg4' | 'Qgxg5' | 'Qgxg6' | 'Qgxg7' | 'Qgxg8' |
        'Qgxh1' | 'Qgxh2' | 'Qgxh3' | 'Qgxh4' | 'Qgxh5' | 'Qgxh6' | 'Qgxh7' | 'Qgxh8' | // 64

        'Qhxa1' | 'Qhxa2' | 'Qhxa3' | 'Qhxa4' | 'Qhxa5' | 'Qhxa6' | 'Qhxa7' | 'Qhxa8' |
        'Qhxb1' | 'Qhxb2' | 'Qhxb3' | 'Qhxb4' | 'Qhxb5' | 'Qhxb6' | 'Qhxb7' | 'Qhxb8' |
        'Qhxc1' | 'Qhxc2' | 'Qhxc3' | 'Qhxc4' | 'Qhxc5' | 'Qhxc6' | 'Qhxc7' | 'Qhxc8' |
        'Qhxd1' | 'Qhxd2' | 'Qhxd3' | 'Qhxd4' | 'Qhxd5' | 'Qhxd6' | 'Qhxd7' | 'Qhxd8' |
        'Qhxe1' | 'Qhxe2' | 'Qhxe3' | 'Qhxe4' | 'Qhxe5' | 'Qhxe6' | 'Qhxe7' | 'Qhxe8' |
        'Qhxf1' | 'Qhxf2' | 'Qhxf3' | 'Qhxf4' | 'Qhxf5' | 'Qhxf6' | 'Qhxf7' | 'Qhxf8' |
        'Qhxg1' | 'Qhxg2' | 'Qhxg3' | 'Qhxg4' | 'Qhxg5' | 'Qhxg6' | 'Qhxg7' | 'Qhxg8' |
        'Qhxh1' | 'Qhxh2' | 'Qhxh3' | 'Qhxh4' | 'Qhxh5' | 'Qhxh6' | 'Qhxh7' | 'Qhxh8' | // 64

        'Qa1' | 'Qa2' | 'Qa3' | 'Qa4' | 'Qa5' | 'Qa6' | 'Qa7' | 'Qa8' |
        'Qb1' | 'Qb2' | 'Qb3' | 'Qb4' | 'Qb5' | 'Qb6' | 'Qb7' | 'Qb8' |
        'Qc1' | 'Qc2' | 'Qc3' | 'Qc4' | 'Qc5' | 'Qc6' | 'Qc7' | 'Qc8' |
        'Qd1' | 'Qd2' | 'Qd3' | 'Qd4' | 'Qd5' | 'Qd6' | 'Qd7' | 'Qd8' |
        'Qe1' | 'Qe2' | 'Qe3' | 'Qe4' | 'Qe5' | 'Qe6' | 'Qe7' | 'Qe8' |
        'Qf1' | 'Qf2' | 'Qf3' | 'Qf4' | 'Qf5' | 'Qf6' | 'Qf7' | 'Qf8' |
        'Qg1' | 'Qg2' | 'Qg3' | 'Qg4' | 'Qg5' | 'Qg6' | 'Qg7' | 'Qg8' |
        'Qh1' | 'Qh2' | 'Qh3' | 'Qh4' | 'Qh5' | 'Qh6' | 'Qh7' | 'Qh8' | // 64

        'Qxa1' | 'Qxa2' | 'Qxa3' | 'Qxa4' | 'Qxa5' | 'Qxa6' | 'Qxa7' | 'Qxa8' |
        'Qxb1' | 'Qxb2' | 'Qxb3' | 'Qxb4' | 'Qxb5' | 'Qxb6' | 'Qxb7' | 'Qxb8' |
        'Qxc1' | 'Qxc2' | 'Qxc3' | 'Qxc4' | 'Qxc5' | 'Qxc6' | 'Qxc7' | 'Qxc8' |
        'Qxd1' | 'Qxd2' | 'Qxd3' | 'Qxd4' | 'Qxd5' | 'Qxd6' | 'Qxd7' | 'Qxd8' |
        'Qxe1' | 'Qxe2' | 'Qxe3' | 'Qxe4' | 'Qxe5' | 'Qxe6' | 'Qxe7' | 'Qxe8' |
        'Qxf1' | 'Qxf2' | 'Qxf3' | 'Qxf4' | 'Qxf5' | 'Qxf6' | 'Qxf7' | 'Qxf8' |
        'Qxg1' | 'Qxg2' | 'Qxg3' | 'Qxg4' | 'Qxg5' | 'Qxg6' | 'Qxg7' | 'Qxg8' |
        'Qxh1' | 'Qxh2' | 'Qxh3' | 'Qxh4' | 'Qxh5' | 'Qxh6' | 'Qxh7' | 'Qxh8' ; // 64

KING_MOVE :
        'Kaa1' | 'Kaa2' | 'Kaa3' | 'Kaa4' | 'Kaa5' | 'Kaa6' | 'Kaa7' | 'Kaa8' |
        'Kab1' | 'Kab2' | 'Kab3' | 'Kab4' | 'Kab5' | 'Kab6' | 'Kab7' | 'Kab8' |
        'Kac1' | 'Kac2' | 'Kac3' | 'Kac4' | 'Kac5' | 'Kac6' | 'Kac7' | 'Kac8' |
        'Kad1' | 'Kad2' | 'Kad3' | 'Kad4' | 'Kad5' | 'Kad6' | 'Kad7' | 'Kad8' |
        'Kae1' | 'Kae2' | 'Kae3' | 'Kae4' | 'Kae5' | 'Kae6' | 'Kae7' | 'Kae8' |
        'Kaf1' | 'Kaf2' | 'Kaf3' | 'Kaf4' | 'Kaf5' | 'Kaf6' | 'Kaf7' | 'Kaf8' |
        'Kag1' | 'Kag2' | 'Kag3' | 'Kag4' | 'Kag5' | 'Kag6' | 'Kag7' | 'Kag8' |
        'Kah1' | 'Kah2' | 'Kah3' | 'Kah4' | 'Kah5' | 'Kah6' | 'Kah7' | 'Kah8' | // 64

        'Kba1' | 'Kba2' | 'Kba3' | 'Kba4' | 'Kba5' | 'Kba6' | 'Kba7' | 'Kba8' |
        'Kbb1' | 'Kbb2' | 'Kbb3' | 'Kbb4' | 'Kbb5' | 'Kbb6' | 'Kbb7' | 'Kbb8' |
        'Kbc1' | 'Kbc2' | 'Kbc3' | 'Kbc4' | 'Kbc5' | 'Kbc6' | 'Kbc7' | 'Kbc8' |
        'Kbd1' | 'Kbd2' | 'Kbd3' | 'Kbd4' | 'Kbd5' | 'Kbd6' | 'Kbd7' | 'Kbd8' |
        'Kbe1' | 'Kbe2' | 'Kbe3' | 'Kbe4' | 'Kbe5' | 'Kbe6' | 'Kbe7' | 'Kbe8' |
        'Kbf1' | 'Kbf2' | 'Kbf3' | 'Kbf4' | 'Kbf5' | 'Kbf6' | 'Kbf7' | 'Kbf8' |
        'Kbg1' | 'Kbg2' | 'Kbg3' | 'Kbg4' | 'Kbg5' | 'Kbg6' | 'Kbg7' | 'Kbg8' |
        'Kbh1' | 'Kbh2' | 'Kbh3' | 'Kbh4' | 'Kbh5' | 'Kbh6' | 'Kbh7' | 'Kbh8' | // 64

        'Kca1' | 'Kca2' | 'Kca3' | 'Kca4' | 'Kca5' | 'Kca6' | 'Kca7' | 'Kca8' |
        'Kcb1' | 'Kcb2' | 'Kcb3' | 'Kcb4' | 'Kcb5' | 'Kcb6' | 'Kcb7' | 'Kcb8' |
        'Kcc1' | 'Kcc2' | 'Kcc3' | 'Kcc4' | 'Kcc5' | 'Kcc6' | 'Kcc7' | 'Kcc8' |
        'Kcd1' | 'Kcd2' | 'Kcd3' | 'Kcd4' | 'Kcd5' | 'Kcd6' | 'Kcd7' | 'Kcd8' |
        'Kce1' | 'Kce2' | 'Kce3' | 'Kce4' | 'Kce5' | 'Kce6' | 'Kce7' | 'Kce8' |
        'Kcf1' | 'Kcf2' | 'Kcf3' | 'Kcf4' | 'Kcf5' | 'Kcf6' | 'Kcf7' | 'Kcf8' |
        'Kcg1' | 'Kcg2' | 'Kcg3' | 'Kcg4' | 'Kcg5' | 'Kcg6' | 'Kcg7' | 'Kcg8' |
        'Kch1' | 'Kch2' | 'Kch3' | 'Kch4' | 'Kch5' | 'Kch6' | 'Kch7' | 'Kch8' | // 64

        'Kda1' | 'Kda2' | 'Kda3' | 'Kda4' | 'Kda5' | 'Kda6' | 'Kda7' | 'Kda8' |
        'Kdb1' | 'Kdb2' | 'Kdb3' | 'Kdb4' | 'Kdb5' | 'Kdb6' | 'Kdb7' | 'Kdb8' |
        'Kdc1' | 'Kdc2' | 'Kdc3' | 'Kdc4' | 'Kdc5' | 'Kdc6' | 'Kdc7' | 'Kdc8' |
        'Kdd1' | 'Kdd2' | 'Kdd3' | 'Kdd4' | 'Kdd5' | 'Kdd6' | 'Kdd7' | 'Kdd8' |
        'Kde1' | 'Kde2' | 'Kde3' | 'Kde4' | 'Kde5' | 'Kde6' | 'Kde7' | 'Kde8' |
        'Kdf1' | 'Kdf2' | 'Kdf3' | 'Kdf4' | 'Kdf5' | 'Kdf6' | 'Kdf7' | 'Kdf8' |
        'Kdg1' | 'Kdg2' | 'Kdg3' | 'Kdg4' | 'Kdg5' | 'Kdg6' | 'Kdg7' | 'Kdg8' |
        'Kdh1' | 'Kdh2' | 'Kdh3' | 'Kdh4' | 'Kdh5' | 'Kdh6' | 'Kdh7' | 'Kdh8' | // 64

        'Kea1' | 'Kea2' | 'Kea3' | 'Kea4' | 'Kea5' | 'Kea6' | 'Kea7' | 'Kea8' |
        'Keb1' | 'Keb2' | 'Keb3' | 'Keb4' | 'Keb5' | 'Keb6' | 'Keb7' | 'Keb8' |
        'Kec1' | 'Kec2' | 'Kec3' | 'Kec4' | 'Kec5' | 'Kec6' | 'Kec7' | 'Kec8' |
        'Ked1' | 'Ked2' | 'Ked3' | 'Ked4' | 'Ked5' | 'Ked6' | 'Ked7' | 'Ked8' |
        'Kee1' | 'Kee2' | 'Kee3' | 'Kee4' | 'Kee5' | 'Kee6' | 'Kee7' | 'Kee8' |
        'Kef1' | 'Kef2' | 'Kef3' | 'Kef4' | 'Kef5' | 'Kef6' | 'Kef7' | 'Kef8' |
        'Keg1' | 'Keg2' | 'Keg3' | 'Keg4' | 'Keg5' | 'Keg6' | 'Keg7' | 'Keg8' |
        'Keh1' | 'Keh2' | 'Keh3' | 'Keh4' | 'Keh5' | 'Keh6' | 'Keh7' | 'Keh8' | // 64

        'Kfa1' | 'Kfa2' | 'Kfa3' | 'Kfa4' | 'Kfa5' | 'Kfa6' | 'Kfa7' | 'Kfa8' |
        'Kfb1' | 'Kfb2' | 'Kfb3' | 'Kfb4' | 'Kfb5' | 'Kfb6' | 'Kfb7' | 'Kfb8' |
        'Kfc1' | 'Kfc2' | 'Kfc3' | 'Kfc4' | 'Kfc5' | 'Kfc6' | 'Kfc7' | 'Kfc8' |
        'Kfd1' | 'Kfd2' | 'Kfd3' | 'Kfd4' | 'Kfd5' | 'Kfd6' | 'Kfd7' | 'Kfd8' |
        'Kfe1' | 'Kfe2' | 'Kfe3' | 'Kfe4' | 'Kfe5' | 'Kfe6' | 'Kfe7' | 'Kfe8' |
        'Kff1' | 'Kff2' | 'Kff3' | 'Kff4' | 'Kff5' | 'Kff6' | 'Kff7' | 'Kff8' |
        'Kfg1' | 'Kfg2' | 'Kfg3' | 'Kfg4' | 'Kfg5' | 'Kfg6' | 'Kfg7' | 'Kfg8' |
        'Kfh1' | 'Kfh2' | 'Kfh3' | 'Kfh4' | 'Kfh5' | 'Kfh6' | 'Kfh7' | 'Kfh8' | // 64

        'Kga1' | 'Kga2' | 'Kga3' | 'Kga4' | 'Kga5' | 'Kga6' | 'Kga7' | 'Kga8' |
        'Kgb1' | 'Kgb2' | 'Kgb3' | 'Kgb4' | 'Kgb5' | 'Kgb6' | 'Kgb7' | 'Kgb8' |
        'Kgc1' | 'Kgc2' | 'Kgc3' | 'Kgc4' | 'Kgc5' | 'Kgc6' | 'Kgc7' | 'Kgc8' |
        'Kgd1' | 'Kgd2' | 'Kgd3' | 'Kgd4' | 'Kgd5' | 'Kgd6' | 'Kgd7' | 'Kgd8' |
        'Kge1' | 'Kge2' | 'Kge3' | 'Kge4' | 'Kge5' | 'Kge6' | 'Kge7' | 'Kge8' |
        'Kgf1' | 'Kgf2' | 'Kgf3' | 'Kgf4' | 'Kgf5' | 'Kgf6' | 'Kgf7' | 'Kgf8' |
        'Kgg1' | 'Kgg2' | 'Kgg3' | 'Kgg4' | 'Kgg5' | 'Kgg6' | 'Kgg7' | 'Kgg8' |
        'Kgh1' | 'Kgh2' | 'Kgh3' | 'Kgh4' | 'Kgh5' | 'Kgh6' | 'Kgh7' | 'Kgh8' | // 64

        'Kha1' | 'Kha2' | 'Kha3' | 'Kha4' | 'Kha5' | 'Kha6' | 'Kha7' | 'Kha8' |
        'Khb1' | 'Khb2' | 'Khb3' | 'Khb4' | 'Khb5' | 'Khb6' | 'Khb7' | 'Khb8' |
        'Khc1' | 'Khc2' | 'Khc3' | 'Khc4' | 'Khc5' | 'Khc6' | 'Khc7' | 'Khc8' |
        'Khd1' | 'Khd2' | 'Khd3' | 'Khd4' | 'Khd5' | 'Khd6' | 'Khd7' | 'Khd8' |
        'Khe1' | 'Khe2' | 'Khe3' | 'Khe4' | 'Khe5' | 'Khe6' | 'Khe7' | 'Khe8' |
        'Khf1' | 'Khf2' | 'Khf3' | 'Khf4' | 'Khf5' | 'Khf6' | 'Khf7' | 'Khf8' |
        'Khg1' | 'Khg2' | 'Khg3' | 'Khg4' | 'Khg5' | 'Khg6' | 'Khg7' | 'Khg8' |
        'Khh1' | 'Khh2' | 'Khh3' | 'Khh4' | 'Khh5' | 'Khh6' | 'Khh7' | 'Khh8' | // 64

        'Kaxa1' | 'Kaxa2' | 'Kaxa3' | 'Kaxa4' | 'Kaxa5' | 'Kaxa6' | 'Kaxa7' | 'Kaxa8' |
        'Kaxb1' | 'Kaxb2' | 'Kaxb3' | 'Kaxb4' | 'Kaxb5' | 'Kaxb6' | 'Kaxb7' | 'Kaxb8' |
        'Kaxc1' | 'Kaxc2' | 'Kaxc3' | 'Kaxc4' | 'Kaxc5' | 'Kaxc6' | 'Kaxc7' | 'Kaxc8' |
        'Kaxd1' | 'Kaxd2' | 'Kaxd3' | 'Kaxd4' | 'Kaxd5' | 'Kaxd6' | 'Kaxd7' | 'Kaxd8' |
        'Kaxe1' | 'Kaxe2' | 'Kaxe3' | 'Kaxe4' | 'Kaxe5' | 'Kaxe6' | 'Kaxe7' | 'Kaxe8' |
        'Kaxf1' | 'Kaxf2' | 'Kaxf3' | 'Kaxf4' | 'Kaxf5' | 'Kaxf6' | 'Kaxf7' | 'Kaxf8' |
        'Kaxg1' | 'Kaxg2' | 'Kaxg3' | 'Kaxg4' | 'Kaxg5' | 'Kaxg6' | 'Kaxg7' | 'Kaxg8' |
        'Kaxh1' | 'Kaxh2' | 'Kaxh3' | 'Kaxh4' | 'Kaxh5' | 'Kaxh6' | 'Kaxh7' | 'Kaxh8' | // 64

        'Kbxa1' | 'Kbxa2' | 'Kbxa3' | 'Kbxa4' | 'Kbxa5' | 'Kbxa6' | 'Kbxa7' | 'Kbxa8' |
        'Kbxb1' | 'Kbxb2' | 'Kbxb3' | 'Kbxb4' | 'Kbxb5' | 'Kbxb6' | 'Kbxb7' | 'Kbxb8' |
        'Kbxc1' | 'Kbxc2' | 'Kbxc3' | 'Kbxc4' | 'Kbxc5' | 'Kbxc6' | 'Kbxc7' | 'Kbxc8' |
        'Kbxd1' | 'Kbxd2' | 'Kbxd3' | 'Kbxd4' | 'Kbxd5' | 'Kbxd6' | 'Kbxd7' | 'Kbxd8' |
        'Kbxe1' | 'Kbxe2' | 'Kbxe3' | 'Kbxe4' | 'Kbxe5' | 'Kbxe6' | 'Kbxe7' | 'Kbxe8' |
        'Kbxf1' | 'Kbxf2' | 'Kbxf3' | 'Kbxf4' | 'Kbxf5' | 'Kbxf6' | 'Kbxf7' | 'Kbxf8' |
        'Kbxg1' | 'Kbxg2' | 'Kbxg3' | 'Kbxg4' | 'Kbxg5' | 'Kbxg6' | 'Kbxg7' | 'Kbxg8' |
        'Kbxh1' | 'Kbxh2' | 'Kbxh3' | 'Kbxh4' | 'Kbxh5' | 'Kbxh6' | 'Kbxh7' | 'Kbxh8' | // 64

        'Kcxa1' | 'Kcxa2' | 'Kcxa3' | 'Kcxa4' | 'Kcxa5' | 'Kcxa6' | 'Kcxa7' | 'Kcxa8' |
        'Kcxb1' | 'Kcxb2' | 'Kcxb3' | 'Kcxb4' | 'Kcxb5' | 'Kcxb6' | 'Kcxb7' | 'Kcxb8' |
        'Kcxc1' | 'Kcxc2' | 'Kcxc3' | 'Kcxc4' | 'Kcxc5' | 'Kcxc6' | 'Kcxc7' | 'Kcxc8' |
        'Kcxd1' | 'Kcxd2' | 'Kcxd3' | 'Kcxd4' | 'Kcxd5' | 'Kcxd6' | 'Kcxd7' | 'Kcxd8' |
        'Kcxe1' | 'Kcxe2' | 'Kcxe3' | 'Kcxe4' | 'Kcxe5' | 'Kcxe6' | 'Kcxe7' | 'Kcxe8' |
        'Kcxf1' | 'Kcxf2' | 'Kcxf3' | 'Kcxf4' | 'Kcxf5' | 'Kcxf6' | 'Kcxf7' | 'Kcxf8' |
        'Kcxg1' | 'Kcxg2' | 'Kcxg3' | 'Kcxg4' | 'Kcxg5' | 'Kcxg6' | 'Kcxg7' | 'Kcxg8' |
        'Kcxh1' | 'Kcxh2' | 'Kcxh3' | 'Kcxh4' | 'Kcxh5' | 'Kcxh6' | 'Kcxh7' | 'Kcxh8' | // 64

        'Kdxa1' | 'Kdxa2' | 'Kdxa3' | 'Kdxa4' | 'Kdxa5' | 'Kdxa6' | 'Kdxa7' | 'Kdxa8' |
        'Kdxb1' | 'Kdxb2' | 'Kdxb3' | 'Kdxb4' | 'Kdxb5' | 'Kdxb6' | 'Kdxb7' | 'Kdxb8' |
        'Kdxc1' | 'Kdxc2' | 'Kdxc3' | 'Kdxc4' | 'Kdxc5' | 'Kdxc6' | 'Kdxc7' | 'Kdxc8' |
        'Kdxd1' | 'Kdxd2' | 'Kdxd3' | 'Kdxd4' | 'Kdxd5' | 'Kdxd6' | 'Kdxd7' | 'Kdxd8' |
        'Kdxe1' | 'Kdxe2' | 'Kdxe3' | 'Kdxe4' | 'Kdxe5' | 'Kdxe6' | 'Kdxe7' | 'Kdxe8' |
        'Kdxf1' | 'Kdxf2' | 'Kdxf3' | 'Kdxf4' | 'Kdxf5' | 'Kdxf6' | 'Kdxf7' | 'Kdxf8' |
        'Kdxg1' | 'Kdxg2' | 'Kdxg3' | 'Kdxg4' | 'Kdxg5' | 'Kdxg6' | 'Kdxg7' | 'Kdxg8' |
        'Kdxh1' | 'Kdxh2' | 'Kdxh3' | 'Kdxh4' | 'Kdxh5' | 'Kdxh6' | 'Kdxh7' | 'Kdxh8' | // 64

        'Kexa1' | 'Kexa2' | 'Kexa3' | 'Kexa4' | 'Kexa5' | 'Kexa6' | 'Kexa7' | 'Kexa8' |
        'Kexb1' | 'Kexb2' | 'Kexb3' | 'Kexb4' | 'Kexb5' | 'Kexb6' | 'Kexb7' | 'Kexb8' |
        'Kexc1' | 'Kexc2' | 'Kexc3' | 'Kexc4' | 'Kexc5' | 'Kexc6' | 'Kexc7' | 'Kexc8' |
        'Kexd1' | 'Kexd2' | 'Kexd3' | 'Kexd4' | 'Kexd5' | 'Kexd6' | 'Kexd7' | 'Kexd8' |
        'Kexe1' | 'Kexe2' | 'Kexe3' | 'Kexe4' | 'Kexe5' | 'Kexe6' | 'Kexe7' | 'Kexe8' |
        'Kexf1' | 'Kexf2' | 'Kexf3' | 'Kexf4' | 'Kexf5' | 'Kexf6' | 'Kexf7' | 'Kexf8' |
        'Kexg1' | 'Kexg2' | 'Kexg3' | 'Kexg4' | 'Kexg5' | 'Kexg6' | 'Kexg7' | 'Kexg8' |
        'Kexh1' | 'Kexh2' | 'Kexh3' | 'Kexh4' | 'Kexh5' | 'Kexh6' | 'Kexh7' | 'Kexh8' | // 64

        'Kfxa1' | 'Kfxa2' | 'Kfxa3' | 'Kfxa4' | 'Kfxa5' | 'Kfxa6' | 'Kfxa7' | 'Kfxa8' |
        'Kfxb1' | 'Kfxb2' | 'Kfxb3' | 'Kfxb4' | 'Kfxb5' | 'Kfxb6' | 'Kfxb7' | 'Kfxb8' |
        'Kfxc1' | 'Kfxc2' | 'Kfxc3' | 'Kfxc4' | 'Kfxc5' | 'Kfxc6' | 'Kfxc7' | 'Kfxc8' |
        'Kfxd1' | 'Kfxd2' | 'Kfxd3' | 'Kfxd4' | 'Kfxd5' | 'Kfxd6' | 'Kfxd7' | 'Kfxd8' |
        'Kfxe1' | 'Kfxe2' | 'Kfxe3' | 'Kfxe4' | 'Kfxe5' | 'Kfxe6' | 'Kfxe7' | 'Kfxe8' |
        'Kfxf1' | 'Kfxf2' | 'Kfxf3' | 'Kfxf4' | 'Kfxf5' | 'Kfxf6' | 'Kfxf7' | 'Kfxf8' |
        'Kfxg1' | 'Kfxg2' | 'Kfxg3' | 'Kfxg4' | 'Kfxg5' | 'Kfxg6' | 'Kfxg7' | 'Kfxg8' |
        'Kfxh1' | 'Kfxh2' | 'Kfxh3' | 'Kfxh4' | 'Kfxh5' | 'Kfxh6' | 'Kfxh7' | 'Kfxh8' | // 64

        'Kgxa1' | 'Kgxa2' | 'Kgxa3' | 'Kgxa4' | 'Kgxa5' | 'Kgxa6' | 'Kgxa7' | 'Kgxa8' |
        'Kgxb1' | 'Kgxb2' | 'Kgxb3' | 'Kgxb4' | 'Kgxb5' | 'Kgxb6' | 'Kgxb7' | 'Kgxb8' |
        'Kgxc1' | 'Kgxc2' | 'Kgxc3' | 'Kgxc4' | 'Kgxc5' | 'Kgxc6' | 'Kgxc7' | 'Kgxc8' |
        'Kgxd1' | 'Kgxd2' | 'Kgxd3' | 'Kgxd4' | 'Kgxd5' | 'Kgxd6' | 'Kgxd7' | 'Kgxd8' |
        'Kgxe1' | 'Kgxe2' | 'Kgxe3' | 'Kgxe4' | 'Kgxe5' | 'Kgxe6' | 'Kgxe7' | 'Kgxe8' |
        'Kgxf1' | 'Kgxf2' | 'Kgxf3' | 'Kgxf4' | 'Kgxf5' | 'Kgxf6' | 'Kgxf7' | 'Kgxf8' |
        'Kgxg1' | 'Kgxg2' | 'Kgxg3' | 'Kgxg4' | 'Kgxg5' | 'Kgxg6' | 'Kgxg7' | 'Kgxg8' |
        'Kgxh1' | 'Kgxh2' | 'Kgxh3' | 'Kgxh4' | 'Kgxh5' | 'Kgxh6' | 'Kgxh7' | 'Kgxh8' | // 64

        'Khxa1' | 'Khxa2' | 'Khxa3' | 'Khxa4' | 'Khxa5' | 'Khxa6' | 'Khxa7' | 'Khxa8' |
        'Khxb1' | 'Khxb2' | 'Khxb3' | 'Khxb4' | 'Khxb5' | 'Khxb6' | 'Khxb7' | 'Khxb8' |
        'Khxc1' | 'Khxc2' | 'Khxc3' | 'Khxc4' | 'Khxc5' | 'Khxc6' | 'Khxc7' | 'Khxc8' |
        'Khxd1' | 'Khxd2' | 'Khxd3' | 'Khxd4' | 'Khxd5' | 'Khxd6' | 'Khxd7' | 'Khxd8' |
        'Khxe1' | 'Khxe2' | 'Khxe3' | 'Khxe4' | 'Khxe5' | 'Khxe6' | 'Khxe7' | 'Khxe8' |
        'Khxf1' | 'Khxf2' | 'Khxf3' | 'Khxf4' | 'Khxf5' | 'Khxf6' | 'Khxf7' | 'Khxf8' |
        'Khxg1' | 'Khxg2' | 'Khxg3' | 'Khxg4' | 'Khxg5' | 'Khxg6' | 'Khxg7' | 'Khxg8' |
        'Khxh1' | 'Khxh2' | 'Khxh3' | 'Khxh4' | 'Khxh5' | 'Khxh6' | 'Khxh7' | 'Khxh8' | // 64

        'Ka1' | 'Ka2' | 'Ka3' | 'Ka4' | 'Ka5' | 'Ka6' | 'Ka7' | 'Ka8' |
        'Kb1' | 'Kb2' | 'Kb3' | 'Kb4' | 'Kb5' | 'Kb6' | 'Kb7' | 'Kb8' |
        'Kc1' | 'Kc2' | 'Kc3' | 'Kc4' | 'Kc5' | 'Kc6' | 'Kc7' | 'Kc8' |
        'Kd1' | 'Kd2' | 'Kd3' | 'Kd4' | 'Kd5' | 'Kd6' | 'Kd7' | 'Kd8' |
        'Ke1' | 'Ke2' | 'Ke3' | 'Ke4' | 'Ke5' | 'Ke6' | 'Ke7' | 'Ke8' |
        'Kf1' | 'Kf2' | 'Kf3' | 'Kf4' | 'Kf5' | 'Kf6' | 'Kf7' | 'Kf8' |
        'Kg1' | 'Kg2' | 'Kg3' | 'Kg4' | 'Kg5' | 'Kg6' | 'Kg7' | 'Kg8' |
        'Kh1' | 'Kh2' | 'Kh3' | 'Kh4' | 'Kh5' | 'Kh6' | 'Kh7' | 'Kh8' | // 64

        'Kxa1' | 'Kxa2' | 'Kxa3' | 'Kxa4' | 'Kxa5' | 'Kxa6' | 'Kxa7' | 'Kxa8' |
        'Kxb1' | 'Kxb2' | 'Kxb3' | 'Kxb4' | 'Kxb5' | 'Kxb6' | 'Kxb7' | 'Kxb8' |
        'Kxc1' | 'Kxc2' | 'Kxc3' | 'Kxc4' | 'Kxc5' | 'Kxc6' | 'Kxc7' | 'Kxc8' |
        'Kxd1' | 'Kxd2' | 'Kxd3' | 'Kxd4' | 'Kxd5' | 'Kxd6' | 'Kxd7' | 'Kxd8' |
        'Kxe1' | 'Kxe2' | 'Kxe3' | 'Kxe4' | 'Kxe5' | 'Kxe6' | 'Kxe7' | 'Kxe8' |
        'Kxf1' | 'Kxf2' | 'Kxf3' | 'Kxf4' | 'Kxf5' | 'Kxf6' | 'Kxf7' | 'Kxf8' |
        'Kxg1' | 'Kxg2' | 'Kxg3' | 'Kxg4' | 'Kxg5' | 'Kxg6' | 'Kxg7' | 'Kxg8' |
        'Kxh1' | 'Kxh2' | 'Kxh3' | 'Kxh4' | 'Kxh5' | 'Kxh6' | 'Kxh7' | 'Kxh8' ; // 64

ROOK_MOVE :
        'R1a1' | 'R2a1' | 'R3a1' | 'R4a1' | 'R5a1' | 'R6a1' | 'R7a1' | 'R8a1' |
        'R1a2' | 'R2a2' | 'R3a2' | 'R4a2' | 'R5a2' | 'R6a2' | 'R7a2' | 'R8a2' |
        'R1a3' | 'R2a3' | 'R3a3' | 'R4a3' | 'R5a3' | 'R6a3' | 'R7a3' | 'R8a3' |
        'R1a4' | 'R2a4' | 'R3a4' | 'R4a4' | 'R5a4' | 'R6a4' | 'R7a4' | 'R8a4' |
        'R1a5' | 'R2a5' | 'R3a5' | 'R4a5' | 'R5a5' | 'R6a5' | 'R7a5' | 'R8a5' |
        'R1a6' | 'R2a6' | 'R3a6' | 'R4a6' | 'R5a6' | 'R6a6' | 'R7a6' | 'R8a6' |
        'R1a7' | 'R2a7' | 'R3a7' | 'R4a7' | 'R5a7' | 'R6a7' | 'R7a7' | 'R8a7' |
        'R1a8' | 'R2a8' | 'R3a8' | 'R4a8' | 'R5a8' | 'R6a8' | 'R7a8' | 'R8a8' | // 64
        'R1b1' | 'R2b1' | 'R3b1' | 'R4b1' | 'R5b1' | 'R6b1' | 'R7b1' | 'R8b1' |
        'R1b2' | 'R2b2' | 'R3b2' | 'R4b2' | 'R5b2' | 'R6b2' | 'R7b2' | 'R8b2' |
        'R1b3' | 'R2b3' | 'R3b3' | 'R4b3' | 'R5b3' | 'R6b3' | 'R7b3' | 'R8b3' |
        'R1b4' | 'R2b4' | 'R3b4' | 'R4b4' | 'R5b4' | 'R6b4' | 'R7b4' | 'R8b4' |
        'R1b5' | 'R2b5' | 'R3b5' | 'R4b5' | 'R5b5' | 'R6b5' | 'R7b5' | 'R8b5' |
        'R1b6' | 'R2b6' | 'R3b6' | 'R4b6' | 'R5b6' | 'R6b6' | 'R7b6' | 'R8b6' |
        'R1b7' | 'R2b7' | 'R3b7' | 'R4b7' | 'R5b7' | 'R6b7' | 'R7b7' | 'R8b7' |
        'R1b8' | 'R2b8' | 'R3b8' | 'R4b8' | 'R5b8' | 'R6b8' | 'R7b8' | 'R8b8' | // 64
        'R1c1' | 'R2c1' | 'R3c1' | 'R4c1' | 'R5c1' | 'R6c1' | 'R7c1' | 'R8c1' |
        'R1c2' | 'R2c2' | 'R3c2' | 'R4c2' | 'R5c2' | 'R6c2' | 'R7c2' | 'R8c2' |
        'R1c3' | 'R2c3' | 'R3c3' | 'R4c3' | 'R5c3' | 'R6c3' | 'R7c3' | 'R8c3' |
        'R1c4' | 'R2c4' | 'R3c4' | 'R4c4' | 'R5c4' | 'R6c4' | 'R7c4' | 'R8c4' |
        'R1c5' | 'R2c5' | 'R3c5' | 'R4c5' | 'R5c5' | 'R6c5' | 'R7c5' | 'R8c5' |
        'R1c6' | 'R2c6' | 'R3c6' | 'R4c6' | 'R5c6' | 'R6c6' | 'R7c6' | 'R8c6' |
        'R1c7' | 'R2c7' | 'R3c7' | 'R4c7' | 'R5c7' | 'R6c7' | 'R7c7' | 'R8c7' |
        'R1c8' | 'R2c8' | 'R3c8' | 'R4c8' | 'R5c8' | 'R6c8' | 'R7c8' | 'R8c8' | // 64
        'R1d1' | 'R2d1' | 'R3d1' | 'R4d1' | 'R5d1' | 'R6d1' | 'R7d1' | 'R8d1' |
        'R1d2' | 'R2d2' | 'R3d2' | 'R4d2' | 'R5d2' | 'R6d2' | 'R7d2' | 'R8d2' |
        'R1d3' | 'R2d3' | 'R3d3' | 'R4d3' | 'R5d3' | 'R6d3' | 'R7d3' | 'R8d3' |
        'R1d4' | 'R2d4' | 'R3d4' | 'R4d4' | 'R5d4' | 'R6d4' | 'R7d4' | 'R8d4' |
        'R1d5' | 'R2d5' | 'R3d5' | 'R4d5' | 'R5d5' | 'R6d5' | 'R7d5' | 'R8d5' |
        'R1d6' | 'R2d6' | 'R3d6' | 'R4d6' | 'R5d6' | 'R6d6' | 'R7d6' | 'R8d6' |
        'R1d7' | 'R2d7' | 'R3d7' | 'R4d7' | 'R5d7' | 'R6d7' | 'R7d7' | 'R8d7' |
        'R1d8' | 'R2d8' | 'R3d8' | 'R4d8' | 'R5d8' | 'R6d8' | 'R7d8' | 'R8d8' | // 64
        'R1e1' | 'R2e1' | 'R3e1' | 'R4e1' | 'R5e1' | 'R6e1' | 'R7e1' | 'R8e1' |
        'R1e2' | 'R2e2' | 'R3e2' | 'R4e2' | 'R5e2' | 'R6e2' | 'R7e2' | 'R8e2' |
        'R1e3' | 'R2e3' | 'R3e3' | 'R4e3' | 'R5e3' | 'R6e3' | 'R7e3' | 'R8e3' |
        'R1e4' | 'R2e4' | 'R3e4' | 'R4e4' | 'R5e4' | 'R6e4' | 'R7e4' | 'R8e4' |
        'R1e5' | 'R2e5' | 'R3e5' | 'R4e5' | 'R5e5' | 'R6e5' | 'R7e5' | 'R8e5' |
        'R1e6' | 'R2e6' | 'R3e6' | 'R4e6' | 'R5e6' | 'R6e6' | 'R7e6' | 'R8e6' |
        'R1e7' | 'R2e7' | 'R3e7' | 'R4e7' | 'R5e7' | 'R6e7' | 'R7e7' | 'R8e7' |
        'R1e8' | 'R2e8' | 'R3e8' | 'R4e8' | 'R5e8' | 'R6e8' | 'R7e8' | 'R8e8' | // 64
        'R1f1' | 'R2f1' | 'R3f1' | 'R4f1' | 'R5f1' | 'R6f1' | 'R7f1' | 'R8f1' |
        'R1f2' | 'R2f2' | 'R3f2' | 'R4f2' | 'R5f2' | 'R6f2' | 'R7f2' | 'R8f2' |
        'R1f3' | 'R2f3' | 'R3f3' | 'R4f3' | 'R5f3' | 'R6f3' | 'R7f3' | 'R8f3' |
        'R1f4' | 'R2f4' | 'R3f4' | 'R4f4' | 'R5f4' | 'R6f4' | 'R7f4' | 'R8f4' |
        'R1f5' | 'R2f5' | 'R3f5' | 'R4f5' | 'R5f5' | 'R6f5' | 'R7f5' | 'R8f5' |
        'R1f6' | 'R2f6' | 'R3f6' | 'R4f6' | 'R5f6' | 'R6f6' | 'R7f6' | 'R8f6' |
        'R1f7' | 'R2f7' | 'R3f7' | 'R4f7' | 'R5f7' | 'R6f7' | 'R7f7' | 'R8f7' |
        'R1f8' | 'R2f8' | 'R3f8' | 'R4f8' | 'R5f8' | 'R6f8' | 'R7f8' | 'R8f8' | // 64
        'R1g1' | 'R2g1' | 'R3g1' | 'R4g1' | 'R5g1' | 'R6g1' | 'R7g1' | 'R8g1' |
        'R1g2' | 'R2g2' | 'R3g2' | 'R4g2' | 'R5g2' | 'R6g2' | 'R7g2' | 'R8g2' |
        'R1g3' | 'R2g3' | 'R3g3' | 'R4g3' | 'R5g3' | 'R6g3' | 'R7g3' | 'R8g3' |
        'R1g4' | 'R2g4' | 'R3g4' | 'R4g4' | 'R5g4' | 'R6g4' | 'R7g4' | 'R8g4' |
        'R1g5' | 'R2g5' | 'R3g5' | 'R4g5' | 'R5g5' | 'R6g5' | 'R7g5' | 'R8g5' |
        'R1g6' | 'R2g6' | 'R3g6' | 'R4g6' | 'R5g6' | 'R6g6' | 'R7g6' | 'R8g6' |
        'R1g7' | 'R2g7' | 'R3g7' | 'R4g7' | 'R5g7' | 'R6g7' | 'R7g7' | 'R8g7' |
        'R1g8' | 'R2g8' | 'R3g8' | 'R4g8' | 'R5g8' | 'R6g8' | 'R7g8' | 'R8g8' | // 64
        'R1h1' | 'R2h1' | 'R3h1' | 'R4h1' | 'R5h1' | 'R6h1' | 'R7h1' | 'R8h1' |
        'R1h2' | 'R2h2' | 'R3h2' | 'R4h2' | 'R5h2' | 'R6h2' | 'R7h2' | 'R8h2' |
        'R1h3' | 'R2h3' | 'R3h3' | 'R4h3' | 'R5h3' | 'R6h3' | 'R7h3' | 'R8h3' |
        'R1h4' | 'R2h4' | 'R3h4' | 'R4h4' | 'R5h4' | 'R6h4' | 'R7h4' | 'R8h4' |
        'R1h5' | 'R2h5' | 'R3h5' | 'R4h5' | 'R5h5' | 'R6h5' | 'R7h5' | 'R8h5' |
        'R1h6' | 'R2h6' | 'R3h6' | 'R4h6' | 'R5h6' | 'R6h6' | 'R7h6' | 'R8h6' |
        'R1h7' | 'R2h7' | 'R3h7' | 'R4h7' | 'R5h7' | 'R6h7' | 'R7h7' | 'R8h7' |
        'R1h8' | 'R2h8' | 'R3h8' | 'R4h8' | 'R5h8' | 'R6h8' | 'R7h8' | 'R8h8' | // 64

        'Raa1' | 'Raa2' | 'Raa3' | 'Raa4' | 'Raa5' | 'Raa6' | 'Raa7' | 'Raa8' |
        'Rab1' | 'Rab2' | 'Rab3' | 'Rab4' | 'Rab5' | 'Rab6' | 'Rab7' | 'Rab8' |
        'Rac1' | 'Rac2' | 'Rac3' | 'Rac4' | 'Rac5' | 'Rac6' | 'Rac7' | 'Rac8' |
        'Rad1' | 'Rad2' | 'Rad3' | 'Rad4' | 'Rad5' | 'Rad6' | 'Rad7' | 'Rad8' |
        'Rae1' | 'Rae2' | 'Rae3' | 'Rae4' | 'Rae5' | 'Rae6' | 'Rae7' | 'Rae8' |
        'Raf1' | 'Raf2' | 'Raf3' | 'Raf4' | 'Raf5' | 'Raf6' | 'Raf7' | 'Raf8' |
        'Rag1' | 'Rag2' | 'Rag3' | 'Rag4' | 'Rag5' | 'Rag6' | 'Rag7' | 'Rag8' |
        'Rah1' | 'Rah2' | 'Rah3' | 'Rah4' | 'Rah5' | 'Rah6' | 'Rah7' | 'Rah8' | // 64

        'Rba1' | 'Rba2' | 'Rba3' | 'Rba4' | 'Rba5' | 'Rba6' | 'Rba7' | 'Rba8' |
        'Rbb1' | 'Rbb2' | 'Rbb3' | 'Rbb4' | 'Rbb5' | 'Rbb6' | 'Rbb7' | 'Rbb8' |
        'Rbc1' | 'Rbc2' | 'Rbc3' | 'Rbc4' | 'Rbc5' | 'Rbc6' | 'Rbc7' | 'Rbc8' |
        'Rbd1' | 'Rbd2' | 'Rbd3' | 'Rbd4' | 'Rbd5' | 'Rbd6' | 'Rbd7' | 'Rbd8' |
        'Rbe1' | 'Rbe2' | 'Rbe3' | 'Rbe4' | 'Rbe5' | 'Rbe6' | 'Rbe7' | 'Rbe8' |
        'Rbf1' | 'Rbf2' | 'Rbf3' | 'Rbf4' | 'Rbf5' | 'Rbf6' | 'Rbf7' | 'Rbf8' |
        'Rbg1' | 'Rbg2' | 'Rbg3' | 'Rbg4' | 'Rbg5' | 'Rbg6' | 'Rbg7' | 'Rbg8' |
        'Rbh1' | 'Rbh2' | 'Rbh3' | 'Rbh4' | 'Rbh5' | 'Rbh6' | 'Rbh7' | 'Rbh8' | // 64

        'Rca1' | 'Rca2' | 'Rca3' | 'Rca4' | 'Rca5' | 'Rca6' | 'Rca7' | 'Rca8' |
        'Rcb1' | 'Rcb2' | 'Rcb3' | 'Rcb4' | 'Rcb5' | 'Rcb6' | 'Rcb7' | 'Rcb8' |
        'Rcc1' | 'Rcc2' | 'Rcc3' | 'Rcc4' | 'Rcc5' | 'Rcc6' | 'Rcc7' | 'Rcc8' |
        'Rcd1' | 'Rcd2' | 'Rcd3' | 'Rcd4' | 'Rcd5' | 'Rcd6' | 'Rcd7' | 'Rcd8' |
        'Rce1' | 'Rce2' | 'Rce3' | 'Rce4' | 'Rce5' | 'Rce6' | 'Rce7' | 'Rce8' |
        'Rcf1' | 'Rcf2' | 'Rcf3' | 'Rcf4' | 'Rcf5' | 'Rcf6' | 'Rcf7' | 'Rcf8' |
        'Rcg1' | 'Rcg2' | 'Rcg3' | 'Rcg4' | 'Rcg5' | 'Rcg6' | 'Rcg7' | 'Rcg8' |
        'Rch1' | 'Rch2' | 'Rch3' | 'Rch4' | 'Rch5' | 'Rch6' | 'Rch7' | 'Rch8' | // 64

        'Rda1' | 'Rda2' | 'Rda3' | 'Rda4' | 'Rda5' | 'Rda6' | 'Rda7' | 'Rda8' |
        'Rdb1' | 'Rdb2' | 'Rdb3' | 'Rdb4' | 'Rdb5' | 'Rdb6' | 'Rdb7' | 'Rdb8' |
        'Rdc1' | 'Rdc2' | 'Rdc3' | 'Rdc4' | 'Rdc5' | 'Rdc6' | 'Rdc7' | 'Rdc8' |
        'Rdd1' | 'Rdd2' | 'Rdd3' | 'Rdd4' | 'Rdd5' | 'Rdd6' | 'Rdd7' | 'Rdd8' |
        'Rde1' | 'Rde2' | 'Rde3' | 'Rde4' | 'Rde5' | 'Rde6' | 'Rde7' | 'Rde8' |
        'Rdf1' | 'Rdf2' | 'Rdf3' | 'Rdf4' | 'Rdf5' | 'Rdf6' | 'Rdf7' | 'Rdf8' |
        'Rdg1' | 'Rdg2' | 'Rdg3' | 'Rdg4' | 'Rdg5' | 'Rdg6' | 'Rdg7' | 'Rdg8' |
        'Rdh1' | 'Rdh2' | 'Rdh3' | 'Rdh4' | 'Rdh5' | 'Rdh6' | 'Rdh7' | 'Rdh8' | // 64

        'Rea1' | 'Rea2' | 'Rea3' | 'Rea4' | 'Rea5' | 'Rea6' | 'Rea7' | 'Rea8' |
        'Reb1' | 'Reb2' | 'Reb3' | 'Reb4' | 'Reb5' | 'Reb6' | 'Reb7' | 'Reb8' |
        'Rec1' | 'Rec2' | 'Rec3' | 'Rec4' | 'Rec5' | 'Rec6' | 'Rec7' | 'Rec8' |
        'Red1' | 'Red2' | 'Red3' | 'Red4' | 'Red5' | 'Red6' | 'Red7' | 'Red8' |
        'Ree1' | 'Ree2' | 'Ree3' | 'Ree4' | 'Ree5' | 'Ree6' | 'Ree7' | 'Ree8' |
        'Ref1' | 'Ref2' | 'Ref3' | 'Ref4' | 'Ref5' | 'Ref6' | 'Ref7' | 'Ref8' |
        'Reg1' | 'Reg2' | 'Reg3' | 'Reg4' | 'Reg5' | 'Reg6' | 'Reg7' | 'Reg8' |
        'Reh1' | 'Reh2' | 'Reh3' | 'Reh4' | 'Reh5' | 'Reh6' | 'Reh7' | 'Reh8' | // 64

        'Rfa1' | 'Rfa2' | 'Rfa3' | 'Rfa4' | 'Rfa5' | 'Rfa6' | 'Rfa7' | 'Rfa8' |
        'Rfb1' | 'Rfb2' | 'Rfb3' | 'Rfb4' | 'Rfb5' | 'Rfb6' | 'Rfb7' | 'Rfb8' |
        'Rfc1' | 'Rfc2' | 'Rfc3' | 'Rfc4' | 'Rfc5' | 'Rfc6' | 'Rfc7' | 'Rfc8' |
        'Rfd1' | 'Rfd2' | 'Rfd3' | 'Rfd4' | 'Rfd5' | 'Rfd6' | 'Rfd7' | 'Rfd8' |
        'Rfe1' | 'Rfe2' | 'Rfe3' | 'Rfe4' | 'Rfe5' | 'Rfe6' | 'Rfe7' | 'Rfe8' |
        'Rff1' | 'Rff2' | 'Rff3' | 'Rff4' | 'Rff5' | 'Rff6' | 'Rff7' | 'Rff8' |
        'Rfg1' | 'Rfg2' | 'Rfg3' | 'Rfg4' | 'Rfg5' | 'Rfg6' | 'Rfg7' | 'Rfg8' |
        'Rfh1' | 'Rfh2' | 'Rfh3' | 'Rfh4' | 'Rfh5' | 'Rfh6' | 'Rfh7' | 'Rfh8' | // 64

        'Rga1' | 'Rga2' | 'Rga3' | 'Rga4' | 'Rga5' | 'Rga6' | 'Rga7' | 'Rga8' |
        'Rgb1' | 'Rgb2' | 'Rgb3' | 'Rgb4' | 'Rgb5' | 'Rgb6' | 'Rgb7' | 'Rgb8' |
        'Rgc1' | 'Rgc2' | 'Rgc3' | 'Rgc4' | 'Rgc5' | 'Rgc6' | 'Rgc7' | 'Rgc8' |
        'Rgd1' | 'Rgd2' | 'Rgd3' | 'Rgd4' | 'Rgd5' | 'Rgd6' | 'Rgd7' | 'Rgd8' |
        'Rge1' | 'Rge2' | 'Rge3' | 'Rge4' | 'Rge5' | 'Rge6' | 'Rge7' | 'Rge8' |
        'Rgf1' | 'Rgf2' | 'Rgf3' | 'Rgf4' | 'Rgf5' | 'Rgf6' | 'Rgf7' | 'Rgf8' |
        'Rgg1' | 'Rgg2' | 'Rgg3' | 'Rgg4' | 'Rgg5' | 'Rgg6' | 'Rgg7' | 'Rgg8' |
        'Rgh1' | 'Rgh2' | 'Rgh3' | 'Rgh4' | 'Rgh5' | 'Rgh6' | 'Rgh7' | 'Rgh8' | // 64

        'Rha1' | 'Rha2' | 'Rha3' | 'Rha4' | 'Rha5' | 'Rha6' | 'Rha7' | 'Rha8' |
        'Rhb1' | 'Rhb2' | 'Rhb3' | 'Rhb4' | 'Rhb5' | 'Rhb6' | 'Rhb7' | 'Rhb8' |
        'Rhc1' | 'Rhc2' | 'Rhc3' | 'Rhc4' | 'Rhc5' | 'Rhc6' | 'Rhc7' | 'Rhc8' |
        'Rhd1' | 'Rhd2' | 'Rhd3' | 'Rhd4' | 'Rhd5' | 'Rhd6' | 'Rhd7' | 'Rhd8' |
        'Rhe1' | 'Rhe2' | 'Rhe3' | 'Rhe4' | 'Rhe5' | 'Rhe6' | 'Rhe7' | 'Rhe8' |
        'Rhf1' | 'Rhf2' | 'Rhf3' | 'Rhf4' | 'Rhf5' | 'Rhf6' | 'Rhf7' | 'Rhf8' |
        'Rhg1' | 'Rhg2' | 'Rhg3' | 'Rhg4' | 'Rhg5' | 'Rhg6' | 'Rhg7' | 'Rhg8' |
        'Rhh1' | 'Rhh2' | 'Rhh3' | 'Rhh4' | 'Rhh5' | 'Rhh6' | 'Rhh7' | 'Rhh8' | // 64

        'Raxa1' | 'Raxa2' | 'Raxa3' | 'Raxa4' | 'Raxa5' | 'Raxa6' | 'Raxa7' | 'Raxa8' |
        'Raxb1' | 'Raxb2' | 'Raxb3' | 'Raxb4' | 'Raxb5' | 'Raxb6' | 'Raxb7' | 'Raxb8' |
        'Raxc1' | 'Raxc2' | 'Raxc3' | 'Raxc4' | 'Raxc5' | 'Raxc6' | 'Raxc7' | 'Raxc8' |
        'Raxd1' | 'Raxd2' | 'Raxd3' | 'Raxd4' | 'Raxd5' | 'Raxd6' | 'Raxd7' | 'Raxd8' |
        'Raxe1' | 'Raxe2' | 'Raxe3' | 'Raxe4' | 'Raxe5' | 'Raxe6' | 'Raxe7' | 'Raxe8' |
        'Raxf1' | 'Raxf2' | 'Raxf3' | 'Raxf4' | 'Raxf5' | 'Raxf6' | 'Raxf7' | 'Raxf8' |
        'Raxg1' | 'Raxg2' | 'Raxg3' | 'Raxg4' | 'Raxg5' | 'Raxg6' | 'Raxg7' | 'Raxg8' |
        'Raxh1' | 'Raxh2' | 'Raxh3' | 'Raxh4' | 'Raxh5' | 'Raxh6' | 'Raxh7' | 'Raxh8' | // 64

        'Rbxa1' | 'Rbxa2' | 'Rbxa3' | 'Rbxa4' | 'Rbxa5' | 'Rbxa6' | 'Rbxa7' | 'Rbxa8' |
        'Rbxb1' | 'Rbxb2' | 'Rbxb3' | 'Rbxb4' | 'Rbxb5' | 'Rbxb6' | 'Rbxb7' | 'Rbxb8' |
        'Rbxc1' | 'Rbxc2' | 'Rbxc3' | 'Rbxc4' | 'Rbxc5' | 'Rbxc6' | 'Rbxc7' | 'Rbxc8' |
        'Rbxd1' | 'Rbxd2' | 'Rbxd3' | 'Rbxd4' | 'Rbxd5' | 'Rbxd6' | 'Rbxd7' | 'Rbxd8' |
        'Rbxe1' | 'Rbxe2' | 'Rbxe3' | 'Rbxe4' | 'Rbxe5' | 'Rbxe6' | 'Rbxe7' | 'Rbxe8' |
        'Rbxf1' | 'Rbxf2' | 'Rbxf3' | 'Rbxf4' | 'Rbxf5' | 'Rbxf6' | 'Rbxf7' | 'Rbxf8' |
        'Rbxg1' | 'Rbxg2' | 'Rbxg3' | 'Rbxg4' | 'Rbxg5' | 'Rbxg6' | 'Rbxg7' | 'Rbxg8' |
        'Rbxh1' | 'Rbxh2' | 'Rbxh3' | 'Rbxh4' | 'Rbxh5' | 'Rbxh6' | 'Rbxh7' | 'Rbxh8' | // 64

        'Rcxa1' | 'Rcxa2' | 'Rcxa3' | 'Rcxa4' | 'Rcxa5' | 'Rcxa6' | 'Rcxa7' | 'Rcxa8' |
        'Rcxb1' | 'Rcxb2' | 'Rcxb3' | 'Rcxb4' | 'Rcxb5' | 'Rcxb6' | 'Rcxb7' | 'Rcxb8' |
        'Rcxc1' | 'Rcxc2' | 'Rcxc3' | 'Rcxc4' | 'Rcxc5' | 'Rcxc6' | 'Rcxc7' | 'Rcxc8' |
        'Rcxd1' | 'Rcxd2' | 'Rcxd3' | 'Rcxd4' | 'Rcxd5' | 'Rcxd6' | 'Rcxd7' | 'Rcxd8' |
        'Rcxe1' | 'Rcxe2' | 'Rcxe3' | 'Rcxe4' | 'Rcxe5' | 'Rcxe6' | 'Rcxe7' | 'Rcxe8' |
        'Rcxf1' | 'Rcxf2' | 'Rcxf3' | 'Rcxf4' | 'Rcxf5' | 'Rcxf6' | 'Rcxf7' | 'Rcxf8' |
        'Rcxg1' | 'Rcxg2' | 'Rcxg3' | 'Rcxg4' | 'Rcxg5' | 'Rcxg6' | 'Rcxg7' | 'Rcxg8' |
        'Rcxh1' | 'Rcxh2' | 'Rcxh3' | 'Rcxh4' | 'Rcxh5' | 'Rcxh6' | 'Rcxh7' | 'Rcxh8' | // 64

        'Rdxa1' | 'Rdxa2' | 'Rdxa3' | 'Rdxa4' | 'Rdxa5' | 'Rdxa6' | 'Rdxa7' | 'Rdxa8' |
        'Rdxb1' | 'Rdxb2' | 'Rdxb3' | 'Rdxb4' | 'Rdxb5' | 'Rdxb6' | 'Rdxb7' | 'Rdxb8' |
        'Rdxc1' | 'Rdxc2' | 'Rdxc3' | 'Rdxc4' | 'Rdxc5' | 'Rdxc6' | 'Rdxc7' | 'Rdxc8' |
        'Rdxd1' | 'Rdxd2' | 'Rdxd3' | 'Rdxd4' | 'Rdxd5' | 'Rdxd6' | 'Rdxd7' | 'Rdxd8' |
        'Rdxe1' | 'Rdxe2' | 'Rdxe3' | 'Rdxe4' | 'Rdxe5' | 'Rdxe6' | 'Rdxe7' | 'Rdxe8' |
        'Rdxf1' | 'Rdxf2' | 'Rdxf3' | 'Rdxf4' | 'Rdxf5' | 'Rdxf6' | 'Rdxf7' | 'Rdxf8' |
        'Rdxg1' | 'Rdxg2' | 'Rdxg3' | 'Rdxg4' | 'Rdxg5' | 'Rdxg6' | 'Rdxg7' | 'Rdxg8' |
        'Rdxh1' | 'Rdxh2' | 'Rdxh3' | 'Rdxh4' | 'Rdxh5' | 'Rdxh6' | 'Rdxh7' | 'Rdxh8' | // 64

        'Rexa1' | 'Rexa2' | 'Rexa3' | 'Rexa4' | 'Rexa5' | 'Rexa6' | 'Rexa7' | 'Rexa8' |
        'Rexb1' | 'Rexb2' | 'Rexb3' | 'Rexb4' | 'Rexb5' | 'Rexb6' | 'Rexb7' | 'Rexb8' |
        'Rexc1' | 'Rexc2' | 'Rexc3' | 'Rexc4' | 'Rexc5' | 'Rexc6' | 'Rexc7' | 'Rexc8' |
        'Rexd1' | 'Rexd2' | 'Rexd3' | 'Rexd4' | 'Rexd5' | 'Rexd6' | 'Rexd7' | 'Rexd8' |
        'Rexe1' | 'Rexe2' | 'Rexe3' | 'Rexe4' | 'Rexe5' | 'Rexe6' | 'Rexe7' | 'Rexe8' |
        'Rexf1' | 'Rexf2' | 'Rexf3' | 'Rexf4' | 'Rexf5' | 'Rexf6' | 'Rexf7' | 'Rexf8' |
        'Rexg1' | 'Rexg2' | 'Rexg3' | 'Rexg4' | 'Rexg5' | 'Rexg6' | 'Rexg7' | 'Rexg8' |
        'Rexh1' | 'Rexh2' | 'Rexh3' | 'Rexh4' | 'Rexh5' | 'Rexh6' | 'Rexh7' | 'Rexh8' | // 64

        'Rfxa1' | 'Rfxa2' | 'Rfxa3' | 'Rfxa4' | 'Rfxa5' | 'Rfxa6' | 'Rfxa7' | 'Rfxa8' |
        'Rfxb1' | 'Rfxb2' | 'Rfxb3' | 'Rfxb4' | 'Rfxb5' | 'Rfxb6' | 'Rfxb7' | 'Rfxb8' |
        'Rfxc1' | 'Rfxc2' | 'Rfxc3' | 'Rfxc4' | 'Rfxc5' | 'Rfxc6' | 'Rfxc7' | 'Rfxc8' |
        'Rfxd1' | 'Rfxd2' | 'Rfxd3' | 'Rfxd4' | 'Rfxd5' | 'Rfxd6' | 'Rfxd7' | 'Rfxd8' |
        'Rfxe1' | 'Rfxe2' | 'Rfxe3' | 'Rfxe4' | 'Rfxe5' | 'Rfxe6' | 'Rfxe7' | 'Rfxe8' |
        'Rfxf1' | 'Rfxf2' | 'Rfxf3' | 'Rfxf4' | 'Rfxf5' | 'Rfxf6' | 'Rfxf7' | 'Rfxf8' |
        'Rfxg1' | 'Rfxg2' | 'Rfxg3' | 'Rfxg4' | 'Rfxg5' | 'Rfxg6' | 'Rfxg7' | 'Rfxg8' |
        'Rfxh1' | 'Rfxh2' | 'Rfxh3' | 'Rfxh4' | 'Rfxh5' | 'Rfxh6' | 'Rfxh7' | 'Rfxh8' | // 64

        'Rgxa1' | 'Rgxa2' | 'Rgxa3' | 'Rgxa4' | 'Rgxa5' | 'Rgxa6' | 'Rgxa7' | 'Rgxa8' |
        'Rgxb1' | 'Rgxb2' | 'Rgxb3' | 'Rgxb4' | 'Rgxb5' | 'Rgxb6' | 'Rgxb7' | 'Rgxb8' |
        'Rgxc1' | 'Rgxc2' | 'Rgxc3' | 'Rgxc4' | 'Rgxc5' | 'Rgxc6' | 'Rgxc7' | 'Rgxc8' |
        'Rgxd1' | 'Rgxd2' | 'Rgxd3' | 'Rgxd4' | 'Rgxd5' | 'Rgxd6' | 'Rgxd7' | 'Rgxd8' |
        'Rgxe1' | 'Rgxe2' | 'Rgxe3' | 'Rgxe4' | 'Rgxe5' | 'Rgxe6' | 'Rgxe7' | 'Rgxe8' |
        'Rgxf1' | 'Rgxf2' | 'Rgxf3' | 'Rgxf4' | 'Rgxf5' | 'Rgxf6' | 'Rgxf7' | 'Rgxf8' |
        'Rgxg1' | 'Rgxg2' | 'Rgxg3' | 'Rgxg4' | 'Rgxg5' | 'Rgxg6' | 'Rgxg7' | 'Rgxg8' |
        'Rgxh1' | 'Rgxh2' | 'Rgxh3' | 'Rgxh4' | 'Rgxh5' | 'Rgxh6' | 'Rgxh7' | 'Rgxh8' | // 64

        'Rhxa1' | 'Rhxa2' | 'Rhxa3' | 'Rhxa4' | 'Rhxa5' | 'Rhxa6' | 'Rhxa7' | 'Rhxa8' |
        'Rhxb1' | 'Rhxb2' | 'Rhxb3' | 'Rhxb4' | 'Rhxb5' | 'Rhxb6' | 'Rhxb7' | 'Rhxb8' |
        'Rhxc1' | 'Rhxc2' | 'Rhxc3' | 'Rhxc4' | 'Rhxc5' | 'Rhxc6' | 'Rhxc7' | 'Rhxc8' |
        'Rhxd1' | 'Rhxd2' | 'Rhxd3' | 'Rhxd4' | 'Rhxd5' | 'Rhxd6' | 'Rhxd7' | 'Rhxd8' |
        'Rhxe1' | 'Rhxe2' | 'Rhxe3' | 'Rhxe4' | 'Rhxe5' | 'Rhxe6' | 'Rhxe7' | 'Rhxe8' |
        'Rhxf1' | 'Rhxf2' | 'Rhxf3' | 'Rhxf4' | 'Rhxf5' | 'Rhxf6' | 'Rhxf7' | 'Rhxf8' |
        'Rhxg1' | 'Rhxg2' | 'Rhxg3' | 'Rhxg4' | 'Rhxg5' | 'Rhxg6' | 'Rhxg7' | 'Rhxg8' |
        'Rhxh1' | 'Rhxh2' | 'Rhxh3' | 'Rhxh4' | 'Rhxh5' | 'Rhxh6' | 'Rhxh7' | 'Rhxh8' | // 64

        'Ra1' | 'Ra2' | 'Ra3' | 'Ra4' | 'Ra5' | 'Ra6' | 'Ra7' | 'Ra8' |
        'Rb1' | 'Rb2' | 'Rb3' | 'Rb4' | 'Rb5' | 'Rb6' | 'Rb7' | 'Rb8' |
        'Rc1' | 'Rc2' | 'Rc3' | 'Rc4' | 'Rc5' | 'Rc6' | 'Rc7' | 'Rc8' |
        'Rd1' | 'Rd2' | 'Rd3' | 'Rd4' | 'Rd5' | 'Rd6' | 'Rd7' | 'Rd8' |
        'Re1' | 'Re2' | 'Re3' | 'Re4' | 'Re5' | 'Re6' | 'Re7' | 'Re8' |
        'Rf1' | 'Rf2' | 'Rf3' | 'Rf4' | 'Rf5' | 'Rf6' | 'Rf7' | 'Rf8' |
        'Rg1' | 'Rg2' | 'Rg3' | 'Rg4' | 'Rg5' | 'Rg6' | 'Rg7' | 'Rg8' |
        'Rh1' | 'Rh2' | 'Rh3' | 'Rh4' | 'Rh5' | 'Rh6' | 'Rh7' | 'Rh8' | // 64

        'Rxa1' | 'Rxa2' | 'Rxa3' | 'Rxa4' | 'Rxa5' | 'Rxa6' | 'Rxa7' | 'Rxa8' |
        'Rxb1' | 'Rxb2' | 'Rxb3' | 'Rxb4' | 'Rxb5' | 'Rxb6' | 'Rxb7' | 'Rxb8' |
        'Rxc1' | 'Rxc2' | 'Rxc3' | 'Rxc4' | 'Rxc5' | 'Rxc6' | 'Rxc7' | 'Rxc8' |
        'Rxd1' | 'Rxd2' | 'Rxd3' | 'Rxd4' | 'Rxd5' | 'Rxd6' | 'Rxd7' | 'Rxd8' |
        'Rxe1' | 'Rxe2' | 'Rxe3' | 'Rxe4' | 'Rxe5' | 'Rxe6' | 'Rxe7' | 'Rxe8' |
        'Rxf1' | 'Rxf2' | 'Rxf3' | 'Rxf4' | 'Rxf5' | 'Rxf6' | 'Rxf7' | 'Rxf8' |
        'Rxg1' | 'Rxg2' | 'Rxg3' | 'Rxg4' | 'Rxg5' | 'Rxg6' | 'Rxg7' | 'Rxg8' |
        'Rxh1' | 'Rxh2' | 'Rxh3' | 'Rxh4' | 'Rxh5' | 'Rxh6' | 'Rxh7' | 'Rxh8' | // 64

        'R1xa1' | 'R1xa2' | 'R1xa3' | 'R1xa4' | 'R1xa5' | 'R1xa6' | 'R1xa7' | 'R1xa8' |
        'R1xb1' | 'R1xb2' | 'R1xb3' | 'R1xb4' | 'R1xb5' | 'R1xb6' | 'R1xb7' | 'R1xb8' |
        'R1xc1' | 'R1xc2' | 'R1xc3' | 'R1xc4' | 'R1xc5' | 'R1xc6' | 'R1xc7' | 'R1xc8' |
        'R1xd1' | 'R1xd2' | 'R1xd3' | 'R1xd4' | 'R1xd5' | 'R1xd6' | 'R1xd7' | 'R1xd8' |
        'R1xe1' | 'R1xe2' | 'R1xe3' | 'R1xe4' | 'R1xe5' | 'R1xe6' | 'R1xe7' | 'R1xe8' |
        'R1xf1' | 'R1xf2' | 'R1xf3' | 'R1xf4' | 'R1xf5' | 'R1xf6' | 'R1xf7' | 'R1xf8' |
        'R1xg1' | 'R1xg2' | 'R1xg3' | 'R1xg4' | 'R1xg5' | 'R1xg6' | 'R1xg7' | 'R1xg8' |
        'R1xh1' | 'R1xh2' | 'R1xh3' | 'R1xh4' | 'R1xh5' | 'R1xh6' | 'R1xh7' | 'R1xh8' | // 64

        'R2xa1' | 'R2xa2' | 'R2xa3' | 'R2xa4' | 'R2xa5' | 'R2xa6' | 'R2xa7' | 'R2xa8' |
        'R2xb1' | 'R2xb2' | 'R2xb3' | 'R2xb4' | 'R2xb5' | 'R2xb6' | 'R2xb7' | 'R2xb8' |
        'R2xc1' | 'R2xc2' | 'R2xc3' | 'R2xc4' | 'R2xc5' | 'R2xc6' | 'R2xc7' | 'R2xc8' |
        'R2xd1' | 'R2xd2' | 'R2xd3' | 'R2xd4' | 'R2xd5' | 'R2xd6' | 'R2xd7' | 'R2xd8' |
        'R2xe1' | 'R2xe2' | 'R2xe3' | 'R2xe4' | 'R2xe5' | 'R2xe6' | 'R2xe7' | 'R2xe8' |
        'R2xf1' | 'R2xf2' | 'R2xf3' | 'R2xf4' | 'R2xf5' | 'R2xf6' | 'R2xf7' | 'R2xf8' |
        'R2xg1' | 'R2xg2' | 'R2xg3' | 'R2xg4' | 'R2xg5' | 'R2xg6' | 'R2xg7' | 'R2xg8' |
        'R2xh1' | 'R2xh2' | 'R2xh3' | 'R2xh4' | 'R2xh5' | 'R2xh6' | 'R2xh7' | 'R2xh8' | // 64

        'R3xa1' | 'R3xa2' | 'R3xa3' | 'R3xa4' | 'R3xa5' | 'R3xa6' | 'R3xa7' | 'R3xa8' |
        'R3xb1' | 'R3xb2' | 'R3xb3' | 'R3xb4' | 'R3xb5' | 'R3xb6' | 'R3xb7' | 'R3xb8' |
        'R3xc1' | 'R3xc2' | 'R3xc3' | 'R3xc4' | 'R3xc5' | 'R3xc6' | 'R3xc7' | 'R3xc8' |
        'R3xd1' | 'R3xd2' | 'R3xd3' | 'R3xd4' | 'R3xd5' | 'R3xd6' | 'R3xd7' | 'R3xd8' |
        'R3xe1' | 'R3xe2' | 'R3xe3' | 'R3xe4' | 'R3xe5' | 'R3xe6' | 'R3xe7' | 'R3xe8' |
        'R3xf1' | 'R3xf2' | 'R3xf3' | 'R3xf4' | 'R3xf5' | 'R3xf6' | 'R3xf7' | 'R3xf8' |
        'R3xg1' | 'R3xg2' | 'R3xg3' | 'R3xg4' | 'R3xg5' | 'R3xg6' | 'R3xg7' | 'R3xg8' |
        'R3xh1' | 'R3xh2' | 'R3xh3' | 'R3xh4' | 'R3xh5' | 'R3xh6' | 'R3xh7' | 'R3xh8' | // 64

        'R4xa1' | 'R4xa2' | 'R4xa3' | 'R4xa4' | 'R4xa5' | 'R4xa6' | 'R4xa7' | 'R4xa8' |
        'R4xb1' | 'R4xb2' | 'R4xb3' | 'R4xb4' | 'R4xb5' | 'R4xb6' | 'R4xb7' | 'R4xb8' |
        'R4xc1' | 'R4xc2' | 'R4xc3' | 'R4xc4' | 'R4xc5' | 'R4xc6' | 'R4xc7' | 'R4xc8' |
        'R4xd1' | 'R4xd2' | 'R4xd3' | 'R4xd4' | 'R4xd5' | 'R4xd6' | 'R4xd7' | 'R4xd8' |
        'R4xe1' | 'R4xe2' | 'R4xe3' | 'R4xe4' | 'R4xe5' | 'R4xe6' | 'R4xe7' | 'R4xe8' |
        'R4xf1' | 'R4xf2' | 'R4xf3' | 'R4xf4' | 'R4xf5' | 'R4xf6' | 'R4xf7' | 'R4xf8' |
        'R4xg1' | 'R4xg2' | 'R4xg3' | 'R4xg4' | 'R4xg5' | 'R4xg6' | 'R4xg7' | 'R4xg8' |
        'R4xh1' | 'R4xh2' | 'R4xh3' | 'R4xh4' | 'R4xh5' | 'R4xh6' | 'R4xh7' | 'R4xh8' | // 64

        'R5xa1' | 'R5xa2' | 'R5xa3' | 'R5xa4' | 'R5xa5' | 'R5xa6' | 'R5xa7' | 'R5xa8' |
        'R5xb1' | 'R5xb2' | 'R5xb3' | 'R5xb4' | 'R5xb5' | 'R5xb6' | 'R5xb7' | 'R5xb8' |
        'R5xc1' | 'R5xc2' | 'R5xc3' | 'R5xc4' | 'R5xc5' | 'R5xc6' | 'R5xc7' | 'R5xc8' |
        'R5xd1' | 'R5xd2' | 'R5xd3' | 'R5xd4' | 'R5xd5' | 'R5xd6' | 'R5xd7' | 'R5xd8' |
        'R5xe1' | 'R5xe2' | 'R5xe3' | 'R5xe4' | 'R5xe5' | 'R5xe6' | 'R5xe7' | 'R5xe8' |
        'R5xf1' | 'R5xf2' | 'R5xf3' | 'R5xf4' | 'R5xf5' | 'R5xf6' | 'R5xf7' | 'R5xf8' |
        'R5xg1' | 'R5xg2' | 'R5xg3' | 'R5xg4' | 'R5xg5' | 'R5xg6' | 'R5xg7' | 'R5xg8' |
        'R5xh1' | 'R5xh2' | 'R5xh3' | 'R5xh4' | 'R5xh5' | 'R5xh6' | 'R5xh7' | 'R5xh8' | // 64

        'R6xa1' | 'R6xa2' | 'R6xa3' | 'R6xa4' | 'R6xa5' | 'R6xa6' | 'R6xa7' | 'R6xa8' |
        'R6xb1' | 'R6xb2' | 'R6xb3' | 'R6xb4' | 'R6xb5' | 'R6xb6' | 'R6xb7' | 'R6xb8' |
        'R6xc1' | 'R6xc2' | 'R6xc3' | 'R6xc4' | 'R6xc5' | 'R6xc6' | 'R6xc7' | 'R6xc8' |
        'R6xd1' | 'R6xd2' | 'R6xd3' | 'R6xd4' | 'R6xd5' | 'R6xd6' | 'R6xd7' | 'R6xd8' |
        'R6xe1' | 'R6xe2' | 'R6xe3' | 'R6xe4' | 'R6xe5' | 'R6xe6' | 'R6xe7' | 'R6xe8' |
        'R6xf1' | 'R6xf2' | 'R6xf3' | 'R6xf4' | 'R6xf5' | 'R6xf6' | 'R6xf7' | 'R6xf8' |
        'R6xg1' | 'R6xg2' | 'R6xg3' | 'R6xg4' | 'R6xg5' | 'R6xg6' | 'R6xg7' | 'R6xg8' |
        'R6xh1' | 'R6xh2' | 'R6xh3' | 'R6xh4' | 'R6xh5' | 'R6xh6' | 'R6xh7' | 'R6xh8' | // 64

        'R7xa1' | 'R7xa2' | 'R7xa3' | 'R7xa4' | 'R7xa5' | 'R7xa6' | 'R7xa7' | 'R7xa8' |
        'R7xb1' | 'R7xb2' | 'R7xb3' | 'R7xb4' | 'R7xb5' | 'R7xb6' | 'R7xb7' | 'R7xb8' |
        'R7xc1' | 'R7xc2' | 'R7xc3' | 'R7xc4' | 'R7xc5' | 'R7xc6' | 'R7xc7' | 'R7xc8' |
        'R7xd1' | 'R7xd2' | 'R7xd3' | 'R7xd4' | 'R7xd5' | 'R7xd6' | 'R7xd7' | 'R7xd8' |
        'R7xe1' | 'R7xe2' | 'R7xe3' | 'R7xe4' | 'R7xe5' | 'R7xe6' | 'R7xe7' | 'R7xe8' |
        'R7xf1' | 'R7xf2' | 'R7xf3' | 'R7xf4' | 'R7xf5' | 'R7xf6' | 'R7xf7' | 'R7xf8' |
        'R7xg1' | 'R7xg2' | 'R7xg3' | 'R7xg4' | 'R7xg5' | 'R7xg6' | 'R7xg7' | 'R7xg8' |
        'R7xh1' | 'R7xh2' | 'R7xh3' | 'R7xh4' | 'R7xh5' | 'R7xh6' | 'R7xh7' | 'R7xh8' | // 64

        'R8xa1' | 'R8xa2' | 'R8xa3' | 'R8xa4' | 'R8xa5' | 'R8xa6' | 'R8xa7' | 'R8xa8' |
        'R8xb1' | 'R8xb2' | 'R8xb3' | 'R8xb4' | 'R8xb5' | 'R8xb6' | 'R8xb7' | 'R8xb8' |
        'R8xc1' | 'R8xc2' | 'R8xc3' | 'R8xc4' | 'R8xc5' | 'R8xc6' | 'R8xc7' | 'R8xc8' |
        'R8xd1' | 'R8xd2' | 'R8xd3' | 'R8xd4' | 'R8xd5' | 'R8xd6' | 'R8xd7' | 'R8xd8' |
        'R8xe1' | 'R8xe2' | 'R8xe3' | 'R8xe4' | 'R8xe5' | 'R8xe6' | 'R8xe7' | 'R8xe8' |
        'R8xf1' | 'R8xf2' | 'R8xf3' | 'R8xf4' | 'R8xf5' | 'R8xf6' | 'R8xf7' | 'R8xf8' |
        'R8xg1' | 'R8xg2' | 'R8xg3' | 'R8xg4' | 'R8xg5' | 'R8xg6' | 'R8xg7' | 'R8xg8' |
        'R8xh1' | 'R8xh2' | 'R8xh3' | 'R8xh4' | 'R8xh5' | 'R8xh6' | 'R8xh7' | 'R8xh8' ; // 64

NULL_MOVE : 'Z0';

/// A string token is a sequence of zero or more printing characters delimited by a
/// pair of quote characters (ASCII decimal value 34, hexadecimal value 0x22).  An
/// empty string is represented by two adjacent quotes.  (Note: an apostrophe is
/// not a quote.)  A quote inside a string is represented by the backslash
/// immediately followed by a quote.  A backslash inside a string is represented by
/// two adjacent backslashes.  Strings are commonly used as tag pair values (see
/// below).  Non-printing characters like newline and tab are not permitted inside
/// of strings.  A string token is terminated by its closing quote.  Currently, a
/// string is limited to a maximum of 255 characters of data.
STRING
 : '"' ('\\\\' | '\\"' | ~[\\"])* '"'
 ;

/// An integer token is a sequence of one or more decimal digit characters.  It is
/// a special case of the more general "symbol" token class described below.
/// Integer tokens are used to help represent move number indications (see below).
/// An integer token is terminated just prior to the first non-symbol character
/// following the integer digit sequence.
INTEGER
 : [0-9]+
 ;

/// A period character (".") is a token by itself.  It is used for move number
/// indications (see below).  It is self terminating.
PERIOD
 : '.'
 ;

/// An asterisk character ("*") is a token by itself.  It is used as one of the
/// possible game termination markers (see below); it indicates an incomplete game
/// or a game with an unknown or otherwise unavailable result.  It is self
/// terminating.
ASTERISK
 : '*'
 ;

/// The left and right bracket characters ("[" and "]") are tokens.  They are used
/// to delimit tag pairs (see below).  Both are self terminating.
LEFT_BRACKET
 : '['
 ;

RIGHT_BRACKET
 : ']'
 ;

/// The left and right parenthesis characters ("(" and ")") are tokens.  They are
/// used to delimit Recursive Annotation Variations (see below).  Both are self
/// terminating.
LEFT_PARENTHESIS
 : '('
 ;

RIGHT_PARENTHESIS
 : ')'
 ;

/// The left and right angle bracket characters ("<" and ">") are tokens.  They are
/// reserved for future expansion.  Both are self terminating.
LEFT_ANGLE_BRACKET
 : '<'
 ;

RIGHT_ANGLE_BRACKET
 : '>'
 ;

/// A Numeric Annotation Glyph ("NAG", see below) is a token; it is composed of a
/// dollar sign character ("$") immediately followed by one or more digit
/// characters.  It is terminated just prior to the first non-digit character
/// following the digit sequence.
NUMERIC_ANNOTATION_GLYPH
 : '$' [0-9]+
 ;

/// A symbol token starts with a letter or digit character and is immediately
/// followed by a sequence of zero or more symbol continuation characters.  These
/// continuation characters are letter characters ("A-Za-z"), digit characters
/// ("0-9"), the underscore ("_"), the plus sign ("+"), the octothorpe sign ("#"),
/// the equal sign ("="), the colon (":"),  and the hyphen ("-").  Symbols are used
/// for a variety of purposes.  All characters in a symbol are significant.  A
/// symbol token is terminated just prior to the first non-symbol character
/// following the symbol character sequence.  Currently, a symbol is limited to a
/// maximum of 255 characters in length.
SYMBOL
 : [a-zA-Z0-9] [a-zA-Z0-9_+#=:-]*
 ;

/// Import format PGN allows for the use of traditional suffix annotations for
/// moves.  There are exactly six such annotations available: "!", "?", "!!", "!?",
/// "?!", and "??".  At most one such suffix annotation may appear per move, and if
/// present, it is always the last part of the move symbol.
SUFFIX_ANNOTATION
 : [?!] [?!]?
 ;

// A fall through rule that will catch any character not matched by any of the
// previous lexer rules.
UNEXPECTED_CHAR
 : .
 ;
