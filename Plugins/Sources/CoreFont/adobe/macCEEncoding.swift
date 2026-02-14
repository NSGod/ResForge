//
//  macCEEncoding.swift
//  CoreFont
//
//  Created by Mark Douma on 1/1/2026.
//
/* Copyright 2014 Adobe Systems Incorporated (http://www.adobe.com/). All Rights Reserved.
   This software is licensed as OpenSource, under the Apache License, Version 2.0.
   This license is available at: http://opensource.org/licenses/Apache-2.0. */

/* Mac OS Central European aggregate Unicode initializer.

   Element values are UVs. UV_UNDEF is 0xFFFF. Index by code, get UV.
   Source: ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/APPLE/CENTEURO.TXT
   as of 9/9/99. */

/*
 #   The entries are in Mac OS Central European code order.
 #
 #   Control character mappings are not shown in this table, following
 #   the conventions of the standard UTC mapping tables. However, the
 #   Mac OS Central European character set uses the standard control
 #   characters at 0x00-0x1F and 0x7F.
 #
 # Notes on Mac OS Central European:
 # ---------------------------------
 #
 #   This is a legacy Mac OS encoding; in the Mac OS X Carbon and Cocoa
 #   environments, it is only supported directly in programming
 #   interfaces for QuickDraw Text, the Script Manager, and related
 #   Text Utilities. For other purposes it is supported via transcoding
 #   to and from Unicode.
 #
 #   This character set is intended to cover the following languages:
 #
 #   Polish, Czech, Slovak, Hungarian, Estonian, Latvian, Lithuanian
 #
 #   These are written in Latin script, but using a different set of
 #   of accented characters than Mac OS Roman. The Mac OS Central
 #   European character set also includes a number of characters
 #   needed for the Mac OS user interface and localization (e.g.
 #   ellipsis, bullet, copyright sign), several typographic
 #   punctuation symbols, math symbols, etc. However, it has a
 #   smaller set of punctuation and symbols than Mac OS Roman. All of
 #   the characters in Mac OS Central European that are also in the
 #   Mac OS Roman character set are at the same code point in both
 #   character sets; this improves application compatibility.
 #
 #   Note: This does not have the same letter repertoire as ISO
 #   8859-2 (Latin-2); each has some accented letters that the other
 #   does not have.
 */

import Foundation

