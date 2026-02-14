//
//  macGreekEncoding.swift
//  CoreFont
//
//  Created by Mark Douma on 1/1/2026.
//
/* Copyright 2014 Adobe Systems Incorporated (http://www.adobe.com/). All Rights Reserved.
  This software is licensed as OpenSource, under the Apache License, Version 2.0.
  This license is available at: http://opensource.org/licenses/Apache-2.0. */

/* Mac OS Greek aggregate Unicode initializer.

  Element values are UVs. UV_UNDEF is 0xFFFF. Index by code, get UV.
  Source: ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/APPLE/GREEK.TXT
  as of 9/9/99. */

/*
#   The entries are in Mac OS Greek code order.
#
#   One of these mappings requires the use of a corporate character.
#   See the file "CORPCHAR.TXT" and notes below.
#
#   Control character mappings are not shown in this table, following
#   the conventions of the standard UTC mapping tables. However, the
#   Mac OS Greek character set uses the standard control characters at
#   0x00-0x1F and 0x7F.
#
# Notes on Mac OS Greek:
# ----------------------
#
#   This is a legacy Mac OS encoding; in the Mac OS X Carbon and Cocoa
#   environments, it is only supported via transcoding to and from
#   Unicode.
#
#   Although a Mac OS script code is defined for Greek (smGreek = 6),
#   the Greek localized system does not currently use it (the font
#   family IDs are in the Mac OS Roman range). To determine if the
#   Greek encoding is being used when the script code is smRoman (0),
#   you must check if the system region code is 20, verGreece.
#
#   The Mac OS Greek encoding is a superset of the repertoire of
#   ISO 8859-7 (although characters are not at the same code points),
#   except that LEFT & RIGHT SINGLE QUOTATION MARK replace the
#   MODIFIER LETTER REVERSED COMMA & APOSTROPHE (spacing versions of
#   Greek rough & smooth breathing marks) that are in ISO 8859-7.
#   The added characters in Mac OS Greek include more punctuation and
#   symbols and several accented Latin letters.
#
#   Before Mac OS 9.2.2, code point 0x9C was SOFT HYPHEN (U+00AD), and
#   code point 0xFF was undefined. In Mac OS 9.2.2 and later versions,
#   SOFT HYPHEN was moved to 0xFF, and code point 0x9C was changed to be
#   EURO SIGN (U+20AC); the standard Apple fonts are updated for Mac OS
#   9.2.2 to reflect this. There is a "no Euro sign" variant of the Mac
#   OS Greek encoding that uses the older mapping; this can be used for
#   older fonts.
#
#   This "no Euro sign" variant of Mac OS Greek was the character set
#   used by Mac OS Greek systems before 9.2.2 except for system 6.0.7,
#   which used a variant character set but was quickly replaced with
#   Greek system 6.0.7.1 using the no Euro sign" character set
#   documented here. Greek system 4.1 used a variant Greek set that had
#   ISO 8859-7 in 0xA0-0xFF (with some holes filled in with DTP
#   characters), and Mac OS Roman accented Roman letters in 0x80-0x9F.
#
# Unicode mapping issues and notes:
# ---------------------------------
#
# Details of mapping changes in each version:
# -------------------------------------------
#
#   Changes from version b02 to version b03/c01:
#
#   - The Mac OS Greek encoding changed for Mac OS 9.2.2 and later
#     as follows:
#     0x9C, changed from 0x00AD SOFT HYPHEN to 0x20AC EURO SIGN
#     0xFF, changed from undefined to 0x00AD SOFT HYPHEN
#
#   Changes from version n04 to version n06:
#
#   - Change mapping of 0xAF from U+0387 to its canonical
#     decomposition, U+00B7.
#
##################
*/

import Foundation

