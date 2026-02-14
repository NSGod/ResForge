//
//  macArabicEncoding.swift
//  CoreFont
//
//  Created by Mark Douma on 1/1/2026.
//

/* Copyright 2014 Adobe Systems Incorporated (http://www.adobe.com/). All Rights Reserved.
   This software is licensed as OpenSource, under the Apache License, Version 2.0.
   This license is available at: http://opensource.org/licenses/Apache-2.0. */

/* Mac OS Arabic aggregate Unicode initializer.

   Element values are UVs. UV_UNDEF is 0xFFFF. Index by code, get UV.
   Source: ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/APPLE/ARABIC.TXT
   as of 9/9/99. */

/*
 # Format:
 # -------
 #
 #   Three tab-separated columns;
 #   '#' begins a comment which continues to the end of the line.
 #     Column #1 is the Mac OS Arabic code (in hex as 0xNN).
 #     Column #2 is the corresponding Unicode (in hex as 0xNNNN),
 #       possibly preceded by a tag indicating required directionality
 #       (i.e. <LR>+0xNNNN or <RL>+0xNNNN).
 #     Column #3 is a comment containing the Unicode name.
 #
 #   The entries are in Mac OS Arabic code order.
 #
 #   Control character mappings are not shown in this table, following
 #   the conventions of the standard UTC mapping tables. However, the
 #   Mac OS Arabic character set uses the standard control characters at
 #   0x00-0x1F and 0x7F.
 #
 # Notes on Mac OS Arabic:
 # -----------------------
 #
 #   This is a legacy Mac OS encoding; in the Mac OS X Carbon and Cocoa
 #   environments, it is only supported via transcoding to and from
 #   Unicode.
 #
 #   1. General
 #
 #   The Mac OS Arabic character set is intended to cover Arabic as
 #   used in North Africa, the Arabian peninsula, and the Levant. It
 #   also contains several characters needed for Urdu and/or Farsi.
 #
 #   The Mac OS Arabic character set is essentially a superset of ISO
 #   8859-6. The 8859-6 code points that are interpreted differently
 #   in the Mac OS Arabic set are as follows:
 #    0xA0 is NO-BREAK SPACE in 8859-6 and right-left SPACE in Mac OS
 #         Arabic; NO-BREAK is 0x81 in Mac OS Arabic.
 #    0xA4 is CURRENCY SIGN in 8859-6 and right-left DOLLAR SIGN in
 #         Mac OS Arabic.
 #    0xAD is SOFT HYPHEN in 8859-6 and right-left HYPHEN-MINUS in
 #         Mac OS Arabic.
 #   ISO 8859-6 specifies that codes 0x30-0x39 can be rendered either
 #   with European digit shapes or Arabic digit shapes. This is also
 #   true in Mac OS Arabic, which determines from context which digit
 #   shapes to use (see below).
 #
 #   The Mac OS Arabic character set uses the C1 controls area and other
 #   code points which are undefined in ISO 8859-6 for additional
 #   graphic characters: additional Arabic letters for Farsi and Urdu,
 #   some accented Roman letters for European languages (such as French),
 #   and duplicates of some of the punctuation, symbols, and digits in
 #   the ASCII block. The duplicate punctuation, symbol, and digit
 #   characters have right-left directionality, while the ASCII versions
 #   have left-right directionality. See the next section for more
 #   information on this.
 #
 #   Mac OS Arabic characters 0xEB-0xF2 are non-spacing/combining marks.
 #
 #   2. Directional characters and roundtrip fidelity
 #
 #   The Mac OS Arabic character set was developed in 1986-1987. At that
 #   time the bidirectional line layout algorithm used in the Mac OS
 #   Arabic system was fairly simple; it used only a few direction
 #   classes (instead of the 19 now used in the Unicode bidirectional
 #   algorithm). In order to permit users to handle some tricky layout
 #   problems, certain punctuation and symbol characters were encoded
 #   twice, one with a left-right direction attribute and the other with
 #   a right-left direction attribute.
 #
 #   For example, plus sign is encoded at 0x2B with a left-right
 #   attribute, and at 0xAB with a right-left attribute. However, there
 #   is only one PLUS SIGN character in Unicode. This leads to some
 #   interesting problems when mapping between Mac OS Arabic and Unicode;
 #   see below.
 #
 #   A related problem is that even when a particular character is
 #   encoded only once in Mac OS Arabic, it may have a different
 #   direction attribute than the corresponding Unicode character.
 #
 #   For example, the Mac OS Arabic character at 0x93 is HORIZONTAL
 #   ELLIPSIS with strong right-left direction. However, the Unicode
 #   character HORIZONTAL ELLIPSIS has direction class neutral.
 #
 #   3. Behavior of ASCII-range numbers in WorldScript
 #
 #   Mac OS Arabic also has two sets of digit codes.
 #
 #   The digits at 0x30-0x39 may be displayed using either European
 #   digit forms or Arabic digit forms, depending on context. If there
 #   is a "strong European" character such as a Latin letter on either
 #   side of a sequence consisting of digits 0x30-0x39 and possibly comma
 #   0x2C or period 0x2E, then the characters will be displayed using
 #   European forms (This will happen even if there are neutral characters
 #   between the digits and the strong European character). Otherwise, the
 #   digits will be displayed using Arabic forms, the comma will be
 #   displayed as Arabic thousands separator, and the period as Arabic
 #   decimal separator. In any case, 0x2C, 0x2E, and 0x30-0x39 are always
 #   left-right.
 #
 #   The digits at 0xB0-0xB9 are always displayed using Arabic digit
 #   shapes, and moreover, these digits always have strong right-left
 #   directionality. These are mainly intended for special layout
 #   purposes such as part numbers, etc.
 #
 #   4. Font variants
 #
 #   The table in this file gives the Unicode mappings for the standard
 #   Mac OS Arabic encoding. This encoding is supported by the Cairo font
 #   (the system font for Arabic), and is the encoding supported by the
 #   text processing utilities. However, the other Arabic fonts actually
 #   implement slightly different encodings; this mainly affects the code
 #   points 0xAA and 0xC0. For these code points the standard Mac OS
 #   Arabic encoding has the following mappings:
 #     0xAA -> <RL>+0x002A ASTERISK, right-left
 #     0xC0 -> <RL>+0x274A EIGHT TEARDROP-SPOKED PROPELLER ASTERISK,
 #                         right-left
 #   This mapping of 0xAA is consistent with the normal convention for
 #   Mac OS Arabic and Hebrew that the right-left duplicates have codes
 #   that are equal to the ASCII code of the left-right character plus
 #   0x80. However, in all of the other fonts, 0xAA is MULTIPLY SIGN, and
 #   right-left ASTERISK may be at a different code point. The other
 #   variants are described below.
 #
 #   The TrueType variant is used for most of the Arabic TrueType fonts:
 #   Baghdad, Geeza, Kufi, Nadeem.  It differs from the standard variant
 #   in the following way:
 #     0xAA -> <RL>+0x00D7 MULTIPLICATION SIGN, right-left
 #     0xC0 -> <RL>+0x002A ASTERISK, right-left
 #
 #   The Thuluth variant is used for the Arabic Postscript-only fonts:
 #   Thuluth and Thuluth bold. It differs from the standard variant in
 #   the following way:
 #     0xAA -> <RL>+0x00D7 MULTIPLICATION SIGN, right-left
 #     0xC0 -> 0x066D ARABIC FIVE POINTED STAR
 #
 #   The AlBayan variant is used for the Arabic TrueType font Al Bayan.
 #   It differs from the standard variant in the following way:
 #     0x81 -> no mapping (glyph just has authorship information, etc.)
 #     0xA3 -> 0xFDFA ARABIC LIGATURE SALLALLAHOU ALAYHE WASALLAM
 #     0xA4 -> 0xFDF2 ARABIC LIGATURE ALLAH ISOLATED FORM
 #     0xAA -> <RL>+0x00D7 MULTIPLICATION SIGN, right-left
 #     0xDC -> <RL>+0x25CF BLACK CIRCLE, right-left
 #     0xFC -> <RL>+0x25A0 BLACK SQUARE, right-left
 #
 # Unicode mapping issues and notes:
 # ---------------------------------
 #
 #   1. Matching the direction of Mac OS Arabic characters
 #
 #   When Mac OS Arabic encodes a character twice but with different
 #   direction attributes for the two code points - as in the case of
 #   plus sign mentioned above - we need a way to map both Mac OS Arabic
 #   code points to Unicode and back again without loss of information.
 #   With the plus sign, for example, mapping one of the Mac OS Arabic
 #   characters to a code in the Unicode corporate use zone is
 #   undesirable, since both of the plus sign characters are likely to
 #   be used in text that is interchanged.
 #
 #   The problem is solved with the use of direction override characters
 #   and direction-dependent mappings. When mapping from Mac OS Arabic
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
 #   When mapping from Unicode to Mac OS Arabic, the Unicode
 #   bidirectional algorithm should be used to determine resolved
 #   direction of the Unicode characters. The mapping from Unicode to
 #   Mac OS Arabic can then be disambiguated by the use of the resolved
 #   direction:
 #
 #     Unicode 0x002B -> Mac OS Arabic 0x2B (if L) or 0xAB (if R)
 #
 #   However, this also means the direction override characters should
 #   be discarded when mapping from Unicode to Mac OS Arabic (after
 #   they have been used to determine resolved direction), since the
 #   direction override information is carried by the code point itself.
 #
 #   Even when direction overrides are not needed for roundtrip
 #   fidelity, they are sometimes used when mapping Mac OS Arabic
 #   characters to Unicode in order to achieve similar text layout with
 #   the resulting Unicode text. For example, the single Mac OS Arabic
 #   ellipsis character has direction class right-left,and there is no
 #   left-right version. However, the Unicode HORIZONTAL ELLIPSIS
 #   character has direction class neutral (which means it may end up
 #   with a resolved direction of left-right if surrounded by left-right
 #   characters). When mapping the Mac OS Arabic ellipsis to Unicode, it
 #   is surrounded with a direction override to help preserve proper
 #   text layout. The resolved direction is not needed or used when
 #   mapping the Unicode HORIZONTAL ELLIPSIS back to Mac OS Arabic.
 #
 #   2. Mapping the Mac OS Arabic digits
 #
 #   The main table below contains mappings that should be used when
 #   strict round-trip fidelity is required. However, for numeric
 #   values, the mappings in that table will produce Unicode characters
 #   that may appear different than the Mac OS Arabic text displayed on
 #   a Mac OS system using WorldScript. This is because WorldScript
 #   uses context-dependent display for the 0x30-0x39 digits.
 #
 #   If roundtrip fidelity is not required, then the following
 #   alternate mappings should be used when a sequence of 0x30-0x39
 #   digits - possibly including 0x2C and 0x2E - occurs in an Arabic
 #   context (that is, when the first "strong" character on either side
 #   of the digit sequence is Arabic, or there is no strong character):
 #
 #     0x2C    0x066C    # ARABIC THOUSANDS SEPARATOR
 #     0x2E    0x066B    # ARABIC DECIMAL SEPARATOR
 #     0x30    0x0660    # ARABIC-INDIC DIGIT ZERO
 #     0x31    0x0661    # ARABIC-INDIC DIGIT ONE
 #     0x32    0x0662    # ARABIC-INDIC DIGIT TWO
 #     0x33    0x0663    # ARABIC-INDIC DIGIT THREE
 #     0x34    0x0664    # ARABIC-INDIC DIGIT FOUR
 #     0x35    0x0665    # ARABIC-INDIC DIGIT FIVE
 #     0x36    0x0666    # ARABIC-INDIC DIGIT SIX
 #     0x37    0x0667    # ARABIC-INDIC DIGIT SEVEN
 #     0x38    0x0668    # ARABIC-INDIC DIGIT EIGHT
 #     0x39    0x0669    # ARABIC-INDIC DIGIT NINE
 #
 # Details of mapping changes in each version:
 # -------------------------------------------
 #
 #   Changes from version n03 to version n07:
 #
 #   - Change mapping for 0xC0 from U+066D to U+274A.
 #
 #   - Add direction overrides (required directionality) to mappings
 #     for 0x25, 0x2C, 0x3B, 0x3F.
 #
 */