let macCEEncoding: [UVBMP] = [
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
    0x0100,       /* 81  LATIN CAPITAL LETTER A WITH MACRON */
    0x0101,       /* 82  LATIN SMALL LETTER A WITH MACRON */
    0x00C9,       /* 83  LATIN CAPITAL LETTER E WITH ACUTE */
    0x0104,       /* 84  LATIN CAPITAL LETTER A WITH OGONEK */
    0x00D6,       /* 85  LATIN CAPITAL LETTER O WITH DIAERESIS */
    0x00DC,       /* 86  LATIN CAPITAL LETTER U WITH DIAERESIS */
    0x00E1,       /* 87  LATIN SMALL LETTER A WITH ACUTE */
    0x0105,       /* 88  LATIN SMALL LETTER A WITH OGONEK */
    0x010C,       /* 89  LATIN CAPITAL LETTER C WITH CARON */
    0x00E4,       /* 8A  LATIN SMALL LETTER A WITH DIAERESIS */
    0x010D,       /* 8B  LATIN SMALL LETTER C WITH CARON */
    0x0106,       /* 8C  LATIN CAPITAL LETTER C WITH ACUTE */
    0x0107,       /* 8D  LATIN SMALL LETTER C WITH ACUTE */
    0x00E9,       /* 8E  LATIN SMALL LETTER E WITH ACUTE */
    0x0179,       /* 8F  LATIN CAPITAL LETTER Z WITH ACUTE */
    0x017A,       /* 90  LATIN SMALL LETTER Z WITH ACUTE */
    0x010E,       /* 91  LATIN CAPITAL LETTER D WITH CARON */
    0x00ED,       /* 92  LATIN SMALL LETTER I WITH ACUTE */
    0x010F,       /* 93  LATIN SMALL LETTER D WITH CARON */
    0x0112,       /* 94  LATIN CAPITAL LETTER E WITH MACRON */
    0x0113,       /* 95  LATIN SMALL LETTER E WITH MACRON */
    0x0116,       /* 96  LATIN CAPITAL LETTER E WITH DOT ABOVE */
    0x00F3,       /* 97  LATIN SMALL LETTER O WITH ACUTE */
    0x0117,       /* 98  LATIN SMALL LETTER E WITH DOT ABOVE */
    0x00F4,       /* 99  LATIN SMALL LETTER O WITH CIRCUMFLEX */
    0x00F6,       /* 9A  LATIN SMALL LETTER O WITH DIAERESIS */
    0x00F5,       /* 9B  LATIN SMALL LETTER O WITH TILDE */
    0x00FA,       /* 9C  LATIN SMALL LETTER U WITH ACUTE */
    0x011A,       /* 9D  LATIN CAPITAL LETTER E WITH CARON */
    0x011B,       /* 9E  LATIN SMALL LETTER E WITH CARON */
    0x00FC,       /* 9F  LATIN SMALL LETTER U WITH DIAERESIS */
    0x2020,       /* A0  DAGGER */
    0x00B0,       /* A1  DEGREE SIGN */
    0x0118,       /* A2  LATIN CAPITAL LETTER E WITH OGONEK */
    0x00A3,       /* A3  POUND SIGN */
    0x00A7,       /* A4  SECTION SIGN */
    0x2022,       /* A5  BULLET */
    0x00B6,       /* A6  PILCROW SIGN */
    0x00DF,       /* A7  LATIN SMALL LETTER SHARP S */
    0x00AE,       /* A8  REGISTERED SIGN */
    0x00A9,       /* A9  COPYRIGHT SIGN */
    0x2122,       /* AA  TRADE MARK SIGN */
    0x0119,       /* AB  LATIN SMALL LETTER E WITH OGONEK */
    0x00A8,       /* AC  DIAERESIS */
    0x2260,       /* AD  NOT EQUAL TO */
    0x0123,       /* AE  LATIN SMALL LETTER G WITH CEDILLA */
    0x012E,       /* AF  LATIN CAPITAL LETTER I WITH OGONEK */
    0x012F,       /* B0  LATIN SMALL LETTER I WITH OGONEK */
    0x012A,       /* B1  LATIN CAPITAL LETTER I WITH MACRON */
    0x2264,       /* B2  LESS-THAN OR EQUAL TO */
    0x2265,       /* B3  GREATER-THAN OR EQUAL TO */
    0x012B,       /* B4  LATIN SMALL LETTER I WITH MACRON */
    0x0136,       /* B5  LATIN CAPITAL LETTER K WITH CEDILLA */
    0x2202,       /* B6  PARTIAL DIFFERENTIAL */
    0x2211,       /* B7  N-ARY SUMMATION */
    0x0142,       /* B8  LATIN SMALL LETTER L WITH STROKE */
    0x013B,       /* B9  LATIN CAPITAL LETTER L WITH CEDILLA */
    0x013C,       /* BA  LATIN SMALL LETTER L WITH CEDILLA */
    0x013D,       /* BB  LATIN CAPITAL LETTER L WITH CARON */
    0x013E,       /* BC  LATIN SMALL LETTER L WITH CARON */
    0x0139,       /* BD  LATIN CAPITAL LETTER L WITH ACUTE */
    0x013A,       /* BE  LATIN SMALL LETTER L WITH ACUTE */
    0x0145,       /* BF  LATIN CAPITAL LETTER N WITH CEDILLA */
    0x0146,       /* C0  LATIN SMALL LETTER N WITH CEDILLA */
    0x0143,       /* C1  LATIN CAPITAL LETTER N WITH ACUTE */
    0x00AC,       /* C2  NOT SIGN */
    0x221A,       /* C3  SQUARE ROOT */
    0x0144,       /* C4  LATIN SMALL LETTER N WITH ACUTE */
    0x0147,       /* C5  LATIN CAPITAL LETTER N WITH CARON */
    0x2206,       /* C6  INCREMENT */
    0x00AB,       /* C7  LEFT-POINTING DOUBLE ANGLE QUOTATION MARK */
    0x00BB,       /* C8  RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK */
    0x2026,       /* C9  HORIZONTAL ELLIPSIS */
    0x00A0,       /* CA  NO-BREAK SPACE */
    0x0148,       /* CB  LATIN SMALL LETTER N WITH CARON */
    0x0150,       /* CC  LATIN CAPITAL LETTER O WITH DOUBLE ACUTE */
    0x00D5,       /* CD  LATIN CAPITAL LETTER O WITH TILDE */
    0x0151,       /* CE  LATIN SMALL LETTER O WITH DOUBLE ACUTE */
    0x014C,       /* CF  LATIN CAPITAL LETTER O WITH MACRON */
    0x2013,       /* D0  EN DASH */
    0x2014,       /* D1  EM DASH */
    0x201C,       /* D2  LEFT DOUBLE QUOTATION MARK */
    0x201D,       /* D3  RIGHT DOUBLE QUOTATION MARK */
    0x2018,       /* D4  LEFT SINGLE QUOTATION MARK */
    0x2019,       /* D5  RIGHT SINGLE QUOTATION MARK */
    0x00F7,       /* D6  DIVISION SIGN */
    0x25CA,       /* D7  LOZENGE */
    0x014D,       /* D8  LATIN SMALL LETTER O WITH MACRON */
    0x0154,       /* D9  LATIN CAPITAL LETTER R WITH ACUTE */
    0x0155,       /* DA  LATIN SMALL LETTER R WITH ACUTE */
    0x0158,       /* DB  LATIN CAPITAL LETTER R WITH CARON */
    0x2039,       /* DC  SINGLE LEFT-POINTING ANGLE QUOTATION MARK */
    0x203A,       /* DD  SINGLE RIGHT-POINTING ANGLE QUOTATION MARK */
    0x0159,       /* DE  LATIN SMALL LETTER R WITH CARON */
    0x0156,       /* DF  LATIN CAPITAL LETTER R WITH CEDILLA */
    0x0157,       /* E0  LATIN SMALL LETTER R WITH CEDILLA */
    0x0160,       /* E1  LATIN CAPITAL LETTER S WITH CARON */
    0x201A,       /* E2  SINGLE LOW-9 QUOTATION MARK */
    0x201E,       /* E3  DOUBLE LOW-9 QUOTATION MARK */
    0x0161,       /* E4  LATIN SMALL LETTER S WITH CARON */
    0x015A,       /* E5  LATIN CAPITAL LETTER S WITH ACUTE */
    0x015B,       /* E6  LATIN SMALL LETTER S WITH ACUTE */
    0x00C1,       /* E7  LATIN CAPITAL LETTER A WITH ACUTE */
    0x0164,       /* E8  LATIN CAPITAL LETTER T WITH CARON */
    0x0165,       /* E9  LATIN SMALL LETTER T WITH CARON */
    0x00CD,       /* EA  LATIN CAPITAL LETTER I WITH ACUTE */
    0x017D,       /* EB  LATIN CAPITAL LETTER Z WITH CARON */
    0x017E,       /* EC  LATIN SMALL LETTER Z WITH CARON */
    0x016A,       /* ED  LATIN CAPITAL LETTER U WITH MACRON */
    0x00D3,       /* EE  LATIN CAPITAL LETTER O WITH ACUTE */
    0x00D4,       /* EF  LATIN CAPITAL LETTER O WITH CIRCUMFLEX */
    0x016B,       /* F0  LATIN SMALL LETTER U WITH MACRON */
    0x016E,       /* F1  LATIN CAPITAL LETTER U WITH RING ABOVE */
    0x00DA,       /* F2  LATIN CAPITAL LETTER U WITH ACUTE */
    0x016F,       /* F3  LATIN SMALL LETTER U WITH RING ABOVE */
    0x0170,       /* F4  LATIN CAPITAL LETTER U WITH DOUBLE ACUTE */
    0x0171,       /* F5  LATIN SMALL LETTER U WITH DOUBLE ACUTE */
    0x0172,       /* F6  LATIN CAPITAL LETTER U WITH OGONEK */
    0x0173,       /* F7  LATIN SMALL LETTER U WITH OGONEK */
    0x00DD,       /* F8  LATIN CAPITAL LETTER Y WITH ACUTE */
    0x00FD,       /* F9  LATIN SMALL LETTER Y WITH ACUTE */
    0x0137,       /* FA  LATIN SMALL LETTER K WITH CEDILLA */
    0x017B,       /* FB  LATIN CAPITAL LETTER Z WITH DOT ABOVE */
    0x0141,       /* FC  LATIN CAPITAL LETTER L WITH STROKE */
    0x017C,       /* FD  LATIN SMALL LETTER Z WITH DOT ABOVE */
    0x0122,       /* FE  LATIN CAPITAL LETTER G WITH CEDILLA */
    0x02C7,       /* FF  CARON */
]

