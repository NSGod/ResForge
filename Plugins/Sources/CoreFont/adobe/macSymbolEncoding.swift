//
//  macSymbolEncoding.swift
//  CoreFont
//
//  Created by Mark Douma on 1/1/2026.
//

/*
 # Format:
 # -------
 #
 #   Three tab-separated columns;
 #   '#' begins a comment which continues to the end of the line.
 #     Column #1 is the Mac OS Symbol code (in hex as 0xNN)
 #     Column #2 is the corresponding Unicode or Unicode sequence
 #       (in hex as 0xNNNN or 0xNNNN+0xNNNN).
 #     Column #3 is a comment containing the Unicode name.
 #       In some cases an additional comment follows the Unicode name.
 #
 #   The entries are in Mac OS Symbol code order.
 #
 #   Some of these mappings require the use of corporate characters.
 #   See the file "CORPCHAR.TXT" and notes below.
 #
 #   Control character mappings are not shown in this table, following
 #   the conventions of the standard UTC mapping tables. However, the
 #   Mac OS Symbol character set uses the standard control characters
 #   at 0x00-0x1F and 0x7F.
 #
 # Notes on Mac OS Symbol:
 # -----------------------
 #
 #   This is a legacy Mac OS encoding; in the Mac OS X Carbon and Cocoa
 #   environments, it is only supported directly in programming
 #   interfaces for QuickDraw Text, the Script Manager, and related
 #   Text Utilities. For other purposes it is supported via transcoding
 #   to and from Unicode.
 #
 #   The Mac OS Symbol encoding shares the script code smRoman
 #   (0) with the Mac OS Roman encoding. To determine if the Symbol
 #   encoding is being used, you must check if the font name is
 #   "Symbol".
 #
 #   Before Mac OS 8.5, code point 0xA0 was unused. In Mac OS 8.5
 #   and later versions, code point 0xA0 is EURO SIGN and maps to
 #   U+20AC (the Symbol font is updated for Mac OS 8.5 to reflect
 #   this).
 #
 #   The layout of the Mac OS Symbol character set is identical to
 #   the layout of the Adobe Symbol encoding vector, with the
 #   addition of the Apple logo character at 0xF0.
 #
 #   This character set encodes a number of glyph fragments. Some are
 #   used as extenders: 0x60 is used to extend radical signs, 0xBD and
 #   0xBE are used to extend vertical and horizontal arrows, etc. In
 #   addition, there are top, bottom, and center sections for
 #   parentheses, brackets, integral signs, and other signs that may
 #   extend vertically for 2 or more lines of normal text. As of
 #   Unicode 3.2, most of these are now encoded in Unicode; a few are
 #   not, so these are mapped using corporate-zone Unicode characters
 #   (see below).
 #
 #   In addition, Symbol separately encodes both serif and sans-serif
 #   forms for copyright, trademark, and registered signs. Unicode
 #   encodes only the abstract characters, so one set of these (the
 #   sans-serif forms) are also mapped using corporate-zone Unicode
 #   characters (see below).
 #
 #   The following code points are unused, and are not shown here:
 #   0x80-0x9F, 0xFF.
 #
 # Unicode mapping issues and notes:
 # ---------------------------------
 #
 #   The goals in the mappings provided here are:
 #   - Ensure roundtrip mapping from every character in the Mac OS
 #     Symbol character set to Unicode and back
 #   - Use standard Unicode characters as much as possible, to
 #     maximize interchangeability of the resulting Unicode text.
 #     Whenever possible, avoid having content carried by private-use
 #     characters.
 #
 #   Some of the characters in the Mac OS Symbol character set do not
 #   correspond to distinct, single Unicode characters. To map these
 #   and satisfy both goals above, we employ various strategies.
 #
 #   a) If possible, use private use characters in combination with
 #   standard Unicode characters to mark variants of the standard
 #   Unicode character.
 #
 #   Apple has defined a block of 32 corporate characters as "transcoding
 #   hints." These are used in combination with standard Unicode
 #   characters to force them to be treated in a special way for mapping
 #   to other encodings; they have no other effect. Sixteen of these
 #   transcoding hints are "grouping hints" - they indicate that the next
 #   2-4 Unicode characters should be treated as a single entity for
 #   transcoding. The other sixteen transcoding hints are "variant tags"
 #   - they are like combining characters, and can follow a standard
 #   Unicode (or a sequence consisting of a base character and other
 #   combining characters) to cause it to be treated in a special way for
 #   transcoding. These always terminate a combining-character sequence.
 #
 #   The transcoding coding hint used in this mapping table is the
 #   variant tag 0xF87F. Since this is combined with standard Unicode
 #   characters, some characters in the Mac OS Symbol character set map
 #   to a sequence of two Unicodes instead of a single Unicode character.
 #
 #   For example, the Mac OS Symbol character at 0xE2 is an alternate,
 #   sans-serif form of the REGISTERED SIGN (the standard mapping is for
 #   the abstract character at 0xD2, which here has a serif form). So 0xE2
 #   is mapped to 0x00AE (REGISTERED SIGN) + 0xF87F (a variant tag).
 #
 #   b) Otherwise, use private use characters by themselves to map
 #   Mac OS Symbol characters which have no relationship to any standard
 #   Unicode character.
 #
 #   The following additional corporate zone Unicode characters are
 #   used for this purpose here:
 #
 #     0xF8E5  radical extender
 #     0xF8FF  Apple logo
 #
 #   NOTE: The graphic image associated with the Apple logo character
 #   is not authorized for use without permission of Apple, and
 #   unauthorized use might constitute trademark infringement.
 #
 # Details of mapping changes in each version:
 # -------------------------------------------
 #
 #   Changes from version c01 to version c02:
 #
 #   - Update mappings for 0xBD from 0xF8E6 to 0x23D0 (use new Unicode
 #     4.0 char)
 #   - Correct mapping for 0xE0 from 0x22C4 to 0x25CA
 #
 #   Changes from version b02 to version b03/c01:
 #
 #   - Update mappings for encoded glyph fragments 0xBE, 0xE6-EF, 0xF4,
 #     0xF6-FE to use new Unicode 3.2 characters instead of using either
 #     single corporate-use characters (e.g. 0xBE was mapped to 0xF8E7) or
 #     sequences combining a standard Unicode character with a transcoding
 #     hint (e.g. 0xE6 was mapped to 0x0028+0xF870).
 #
 #   Changes from version n05 to version b02:
 #
 #   - Encoding changed for Mac OS 8.5; 0xA0 now maps to 0x20AC, EURO
 #   SIGN. 0xA0 was unmapped in earlier versions.
 #
 #   Changes from version n03 to version n05:
 #
 #   - Change strict mapping for 0xE1 & 0xF1 from U+2329 & U+232A
 #     to their canonical decompositions, U+3008 & U+3009.
 #
 #   - Change mapping for the following to use standard Unicode +
 #     transcoding hint, instead of single corporate-zone
 #     character: 0xE2-0xE4, 0xE6-0xEE, 0xF4, 0xF6-0xFE.
 */