import Foundation

let macArabicEncoding: [UVBMP] = [
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
    0x0026,       /* 26  AMPERSAND, left-right */
    0x0027,       /* 27  APOSTROPHE, left-right */
    0x0028,       /* 28  LEFT PARENTHESIS, left-right */
    0x0029,       /* 29  RIGHT PARENTHESIS, left-right */
    0x002A,       /* 2A  ASTERISK, left-right */
    0x002B,       /* 2B  PLUS SIGN, left-right */
    0x002C,       /* 2C  COMMA, left-right */
    0x002D,       /* 2D  HYPHEN-MINUS, left-right */
    0x002E,       /* 2E  FULL STOP, left-right */
    0x002F,       /* 2F  SOLIDUS, left-right */
    0x0030,       /* 30  DIGIT ZERO */
    0x0031,       /* 31  DIGIT ONE */
    0x0032,       /* 32  DIGIT TWO */
    0x0033,       /* 33  DIGIT THREE */
    0x0034,       /* 34  DIGIT FOUR */
    0x0035,       /* 35  DIGIT FIVE */
    0x0036,       /* 36  DIGIT SIX */
    0x0037,       /* 37  DIGIT SEVEN */
    0x0038,       /* 38  DIGIT EIGHT */
    0x0039,       /* 39  DIGIT NINE */
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
    0x005C,       /* 5C  REVERSE SOLIDUS, left-right */
    0x005D,       /* 5D  RIGHT SQUARE BRACKET, left-right */
    0x005E,       /* 5E  CIRCUMFLEX ACCENT, left-right */
    0x005F,       /* 5F  LOW LINE, left-right */
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
    0x00A0,       /* 81  NO-BREAK SPACE, right-left */
    0x00C7,       /* 82  LATIN CAPITAL LETTER C WITH CEDILLA */
    0x00C9,       /* 83  LATIN CAPITAL LETTER E WITH ACUTE */
    0x00D1,       /* 84  LATIN CAPITAL LETTER N WITH TILDE */
    0x00D6,       /* 85  LATIN CAPITAL LETTER O WITH DIAERESIS */
    0x00DC,       /* 86  LATIN CAPITAL LETTER U WITH DIAERESIS */
    0x00E1,       /* 87  LATIN SMALL LETTER A WITH ACUTE */
    0x00E0,       /* 88  LATIN SMALL LETTER A WITH GRAVE */
    0x00E2,       /* 89  LATIN SMALL LETTER A WITH CIRCUMFLEX */
    0x00E4,       /* 8A  LATIN SMALL LETTER A WITH DIAERESIS */
    0x06BA,       /* 8B  ARABIC LETTER NOON GHUNNA */
    0x00AB,       /* 8C  LEFT-POINTING DOUBLE ANGLE QUOTATION MARK, right-left */
    0x00E7,       /* 8D  LATIN SMALL LETTER C WITH CEDILLA */
    0x00E9,       /* 8E  LATIN SMALL LETTER E WITH ACUTE */
    0x00E8,       /* 8F  LATIN SMALL LETTER E WITH GRAVE */
    0x00EA,       /* 90  LATIN SMALL LETTER E WITH CIRCUMFLEX */
    0x00EB,       /* 91  LATIN SMALL LETTER E WITH DIAERESIS */
    0x00ED,       /* 92  LATIN SMALL LETTER I WITH ACUTE */
    0x2026,       /* 93  HORIZONTAL ELLIPSIS, right-left */
    0x00EE,       /* 94  LATIN SMALL LETTER I WITH CIRCUMFLEX */
    0x00EF,       /* 95  LATIN SMALL LETTER I WITH DIAERESIS */
    0x00F1,       /* 96  LATIN SMALL LETTER N WITH TILDE */
    0x00F3,       /* 97  LATIN SMALL LETTER O WITH ACUTE */
    0x00BB,       /* 98  RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK, right-left */
    0x00F4,       /* 99  LATIN SMALL LETTER O WITH CIRCUMFLEX */
    0x00F6,       /* 9A  LATIN SMALL LETTER O WITH DIAERESIS */
    0x00F7,       /* 9B  DIVISION SIGN, right-left */
    0x00FA,       /* 9C  LATIN SMALL LETTER U WITH ACUTE */
    0x00F9,       /* 9D  LATIN SMALL LETTER U WITH GRAVE */
    0x00FB,       /* 9E  LATIN SMALL LETTER U WITH CIRCUMFLEX */
    0x00FC,       /* 9F  LATIN SMALL LETTER U WITH DIAERESIS */
    0x0020,       /* A0  SPACE, right-left */
    0x0021,       /* A1  EXCLAMATION MARK, right-left */
    0x0022,       /* A2  QUOTATION MARK, right-left */
    0x0023,       /* A3  NUMBER SIGN, right-left */
    0x0024,       /* A4  DOLLAR SIGN, right-left */
    0x066A,       /* A5  ARABIC PERCENT SIGN */
    0x0026,       /* A6  AMPERSAND, right-left */
    0x0027,       /* A7  APOSTROPHE, right-left */
    0x0028,       /* A8  LEFT PARENTHESIS, right-left */
    0x0029,       /* A9  RIGHT PARENTHESIS, right-left */
    0x002A,       /* AA  ASTERISK, right-left */
    0x002B,       /* AB  PLUS SIGN, right-left */
    0x060C,       /* AC  ARABIC COMMA */
    0x002D,       /* AD  HYPHEN-MINUS, right-left */
    0x002E,       /* AE  FULL STOP, right-left */
    0x002F,       /* AF  SOLIDUS, right-left */
    0x0660,       /* B0  ARABIC-INDIC DIGIT ZERO, right-left */
    0x0661,       /* B1  ARABIC-INDIC DIGIT ONE, right-left */
    0x0662,       /* B2  ARABIC-INDIC DIGIT TWO, right-left */
    0x0663,       /* B3  ARABIC-INDIC DIGIT THREE, right-left */
    0x0664,       /* B4  ARABIC-INDIC DIGIT FOUR, right-left */
    0x0665,       /* B5  ARABIC-INDIC DIGIT FIVE, right-left */
    0x0666,       /* B6  ARABIC-INDIC DIGIT SIX, right-left */
    0x0667,       /* B7  ARABIC-INDIC DIGIT SEVEN, right-left */
    0x0668,       /* B8  ARABIC-INDIC DIGIT EIGHT, right-left */
    0x0669,       /* B9  ARABIC-INDIC DIGIT NINE, right-left */
    0x003A,       /* BA  COLON, right-left */
    0x061B,       /* BB  ARABIC SEMICOLON */
    0x003C,       /* BC  LESS-THAN SIGN, right-left */
    0x003D,       /* BD  EQUALS SIGN, right-left */
    0x003E,       /* BE  GREATER-THAN SIGN, right-left */
    0x061F,       /* BF  ARABIC QUESTION MARK */
    0x274A,       /* C0  EIGHT TEARDROP-SPOKED PROPELLER ASTERISK, right-left */
    0x0621,       /* C1  ARABIC LETTER HAMZA */
    0x0622,       /* C2  ARABIC LETTER ALEF WITH MADDA ABOVE */
    0x0623,       /* C3  ARABIC LETTER ALEF WITH HAMZA ABOVE */
    0x0624,       /* C4  ARABIC LETTER WAW WITH HAMZA ABOVE */
    0x0625,       /* C5  ARABIC LETTER ALEF WITH HAMZA BELOW */
    0x0626,       /* C6  ARABIC LETTER YEH WITH HAMZA ABOVE */
    0x0627,       /* C7  ARABIC LETTER ALEF */
    0x0628,       /* C8  ARABIC LETTER BEH */
    0x0629,       /* C9  ARABIC LETTER TEH MARBUTA */
    0x062A,       /* CA  ARABIC LETTER TEH */
    0x062B,       /* CB  ARABIC LETTER THEH */
    0x062C,       /* CC  ARABIC LETTER JEEM */
    0x062D,       /* CD  ARABIC LETTER HAH */
    0x062E,       /* CE  ARABIC LETTER KHAH */
    0x062F,       /* CF  ARABIC LETTER DAL */
    0x0630,       /* D0  ARABIC LETTER THAL */
    0x0631,       /* D1  ARABIC LETTER REH */
    0x0632,       /* D2  ARABIC LETTER ZAIN */
    0x0633,       /* D3  ARABIC LETTER SEEN */
    0x0634,       /* D4  ARABIC LETTER SHEEN */
    0x0635,       /* D5  ARABIC LETTER SAD */
    0x0636,       /* D6  ARABIC LETTER DAD */
    0x0637,       /* D7  ARABIC LETTER TAH */
    0x0638,       /* D8  ARABIC LETTER ZAH */
    0x0639,       /* D9  ARABIC LETTER AIN */
    0x063A,       /* DA  ARABIC LETTER GHAIN */
    0x005B,       /* DB  LEFT SQUARE BRACKET, right-left */
    0x005C,       /* DC  REVERSE SOLIDUS, right-left */
    0x005D,       /* DD  RIGHT SQUARE BRACKET, right-left */
    0x005E,       /* DE  CIRCUMFLEX ACCENT, right-left */
    0x005F,       /* DF  LOW LINE, right-left */
    0x0640,       /* E0  ARABIC TATWEEL */
    0x0641,       /* E1  ARABIC LETTER FEH */
    0x0642,       /* E2  ARABIC LETTER QAF */
    0x0643,       /* E3  ARABIC LETTER KAF */
    0x0644,       /* E4  ARABIC LETTER LAM */
    0x0645,       /* E5  ARABIC LETTER MEEM */
    0x0646,       /* E6  ARABIC LETTER NOON */
    0x0647,       /* E7  ARABIC LETTER HEH */
    0x0648,       /* E8  ARABIC LETTER WAW */
    0x0649,       /* E9  ARABIC LETTER ALEF MAKSURA */
    0x064A,       /* EA  ARABIC LETTER YEH */
    0x064B,       /* EB  ARABIC FATHATAN */
    0x064C,       /* EC  ARABIC DAMMATAN */
    0x064D,       /* ED  ARABIC KASRATAN */
    0x064E,       /* EE  ARABIC FATHA */
    0x064F,       /* EF  ARABIC DAMMA */
    0x0650,       /* F0  ARABIC KASRA */
    0x0651,       /* F1  ARABIC SHADDA */
    0x0652,       /* F2  ARABIC SUKUN */
    0x067E,       /* F3  ARABIC LETTER PEH */
    0x0679,       /* F4  ARABIC LETTER TTEH */
    0x0686,       /* F5  ARABIC LETTER TCHEH */
    0x06D5,       /* F6  ARABIC LETTER AE */
    0x06A4,       /* F7  ARABIC LETTER VEH */
    0x06AF,       /* F8  ARABIC LETTER GAF */
    0x0688,       /* F9  ARABIC LETTER DDAL */
    0x0691,       /* FA  ARABIC LETTER RREH */
    0x007B,       /* FB  LEFT CURLY BRACKET, right-left */
    0x007C,       /* FC  VERTICAL LINE, right-left */
    0x007D,       /* FD  RIGHT CURLY BRACKET, right-left */
    0x0698,       /* FE  ARABIC LETTER JEH */
    0x06D2,       /* FF  ARABIC LETTER YEH BARREE */
]

