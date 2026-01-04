//
//  macIcelandicEncoding.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/1/2026.
//
/* Copyright 2014 Adobe Systems Incorporated (http://www.adobe.com/). All Rights Reserved.
   This software is licensed as OpenSource, under the Apache License, Version 2.0.
   This license is available at: http://opensource.org/licenses/Apache-2.0. */

/* Mac OS Icelandic aggregate Unicode initializer.

   Element values are UVs. UV_UNDEF is 0xFFFF. Index by code, get UV.
   Source: ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/APPLE/ICELAND.TXT
   as of 9/9/99, with EURO SIGN replacing CURRENCY SIGN. */

/*
 # Format:
 # -------
 #
 #   Three tab-separated columns;
 #   '#' begins a comment which continues to the end of the line.
 #     Column #1 is the Mac OS Icelandic code (in hex as 0xNN)
 #     Column #2 is the corresponding Unicode (in hex as 0xNNNN)
 #     Column #3 is a comment containing the Unicode name
 #
 #   The entries are in Mac OS Icelandic code order.
 #
 #   One of these mappings requires the use of a corporate character.
 #   See the file "CORPCHAR.TXT" and notes below.
 #
 #   Control character mappings are not shown in this table, following
 #   the conventions of the standard UTC mapping tables. However, the
 #   Mac OS Icelandic character set uses the standard control characters
 #   at 0x00-0x1F and 0x7F.
 #
 # Notes on Mac OS Icelandic:
 # --------------------------
 #
 #   This is a legacy Mac OS encoding; in the Mac OS X Carbon and Cocoa
 #   environments, it is only supported via transcoding to and from
 #   Unicode.
 #
 #   1. General
 #
 #   Mac OS Icelandic is used for Icelandic and Faroese.
 #
 #   The Mac OS Icelandic encoding shares the script code smRoman
 #   (0) with the standard Mac OS Roman encoding. To determine if
 #   the Icelandic encoding is being used, you must also check if
 #   the system region code is 21, verIceland.
 #
 #   This character set is a variant of standard Mac OS Roman,
 #   adding upper and lower eth, thorn, and Y acute. It has 6 code
 #   point differences from standard Mac OS Roman.
 #
 #   Before Mac OS 8.5, code point 0xDB was CURRENCY SIGN, and was
 #   mapped to U+00A4. In Mac OS 8.5 and later versions, code point
 #   0xDB is changed to EURO SIGN and maps to U+20AC; the standard
 #   Apple fonts are updated for Mac OS 8.5 to reflect this. There are
 #   "currency sign" variants of the Mac OS Icelandic encoding that
 #   still map 0xDB to U+00A4; these can be used for older fonts.
 #
 #   2. Font variants
 #
 #   The table in this file gives the Unicode mappings for the standard
 #   Mac OS Icelandic encoding. This encoding is supported by the
 #   Icelandic versions of the fonts Chicago, Geneva, Monaco, and New
 #   York, and is the encoding supported by the text processing
 #   utilities. However, other TrueType fonts implement a slightly
 #   different encoding; the difference is only in two code points.
 #   For the standard variant, these are:
 #     0xBB -> 0x00AA  FEMININE ORDINAL INDICATOR
 #     0xBC -> 0x00BA  MASCULINE ORDINAL INDICATOR
 #
 #   For the TrueType variant (used by the Icelandic versions of the
 #   fonts Courier, Helvetica, Palatino, and Times), these are:
 #     0xBB -> 0xFB01  LATIN SMALL LIGATURE FI
 #     0xBC -> 0xFB02  LATIN SMALL LIGATURE FL
 #
 # Unicode mapping issues and notes:
 # ---------------------------------
 #
 #   The following corporate zone Unicode character is used in this
 #   mapping:
 #
 #     0xF8FF  Apple logo
 #
 #   NOTE: The graphic image associated with the Apple logo character
 #   is not authorized for use without permission of Apple, and
 #   unauthorized use might constitute trademark infringement.
 #
 # Details of mapping changes in each version:
 # -------------------------------------------
 #
 #   Changes from version n06 to version b02:
 #
 #   - Encoding changed for Mac OS 8.5; change mapping of 0xDB from
 #   CURRENCY SIGN (U+00A4) to EURO SIGN (U+20AC).
 #
 #   Changes from version n02 to version n03:
 #
 #   - Change mapping of 0xBD from U+2126 to its canonical
 #     decomposition, U+03A9.
 #
 ##################
 */

import Foundation