import Foundation

let macSymbolEncoding: [UVBMP] = [
    .undefined,   /* 00 */
    .undefined,   /* 01 */
    .undefined,   /* 02 */
    .undefined,   /* 03 */
    .undefined,   /* 04 */
    .undefined,   /* 05 */
    .undefined,   /* 06 */
    .undefined,   /* 07 */
    .undefined,   /* 08 */
    .undefined,   /* 09 */
    .undefined,   /* 0A */
    .undefined,   /* 0B */
    .undefined,   /* 0C */
    .undefined,   /* 0D */
    .undefined,   /* 0E */
    .undefined,   /* 0F */
    .undefined,   /* 10 */
    .undefined,   /* 11 */
    .undefined,   /* 12 */
    .undefined,   /* 13 */
    .undefined,   /* 14 */
    .undefined,   /* 15 */
    .undefined,   /* 16 */
    .undefined,   /* 17 */
    .undefined,   /* 18 */
    .undefined,   /* 19 */
    .undefined,   /* 1A */
    .undefined,   /* 1B */
    .undefined,   /* 1C */
    .undefined,   /* 1D */
    .undefined,   /* 1E */
    .undefined,   /* 1F */
    0x0020,       /* 20    SPACE */
    0x0021,       /* 21    EXCLAMATION MARK */
    0x2200,       /* 22    FOR ALL */
    0x0023,       /* 23    NUMBER SIGN */
    0x2203,       /* 24    THERE EXISTS */
    0x0025,       /* 25    PERCENT SIGN */
    0x0026,       /* 26    AMPERSAND */
    0x220D,       /* 27    SMALL CONTAINS AS MEMBER */
    0x0028,       /* 28    LEFT PARENTHESIS */
    0x0029,       /* 29    RIGHT PARENTHESIS */
    0x2217,       /* 2A    ASTERISK OPERATOR */
    0x002B,       /* 2B    PLUS SIGN */
    0x002C,       /* 2C    COMMA */
    0x2212,       /* 2D    MINUS SIGN */
    0x002E,       /* 2E    FULL STOP */
    0x002F,       /* 2F    SOLIDUS */
    0x0030,       /* 30    DIGIT ZERO */
    0x0031,       /* 31    DIGIT ONE */
    0x0032,       /* 32    DIGIT TWO */
    0x0033,       /* 33    DIGIT THREE */
    0x0034,       /* 34    DIGIT FOUR */
    0x0035,       /* 35    DIGIT FIVE */
    0x0036,       /* 36    DIGIT SIX */
    0x0037,       /* 37    DIGIT SEVEN */
    0x0038,       /* 38    DIGIT EIGHT */
    0x0039,       /* 39    DIGIT NINE */
    0x003A,       /* 3A    COLON */
    0x003B,       /* 3B    SEMICOLON */
    0x003C,       /* 3C    LESS-THAN SIGN */
    0x003D,       /* 3D    EQUALS SIGN */
    0x003E,       /* 3E    GREATER-THAN SIGN */
    0x003F,       /* 3F    QUESTION MARK */
    0x2245,       /* 40    APPROXIMATELY EQUAL TO */
    0x0391,       /* 41    GREEK CAPITAL LETTER ALPHA */
    0x0392,       /* 42    GREEK CAPITAL LETTER BETA */
    0x03A7,       /* 43    GREEK CAPITAL LETTER CHI */
    0x0394,       /* 44    GREEK CAPITAL LETTER DELTA */
    0x0395,       /* 45    GREEK CAPITAL LETTER EPSILON */
    0x03A6,       /* 46    GREEK CAPITAL LETTER PHI */
    0x0393,       /* 47    GREEK CAPITAL LETTER GAMMA */
    0x0397,       /* 48    GREEK CAPITAL LETTER ETA */
    0x0399,       /* 49    GREEK CAPITAL LETTER IOTA */
    0x03D1,       /* 4A    GREEK THETA SYMBOL */
    0x039A,       /* 4B    GREEK CAPITAL LETTER KAPPA */
    0x039B,       /* 4C    GREEK CAPITAL LETTER LAMDA */
    0x039C,       /* 4D    GREEK CAPITAL LETTER MU */
    0x039D,       /* 4E    GREEK CAPITAL LETTER NU */
    0x039F,       /* 4F    GREEK CAPITAL LETTER OMICRON */
    0x03A0,       /* 50    GREEK CAPITAL LETTER PI */
    0x0398,       /* 51    GREEK CAPITAL LETTER THETA */
    0x03A1,       /* 52    GREEK CAPITAL LETTER RHO */
    0x03A3,       /* 53    GREEK CAPITAL LETTER SIGMA */
    0x03A4,       /* 54    GREEK CAPITAL LETTER TAU */
    0x03A5,       /* 55    GREEK CAPITAL LETTER UPSILON */
    0x03C2,       /* 56    GREEK SMALL LETTER FINAL SIGMA */
    0x03A9,       /* 57    GREEK CAPITAL LETTER OMEGA */
    0x039E,       /* 58    GREEK CAPITAL LETTER XI */
    0x03A8,       /* 59    GREEK CAPITAL LETTER PSI */
    0x0396,       /* 5A    GREEK CAPITAL LETTER ZETA */
    0x005B,       /* 5B    LEFT SQUARE BRACKET */
    0x2234,       /* 5C    THEREFORE */
    0x005D,       /* 5D    RIGHT SQUARE BRACKET */
    0x22A5,       /* 5E    UP TACK */
    0x005F,       /* 5F    LOW LINE */
    0xF8E5,       /* 60    radical extender # corporate char */
    0x03B1,       /* 61    GREEK SMALL LETTER ALPHA */
    0x03B2,       /* 62    GREEK SMALL LETTER BETA */
    0x03C7,       /* 63    GREEK SMALL LETTER CHI */
    0x03B4,       /* 64    GREEK SMALL LETTER DELTA */
    0x03B5,       /* 65    GREEK SMALL LETTER EPSILON */
    0x03C6,       /* 66    GREEK SMALL LETTER PHI */
    0x03B3,       /* 67    GREEK SMALL LETTER GAMMA */
    0x03B7,       /* 68    GREEK SMALL LETTER ETA */
    0x03B9,       /* 69    GREEK SMALL LETTER IOTA */
    0x03D5,       /* 6A    GREEK PHI SYMBOL */
    0x03BA,       /* 6B    GREEK SMALL LETTER KAPPA */
    0x03BB,       /* 6C    GREEK SMALL LETTER LAMDA */
    0x03BC,       /* 6D    GREEK SMALL LETTER MU */
    0x03BD,       /* 6E    GREEK SMALL LETTER NU */
    0x03BF,       /* 6F    GREEK SMALL LETTER OMICRON */
    0x03C0,       /* 70    GREEK SMALL LETTER PI */
    0x03B8,       /* 71    GREEK SMALL LETTER THETA */
    0x03C1,       /* 72    GREEK SMALL LETTER RHO */
    0x03C3,       /* 73    GREEK SMALL LETTER SIGMA */
    0x03C4,       /* 74    GREEK SMALL LETTER TAU */
    0x03C5,       /* 75    GREEK SMALL LETTER UPSILON */
    0x03D6,       /* 76    GREEK PI SYMBOL */
    0x03C9,       /* 77    GREEK SMALL LETTER OMEGA */
    0x03BE,       /* 78    GREEK SMALL LETTER XI */
    0x03C8,       /* 79    GREEK SMALL LETTER PSI */
    0x03B6,       /* 7A    GREEK SMALL LETTER ZETA */
    0x007B,       /* 7B    LEFT CURLY BRACKET */
    0x007C,       /* 7C    VERTICAL LINE */
    0x007D,       /* 7D    RIGHT CURLY BRACKET */
    0x223C,       /* 7E    TILDE OPERATOR */
    .undefined,   /* 7F */
    .undefined,   /* 80 */
    .undefined,   /* 81 */
    .undefined,   /* 82 */
    .undefined,   /* 83 */
    .undefined,   /* 84 */
    .undefined,   /* 85 */
    .undefined,   /* 86 */
    .undefined,   /* 87 */
    .undefined,   /* 88 */
    .undefined,   /* 89 */
    .undefined,   /* 8A */
    .undefined,   /* 8B */
    .undefined,   /* 8C */
    .undefined,   /* 8D */
    .undefined,   /* 8E */
    .undefined,   /* 8F */
    .undefined,   /* 90 */
    .undefined,   /* 91 */
    .undefined,   /* 92 */
    .undefined,   /* 93 */
    .undefined,   /* 94 */
    .undefined,   /* 95 */
    .undefined,   /* 96 */
    .undefined,   /* 97 */
    .undefined,   /* 98 */
    .undefined,   /* 99 */
    .undefined,   /* 9A */
    .undefined,   /* 9B */
    .undefined,   /* 9C */
    .undefined,   /* 9D */
    .undefined,   /* 9E */
    .undefined,   /* 9F */
    0x20AC,       /* A0    EURO SIGN */
    0x03D2,       /* A1    GREEK UPSILON WITH HOOK SYMBOL */
    0x2032,       /* A2    PRIME # minute */
    0x2264,       /* A3    LESS-THAN OR EQUAL TO */
    0x2044,       /* A4    FRACTION SLASH */
    0x221E,       /* A5    INFINITY */
    0x0192,       /* A6    LATIN SMALL LETTER F WITH HOOK */
    0x2663,       /* A7    BLACK CLUB SUIT */
    0x2666,       /* A8    BLACK DIAMOND SUIT */
    0x2665,       /* A9    BLACK HEART SUIT */
    0x2660,       /* AA    BLACK SPADE SUIT */
    0x2194,       /* AB    LEFT RIGHT ARROW */
    0x2190,       /* AC    LEFTWARDS ARROW */
    0x2191,       /* AD    UPWARDS ARROW */
    0x2192,       /* AE    RIGHTWARDS ARROW */
    0x2193,       /* AF    DOWNWARDS ARROW */
    0x00B0,       /* B0    DEGREE SIGN */
    0x00B1,       /* B1    PLUS-MINUS SIGN */
    0x2033,       /* B2    DOUBLE PRIME # second */
    0x2265,       /* B3    GREATER-THAN OR EQUAL TO */
    0x00D7,       /* B4    MULTIPLICATION SIGN */
    0x221D,       /* B5    PROPORTIONAL TO */
    0x2202,       /* B6    PARTIAL DIFFERENTIAL */
    0x2022,       /* B7    BULLET */
    0x00F7,       /* B8    DIVISION SIGN */
    0x2260,       /* B9    NOT EQUAL TO */
    0x2261,       /* BA    IDENTICAL TO */
    0x2248,       /* BB    ALMOST EQUAL TO */
    0x2026,       /* BC    HORIZONTAL ELLIPSIS */
    0x23D0,       /* BD    VERTICAL LINE EXTENSION (for arrows) # for Unicode 4.0 and later */
    0x23AF,       /* BE    HORIZONTAL LINE EXTENSION (for arrows) # for Unicode 3.2 and later */
    0x21B5,       /* BF    DOWNWARDS ARROW WITH CORNER LEFTWARDS */
    0x2135,       /* C0    ALEF SYMBOL */
    0x2111,       /* C1    BLACK-LETTER CAPITAL I */
    0x211C,       /* C2    BLACK-LETTER CAPITAL R */
    0x2118,       /* C3    SCRIPT CAPITAL P */
    0x2297,       /* C4    CIRCLED TIMES */
    0x2295,       /* C5    CIRCLED PLUS */
    0x2205,       /* C6    EMPTY SET */
    0x2229,       /* C7    INTERSECTION */
    0x222A,       /* C8    UNION */
    0x2283,       /* C9    SUPERSET OF */
    0x2287,       /* CA    SUPERSET OF OR EQUAL TO */
    0x2284,       /* CB    NOT A SUBSET OF */
    0x2282,       /* CC    SUBSET OF */
    0x2286,       /* CD    SUBSET OF OR EQUAL TO */
    0x2208,       /* CE    ELEMENT OF */
    0x2209,       /* CF    NOT AN ELEMENT OF */
    0x2220,       /* D0    ANGLE */
    0x2207,       /* D1    NABLA */
    0x00AE,       /* D2    REGISTERED SIGN # serif */
    0x00A9,       /* D3    COPYRIGHT SIGN # serif */
    0x2122,       /* D4    TRADE MARK SIGN # serif */
    0x220F,       /* D5    N-ARY PRODUCT */
    0x221A,       /* D6    SQUARE ROOT */
    0x22C5,       /* D7    DOT OPERATOR */
    0x00AC,       /* D8    NOT SIGN */
    0x2227,       /* D9    LOGICAL AND */
    0x2228,       /* DA    LOGICAL OR */
    0x21D4,       /* DB    LEFT RIGHT DOUBLE ARROW */
    0x21D0,       /* DC    LEFTWARDS DOUBLE ARROW */
    0x21D1,       /* DD    UPWARDS DOUBLE ARROW */
    0x21D2,       /* DE    RIGHTWARDS DOUBLE ARROW */
    0x21D3,       /* DF    DOWNWARDS DOUBLE ARROW */
    0x25CA,       /* E0    LOZENGE # previously mapped to 0x22C4 DIAMOND OPERATOR */
    0x3008,       /* E1    LEFT ANGLE BRACKET */
    /* FIXME: !! figure these out: */
    /*
    0xE2    0x00AE+0xF87F    # REGISTERED SIGN, alternate: sans serif
    0xE3    0x00A9+0xF87F    # COPYRIGHT SIGN, alternate: sans serif
    0xE4    0x2122+0xF87F    # TRADE MARK SIGN, alternate: sans serif
     */
    0x00AE,       /* E2    REGISTERED SIGN, alternate: sans serif */
    0x00A9,       /* E3    COPYRIGHT SIGN, alternate: sans serif */
    0x2122,       /* E4    TRADE MARK SIGN, alternate: sans serif */
    0x2211,       /* E5    N-ARY SUMMATION */
    0x239B,       /* E6    LEFT PARENTHESIS UPPER HOOK # for Unicode 3.2 and later */
    0x239C,       /* E7    LEFT PARENTHESIS EXTENSION # for Unicode 3.2 and later */
    0x239D,       /* E8    LEFT PARENTHESIS LOWER HOOK # for Unicode 3.2 and later */
    0x23A1,       /* E9    LEFT SQUARE BRACKET UPPER CORNER # for Unicode 3.2 and later */
    0x23A2,       /* EA    LEFT SQUARE BRACKET EXTENSION # for Unicode 3.2 and later */
    0x23A3,       /* EB    LEFT SQUARE BRACKET LOWER CORNER # for Unicode 3.2 and later */
    0x23A7,       /* EC    LEFT CURLY BRACKET UPPER HOOK # for Unicode 3.2 and later */
    0x23A8,       /* ED    LEFT CURLY BRACKET MIDDLE PIECE # for Unicode 3.2 and later */
    0x23A9,       /* EE    LEFT CURLY BRACKET LOWER HOOK # for Unicode 3.2 and later */
    0x23AA,       /* EF    CURLY BRACKET EXTENSION # for Unicode 3.2 and later */
    0xF8FF,       /* F0    Apple logo */
    0x3009,       /* F1    RIGHT ANGLE BRACKET */
    0x222B,       /* F2    INTEGRAL */
    0x2320,       /* F3    TOP HALF INTEGRAL */
    0x23AE,       /* F4    INTEGRAL EXTENSION # for Unicode 3.2 and later */
    0x2321,       /* F5    BOTTOM HALF INTEGRAL */
    0x239E,       /* F6    RIGHT PARENTHESIS UPPER HOOK # for Unicode 3.2 and later */
    0x239F,       /* F7    RIGHT PARENTHESIS EXTENSION # for Unicode 3.2 and later */
    0x23A0,       /* F8    RIGHT PARENTHESIS LOWER HOOK # for Unicode 3.2 and later */
    0x23A4,       /* F9    RIGHT SQUARE BRACKET UPPER CORNER # for Unicode 3.2 and later */
    0x23A5,       /* FA    RIGHT SQUARE BRACKET EXTENSION # for Unicode 3.2 and later */
    0x23A6,       /* FB    RIGHT SQUARE BRACKET LOWER CORNER # for Unicode 3.2 and later */
    0x23AB,       /* FC    RIGHT CURLY BRACKET UPPER HOOK # for Unicode 3.2 and later */
    0x23AC,       /* FD    RIGHT CURLY BRACKET MIDDLE PIECE # for Unicode 3.2 and later */
    0x23AD,       /* FE    RIGHT CURLY BRACKET LOWER HOOK # for Unicode 3.2 and later */
    .undefined,   /* FF */
]