let uvsToMacCE: [UVBMP: CharCode] = [
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
    0x0100:       0x81, /*  LATIN CAPITAL LETTER A WITH MACRON */
    0x0101:       0x82, /*  LATIN SMALL LETTER A WITH MACRON */
    0x00C9:       0x83, /*  LATIN CAPITAL LETTER E WITH ACUTE */
    0x0104:       0x84, /*  LATIN CAPITAL LETTER A WITH OGONEK */
    0x00D6:       0x85, /*  LATIN CAPITAL LETTER O WITH DIAERESIS */
    0x00DC:       0x86, /*  LATIN CAPITAL LETTER U WITH DIAERESIS */
    0x00E1:       0x87, /*  LATIN SMALL LETTER A WITH ACUTE */
    0x0105:       0x88, /*  LATIN SMALL LETTER A WITH OGONEK */
    0x010C:       0x89, /*  LATIN CAPITAL LETTER C WITH CARON */
    0x00E4:       0x8A, /*  LATIN SMALL LETTER A WITH DIAERESIS */
    0x010D:       0x8B, /*  LATIN SMALL LETTER C WITH CARON */
    0x0106:       0x8C, /*  LATIN CAPITAL LETTER C WITH ACUTE */
    0x0107:       0x8D, /*  LATIN SMALL LETTER C WITH ACUTE */
    0x00E9:       0x8E, /*  LATIN SMALL LETTER E WITH ACUTE */
    0x0179:       0x8F, /*  LATIN CAPITAL LETTER Z WITH ACUTE */
    0x017A:       0x90, /*  LATIN SMALL LETTER Z WITH ACUTE */
    0x010E:       0x91, /*  LATIN CAPITAL LETTER D WITH CARON */
    0x00ED:       0x92, /*  LATIN SMALL LETTER I WITH ACUTE */
    0x010F:       0x93, /*  LATIN SMALL LETTER D WITH CARON */
    0x0112:       0x94, /*  LATIN CAPITAL LETTER E WITH MACRON */
    0x0113:       0x95, /*  LATIN SMALL LETTER E WITH MACRON */
    0x0116:       0x96, /*  LATIN CAPITAL LETTER E WITH DOT ABOVE */
    0x00F3:       0x97, /*  LATIN SMALL LETTER O WITH ACUTE */
    0x0117:       0x98, /*  LATIN SMALL LETTER E WITH DOT ABOVE */
    0x00F4:       0x99, /*  LATIN SMALL LETTER O WITH CIRCUMFLEX */
    0x00F6:       0x9A, /*  LATIN SMALL LETTER O WITH DIAERESIS */
    0x00F5:       0x9B, /*  LATIN SMALL LETTER O WITH TILDE */
    0x00FA:       0x9C, /*  LATIN SMALL LETTER U WITH ACUTE */
    0x011A:       0x9D, /*  LATIN CAPITAL LETTER E WITH CARON */
    0x011B:       0x9E, /*  LATIN SMALL LETTER E WITH CARON */
    0x00FC:       0x9F, /*  LATIN SMALL LETTER U WITH DIAERESIS */
    0x2020:       0xA0, /*  DAGGER */
    0x00B0:       0xA1, /*  DEGREE SIGN */
    0x0118:       0xA2, /*  LATIN CAPITAL LETTER E WITH OGONEK */
    0x00A3:       0xA3, /*  POUND SIGN */
    0x00A7:       0xA4, /*  SECTION SIGN */
    0x2022:       0xA5, /*  BULLET */
    0x00B6:       0xA6, /*  PILCROW SIGN */
    0x00DF:       0xA7, /*  LATIN SMALL LETTER SHARP S */
    0x00AE:       0xA8, /*  REGISTERED SIGN */
    0x00A9:       0xA9, /*  COPYRIGHT SIGN */
    0x2122:       0xAA, /*  TRADE MARK SIGN */
    0x0119:       0xAB, /*  LATIN SMALL LETTER E WITH OGONEK */
    0x00A8:       0xAC, /*  DIAERESIS */
    0x2260:       0xAD, /*  NOT EQUAL TO */
    0x0123:       0xAE, /*  LATIN SMALL LETTER G WITH CEDILLA */
    0x012E:       0xAF, /*  LATIN CAPITAL LETTER I WITH OGONEK */
    0x012F:       0xB0, /*  LATIN SMALL LETTER I WITH OGONEK */
    0x012A:       0xB1, /*  LATIN CAPITAL LETTER I WITH MACRON */
    0x2264:       0xB2, /*  LESS-THAN OR EQUAL TO */
    0x2265:       0xB3, /*  GREATER-THAN OR EQUAL TO */
    0x012B:       0xB4, /*  LATIN SMALL LETTER I WITH MACRON */
    0x0136:       0xB5, /*  LATIN CAPITAL LETTER K WITH CEDILLA */
    0x2202:       0xB6, /*  PARTIAL DIFFERENTIAL */
    0x2211:       0xB7, /*  N-ARY SUMMATION */
    0x0142:       0xB8, /*  LATIN SMALL LETTER L WITH STROKE */
    0x013B:       0xB9, /*  LATIN CAPITAL LETTER L WITH CEDILLA */
    0x013C:       0xBA, /*  LATIN SMALL LETTER L WITH CEDILLA */
    0x013D:       0xBB, /*  LATIN CAPITAL LETTER L WITH CARON */
    0x013E:       0xBC, /*  LATIN SMALL LETTER L WITH CARON */
    0x0139:       0xBD, /*  LATIN CAPITAL LETTER L WITH ACUTE */
    0x013A:       0xBE, /*  LATIN SMALL LETTER L WITH ACUTE */
    0x0145:       0xBF, /*  LATIN CAPITAL LETTER N WITH CEDILLA */
    0x0146:       0xC0, /*  LATIN SMALL LETTER N WITH CEDILLA */
    0x0143:       0xC1, /*  LATIN CAPITAL LETTER N WITH ACUTE */
    0x00AC:       0xC2, /*  NOT SIGN */
    0x221A:       0xC3, /*  SQUARE ROOT */
    0x0144:       0xC4, /*  LATIN SMALL LETTER N WITH ACUTE */
    0x0147:       0xC5, /*  LATIN CAPITAL LETTER N WITH CARON */
    0x2206:       0xC6, /*  INCREMENT */
    0x00AB:       0xC7, /*  LEFT-POINTING DOUBLE ANGLE QUOTATION MARK */
    0x00BB:       0xC8, /*  RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK */
    0x2026:       0xC9, /*  HORIZONTAL ELLIPSIS */
    0x00A0:       0xCA, /*  NO-BREAK SPACE */
    0x0148:       0xCB, /*  LATIN SMALL LETTER N WITH CARON */
    0x0150:       0xCC, /*  LATIN CAPITAL LETTER O WITH DOUBLE ACUTE */
    0x00D5:       0xCD, /*  LATIN CAPITAL LETTER O WITH TILDE */
    0x0151:       0xCE, /*  LATIN SMALL LETTER O WITH DOUBLE ACUTE */
    0x014C:       0xCF, /*  LATIN CAPITAL LETTER O WITH MACRON */
    0x2013:       0xD0, /*  EN DASH */
    0x2014:       0xD1, /*  EM DASH */
    0x201C:       0xD2, /*  LEFT DOUBLE QUOTATION MARK */
    0x201D:       0xD3, /*  RIGHT DOUBLE QUOTATION MARK */
    0x2018:       0xD4, /*  LEFT SINGLE QUOTATION MARK */
    0x2019:       0xD5, /*  RIGHT SINGLE QUOTATION MARK */
    0x00F7:       0xD6, /*  DIVISION SIGN */
    0x25CA:       0xD7, /*  LOZENGE */
    0x014D:       0xD8, /*  LATIN SMALL LETTER O WITH MACRON */
    0x0154:       0xD9, /*  LATIN CAPITAL LETTER R WITH ACUTE */
    0x0155:       0xDA, /*  LATIN SMALL LETTER R WITH ACUTE */
    0x0158:       0xDB, /*  LATIN CAPITAL LETTER R WITH CARON */
    0x2039:       0xDC, /*  SINGLE LEFT-POINTING ANGLE QUOTATION MARK */
    0x203A:       0xDD, /*  SINGLE RIGHT-POINTING ANGLE QUOTATION MARK */
    0x0159:       0xDE, /*  LATIN SMALL LETTER R WITH CARON */
    0x0156:       0xDF, /*  LATIN CAPITAL LETTER R WITH CEDILLA */
    0x0157:       0xE0, /*  LATIN SMALL LETTER R WITH CEDILLA */
    0x0160:       0xE1, /*  LATIN CAPITAL LETTER S WITH CARON */
    0x201A:       0xE2, /*  SINGLE LOW-9 QUOTATION MARK */
    0x201E:       0xE3, /*  DOUBLE LOW-9 QUOTATION MARK */
    0x0161:       0xE4, /*  LATIN SMALL LETTER S WITH CARON */
    0x015A:       0xE5, /*  LATIN CAPITAL LETTER S WITH ACUTE */
    0x015B:       0xE6, /*  LATIN SMALL LETTER S WITH ACUTE */
    0x00C1:       0xE7, /*  LATIN CAPITAL LETTER A WITH ACUTE */
    0x0164:       0xE8, /*  LATIN CAPITAL LETTER T WITH CARON */
    0x0165:       0xE9, /*  LATIN SMALL LETTER T WITH CARON */
    0x00CD:       0xEA, /*  LATIN CAPITAL LETTER I WITH ACUTE */
    0x017D:       0xEB, /*  LATIN CAPITAL LETTER Z WITH CARON */
    0x017E:       0xEC, /*  LATIN SMALL LETTER Z WITH CARON */
    0x016A:       0xED, /*  LATIN CAPITAL LETTER U WITH MACRON */
    0x00D3:       0xEE, /*  LATIN CAPITAL LETTER O WITH ACUTE */
    0x00D4:       0xEF, /*  LATIN CAPITAL LETTER O WITH CIRCUMFLEX */
    0x016B:       0xF0, /*  LATIN SMALL LETTER U WITH MACRON */
    0x016E:       0xF1, /*  LATIN CAPITAL LETTER U WITH RING ABOVE */
    0x00DA:       0xF2, /*  LATIN CAPITAL LETTER U WITH ACUTE */
    0x016F:       0xF3, /*  LATIN SMALL LETTER U WITH RING ABOVE */
    0x0170:       0xF4, /*  LATIN CAPITAL LETTER U WITH DOUBLE ACUTE */
    0x0171:       0xF5, /*  LATIN SMALL LETTER U WITH DOUBLE ACUTE */
    0x0172:       0xF6, /*  LATIN CAPITAL LETTER U WITH OGONEK */
    0x0173:       0xF7, /*  LATIN SMALL LETTER U WITH OGONEK */
    0x00DD:       0xF8, /*  LATIN CAPITAL LETTER Y WITH ACUTE */
    0x00FD:       0xF9, /*  LATIN SMALL LETTER Y WITH ACUTE */
    0x0137:       0xFA, /*  LATIN SMALL LETTER K WITH CEDILLA */
    0x017B:       0xFB, /*  LATIN CAPITAL LETTER Z WITH DOT ABOVE */
    0x0141:       0xFC, /*  LATIN CAPITAL LETTER L WITH STROKE */
    0x017C:       0xFD, /*  LATIN SMALL LETTER Z WITH DOT ABOVE */
    0x0122:       0xFE, /*  LATIN CAPITAL LETTER G WITH CEDILLA */
    0x02C7:       0xFF, /*  CARON */
]