let macIcelandicEncoding: [UVBMP] = [
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
    0x0020,       /* 20  SPACE */
    0x0021,       /* 21  EXCLAMATION MARK */
    0x0022,       /* 22  QUOTATION MARK */
    0x0023,       /* 23  NUMBER SIGN */
    0x0024,       /* 24  DOLLAR SIGN */
    0x0025,       /* 25  PERCENT SIGN */
    0x0026,       /* 26  AMPERSAND */
    0x0027,       /* 27  APOSTROPHE */
    0x0028,       /* 28  LEFT PARENTHESIS */
    0x0029,       /* 29  RIGHT PARENTHESIS */
    0x002A,       /* 2A  ASTERISK */
    0x002B,       /* 2B  PLUS SIGN */
    0x002C,       /* 2C  COMMA */
    0x002D,       /* 2D  HYPHEN-MINUS */
    0x002E,       /* 2E  FULL STOP */
    0x002F,       /* 2F  SOLIDUS */
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
    0x003A,       /* 3A  COLON */
    0x003B,       /* 3B  SEMICOLON */
    0x003C,       /* 3C  LESS-THAN SIGN */
    0x003D,       /* 3D  EQUALS SIGN */
    0x003E,       /* 3E  GREATER-THAN SIGN */
    0x003F,       /* 3F  QUESTION MARK */
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
    0x005B,       /* 5B  LEFT SQUARE BRACKET */
    0x005C,       /* 5C  REVERSE SOLIDUS */
    0x005D,       /* 5D  RIGHT SQUARE BRACKET */
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
    0x007B,       /* 7B  LEFT CURLY BRACKET */
    0x007C,       /* 7C  VERTICAL LINE */
    0x007D,       /* 7D  RIGHT CURLY BRACKET */
    0x007E,       /* 7E  TILDE */
    .undefined,   /* 7F */
    0x00C4,       /* 80  LATIN CAPITAL LETTER A WITH DIAERESIS */
    0x00C5,       /* 81  LATIN CAPITAL LETTER A WITH RING ABOVE */
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
    0x00DD,       /* A0  LATIN CAPITAL LETTER Y WITH ACUTE */
    0x00B0,       /* A1  DEGREE SIGN */
    0x00A2,       /* A2  CENT SIGN */
    0x00A3,       /* A3  POUND SIGN */
    0x00A7,       /* A4  SECTION SIGN */
    0x2022,       /* A5  BULLET */
    0x00B6,       /* A6  PILCROW SIGN */
    0x00DF,       /* A7  LATIN SMALL LETTER SHARP S */
    0x00AE,       /* A8  REGISTERED SIGN */
    0x00A9,       /* A9  COPYRIGHT SIGN */
    0x2122,       /* AA  TRADE MARK SIGN */
    0x00B4,       /* AB  ACUTE ACCENT */
    0x00A8,       /* AC  DIAERESIS */
    0x2260,       /* AD  NOT EQUAL TO */
    0x00C6,       /* AE  LATIN CAPITAL LETTER AE */
    0x00D8,       /* AF  LATIN CAPITAL LETTER O WITH STROKE */
    0x221E,       /* B0  INFINITY */
    0x00B1,       /* B1  PLUS-MINUS SIGN */
    0x2264,       /* B2  LESS-THAN OR EQUAL TO */
    0x2265,       /* B3  GREATER-THAN OR EQUAL TO */
    0x00A5,       /* B4  YEN SIGN */
    0x00B5,       /* B5  MICRO SIGN */
    0x2202,       /* B6  PARTIAL DIFFERENTIAL */
    0x2211,       /* B7  N-ARY SUMMATION */
    0x220F,       /* B8  N-ARY PRODUCT */
    0x03C0,       /* B9  GREEK SMALL LETTER PI */
    0x222B,       /* BA  INTEGRAL */
    0x00AA,       /* BB  FEMININE ORDINAL INDICATOR */
    0x00BA,       /* BC  MASCULINE ORDINAL INDICATOR */
    0x03A9,       /* BD  GREEK CAPITAL LETTER OMEGA */
    0x00E6,       /* BE  LATIN SMALL LETTER AE */
    0x00F8,       /* BF  LATIN SMALL LETTER O WITH STROKE */
    0x00BF,       /* C0  INVERTED QUESTION MARK */
    0x00A1,       /* C1  INVERTED EXCLAMATION MARK */
    0x00AC,       /* C2  NOT SIGN */
    0x221A,       /* C3  SQUARE ROOT */
    0x0192,       /* C4  LATIN SMALL LETTER F WITH HOOK */
    0x2248,       /* C5  ALMOST EQUAL TO */
    0x2206,       /* C6  INCREMENT */
    0x00AB,       /* C7  LEFT-POINTING DOUBLE ANGLE QUOTATION MARK */
    0x00BB,       /* C8  RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK */
    0x2026,       /* C9  HORIZONTAL ELLIPSIS */
    0x00A0,       /* CA  NO-BREAK SPACE */
    0x00C0,       /* CB  LATIN CAPITAL LETTER A WITH GRAVE */
    0x00C3,       /* CC  LATIN CAPITAL LETTER A WITH TILDE */
    0x00D5,       /* CD  LATIN CAPITAL LETTER O WITH TILDE */
    0x0152,       /* CE  LATIN CAPITAL LIGATURE OE */
    0x0153,       /* CF  LATIN SMALL LIGATURE OE */
    0x2013,       /* D0  EN DASH */
    0x2014,       /* D1  EM DASH */
    0x201C,       /* D2  LEFT DOUBLE QUOTATION MARK */
    0x201D,       /* D3  RIGHT DOUBLE QUOTATION MARK */
    0x2018,       /* D4  LEFT SINGLE QUOTATION MARK */
    0x2019,       /* D5  RIGHT SINGLE QUOTATION MARK */
    0x00F7,       /* D6  DIVISION SIGN */
    0x25CA,       /* D7  LOZENGE */
    0x00FF,       /* D8  LATIN SMALL LETTER Y WITH DIAERESIS */
    0x0178,       /* D9  LATIN CAPITAL LETTER Y WITH DIAERESIS */
    0x2044,       /* DA  FRACTION SLASH */
    0x20AC,       /* DB  EURO SIGN */
    0x00D0,       /* DC  LATIN CAPITAL LETTER ETH */
    0x00F0,       /* DD  LATIN SMALL LETTER ETH */
    0x00DE,       /* DE  LATIN CAPITAL LETTER THORN */
    0x00FE,       /* DF  LATIN SMALL LETTER THORN */
    0x00FD,       /* E0  LATIN SMALL LETTER Y WITH ACUTE */
    0x00B7,       /* E1  MIDDLE DOT */
    0x201A,       /* E2  SINGLE LOW-9 QUOTATION MARK */
    0x201E,       /* E3  DOUBLE LOW-9 QUOTATION MARK */
    0x2030,       /* E4  PER MILLE SIGN */
    0x00C2,       /* E5  LATIN CAPITAL LETTER A WITH CIRCUMFLEX */
    0x00CA,       /* E6  LATIN CAPITAL LETTER E WITH CIRCUMFLEX */
    0x00C1,       /* E7  LATIN CAPITAL LETTER A WITH ACUTE */
    0x00CB,       /* E8  LATIN CAPITAL LETTER E WITH DIAERESIS */
    0x00C8,       /* E9  LATIN CAPITAL LETTER E WITH GRAVE */
    0x00CD,       /* EA  LATIN CAPITAL LETTER I WITH ACUTE */
    0x00CE,       /* EB  LATIN CAPITAL LETTER I WITH CIRCUMFLEX */
    0x00CF,       /* EC  LATIN CAPITAL LETTER I WITH DIAERESIS */
    0x00CC,       /* ED  LATIN CAPITAL LETTER I WITH GRAVE */
    0x00D3,       /* EE  LATIN CAPITAL LETTER O WITH ACUTE */
    0x00D4,       /* EF  LATIN CAPITAL LETTER O WITH CIRCUMFLEX */
    0xF8FF,       /* F0  Apple logo */
    0x00D2,       /* F1  LATIN CAPITAL LETTER O WITH GRAVE */
    0x00DA,       /* F2  LATIN CAPITAL LETTER U WITH ACUTE */
    0x00DB,       /* F3  LATIN CAPITAL LETTER U WITH CIRCUMFLEX */
    0x00D9,       /* F4  LATIN CAPITAL LETTER U WITH GRAVE */
    0x0131,       /* F5  LATIN SMALL LETTER DOTLESS I */
    0x02C6,       /* F6  MODIFIER LETTER CIRCUMFLEX ACCENT */
    0x02DC,       /* F7  SMALL TILDE */
    0x00AF,       /* F8  MACRON */
    0x02D8,       /* F9  BREVE */
    0x02D9,       /* FA  DOT ABOVE */
    0x02DA,       /* FB  RING ABOVE */
    0x00B8,       /* FC  CEDILLA */
    0x02DD,       /* FD  DOUBLE ACUTE ACCENT */
    0x02DB,       /* FE  OGONEK */
    0x02C7,       /* FF  CARON */
]