let macGreekEncoding: [UVBMP] = [
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
   0x00B9,       /* 81  SUPERSCRIPT ONE */
   0x00B2,       /* 82  SUPERSCRIPT TWO */
   0x00C9,       /* 83  LATIN CAPITAL LETTER E WITH ACUTE */
   0x00B3,       /* 84  SUPERSCRIPT THREE */
   0x00D6,       /* 85  LATIN CAPITAL LETTER O WITH DIAERESIS */
   0x00DC,       /* 86  LATIN CAPITAL LETTER U WITH DIAERESIS */
   0x0385,       /* 87  GREEK DIALYTIKA TONOS */
   0x00E0,       /* 88  LATIN SMALL LETTER A WITH GRAVE */
   0x00E2,       /* 89  LATIN SMALL LETTER A WITH CIRCUMFLEX */
   0x00E4,       /* 8A  LATIN SMALL LETTER A WITH DIAERESIS */
   0x0384,       /* 8B  GREEK TONOS */
   0x00A8,       /* 8C  DIAERESIS */
   0x00E7,       /* 8D  LATIN SMALL LETTER C WITH CEDILLA */
   0x00E9,       /* 8E  LATIN SMALL LETTER E WITH ACUTE */
   0x00E8,       /* 8F  LATIN SMALL LETTER E WITH GRAVE */
   0x00EA,       /* 90  LATIN SMALL LETTER E WITH CIRCUMFLEX */
   0x00EB,       /* 91  LATIN SMALL LETTER E WITH DIAERESIS */
   0x00A3,       /* 92  POUND SIGN */
   0x2122,       /* 93  TRADE MARK SIGN */
   0x00EE,       /* 94  LATIN SMALL LETTER I WITH CIRCUMFLEX */
   0x00EF,       /* 95  LATIN SMALL LETTER I WITH DIAERESIS */
   0x2022,       /* 96  BULLET */
   0x00BD,       /* 97  VULGAR FRACTION ONE HALF */
   0x2030,       /* 98  PER MILLE SIGN */
   0x00F4,       /* 99  LATIN SMALL LETTER O WITH CIRCUMFLEX */
   0x00F6,       /* 9A  LATIN SMALL LETTER O WITH DIAERESIS */
   0x00A6,       /* 9B  BROKEN BAR */
   0x00AD,       /* 9C  SOFT HYPHEN */
   0x00F9,       /* 9D  LATIN SMALL LETTER U WITH GRAVE */
   0x00FB,       /* 9E  LATIN SMALL LETTER U WITH CIRCUMFLEX */
   0x00FC,       /* 9F  LATIN SMALL LETTER U WITH DIAERESIS */
   0x2020,       /* A0  DAGGER */
   0x0393,       /* A1  GREEK CAPITAL LETTER GAMMA */
   0x0394,       /* A2  GREEK CAPITAL LETTER DELTA */
   0x0398,       /* A3  GREEK CAPITAL LETTER THETA */
   0x039B,       /* A4  GREEK CAPITAL LETTER LAMDA */
   0x039E,       /* A5  GREEK CAPITAL LETTER XI */
   0x03A0,       /* A6  GREEK CAPITAL LETTER PI */
   0x00DF,       /* A7  LATIN SMALL LETTER SHARP S */
   0x00AE,       /* A8  REGISTERED SIGN */
   0x00A9,       /* A9  COPYRIGHT SIGN */
   0x03A3,       /* AA  GREEK CAPITAL LETTER SIGMA */
   0x03AA,       /* AB  GREEK CAPITAL LETTER IOTA WITH DIALYTIKA */
   0x00A7,       /* AC  SECTION SIGN */
   0x2260,       /* AD  NOT EQUAL TO */
   0x00B0,       /* AE  DEGREE SIGN */
   0x00B7,       /* AF  MIDDLE DOT */
   0x0391,       /* B0  GREEK CAPITAL LETTER ALPHA */
   0x00B1,       /* B1  PLUS-MINUS SIGN */
   0x2264,       /* B2  LESS-THAN OR EQUAL TO */
   0x2265,       /* B3  GREATER-THAN OR EQUAL TO */
   0x00A5,       /* B4  YEN SIGN */
   0x0392,       /* B5  GREEK CAPITAL LETTER BETA */
   0x0395,       /* B6  GREEK CAPITAL LETTER EPSILON */
   0x0396,       /* B7  GREEK CAPITAL LETTER ZETA */
   0x0397,       /* B8  GREEK CAPITAL LETTER ETA */
   0x0399,       /* B9  GREEK CAPITAL LETTER IOTA */
   0x039A,       /* BA  GREEK CAPITAL LETTER KAPPA */
   0x039C,       /* BB  GREEK CAPITAL LETTER MU */
   0x03A6,       /* BC  GREEK CAPITAL LETTER PHI */
   0x03AB,       /* BD  GREEK CAPITAL LETTER UPSILON WITH DIALYTIKA */
   0x03A8,       /* BE  GREEK CAPITAL LETTER PSI */
   0x03A9,       /* BF  GREEK CAPITAL LETTER OMEGA */
   0x03AC,       /* C0  GREEK SMALL LETTER ALPHA WITH TONOS */
   0x039D,       /* C1  GREEK CAPITAL LETTER NU */
   0x00AC,       /* C2  NOT SIGN */
   0x039F,       /* C3  GREEK CAPITAL LETTER OMICRON */
   0x03A1,       /* C4  GREEK CAPITAL LETTER RHO */
   0x2248,       /* C5  ALMOST EQUAL TO */
   0x03A4,       /* C6  GREEK CAPITAL LETTER TAU */
   0x00AB,       /* C7  LEFT-POINTING DOUBLE ANGLE QUOTATION MARK */
   0x00BB,       /* C8  RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK */
   0x2026,       /* C9  HORIZONTAL ELLIPSIS */
   0x00A0,       /* CA  NO-BREAK SPACE */
   0x03A5,       /* CB  GREEK CAPITAL LETTER UPSILON */
   0x03A7,       /* CC  GREEK CAPITAL LETTER CHI */
   0x0386,       /* CD  GREEK CAPITAL LETTER ALPHA WITH TONOS */
   0x0388,       /* CE  GREEK CAPITAL LETTER EPSILON WITH TONOS */
   0x0153,       /* CF  LATIN SMALL LIGATURE OE */
   0x2013,       /* D0  EN DASH */
   0x2015,       /* D1  HORIZONTAL BAR */
   0x201C,       /* D2  LEFT DOUBLE QUOTATION MARK */
   0x201D,       /* D3  RIGHT DOUBLE QUOTATION MARK */
   0x2018,       /* D4  LEFT SINGLE QUOTATION MARK */
   0x2019,       /* D5  RIGHT SINGLE QUOTATION MARK */
   0x00F7,       /* D6  DIVISION SIGN */
   0x0389,       /* D7  GREEK CAPITAL LETTER ETA WITH TONOS */
   0x038A,       /* D8  GREEK CAPITAL LETTER IOTA WITH TONOS */
   0x038C,       /* D9  GREEK CAPITAL LETTER OMICRON WITH TONOS */
   0x038E,       /* DA  GREEK CAPITAL LETTER UPSILON WITH TONOS */
   0x03AD,       /* DB  GREEK SMALL LETTER EPSILON WITH TONOS */
   0x03AE,       /* DC  GREEK SMALL LETTER ETA WITH TONOS */
   0x03AF,       /* DD  GREEK SMALL LETTER IOTA WITH TONOS */
   0x03CC,       /* DE  GREEK SMALL LETTER OMICRON WITH TONOS */
   0x038F,       /* DF  GREEK CAPITAL LETTER OMEGA WITH TONOS */
   0x03CD,       /* E0  GREEK SMALL LETTER UPSILON WITH TONOS */
   0x03B1,       /* E1  GREEK SMALL LETTER ALPHA */
   0x03B2,       /* E2  GREEK SMALL LETTER BETA */
   0x03C8,       /* E3  GREEK SMALL LETTER PSI */
   0x03B4,       /* E4  GREEK SMALL LETTER DELTA */
   0x03B5,       /* E5  GREEK SMALL LETTER EPSILON */
   0x03C6,       /* E6  GREEK SMALL LETTER PHI */
   0x03B3,       /* E7  GREEK SMALL LETTER GAMMA */
   0x03B7,       /* E8  GREEK SMALL LETTER ETA */
   0x03B9,       /* E9  GREEK SMALL LETTER IOTA */
   0x03BE,       /* EA  GREEK SMALL LETTER XI */
   0x03BA,       /* EB  GREEK SMALL LETTER KAPPA */
   0x03BB,       /* EC  GREEK SMALL LETTER LAMDA */
   0x03BC,       /* ED  GREEK SMALL LETTER MU */
   0x03BD,       /* EE  GREEK SMALL LETTER NU */
   0x03BF,       /* EF  GREEK SMALL LETTER OMICRON */
   0x03C0,       /* F0  GREEK SMALL LETTER PI */
   0x03CE,       /* F1  GREEK SMALL LETTER OMEGA WITH TONOS */
   0x03C1,       /* F2  GREEK SMALL LETTER RHO */
   0x03C3,       /* F3  GREEK SMALL LETTER SIGMA */
   0x03C4,       /* F4  GREEK SMALL LETTER TAU */
   0x03B8,       /* F5  GREEK SMALL LETTER THETA */
   0x03C9,       /* F6  GREEK SMALL LETTER OMEGA */
   0x03C2,       /* F7  GREEK SMALL LETTER FINAL SIGMA */
   0x03C7,       /* F8  GREEK SMALL LETTER CHI */
   0x03C5,       /* F9  GREEK SMALL LETTER UPSILON */
   0x03B6,       /* FA  GREEK SMALL LETTER ZETA */
   0x03CA,       /* FB  GREEK SMALL LETTER IOTA WITH DIALYTIKA */
   0x03CB,       /* FC  GREEK SMALL LETTER UPSILON WITH DIALYTIKA */
   0x0390,       /* FD  GREEK SMALL LETTER IOTA WITH DIALYTIKA AND TONOS */
   0x03B0,       /* FE  GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND TONOS */
   .undefined,   /* FF */
]

