//
//  macFarsiEncoding.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/1/2026.
//

/* Copyright 2014 Adobe Systems Incorporated (http://www.adobe.com/). All Rights Reserved.
   This software is licensed as OpenSource, under the Apache License, Version 2.0.
   This license is available at: http://opensource.org/licenses/Apache-2.0. */

/* Mac OS Farsi aggregate Unicode initializer.

   Element values are UVs. UV_UNDEF is 0xFFFF. Index by code, get UV.
   Source: ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/APPLE/FARSI.TXT
   as of 9/9/99. */

/*
 # Format:
 # -------
 #
 #   Three tab-separated columns;
 #   '#' begins a comment which continues to the end of the line.
 #     Column #1 is the Mac OS Farsi code (in hex as 0xNN)
 #     Column #2 is the corresponding Unicode (in hex as 0xNNNN),
 #       possibly preceded by a tag indicating required directionality
 #       (i.e. <LR>+0xNNNN or <RL>+0xNNNN).
 #     Column #3 is a comment containing the Unicode name.
 #
 #   The entries are in Mac OS Farsi code order.
 #
 #   Control character mappings are not shown in this table, following
 #   the conventions of the standard UTC mapping tables. However, the
 #   Mac OS Farsi character set uses the standard control characters at
 #   0x00-0x1F and 0x7F.
 #
 # Notes on Mac OS Farsi:
 # ----------------------
 #
 #   This is a legacy Mac OS encoding; in the Mac OS X Carbon and Cocoa
 #   environments, it is only supported via transcoding to and from
 #   Unicode.
 #
 #   1. General
 #
 #   The Mac OS Farsi character set is based on the Mac OS Arabic
 #   character set. The main difference is in the right-to-left digits
 #   0xB0-0xB9: For Mac OS Arabic these correspond to right-left
 #   versions of the Unicode ARABIC-INDIC DIGITs 0660-0669; for
 #   Mac OS Farsi these correspond to right-left versions of the
 #   Unicode EXTENDED ARABIC-INDIC DIGITs 06F0-06F9. The other
 #   difference is in the nature of the font variants.
 #
 #   For more information, see the comments in the mapping table for
 #   Mac OS Arabic.
 #
 #   Mac OS Farsi characters 0xEB-0xF2 are non-spacing/combining marks.
 #
 #   2. Directional characters and roundtrip fidelity
 #
 #   The Mac OS Arabic character set (on which Mac OS Farsi is based)
 #   was developed in 1986-1987. At that time the bidirectional line
 #   layout algorithm used in the Mac OS Arabic system was fairly simple;
 #   it used only a few direction classes (instead of the 19 now used in
 #   the Unicode bidirectional algorithm). In order to permit users to
 #   handle some tricky layout problems, certain punctuation and symbol
 #   characters were encoded twice, one with a left-right direction
 #   attribute and the other with a right-left direction attribute. This
 #   is the case in Mac OS Farsi too.
 #
 #   For example, plus sign is encoded at 0x2B with a left-right
 #   attribute, and at 0xAB with a right-left attribute. However, there
 #   is only one PLUS SIGN character in Unicode. This leads to some
 #   interesting problems when mapping between Mac OS Farsi and Unicode;
 #   see below.
 #
 #   A related problem is that even when a particular character is
 #   encoded only once in Mac OS Farsi, it may have a different
 #   direction attribute than the corresponding Unicode character.
 #
 #   For example, the Mac OS Farsi character at 0x93 is HORIZONTAL
 #   ELLIPSIS with strong right-left direction. However, the Unicode
 #   character HORIZONTAL ELLIPSIS has direction class neutral.
 #
 #   3. Behavior of ASCII-range numbers in WorldScript
 #
 #   Mac OS Farsi also has two sets of digit codes.

 #   The digits at 0x30-0x39 may be displayed using either European
 #   digit forms or Persian digit forms, depending on context. If there
 #   is a "strong European" character such as a Latin letter on either
 #   side of a sequence consisting of digits 0x30-0x39 and possibly comma
 #   0x2C or period 0x2E, then the characters will be displayed using
 #   European forms (This will happen even if there are neutral characters
 #   between the digits and the strong European character). Otherwise, the
 #   digits will be displayed using Persian forms, the comma will be
 #   displayed as Arabic thousands separator, and the period as Arabic
 #   decimal separator. In any case, 0x2C, 0x2E, and 0x30-0x39 are always
 #   left-right.
 #
 #   The digits at 0xB0-0xB9 are always displayed using Persian digit
 #   shapes, and moreover, these digits always have strong right-left
 #   directionality. These are mainly intended for special layout
 #   purposes such as part numbers, etc.
 #
 #   4. Font variants
 #
 #   The table in this file gives the Unicode mappings for the standard
 #   Mac OS Farsi encoding. This encoding is supported by the Tehran font
 #   (the system font for Farsi), and is the encoding supported by the
 #   text processing utilities. However, the other Farsi fonts actually
 #   implement a somewhat different encoding; this affects nine code
 #   points including 0xAA and 0xC0 (which are also affected by font
 #   variants in Mac OS Arabic). For these nine code points the standard
 #   Mac OS Farsi encoding has the following mappings:
 #       0x8B -> 0x06BA ARABIC LETTER NOON GHUNNA (Urdu)
 #       0xA4 -> <RL>+0x0024 DOLLAR SIGN, right-left
 #       0xAA -> <RL>+0x002A ASTERISK, right-left
 #       0xC0 -> <RL>+0x274A EIGHT TEARDROP-SPOKED PROPELLER ASTERISK,
 #               right-left
 #       0xF4 -> 0x0679 ARABIC LETTER TTEH (Urdu)
 #       0xF7 -> 0x06A4 ARABIC LETTER VEH (for transliteration)
 #       0xF9 -> 0x0688 ARABIC LETTER DDAL (Urdu)
 #       0xFA -> 0x0691 ARABIC LETTER RREH (Urdu)
 #       0xFF -> 0x06D2 ARABIC LETTER YEH BARREE (Urdu)
 #
 #   The TrueType variant is used for the Farsi TrueType fonts: Ashfahan,
 #   Amir, Kamran, Mashad, NadeemFarsi. It differs from the standard
 #   variant in the following ways:
 #       0x8B -> 0xF882 Arabic ligature "peace on him" (corporate char.)
 #       0xA4 -> 0xFDFC RIAL SIGN (added in Unicode 3.2)
 #       0xAA -> <RL>+0x00D7 MULTIPLICATION SIGN, right-left
 #       0xC0 -> <RL>+0x002A ASTERISK, right-left
 #       0xF4 -> <RL>+0x00B0 DEGREE SIGN, right-left
 #       0xF7 -> 0xFDFA ARABIC LIGATURE SALLALLAHOU ALAYHE WASALLAM
 #       0xF9 -> <RL>+0x25CF BLACK CIRCLE, right-left
 #       0xFA -> <RL>+0x25A0 BLACK SQUARE, right-left
 #       0xFF -> <RL>+0x25B2 BLACK UP-POINTING TRIANGLE, right-left
 #
 # Unicode mapping issues and notes:
 # ---------------------------------
 #
 #   1. Matching the direction of Mac OS Farsi characters
 #
 #   When Mac OS Farsi encodes a character twice but with different
 #   direction attributes for the two code points - as in the case of
 #   plus sign mentioned above - we need a way to map both Mac OS Farsi
 #   code points to Unicode and back again without loss of information.
 #   With the plus sign, for example, mapping one of the Mac OS Farsi
 #   characters to a code in the Unicode corporate use zone is
 #   undesirable, since both of the plus sign characters are likely to
 #   be used in text that is interchanged.
 #
 #   The problem is solved with the use of direction override characters
 #   and direction-dependent mappings. When mapping from Mac OS Farsi
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
 #   When mapping from Unicode to Mac OS Farsi, the Unicode
 #   bidirectional algorithm should be used to determine resolved
 #   direction of the Unicode characters. The mapping from Unicode to
 #   Mac OS Farsi can then be disambiguated by the use of the resolved
 #   direction:
 #
 #     Unicode 0x002B -> Mac OS Farsi 0x2B (if L) or 0xAB (if R)
 #
 #   However, this also means the direction override characters should
 #   be discarded when mapping from Unicode to Mac OS Farsi (after
 #   they have been used to determine resolved direction), since the
 #   direction override information is carried by the code point itself.
 #
 #   Even when direction overrides are not needed for roundtrip
 #   fidelity, they are sometimes used when mapping Mac OS Farsi
 #   characters to Unicode in order to achieve similar text layout with
 #   the resulting Unicode text. For example, the single Mac OS Farsi
 #   ellipsis character has direction class right-left,and there is no
 #   left-right version. However, the Unicode HORIZONTAL ELLIPSIS
 #   character has direction class neutral (which means it may end up
 #   with a resolved direction of left-right if surrounded by left-right
 #   characters). When mapping the Mac OS Farsi ellipsis to Unicode, it
 #   is surrounded with a direction override to help preserve proper
 #   text layout. The resolved direction is not needed or used when
 #   mapping the Unicode HORIZONTAL ELLIPSIS back to Mac OS Farsi.
 #
 #   2. Mapping the Mac OS Farsi digits
 #
 #   The main table below contains mappings that should be used when
 #   strict round-trip fidelity is required. However, for numeric
 #   values, the mappings in that table will produce Unicode characters
 #   that may appear different than the Mac OS Farsi text displayed on
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
 #     0x30    0x06F0    # EXTENDED ARABIC-INDIC DIGIT ZERO
 #     0x31    0x06F1    # EXTENDED ARABIC-INDIC DIGIT ONE
 #     0x32    0x06F2    # EXTENDED ARABIC-INDIC DIGIT TWO
 #     0x33    0x06F3    # EXTENDED ARABIC-INDIC DIGIT THREE
 #     0x34    0x06F4    # EXTENDED ARABIC-INDIC DIGIT FOUR
 #     0x35    0x06F5    # EXTENDED ARABIC-INDIC DIGIT FIVE
 #     0x36    0x06F6    # EXTENDED ARABIC-INDIC DIGIT SIX
 #     0x37    0x06F7    # EXTENDED ARABIC-INDIC DIGIT SEVEN
 #     0x38    0x06F8    # EXTENDED ARABIC-INDIC DIGIT EIGHT
 #     0x39    0x06F9    # EXTENDED ARABIC-INDIC DIGIT NINE
 #
 #   3. Use of corporate-zone Unicodes (mapping the TrueType variant)
 #
 #   The following corporate zone Unicode character is used in this
 #   mapping:
 #
 #     0xF882  Arabic ligature "peace on him"
 #
 # Details of mapping changes in each version:
 # -------------------------------------------
 #
 #   Changes from version b02 to version b03/c01:
 #
 #   - Update mapping of 0xA4 in TrueType variant to use new Unicode
 #     character U+FDFC RIAL SIGN addded for Unicode 3.2
 #
 #   Changes from version n01 to version n04:
 #
 #   - Change mapping of 0xA4 in TrueType variant (just described in
 #     header comment) from single corporate character to use
 #     grouping hint
 #
 */

import Foundation

let macFarsiEncoding: [UVBMP] = [
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
    0x06F0,       /* B0  EXTENDED ARABIC-INDIC DIGIT ZERO, right-left */
    0x06F1,       /* B1  EXTENDED ARABIC-INDIC DIGIT ONE, right-left */
    0x06F2,       /* B2  EXTENDED ARABIC-INDIC DIGIT TWO, right-left */
    0x06F3,       /* B3  EXTENDED ARABIC-INDIC DIGIT THREE, right-left */
    0x06F4,       /* B4  EXTENDED ARABIC-INDIC DIGIT FOUR, right-left */
    0x06F5,       /* B5  EXTENDED ARABIC-INDIC DIGIT FIVE, right-left */
    0x06F6,       /* B6  EXTENDED ARABIC-INDIC DIGIT SIX, right-left */
    0x06F7,       /* B7  EXTENDED ARABIC-INDIC DIGIT SEVEN, right-left */
    0x06F8,       /* B8  EXTENDED ARABIC-INDIC DIGIT EIGHT, right-left */
    0x06F9,       /* B9  EXTENDED ARABIC-INDIC DIGIT NINE, right-left */
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