let uvsToMacArabic: [UVBMP: CharCode] = [
    0x0020:       0x20, /*  SPACE, left-right */
    0x0021:       0x21, /*  EXCLAMATION MARK, left-right */
    0x0022:       0x22, /*  QUOTATION MARK, left-right */
    0x0023:       0x23, /*  NUMBER SIGN, left-right */
    0x0024:       0x24, /*  DOLLAR SIGN, left-right */
    0x0025:       0x25, /*  PERCENT SIGN, left-right */
    0x0026:       0x26, /*  AMPERSAND, left-right */
    0x0027:       0x27, /*  APOSTROPHE, left-right */
    0x0028:       0x28, /*  LEFT PARENTHESIS, left-right */
    0x0029:       0x29, /*  RIGHT PARENTHESIS, left-right */
    0x002A:       0x2A, /*  ASTERISK, left-right */
    0x002B:       0x2B, /*  PLUS SIGN, left-right */
    0x002C:       0x2C, /*  COMMA, left-right */
    0x002D:       0x2D, /*  HYPHEN-MINUS, left-right */
    0x002E:       0x2E, /*  FULL STOP, left-right */
    0x002F:       0x2F, /*  SOLIDUS, left-right */
    0x0030:       0x30, /*  DIGIT ZERO */
    0x0031:       0x31, /*  DIGIT ONE */
    0x0032:       0x32, /*  DIGIT TWO */
    0x0033:       0x33, /*  DIGIT THREE */
    0x0034:       0x34, /*  DIGIT FOUR */
    0x0035:       0x35, /*  DIGIT FIVE */
    0x0036:       0x36, /*  DIGIT SIX */
    0x0037:       0x37, /*  DIGIT SEVEN */
    0x0038:       0x38, /*  DIGIT EIGHT */
    0x0039:       0x39, /*  DIGIT NINE */
    0x003A:       0x3A, /*  COLON, left-right */
    0x003B:       0x3B, /*  SEMICOLON, left-right */
    0x003C:       0x3C, /*  LESS-THAN SIGN, left-right */
    0x003D:       0x3D, /*  EQUALS SIGN, left-right */
    0x003E:       0x3E, /*  GREATER-THAN SIGN, left-right */
    0x003F:       0x3F, /*  QUESTION MARK, left-right */
    0x0040:       0x40, /*  COMMERCIAL AT */
    0x0041:       0x41, /*  LATIN CAPITAL LETTER A */
    0x0042:       0x42, /*  LATIN CAPITAL LETTER B */
    0x0043:       0x43, /*  LATIN CAPITAL LETTER C */
    0x0044:       0x44, /*  LATIN CAPITAL LETTER D */
    0x0045:       0x45, /*  LATIN CAPITAL LETTER E */
    0x0046:       0x46, /*  LATIN CAPITAL LETTER F */
    0x0047:       0x47, /*  LATIN CAPITAL LETTER G */
    0x0048:       0x48, /*  LATIN CAPITAL LETTER H */
    0x0049:       0x49, /*  LATIN CAPITAL LETTER I */
    0x004A:       0x4A, /*  LATIN CAPITAL LETTER J */
    0x004B:       0x4B, /*  LATIN CAPITAL LETTER K */
    0x004C:       0x4C, /*  LATIN CAPITAL LETTER L */
    0x004D:       0x4D, /*  LATIN CAPITAL LETTER M */
    0x004E:       0x4E, /*  LATIN CAPITAL LETTER N */
    0x004F:       0x4F, /*  LATIN CAPITAL LETTER O */
    0x0050:       0x50, /*  LATIN CAPITAL LETTER P */
    0x0051:       0x51, /*  LATIN CAPITAL LETTER Q */
    0x0052:       0x52, /*  LATIN CAPITAL LETTER R */
    0x0053:       0x53, /*  LATIN CAPITAL LETTER S */
    0x0054:       0x54, /*  LATIN CAPITAL LETTER T */
    0x0055:       0x55, /*  LATIN CAPITAL LETTER U */
    0x0056:       0x56, /*  LATIN CAPITAL LETTER V */
    0x0057:       0x57, /*  LATIN CAPITAL LETTER W */
    0x0058:       0x58, /*  LATIN CAPITAL LETTER X */
    0x0059:       0x59, /*  LATIN CAPITAL LETTER Y */
    0x005A:       0x5A, /*  LATIN CAPITAL LETTER Z */
    0x005B:       0x5B, /*  LEFT SQUARE BRACKET, left-right */
    0x005C:       0x5C, /*  REVERSE SOLIDUS, left-right */
    0x005D:       0x5D, /*  RIGHT SQUARE BRACKET, left-right */
    0x005E:       0x5E, /*  CIRCUMFLEX ACCENT, left-right */
    0x005F:       0x5F, /*  LOW LINE, left-right */
    0x0060:       0x60, /*  GRAVE ACCENT */
    0x0061:       0x61, /*  LATIN SMALL LETTER A */
    0x0062:       0x62, /*  LATIN SMALL LETTER B */
    0x0063:       0x63, /*  LATIN SMALL LETTER C */
    0x0064:       0x64, /*  LATIN SMALL LETTER D */
    0x0065:       0x65, /*  LATIN SMALL LETTER E */
    0x0066:       0x66, /*  LATIN SMALL LETTER F */
    0x0067:       0x67, /*  LATIN SMALL LETTER G */
    0x0068:       0x68, /*  LATIN SMALL LETTER H */
    0x0069:       0x69, /*  LATIN SMALL LETTER I */
    0x006A:       0x6A, /*  LATIN SMALL LETTER J */
    0x006B:       0x6B, /*  LATIN SMALL LETTER K */
    0x006C:       0x6C, /*  LATIN SMALL LETTER L */
    0x006D:       0x6D, /*  LATIN SMALL LETTER M */
    0x006E:       0x6E, /*  LATIN SMALL LETTER N */
    0x006F:       0x6F, /*  LATIN SMALL LETTER O */
    0x0070:       0x70, /*  LATIN SMALL LETTER P */
    0x0071:       0x71, /*  LATIN SMALL LETTER Q */
    0x0072:       0x72, /*  LATIN SMALL LETTER R */
    0x0073:       0x73, /*  LATIN SMALL LETTER S */
    0x0074:       0x74, /*  LATIN SMALL LETTER T */
    0x0075:       0x75, /*  LATIN SMALL LETTER U */
    0x0076:       0x76, /*  LATIN SMALL LETTER V */
    0x0077:       0x77, /*  LATIN SMALL LETTER W */
    0x0078:       0x78, /*  LATIN SMALL LETTER X */
    0x0079:       0x79, /*  LATIN SMALL LETTER Y */
    0x007A:       0x7A, /*  LATIN SMALL LETTER Z */
    0x007B:       0x7B, /* LEFT CURLY BRACKET, left-right */
    0x007C:       0x7C, /*  VERTICAL LINE, left-right */
    0x007D:       0x7D, /*  RIGHT CURLY BRACKET, left-right */
    0x007E:       0x7E, /*  TILDE */
    0x00C4:       0x80, /*  LATIN CAPITAL LETTER A WITH DIAERESIS */
    0x00A0:       0x81, /*  NO-BREAK SPACE, right-left */
    0x00C7:       0x82, /*  LATIN CAPITAL LETTER C WITH CEDILLA */
    0x00C9:       0x83, /*  LATIN CAPITAL LETTER E WITH ACUTE */
    0x00D1:       0x84, /*  LATIN CAPITAL LETTER N WITH TILDE */
    0x00D6:       0x85, /*  LATIN CAPITAL LETTER O WITH DIAERESIS */
    0x00DC:       0x86, /*  LATIN CAPITAL LETTER U WITH DIAERESIS */
    0x00E1:       0x87, /*  LATIN SMALL LETTER A WITH ACUTE */
    0x00E0:       0x88, /*  LATIN SMALL LETTER A WITH GRAVE */
    0x00E2:       0x89, /*  LATIN SMALL LETTER A WITH CIRCUMFLEX */
    0x00E4:       0x8A, /*  LATIN SMALL LETTER A WITH DIAERESIS */
    0x06BA:       0x8B, /*  ARABIC LETTER NOON GHUNNA */
    0x00AB:       0x8C, /*  LEFT-POINTING DOUBLE ANGLE QUOTATION MARK, right-left */
    0x00E7:       0x8D, /*  LATIN SMALL LETTER C WITH CEDILLA */
    0x00E9:       0x8E, /*  LATIN SMALL LETTER E WITH ACUTE */
    0x00E8:       0x8F, /*  LATIN SMALL LETTER E WITH GRAVE */
    0x00EA:       0x90, /*  LATIN SMALL LETTER E WITH CIRCUMFLEX */
    0x00EB:       0x91, /*  LATIN SMALL LETTER E WITH DIAERESIS */
    0x00ED:       0x92, /*  LATIN SMALL LETTER I WITH ACUTE */
    0x2026:       0x93, /*  HORIZONTAL ELLIPSIS, right-left */
    0x00EE:       0x94, /*  LATIN SMALL LETTER I WITH CIRCUMFLEX */
    0x00EF:       0x95, /*  LATIN SMALL LETTER I WITH DIAERESIS */
    0x00F1:       0x96, /*  LATIN SMALL LETTER N WITH TILDE */
    0x00F3:       0x97, /*  LATIN SMALL LETTER O WITH ACUTE */
    0x00BB:       0x98, /*  RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK, right-left */
    0x00F4:       0x99, /*  LATIN SMALL LETTER O WITH CIRCUMFLEX */
    0x00F6:       0x9A, /*  LATIN SMALL LETTER O WITH DIAERESIS */
    0x00F7:       0x9B, /*  DIVISION SIGN, right-left */
    0x00FA:       0x9C, /*  LATIN SMALL LETTER U WITH ACUTE */
    0x00F9:       0x9D, /*  LATIN SMALL LETTER U WITH GRAVE */
    0x00FB:       0x9E, /*  LATIN SMALL LETTER U WITH CIRCUMFLEX */
    0x00FC:       0x9F, /*  LATIN SMALL LETTER U WITH DIAERESIS */
//    0x0020:       0xA0, /*  SPACE, right-left */
//    0x0021:       0xA1, /*  EXCLAMATION MARK, right-left */
//    0x0022:       0xA2, /*  QUOTATION MARK, right-left */
//    0x0023:       0xA3, /*  NUMBER SIGN, right-left */
//    0x0024:       0xA4, /*  DOLLAR SIGN, right-left */
    0x066A:       0xA5, /*  ARABIC PERCENT SIGN */
//    0x0026:       0xA6, /*  AMPERSAND, right-left */
//    0x0027:       0xA7, /*  APOSTROPHE, right-left */
//    0x0028:       0xA8, /*  LEFT PARENTHESIS, right-left */
//    0x0029:       0xA9, /*  RIGHT PARENTHESIS, right-left */
//    0x002A:       0xAA, /*  ASTERISK, right-left */
//    0x002B:       0xAB, /*  PLUS SIGN, right-left */
    0x060C:       0xAC, /*  ARABIC COMMA */
//    0x002D:       0xAD, /*  HYPHEN-MINUS, right-left */
//    0x002E:       0xAE, /*  FULL STOP, right-left */
//    0x002F:       0xAF, /*  SOLIDUS, right-left */
    0x0660:       0xB0, /*  ARABIC-INDIC DIGIT ZERO, right-left */
    0x0661:       0xB1, /*  ARABIC-INDIC DIGIT ONE, right-left */
    0x0662:       0xB2, /*  ARABIC-INDIC DIGIT TWO, right-left */
    0x0663:       0xB3, /*  ARABIC-INDIC DIGIT THREE, right-left */
    0x0664:       0xB4, /*  ARABIC-INDIC DIGIT FOUR, right-left */
    0x0665:       0xB5, /*  ARABIC-INDIC DIGIT FIVE, right-left */
    0x0666:       0xB6, /*  ARABIC-INDIC DIGIT SIX, right-left */
    0x0667:       0xB7, /*  ARABIC-INDIC DIGIT SEVEN, right-left */
    0x0668:       0xB8, /*  ARABIC-INDIC DIGIT EIGHT, right-left */
    0x0669:       0xB9, /*  ARABIC-INDIC DIGIT NINE, right-left */
//    0x003A:       0xBA, /*  COLON, right-left */
    0x061B:       0xBB, /*  ARABIC SEMICOLON */
//    0x003C:       0xBC, /*  LESS-THAN SIGN, right-left */
//    0x003D:       0xBD, /*  EQUALS SIGN, right-left */
//    0x003E:       0xBE, /*  GREATER-THAN SIGN, right-left */
    0x061F:       0xBF, /*  ARABIC QUESTION MARK */
    0x274A:       0xC0, /*  EIGHT TEARDROP-SPOKED PROPELLER ASTERISK, right-left */
    0x0621:       0xC1, /*  ARABIC LETTER HAMZA */
    0x0622:       0xC2, /*  ARABIC LETTER ALEF WITH MADDA ABOVE */
    0x0623:       0xC3, /*  ARABIC LETTER ALEF WITH HAMZA ABOVE */
    0x0624:       0xC4, /*  ARABIC LETTER WAW WITH HAMZA ABOVE */
    0x0625:       0xC5, /*  ARABIC LETTER ALEF WITH HAMZA BELOW */
    0x0626:       0xC6, /*  ARABIC LETTER YEH WITH HAMZA ABOVE */
    0x0627:       0xC7, /*  ARABIC LETTER ALEF */
    0x0628:       0xC8, /*  ARABIC LETTER BEH */
    0x0629:       0xC9, /*  ARABIC LETTER TEH MARBUTA */
    0x062A:       0xCA, /*  ARABIC LETTER TEH */
    0x062B:       0xCB, /*  ARABIC LETTER THEH */
    0x062C:       0xCC, /*  ARABIC LETTER JEEM */
    0x062D:       0xCD, /*  ARABIC LETTER HAH */
    0x062E:       0xCE, /*  ARABIC LETTER KHAH */
    0x062F:       0xCF, /*  ARABIC LETTER DAL */
    0x0630:       0xD0, /*  ARABIC LETTER THAL */
    0x0631:       0xD1, /*  ARABIC LETTER REH */
    0x0632:       0xD2, /*  ARABIC LETTER ZAIN */
    0x0633:       0xD3, /*  ARABIC LETTER SEEN */
    0x0634:       0xD4, /*  ARABIC LETTER SHEEN */
    0x0635:       0xD5, /*  ARABIC LETTER SAD */
    0x0636:       0xD6, /*  ARABIC LETTER DAD */
    0x0637:       0xD7, /*  ARABIC LETTER TAH */
    0x0638:       0xD8, /*  ARABIC LETTER ZAH */
    0x0639:       0xD9, /*  ARABIC LETTER AIN */
    0x063A:       0xDA, /*  ARABIC LETTER GHAIN */
//    0x005B:       0xDB, /*  LEFT SQUARE BRACKET, right-left */
//    0x005C:       0xDC, /*  REVERSE SOLIDUS, right-left */
//    0x005D:       0xDD, /*  RIGHT SQUARE BRACKET, right-left */
//    0x005E:       0xDE, /*  CIRCUMFLEX ACCENT, right-left */
//    0x005F:       0xDF, /*  LOW LINE, right-left */
    0x0640:       0xE0, /*  ARABIC TATWEEL */
    0x0641:       0xE1, /*  ARABIC LETTER FEH */
    0x0642:       0xE2, /*  ARABIC LETTER QAF */
    0x0643:       0xE3, /*  ARABIC LETTER KAF */
    0x0644:       0xE4, /*  ARABIC LETTER LAM */
    0x0645:       0xE5, /*  ARABIC LETTER MEEM */
    0x0646:       0xE6, /*  ARABIC LETTER NOON */
    0x0647:       0xE7, /*  ARABIC LETTER HEH */
    0x0648:       0xE8, /*  ARABIC LETTER WAW */
    0x0649:       0xE9, /*  ARABIC LETTER ALEF MAKSURA */
    0x064A:       0xEA, /*  ARABIC LETTER YEH */
    0x064B:       0xEB, /*  ARABIC FATHATAN */
    0x064C:       0xEC, /*  ARABIC DAMMATAN */
    0x064D:       0xED, /*  ARABIC KASRATAN */
    0x064E:       0xEE, /*  ARABIC FATHA */
    0x064F:       0xEF, /*  ARABIC DAMMA */
    0x0650:       0xF0, /*  ARABIC KASRA */
    0x0651:       0xF1, /*  ARABIC SHADDA */
    0x0652:       0xF2, /*  ARABIC SUKUN */
    0x067E:       0xF3, /*  ARABIC LETTER PEH */
    0x0679:       0xF4, /*  ARABIC LETTER TTEH */
    0x0686:       0xF5, /*  ARABIC LETTER TCHEH */
    0x06D5:       0xF6, /*  ARABIC LETTER AE */
    0x06A4:       0xF7, /*  ARABIC LETTER VEH */
    0x06AF:       0xF8, /*  ARABIC LETTER GAF */
    0x0688:       0xF9, /*  ARABIC LETTER DDAL */
    0x0691:       0xFA, /*  ARABIC LETTER RREH */
//    0x007B:       0xFB, /*  LEFT CURLY BRACKET, right-left */
//    0x007C:       0xFC, /*  VERTICAL LINE, right-left */
//    0x007D:       0xFD, /*  RIGHT CURLY BRACKET, right-left */
    0x0698:       0xFE, /*  ARABIC LETTER JEH */
    0x06D2:       0xFF, /*  ARABIC LETTER YEH BARREE */
]
