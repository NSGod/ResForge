//
//  macHebrewEncoding.swift
//  CoreFont
//
//  Created by Mark Douma on 1/1/2026.
//
/* Copyright 2014 Adobe Systems Incorporated (http://www.adobe.com/). All Rights Reserved.
   This software is licensed as OpenSource, under the Apache License, Version 2.0.
   This license is available at: http://opensource.org/licenses/Apache-2.0. */

/* Mac OS Hebrew aggregate Unicode initializer.

   Element values are UVs. UV_UNDEF is 0xFFFF. Index by code, get UV.
   Source: ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/APPLE/HEBREW.TXT
   as of 9/9/99.

   2 entries are mapped to Corporate Use Area Unicode values that Apple has
   deprecated. The full transcoding hint sequence is shown in parentheses for
   such mappings. */
/*
 # Format:
 # -------
 #
 #   Three tab-separated columns;
 #   '#' begins a comment which continues to the end of the line.
 #     Column #1 is the Mac OS Hebrew code (in hex as 0xNN).
 #     Column #2 is the corresponding Unicode or Unicode sequence (in
 #       hex as 0xNNNN, 0xNNNN+0xNNNN, etc.). Sequences of up to 3
 #       Unicode characters are used here. A single Unicode character
 #       may be preceded by a tag indicating required directionality
 #       (i.e. <LR>+0xNNNN or <RL>+0xNNNN).
 #     Column #3 is a comment containing the Unicode name.
 #
 #   The entries are in Mac OS Hebrew code order.
 #
 #   Some of these mappings require the use of corporate characters.
 #   See the file "CORPCHAR.TXT" and notes below.
 #
 #   Control character mappings are not shown in this table, following
 #   the conventions of the standard UTC mapping tables. However, the
 #   Mac OS Hebrew character set uses the standard control characters at
 #   0x00-0x1F and 0x7F.
 #
 # Notes on Mac OS Hebrew:
 # -----------------------
 #
 #   This is a legacy Mac OS encoding; in the Mac OS X Carbon and Cocoa
 #   environments, it is only supported via transcoding to and from
 #   Unicode.
 #
 #   1. General
 #
 #   The Mac OS Hebrew character set supports the Hebrew and Yiddish
 #   languages. It incorporates the Hebrew letter repertoire of
 #   ISO 8859-8, and uses the same code points for them, 0xE0-0xFA.
 #   It also incorporates the ASCII character set. In addition, the
 #   Mac OS Hebrew character set includes the following:
 #
 #   - Hebrew points (nikud marks) at 0xC6, 0xCB-0xCF and 0xD8-0xDF.
 #     These are non-spacing combining marks. Note that the RAFE point
 #     at 0xD8 is not displayed correctly in some fonts, and cannot be
 #     typed using the keyboard layouts in the current Hebrew localized
 #     systems. Also note: The character given in Unicode as QAMATS
 #     (U+05B8) actually refers to two different sounds, depending on
 #     context. For example, when ALEF is followed by QAMATS, the QAMATS
 #     can actually refer to two different sounds depending on the
 #     following letters. The Mac OS Hebrew character set separately
 #     encodes these two sounds for the same graphic shape, as "qamats"
 #     (0xCB) and "qamats qatan" (0xDE). The "qamats" character is more
 #     common, so it is mapped to the Unicode QAMATS; "qamats qatan" can
 #     only be used with a limited number of characters, and it is
 #     mapped using a corporate-zone variant tag (see below).
 #
 #   - Various Hebrew ligatures at 0x81, 0xC0, 0xC7, 0xC8, 0xD6, and
 #     0xD7. Also note that the Yiddish YOD YOD PATAH ligature at 0x81
 #     is missing in some fonts.
 #
 #   - The NEW SHEQEL SIGN at 0xA6.
 #
 #   - Latin characters with diacritics at 0x80 and 0x82-0x9F. However,
 #     most of these cannot be typed using the keyboard layouts in the
 #     Hebrew localized systems.
 #
 #   - Right-left versions of certain ASCII punctuation, symbols and
 #     digits: 0xA0-0xA5, 0xA7-0xBF, 0xFB-0xFF. See below.
 #
 #   - Miscellaneous additional punctuation at 0xC1, 0xC9, 0xCA, and
 #     0xD0-0xD5. There is a variant of the Hebrew encoding in which
 #     the LEFT SINGLE QUOTATION MARK at 0xD4 is replaced by FIGURE
 #     SPACE. The glyphs for some of the other punctuation characters
 #     are missing in some fonts.
 #
 #   - Four obsolete characters at 0xC2-0xC5 known as canorals (not to
 #     be confused with cantillation marks!). These were used for
 #     manual positioning of nikud marks before System 7.1 (at which
 #     point nikud positioning became automatic with WorldScript.).
 #
 #   2. Directional characters and roundtrip fidelity
 #
 #   The Mac OS Hebrew character set was developed around 1987. At that
 #   time the bidirectional line line layout algorithm used in the Mac OS
 #   Hebrew system was fairly simple; it used only a few direction
 #   classes (instead of the 19 now used in the Unicode bidirectional
 #   algorithm). In order to permit users to handle some tricky layou
 #   problems, certain punctuation, symbol, and digit characters have
 #   duplicate code points, one with a left-right direction attribute and
 #   the other with a right-left direction attribute.
 #
 #   For example, plus sign is encoded at 0x2B with a left-right
 #   attribute, and at 0xAB with a right-left attribute. However, there
 #   is only one PLUS SIGN character in Unicode. This leads to some
 #   interesting problems when mapping between Mac OS Hebrew and Unicode;
 #   see below.
 #
 #   A related problem is that even when a particular character is
 #   encoded only once in Mac OS Hebrew, it may have a different
 #   direction attribute than the corresponding Unicode character.
 #
 #   For example, the Mac OS Hebrew character at 0xC9 is HORIZONTAL
 #   ELLIPSIS with strong right-left direction. However, the Unicode
 #   character HORIZONTAL ELLIPSIS has direction class neutral.
 #
 #   3. Font variants
 #
 #   The table in this file gives the Unicode mappings for the standard
 #   Mac OS Hebrew encoding. This encoding is supported by many of the
 #   Apple fonts (including all of the fonts in the Hebrew Language Kit),
 #   and is the encoding supported by the text processing utilities.
 #   However, some TrueType fonts provided with the localized Hebrew
 #   system implement a slightly different encoding; the difference is
 #   only in one code point, 0xD4. For the standard variant, this is:
 #     0xD4 -> <RL>+0x2018  LEFT SINGLE QUOTATION MARK, right-left
 #
 #   The TrueType variant is used by the following TrueType fonts from
 #   the localized system: Caesarea, Carmel Book, Gilboa, Ramat Sharon,
 #   and Sinai Book. For these, 0xD4 is as follows:
 #     0xD4 -> <RL>+0x2007  FIGURE SPACE, right-left
 #
 # Unicode mapping issues and notes:
 # ---------------------------------
 #
 #   1. Matching the direction of Mac OS Hebrew characters
 #
 #   When Mac OS Hebrew encodes a character twice but with different
 #   direction attributes for the two code points - as in the case of
 #   plus sign mentioned above - we need a way to map both Mac OS Hebrew
 #   code points to Unicode and back again without loss of information.
 #   With the plus sign, for example, mapping one of the Mac OS Hebrew
 #   characters to a code in the Unicode corporate use zone is
 #   undesirable, since both of the plus sign characters are likely to
 #   be used in text that is interchanged.
 #
 #   The problem is solved with the use of direction override characters
 #   and direction-dependent mappings. When mapping from Mac OS Hebrew
 #   to Unicode, we use direction overrides as necessary to force the
 #   direction of the resulting Unicode characters.
 #
 #   The required direction is indicated by a direction tag in the
 #   mappings. A tag of <LR> means the corresponding Unicode character
 #   must have a strong left-right context, and a tag of <RL> indicates
 #   a right-left context.
 #
 #   For example, the mapping of 0x2B is given as <LR>+0x002B; the
 #   mapping of 0xAB is given as <RL>+0x002B. If we map an isolated
 #   instance of 0x2B to Unicode, it should be mapped as follows (LRO
 #   indicates LEFT-RIGHT OVERRIDE, PDF indicates POP DIRECTION
 #   FORMATTING):
 #
 #     0x2B ->  0x202D (LRO) + 0x002B (PLUS SIGN) + 0x202C (PDF)
 #
 #   When mapping several characters in a row that require direction
 #   forcing, the overrides need only be used at the beginning and end.
 #   For example:
 #
 #     0x24 0x20 0x28 0x29 -> 0x202D 0x0024 0x0020 0x0028 0x0029 0x202C
 #
 #   If neutral characters that require direction forcing are already
 #   between strong-direction characters with matching directionality,
 #   then direction overrides need not be used. Direction overrides are
 #   always needed to map the right-left digits at 0xB0-0xB9.
 #
 #   When mapping from Unicode to Mac OS Hebrew, the Unicode
 #   bidirectional algorithm should be used to determine resolved
 #   direction of the Unicode characters. The mapping from Unicode to
 #   Mac OS Hebrew can then be disambiguated by the use of the resolved
 #   direction:
 #
 #     Unicode 0x002B -> Mac OS Hebrew 0x2B (if L) or 0xAB (if R)
 #
 #   However, this also means the direction override characters should
 #   be discarded when mapping from Unicode to Mac OS Hebrew (after
 #   they have been used to determine resolved direction), since the
 #   direction override information is carried by the code point itself.
 #
 #   Even when direction overrides are not needed for roundtrip
 #   fidelity, they are sometimes used when mapping Mac OS Hebrew
 #   characters to Unicode in order to achieve similar text layout with
 #   the resulting Unicode text. For example, the single Mac OS Hebrew
 #   ellipsis character has direction class right-left,and there is no
 #   left-right version. However, the Unicode HORIZONTAL ELLIPSIS
 #   character has direction class neutral (which means it may end up
 #   with a resolved direction of left-right if surrounded by left-right
 #   characters). When mapping the Mac OS Hebrew ellipsis to Unicode, it
 #   is surrounded with a direction override to help preserve proper
 #   text layout. The resolved direction is not needed or used when
 #   mapping the Unicode HORIZONTAL ELLIPSIS back to Mac OS Hebrew.
 #
 #   2. Use of corporate-zone Unicodes
 #
 #   The goals in the mappings provided here are:
 #   - Ensure roundtrip mapping from every character in the Mac OS
 #     Hebrew character set to Unicode and back
 #   - Use standard Unicode characters as much as possible, to
 #     maximize interchangeability of the resulting Unicode text.
 #     Whenever possible, avoid having content carried by private-use
 #     characters.
 #
 #   Some of the characters in the Mac OS Hebrew character set do not
 #   correspond to distinct, single Unicode characters. To map these
 #   and satisfy both goals above, we employ various strategies.
 #
 #   a) If possible, use private use characters in combination with
 #   standard Unicode characters to mark variants of the standard
 #   Unicode character.
 #
 #   Apple has defined a block of 32 corporate characters as "transcoding
 #   hints." These are used in combination with standard Unicode characters
 #   to force them to be treated in a special way for mapping to other
 #   encodings; they have no other effect. Sixteen of these transcoding
 #   hints are "grouping hints" - they indicate that the next 2-4 Unicode
 #   characters should be treated as a single entity for transcoding. The
 #   other sixteen transcoding hints are "variant tags" - they are like
 #   combining characters, and can follow a standard Unicode (or a sequence
 #   consisting of a base character and other combining characters) to
 #   cause it to be treated in a special way for transcoding. These always
 #   terminate a combining-character sequence.
 #
 #   Two transcoding hints are used in this mapping table: a grouping hint
 #   and a variant tag:
 #   hint:
 #     0xF86A  group next 2 characters, right-left directionality
 #     0xF87F  variant tag
 #
 #   In Mac OS Hebrew, 0xC0 is a ligature for lamed holam. This can also
 #   be represented in Mac OS Hebrew as 0xEC+0xDD, using separate
 #   characters for lamed and holam. The latter sequence is mapped to
 #   Unicode as 0x05DC+0x05B9, i.e. as the sequence HEBREW LETTER LAMED +
 #   HEBREW POINT HOLAM. We want to map the ligature 0xC0 using the same
 #   standard Unicode characters, but for round-trip fidelity we need to
 #   distinguish it from the mapping of the sequence 0xEC+0xDD. Thus for
 #   0xC0 we use a grouping hint, and map as follows:
 #
 #     0xC0 -> 0xF86A+0x05DC+0x05B9
 #
 #   The variant tag is used for "qamats qatan" to mark it as an alternate
 #   for HEBREW POINT QAMATS, as follows:
 #
 #     0xDE -> 0x05B8+0xF87F
 #
 #   b) Otherwise, use private use characters by themselves to map Mac OS
 #   Hebrew characters which  have no relationship to any standard Unicode
 #   character.
 #
 #   The following additional corporate zone Unicode characters are used
 #   for this purpose here (to map the obsolete "canorals", see above):
 #
 #     0xF89B  Hebrew canoral 1
 #     0xF89C  Hebrew canoral 2
 #     0xF89D  Hebrew canoral 3
 #     0xF89E  Hebrew canoral 4
 #
 #   3. Roundtrip considerations when mapping to decomposed Unicode
 #
 #   Both Mac OS Hebrew and Unicode provide multiple ways of representing
 #   certain letter-and-point combinations. For example, HEBREW LETTER
 #   VAV WITH HOLAM can be represented in Unicode as the single character
 #   0xFB4B or as the sequence 0x05D5 0x05B9; similarly, it can be
 #   represented in Mac OS Hebrew as 0xC7 or as the sequence 0xE5 0xDD.
 #   This leads to some roundtrip problems. First note that we have the
 #   following mappings without such problems:
 #
 #   Mac   standard                            decomp. of     reverse map
 #   OS    Unicode mapping                     std. mapping   of decomp.
 #   ----  ----------------------------------  -------------  -----------
 #   0xC6  0x05BC  ... POINT DAGESH OR MAPIQ   0x05BC (same)  0xC6
 #   0xE5  0x05D5  ... LETTER VAV              0x05D5 (same)  0xE5
 #   0xDD  0x05B9  ... POINT HOLAM             0x05B9 (same)  0xDD
 #
 #   However, those mappings above cause roundtrip problems for the
 #   the following mappings if they are decomposed:
 #
 #   Mac   standard                            decomp. of     reverse map
 #   OS    Unicode mapping                     std. mapping   of decomp.
 #   ----  ----------------------------------  -------------  -----------
 #   0xC7  0xFB4B  ... LETTER VAV WITH HOLAM   0x05D5 0x05B9  0xE5 0xDD
 #   0xC8  0xFB35  ... LETTER VAV WITH DAGESH  0x05D5 0x05BC  0xE5 0xC6
 #
 #   One solution is to use a grouping transcoding hint with the two
 #   decompositions above to mark the decomposed sequence for special
 #   treatment in transcoding. This yields the following mappings to
 #   decomposed Unicode:
 #
 #   Mac                                decomposed
 #   OS                                 Unicode mapping
 #   ----                               --------------------
 #   0xC7                               0xF86A 0x05D5 0x05B9
 #   0xC8                               0xF86A 0x05D5 0x05BC
 #
 # Details of mapping changes in each version:
 # -------------------------------------------
 #
 #   Changes from version b02 to version b03/c01:
 #
 #   - Stop specifying left-right context for digits 0x30-0x39, since the
 #     corresponding Unicodes 0x0030-0x0039 already have left-right
 #     directionality.
 #
 #   - Change mapping of 0x81 from 0xFB1F HEBREW LIGATURE YIDDISH YOD YOD
 #     PATAH to its canonical decomposition 0x05F2+0x05B7 to improve
 #     cross-platform compatibility (Windows doesn't handle 0xFB1F)
 #
 #   - Interchange the mappings of 0xA8 and 0xA9 to obtain the correct
 #     open/close behavior; they work differently than in Mac Arabic.
 #     The old mapping was
 #         0xA8 <RL>+0x0028 # LEFT PARENTHESIS, right-left
 #         0xA9 <RL>+0x0029 # RIGHT PARENTHESIS, right-left
 #     and the new mapping is
 #         0xA8 <RL>+0x0029 # RIGHT PARENTHESIS, right-left
 #         0xA9 <RL>+0x0028 # LEFT PARENTHESIS, right-left
 #
 #   Changes from version n01 to version n03:
 #
 #   - Change mapping for 0xC0 from single corporate character to
 #     grouping hint plus standard Unicodes
 #
 #   - Change mapping for 0xDE from single corporate character to
 #     standard Unicode plus variant tag
 #
 ##################
 */