let uvsToMacGreek: [UVBMP: CharCode] = [
    0x0020:       0x20, /*  SPACE */
    0x0021:       0x21, /*  EXCLAMATION MARK */
    0x0022:       0x22, /*  QUOTATION MARK */
    0x0023:       0x23, /*  NUMBER SIGN */
    0x0024:       0x24, /*  DOLLAR SIGN */
    0x0025:       0x25, /*  PERCENT SIGN */
    0x0026:       0x26, /*  AMPERSAND */
    0x0027:       0x27, /*  APOSTROPHE */
    0x0028:       0x28, /*  LEFT PARENTHESIS */
    0x0029:       0x29, /*  RIGHT PARENTHESIS */
    0x002A:       0x2A, /*  ASTERISK */
    0x002B:       0x2B, /*  PLUS SIGN */
    0x002C:       0x2C, /*  COMMA */
    0x002D:       0x2D, /*  HYPHEN-MINUS */
    0x002E:       0x2E, /*  FULL STOP */
    0x002F:       0x2F, /*  SOLIDUS */
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
    0x003A:       0x3A, /*  COLON */
    0x003B:       0x3B, /*  SEMICOLON */
    0x003C:       0x3C, /*  LESS-THAN SIGN */
    0x003D:       0x3D, /*  EQUALS SIGN */
    0x003E:       0x3E, /*  GREATER-THAN SIGN */
    0x003F:       0x3F, /*  QUESTION MARK */
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
    0x005B:       0x5B, /*  LEFT SQUARE BRACKET */
    0x005C:       0x5C, /*  REVERSE SOLIDUS */
    0x005D:       0x5D, /*  RIGHT SQUARE BRACKET */
    0x005E:       0x5E, /*  CIRCUMFLEX ACCENT */
    0x005F:       0x5F, /*  LOW LINE */
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
    0x007B:       0x7B, /*  LEFT CURLY BRACKET */
    0x007C:       0x7C, /*  VERTICAL LINE */
    0x007D:       0x7D, /*  RIGHT CURLY BRACKET */
    0x007E:       0x7E, /*  TILDE */
    0x00C4:       0x80, /*  LATIN CAPITAL LETTER A WITH DIAERESIS */
    0x00B9:       0x81, /*  SUPERSCRIPT ONE */
    0x00B2:       0x82, /*  SUPERSCRIPT TWO */
    0x00C9:       0x83, /*  LATIN CAPITAL LETTER E WITH ACUTE */
    0x00B3:       0x84, /*  SUPERSCRIPT THREE */
    0x00D6:       0x85, /*  LATIN CAPITAL LETTER O WITH DIAERESIS */
    0x00DC:       0x86, /*  LATIN CAPITAL LETTER U WITH DIAERESIS */
    0x0385:       0x87, /*  GREEK DIALYTIKA TONOS */
    0x00E0:       0x88, /*  LATIN SMALL LETTER A WITH GRAVE */
    0x00E2:       0x89, /*  LATIN SMALL LETTER A WITH CIRCUMFLEX */
    0x00E4:       0x8A, /*  LATIN SMALL LETTER A WITH DIAERESIS */
    0x0384:       0x8B, /*  GREEK TONOS */
    0x00A8:       0x8C, /*  DIAERESIS */
    0x00E7:       0x8D, /*  LATIN SMALL LETTER C WITH CEDILLA */
    0x00E9:       0x8E, /*  LATIN SMALL LETTER E WITH ACUTE */
    0x00E8:       0x8F, /*  LATIN SMALL LETTER E WITH GRAVE */
    0x00EA:       0x90, /*  LATIN SMALL LETTER E WITH CIRCUMFLEX */
    0x00EB:       0x91, /*  LATIN SMALL LETTER E WITH DIAERESIS */
    0x00A3:       0x92, /*  POUND SIGN */
    0x2122:       0x93, /*  TRADE MARK SIGN */
    0x00EE:       0x94, /*  LATIN SMALL LETTER I WITH CIRCUMFLEX */
    0x00EF:       0x95, /*  LATIN SMALL LETTER I WITH DIAERESIS */
    0x2022:       0x96, /*  BULLET */
    0x00BD:       0x97, /*  VULGAR FRACTION ONE HALF */
    0x2030:       0x98, /*  PER MILLE SIGN */
    0x00F4:       0x99, /*  LATIN SMALL LETTER O WITH CIRCUMFLEX */
    0x00F6:       0x9A, /*  LATIN SMALL LETTER O WITH DIAERESIS */
    0x00A6:       0x9B, /*  BROKEN BAR */
    0x00AD:       0x9C, /*  SOFT HYPHEN */
    0x00F9:       0x9D, /*  LATIN SMALL LETTER U WITH GRAVE */
    0x00FB:       0x9E, /*  LATIN SMALL LETTER U WITH CIRCUMFLEX */
    0x00FC:       0x9F, /*  LATIN SMALL LETTER U WITH DIAERESIS */
    0x2020:       0xA0, /*  DAGGER */
    0x0393:       0xA1, /*  GREEK CAPITAL LETTER GAMMA */
    0x0394:       0xA2, /*  GREEK CAPITAL LETTER DELTA */
    0x0398:       0xA3, /*  GREEK CAPITAL LETTER THETA */
    0x039B:       0xA4, /*  GREEK CAPITAL LETTER LAMDA */
    0x039E:       0xA5, /*  GREEK CAPITAL LETTER XI */
    0x03A0:       0xA6, /*  GREEK CAPITAL LETTER PI */
    0x00DF:       0xA7, /*  LATIN SMALL LETTER SHARP S */
    0x00AE:       0xA8, /*  REGISTERED SIGN */
    0x00A9:       0xA9, /*  COPYRIGHT SIGN */
    0x03A3:       0xAA, /*  GREEK CAPITAL LETTER SIGMA */
    0x03AA:       0xAB, /*  GREEK CAPITAL LETTER IOTA WITH DIALYTIKA */
    0x00A7:       0xAC, /*  SECTION SIGN */
    0x2260:       0xAD, /*  NOT EQUAL TO */
    0x00B0:       0xAE, /*  DEGREE SIGN */
    0x00B7:       0xAF, /*  MIDDLE DOT */
    0x0391:       0xB0, /*  GREEK CAPITAL LETTER ALPHA */
    0x00B1:       0xB1, /*  PLUS-MINUS SIGN */
    0x2264:       0xB2, /*  LESS-THAN OR EQUAL TO */
    0x2265:       0xB3, /*  GREATER-THAN OR EQUAL TO */
    0x00A5:       0xB4, /*  YEN SIGN */
    0x0392:       0xB5, /*  GREEK CAPITAL LETTER BETA */
    0x0395:       0xB6, /*  GREEK CAPITAL LETTER EPSILON */
    0x0396:       0xB7, /*  GREEK CAPITAL LETTER ZETA */
    0x0397:       0xB8, /*  GREEK CAPITAL LETTER ETA */
    0x0399:       0xB9, /*  GREEK CAPITAL LETTER IOTA */
    0x039A:       0xBA, /*  GREEK CAPITAL LETTER KAPPA */
    0x039C:       0xBB, /*  GREEK CAPITAL LETTER MU */
    0x03A6:       0xBC, /*  GREEK CAPITAL LETTER PHI */
    0x03AB:       0xBD, /*  GREEK CAPITAL LETTER UPSILON WITH DIALYTIKA */
    0x03A8:       0xBE, /*  GREEK CAPITAL LETTER PSI */
    0x03A9:       0xBF, /*  GREEK CAPITAL LETTER OMEGA */
    0x03AC:       0xC0, /*  GREEK SMALL LETTER ALPHA WITH TONOS */
    0x039D:       0xC1, /*  GREEK CAPITAL LETTER NU */
    0x00AC:       0xC2, /*  NOT SIGN */
    0x039F:       0xC3, /*  GREEK CAPITAL LETTER OMICRON */
    0x03A1:       0xC4, /*  GREEK CAPITAL LETTER RHO */
    0x2248:       0xC5, /*  ALMOST EQUAL TO */
    0x03A4:       0xC6, /*  GREEK CAPITAL LETTER TAU */
    0x00AB:       0xC7, /*  LEFT-POINTING DOUBLE ANGLE QUOTATION MARK */
    0x00BB:       0xC8, /*  RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK */
    0x2026:       0xC9, /*  HORIZONTAL ELLIPSIS */
    0x00A0:       0xCA, /*  NO-BREAK SPACE */
    0x03A5:       0xCB, /*  GREEK CAPITAL LETTER UPSILON */
    0x03A7:       0xCC, /*  GREEK CAPITAL LETTER CHI */
    0x0386:       0xCD, /*  GREEK CAPITAL LETTER ALPHA WITH TONOS */
    0x0388:       0xCE, /*  GREEK CAPITAL LETTER EPSILON WITH TONOS */
    0x0153:       0xCF, /*  LATIN SMALL LIGATURE OE */
    0x2013:       0xD0, /*  EN DASH */
    0x2015:       0xD1, /*  HORIZONTAL BAR */
    0x201C:       0xD2, /*  LEFT DOUBLE QUOTATION MARK */
    0x201D:       0xD3, /*  RIGHT DOUBLE QUOTATION MARK */
    0x2018:       0xD4, /*  LEFT SINGLE QUOTATION MARK */
    0x2019:       0xD5, /*  RIGHT SINGLE QUOTATION MARK */
    0x00F7:       0xD6, /*  DIVISION SIGN */
    0x0389:       0xD7, /*  GREEK CAPITAL LETTER ETA WITH TONOS */
    0x038A:       0xD8, /*  GREEK CAPITAL LETTER IOTA WITH TONOS */
    0x038C:       0xD9, /*  GREEK CAPITAL LETTER OMICRON WITH TONOS */
    0x038E:       0xDA, /*  GREEK CAPITAL LETTER UPSILON WITH TONOS */
    0x03AD:       0xDB, /*  GREEK SMALL LETTER EPSILON WITH TONOS */
    0x03AE:       0xDC, /*  GREEK SMALL LETTER ETA WITH TONOS */
    0x03AF:       0xDD, /*  GREEK SMALL LETTER IOTA WITH TONOS */
    0x03CC:       0xDE, /*  GREEK SMALL LETTER OMICRON WITH TONOS */
    0x038F:       0xDF, /*  GREEK CAPITAL LETTER OMEGA WITH TONOS */
    0x03CD:       0xE0, /*  GREEK SMALL LETTER UPSILON WITH TONOS */
    0x03B1:       0xE1, /*  GREEK SMALL LETTER ALPHA */
    0x03B2:       0xE2, /*  GREEK SMALL LETTER BETA */
    0x03C8:       0xE3, /*  GREEK SMALL LETTER PSI */
    0x03B4:       0xE4, /*  GREEK SMALL LETTER DELTA */
    0x03B5:       0xE5, /*  GREEK SMALL LETTER EPSILON */
    0x03C6:       0xE6, /*  GREEK SMALL LETTER PHI */
    0x03B3:       0xE7, /*  GREEK SMALL LETTER GAMMA */
    0x03B7:       0xE8, /*  GREEK SMALL LETTER ETA */
    0x03B9:       0xE9, /*  GREEK SMALL LETTER IOTA */
    0x03BE:       0xEA, /*  GREEK SMALL LETTER XI */
    0x03BA:       0xEB, /*  GREEK SMALL LETTER KAPPA */
    0x03BB:       0xEC, /*  GREEK SMALL LETTER LAMDA */
    0x03BC:       0xED, /*  GREEK SMALL LETTER MU */
    0x03BD:       0xEE, /*  GREEK SMALL LETTER NU */
    0x03BF:       0xEF, /*  GREEK SMALL LETTER OMICRON */
    0x03C0:       0xF0, /*  GREEK SMALL LETTER PI */
    0x03CE:       0xF1, /*  GREEK SMALL LETTER OMEGA WITH TONOS */
    0x03C1:       0xF2, /*  GREEK SMALL LETTER RHO */
    0x03C3:       0xF3, /*  GREEK SMALL LETTER SIGMA */
    0x03C4:       0xF4, /*  GREEK SMALL LETTER TAU */
    0x03B8:       0xF5, /*  GREEK SMALL LETTER THETA */
    0x03C9:       0xF6, /*  GREEK SMALL LETTER OMEGA */
    0x03C2:       0xF7, /*  GREEK SMALL LETTER FINAL SIGMA */
    0x03C7:       0xF8, /*  GREEK SMALL LETTER CHI */
    0x03C5:       0xF9, /*  GREEK SMALL LETTER UPSILON */
    0x03B6:       0xFA, /*  GREEK SMALL LETTER ZETA */
    0x03CA:       0xFB, /*  GREEK SMALL LETTER IOTA WITH DIALYTIKA */
    0x03CB:       0xFC, /*  GREEK SMALL LETTER UPSILON WITH DIALYTIKA */
    0x0390:       0xFD, /*  GREEK SMALL LETTER IOTA WITH DIALYTIKA AND TONOS */
    0x03B0:       0xFE, /*  GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND TONOS */
]