import Foundation

let macHebrewEncoding: [UVBMP] = [
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
    0x0020,       /* 20  SPACE, left-right */
    0x0021,       /* 21  EXCLAMATION MARK, left-right */
    0x0022,       /* 22  QUOTATION MARK, left-right */
    0x0023,       /* 23  NUMBER SIGN, left-right */
    0x0024,       /* 24  DOLLAR SIGN, left-right */
    0x0025,       /* 25  PERCENT SIGN, left-right */
    0x0026,       /* 26  AMPERSAND */
    0x0027,       /* 27  APOSTROPHE, left-right */
    0x0028,       /* 28  LEFT PARENTHESIS, left-right */
    0x0029,       /* 29  RIGHT PARENTHESIS, left-right */
    0x002A,       /* 2A  ASTERISK, left-right */
    0x002B,       /* 2B  PLUS SIGN, left-right */
    0x002C,       /* 2C  COMMA, left-right */
    0x002D,       /* 2D  HYPHEN-MINUS, left-right */
    0x002E,       /* 2E  FULL STOP, left-right */
    0x002F,       /* 2F  SOLIDUS, left-right */
    0x0030,       /* 30  DIGIT ZERO, left-right */
    0x0031,       /* 31  DIGIT ONE, left-right */
    0x0032,       /* 32  DIGIT TWO, left-right */
    0x0033,       /* 33  DIGIT THREE, left-right */
    0x0034,       /* 34  DIGIT FOUR, left-right */
    0x0035,       /* 35  DIGIT FIVE, left-right */
    0x0036,       /* 36  DIGIT SIX, left-right */
    0x0037,       /* 37  DIGIT SEVEN, left-right */
    0x0038,       /* 38  DIGIT EIGHT, left-right */
    0x0039,       /* 39  DIGIT NINE, left-right */
    0x003A,       /* 3A  COLON, left-right */
    0x003B,       /* 3B  SEMICOLON, left-right */
    0x003C,       /* 3C  LESS-THAN SIGN, left-right */
    0x003D,       /* 3D  EQUALS SIGN, left-right */
    0x003E,       /* 3E  GREATER-THAN SIGN, left-right */
    0x003F,       /* 3F  QUESTION MARK, left-right */
    0x0040,       /* 40  COMMERCIAL AT */
    0x0041,       /* 41  LATIN CAPITAL LETTER A */
    0x0042,       /* 42  LATIN CAPITAL LETTER B */
    0x0043,       /* 43  LATIN CAPITAL LETTER C */
    0x0044,       /* 44  LATIN CAPITAL LETTER D */
    0x0045,       /* 45  LATIN CAPITAL LETTER E */
    0x0046,       /* 46  LATIN CAPITAL LETTER F */
    0x0047,       /* 47  LATIN CAPITAL LETTER G */
    0x0048,       /* 48  LATIN CAPITAL LETTER H */
    0x0049,       /* 49  LATIN CAPITAL LETTER I */
    0x004A,       /* 4A  LATIN CAPITAL LETTER J */
    0x004B,       /* 4B  LATIN CAPITAL LETTER K */
    0x004C,       /* 4C  LATIN CAPITAL LETTER L */
    0x004D,       /* 4D  LATIN CAPITAL LETTER M */
    0x004E,       /* 4E  LATIN CAPITAL LETTER N */
    0x004F,       /* 4F  LATIN CAPITAL LETTER O */
    0x0050,       /* 50  LATIN CAPITAL LETTER P */
    0x0051,       /* 51  LATIN CAPITAL LETTER Q */
    0x0052,       /* 52  LATIN CAPITAL LETTER R */
    0x0053,       /* 53  LATIN CAPITAL LETTER S */
    0x0054,       /* 54  LATIN CAPITAL LETTER T */
    0x0055,       /* 55  LATIN CAPITAL LETTER U */
    0x0056,       /* 56  LATIN CAPITAL LETTER V */
    0x0057,       /* 57  LATIN CAPITAL LETTER W */
    0x0058,       /* 58  LATIN CAPITAL LETTER X */
    0x0059,       /* 59  LATIN CAPITAL LETTER Y */
    0x005A,       /* 5A  LATIN CAPITAL LETTER Z */
    0x005B,       /* 5B  LEFT SQUARE BRACKET, left-right */
    0x005C,       /* 5C  REVERSE SOLIDUS */
    0x005D,       /* 5D  RIGHT SQUARE BRACKET, left-right */
    0x005E,       /* 5E  CIRCUMFLEX ACCENT */
    0x005F,       /* 5F  LOW LINE */
    0x0060,       /* 60  GRAVE ACCENT */
    0x0061,       /* 61  LATIN SMALL LETTER A */
    0x0062,       /* 62  LATIN SMALL LETTER B */
    0x0063,       /* 63  LATIN SMALL LETTER C */
    0x0064,       /* 64  LATIN SMALL LETTER D */
    0x0065,       /* 65  LATIN SMALL LETTER E */
    0x0066,       /* 66  LATIN SMALL LETTER F */
    0x0067,       /* 67  LATIN SMALL LETTER G */
    0x0068,       /* 68  LATIN SMALL LETTER H */
    0x0069,       /* 69  LATIN SMALL LETTER I */
    0x006A,       /* 6A  LATIN SMALL LETTER J */
    0x006B,       /* 6B  LATIN SMALL LETTER K */
    0x006C,       /* 6C  LATIN SMALL LETTER L */
    0x006D,       /* 6D  LATIN SMALL LETTER M */
    0x006E,       /* 6E  LATIN SMALL LETTER N */
    0x006F,       /* 6F  LATIN SMALL LETTER O */
    0x0070,       /* 70  LATIN SMALL LETTER P */
    0x0071,       /* 71  LATIN SMALL LETTER Q */
    0x0072,       /* 72  LATIN SMALL LETTER R */
    0x0073,       /* 73  LATIN SMALL LETTER S */
    0x0074,       /* 74  LATIN SMALL LETTER T */
    0x0075,       /* 75  LATIN SMALL LETTER U */
    0x0076,       /* 76  LATIN SMALL LETTER V */
    0x0077,       /* 77  LATIN SMALL LETTER W */
    0x0078,       /* 78  LATIN SMALL LETTER X */
    0x0079,       /* 79  LATIN SMALL LETTER Y */
    0x007A,       /* 7A  LATIN SMALL LETTER Z */
    0x007B,       /* 7B  LEFT CURLY BRACKET, left-right */
    0x007C,       /* 7C  VERTICAL LINE, left-right */
    0x007D,       /* 7D  RIGHT CURLY BRACKET, left-right */
    0x007E,       /* 7E  TILDE */
    .undefined,   /* 7F */
    0x00C4,       /* 80  LATIN CAPITAL LETTER A WITH DIAERESIS */
    0xFB1F,       /* 81  HEBREW LIGATURE YIDDISH YOD YOD PATAH */
    0x00C7,       /* 82  LATIN CAPITAL LETTER C WITH CEDILLA */
    0x00C9,       /* 83  LATIN CAPITAL LETTER E WITH ACUTE */
    0x00D1,       /* 84  LATIN CAPITAL LETTER N WITH TILDE */
    0x00D6,       /* 85  LATIN CAPITAL LETTER O WITH DIAERESIS */
    0x00DC,       /* 86  LATIN CAPITAL LETTER U WITH DIAERESIS */
    0x00E1,       /* 87  LATIN SMALL LETTER A WITH ACUTE */
    0x00E0,       /* 88  LATIN SMALL LETTER A WITH GRAVE */
    0x00E2,       /* 89  LATIN SMALL LETTER A WITH CIRCUMFLEX */
    0x00E4,       /* 8A  LATIN SMALL LETTER A WITH DIAERESIS */
    0x00E3,       /* 8B  LATIN SMALL LETTER A WITH TILDE */
    0x00E5,       /* 8C  LATIN SMALL LETTER A WITH RING ABOVE */
    0x00E7,       /* 8D  LATIN SMALL LETTER C WITH CEDILLA */
    0x00E9,       /* 8E  LATIN SMALL LETTER E WITH ACUTE */
    0x00E8,       /* 8F  LATIN SMALL LETTER E WITH GRAVE */
    0x00EA,       /* 90  LATIN SMALL LETTER E WITH CIRCUMFLEX */
    0x00EB,       /* 91  LATIN SMALL LETTER E WITH DIAERESIS */
    0x00ED,       /* 92  LATIN SMALL LETTER I WITH ACUTE */
    0x00EC,       /* 93  LATIN SMALL LETTER I WITH GRAVE */
    0x00EE,       /* 94  LATIN SMALL LETTER I WITH CIRCUMFLEX */
    0x00EF,       /* 95  LATIN SMALL LETTER I WITH DIAERESIS */
    0x00F1,       /* 96  LATIN SMALL LETTER N WITH TILDE */
    0x00F3,       /* 97  LATIN SMALL LETTER O WITH ACUTE */
    0x00F2,       /* 98  LATIN SMALL LETTER O WITH GRAVE */
    0x00F4,       /* 99  LATIN SMALL LETTER O WITH CIRCUMFLEX */
    0x00F6,       /* 9A  LATIN SMALL LETTER O WITH DIAERESIS */
    0x00F5,       /* 9B  LATIN SMALL LETTER O WITH TILDE */
    0x00FA,       /* 9C  LATIN SMALL LETTER U WITH ACUTE */
    0x00F9,       /* 9D  LATIN SMALL LETTER U WITH GRAVE */
    0x00FB,       /* 9E  LATIN SMALL LETTER U WITH CIRCUMFLEX */
    0x00FC,       /* 9F  LATIN SMALL LETTER U WITH DIAERESIS */
    0x0020,       /* A0  SPACE, right-left */
    0x0021,       /* A1  EXCLAMATION MARK, right-left */
    0x0022,       /* A2  QUOTATION MARK, right-left */
    0x0023,       /* A3  NUMBER SIGN, right-left */
    0x0024,       /* A4  DOLLAR SIGN, right-left */
    0x0025,       /* A5  PERCENT SIGN, right-left */
    0x20AA,       /* A6  NEW SHEQEL SIGN */
    0x0027,       /* A7  APOSTROPHE, right-left */
    0x0028,       /* A8  LEFT PARENTHESIS, right-left */
    0x0029,       /* A9  RIGHT PARENTHESIS, right-left */
    0x002A,       /* AA  ASTERISK, right-left */
    0x002B,       /* AB  PLUS SIGN, right-left */
    0x002C,       /* AC  COMMA, right-left */
    0x002D,       /* AD  HYPHEN-MINUS, right-left */
    0x002E,       /* AE  FULL STOP, right-left */
    0x002F,       /* AF  SOLIDUS, right-left */
    0x0030,       /* B0  DIGIT ZERO, right-left */
    0x0031,       /* B1  DIGIT ONE, right-left */
    0x0032,       /* B2  DIGIT TWO, right-left */
    0x0033,       /* B3  DIGIT THREE, right-left */
    0x0034,       /* B4  DIGIT FOUR, right-left */
    0x0035,       /* B5  DIGIT FIVE, right-left */
    0x0036,       /* B6  DIGIT SIX, right-left */
    0x0037,       /* B7  DIGIT SEVEN, right-left */
    0x0038,       /* B8  DIGIT EIGHT, right-left */
    0x0039,       /* B9  DIGIT NINE, right-left */
    0x003A,       /* BA  COLON, right-left */
    0x003B,       /* BB  SEMICOLON, right-left */
    0x003C,       /* BC  LESS-THAN SIGN, right-left */
    0x003D,       /* BD  EQUALS SIGN, right-left */
    0x003E,       /* BE  GREATER-THAN SIGN, right-left */
    0x003F,       /* BF  QUESTION MARK, right-left */
    0xF89A,       /* C0  Hebrew ligature lamed holam (0xF86A+0x05DC+0x05B9) */
    0x201E,       /* C1  DOUBLE LOW-9 QUOTATION MARK, right-left */
    0xF89B,       /* C2  Hebrew canoral 1 */
    0xF89C,       /* C3  Hebrew canoral 2 */
    0xF89D,       /* C4  Hebrew canoral 3 */
    0xF89E,       /* C5  Hebrew canoral 4 */
    0x05BC,       /* C6  HEBREW POINT DAGESH OR MAPIQ */
    0xFB4B,       /* C7  HEBREW LETTER VAV WITH HOLAM */
    0xFB35,       /* C8  HEBREW LETTER VAV WITH DAGESH */
    0x2026,       /* C9  HORIZONTAL ELLIPSIS, right-left */
    0x00A0,       /* CA  NO-BREAK SPACE, right-left */
    0x05B8,       /* CB  HEBREW POINT QAMATS */
    0x05B7,       /* CC  HEBREW POINT PATAH */
    0x05B5,       /* CD  HEBREW POINT TSERE */
    0x05B6,       /* CE  HEBREW POINT SEGOL */
    0x05B4,       /* CF  HEBREW POINT HIRIQ */
    0x2013,       /* D0  EN DASH, right-left */
    0x2014,       /* D1  EM DASH, right-left */
    0x201C,       /* D2  LEFT DOUBLE QUOTATION MARK, right-left */
    0x201D,       /* D3  RIGHT DOUBLE QUOTATION MARK, right-left */
    0x2018,       /* D4  LEFT SINGLE QUOTATION MARK, right-left */
    0x2019,       /* D5  RIGHT SINGLE QUOTATION MARK, right-left */
    0xFB2A,       /* D6  HEBREW LETTER SHIN WITH SHIN DOT */
    0xFB2B,       /* D7  HEBREW LETTER SHIN WITH SIN DOT */
    0x05BF,       /* D8  HEBREW POINT RAFE */
    0x05B0,       /* D9  HEBREW POINT SHEVA */
    0x05B2,       /* DA  HEBREW POINT HATAF PATAH */
    0x05B1,       /* DB  HEBREW POINT HATAF SEGOL */
    0x05BB,       /* DC  HEBREW POINT QUBUTS */
    0x05B9,       /* DD  HEBREW POINT HOLAM */
    0xF89F,       /* DE  HEBREW POINT QAMATS, alternate form "qamats qatan" (0x05B8+0xF87F) */
    0x05B3,       /* DF  HEBREW POINT HATAF QAMATS */
    0x05D0,       /* E0  HEBREW LETTER ALEF */
    0x05D1,       /* E1  HEBREW LETTER BET */
    0x05D2,       /* E2  HEBREW LETTER GIMEL */
    0x05D3,       /* E3  HEBREW LETTER DALET */
    0x05D4,       /* E4  HEBREW LETTER HE */
    0x05D5,       /* E5  HEBREW LETTER VAV */
    0x05D6,       /* E6  HEBREW LETTER ZAYIN */
    0x05D7,       /* E7  HEBREW LETTER HET */
    0x05D8,       /* E8  HEBREW LETTER TET */
    0x05D9,       /* E9  HEBREW LETTER YOD */
    0x05DA,       /* EA  HEBREW LETTER FINAL KAF */
    0x05DB,       /* EB  HEBREW LETTER KAF */
    0x05DC,       /* EC  HEBREW LETTER LAMED */
    0x05DD,       /* ED  HEBREW LETTER FINAL MEM */
    0x05DE,       /* EE  HEBREW LETTER MEM */
    0x05DF,       /* EF  HEBREW LETTER FINAL NUN */
    0x05E0,       /* F0  HEBREW LETTER NUN */
    0x05E1,       /* F1  HEBREW LETTER SAMEKH */
    0x05E2,       /* F2  HEBREW LETTER AYIN */
    0x05E3,       /* F3  HEBREW LETTER FINAL PE */
    0x05E4,       /* F4  HEBREW LETTER PE */
    0x05E5,       /* F5  HEBREW LETTER FINAL TSADI */
    0x05E6,       /* F6  HEBREW LETTER TSADI */
    0x05E7,       /* F7  HEBREW LETTER QOF */
    0x05E8,       /* F8  HEBREW LETTER RESH */
    0x05E9,       /* F9  HEBREW LETTER SHIN */
    0x05EA,       /* FA  HEBREW LETTER TAV */
    0x007D,       /* FB  RIGHT CURLY BRACKET, right-left */
    0x005D,       /* FC  RIGHT SQUARE BRACKET, right-left */
    0x007B,       /* FD  LEFT CURLY BRACKET, right-left */
    0x005B,       /* FE  LEFT SQUARE BRACKET, right-left */
    0x007C,       /* FF  VERTICAL LINE, right-left */
]
