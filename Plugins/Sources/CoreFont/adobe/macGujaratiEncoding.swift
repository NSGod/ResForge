//
//  macGujaratiEncoding.swift
//  CoreFont
//
//  Created by Mark Douma on 1/1/2026.
//

/* Copyright 2014 Adobe Systems Incorporated (http://www.adobe.com/). All Rights Reserved.
   This software is licensed as OpenSource, under the Apache License, Version 2.0.
   This license is available at: http://opensource.org/licenses/Apache-2.0. */

/* Mac OS Gujarati aggregate Unicode initializer.

   Element values are UVs. UV_UNDEF is 0xFFFF. Index by code, get UV.
   Source: ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/APPLE/GUJARATI.TXT
   as of 9/9/99. */

/*
 # Format:
 # -------
 #
 #   Three tab-separated columns;
 #   '#' begins a comment which continues to the end of the line.
 #     Column #1 is the Mac OS Gujarati code or code sequence
 #       (in hex as 0xNN or 0xNN+0xNN)
 #     Column #2 is the corresponding Unicode or Unicode sequence
 #       (in hex as 0xNNNN or 0xNNNN+0xNNNN).
 #     Column #3 is a comment containing the Unicode name or sequence
 #       of names. In some cases an additional comment follows the
 #       Unicode name(s).
 #
 #   The entries are in two sections. The first section is for pairs of
 #   Mac OS Gujarati code points that must be mapped in a special way.
 #   The second section maps individual code points.
 #
 #   Within each section, the entries are in Mac OS Gujarati code order.
 #
 #   Control character mappings are not shown in this table, following
 #   the conventions of the standard UTC mapping tables. However, the
 #   Mac OS Gujarati character set uses the standard control characters
 #   at 0x00-0x1F and 0x7F.
 #
 # Notes on Mac OS Gujarati:
 # -------------------------
 #
 #   This is a legacy Mac OS encoding; in the Mac OS X Carbon and Cocoa
 #   environments, it is only supported via transcoding to and from
 #   Unicode.
 #
 #   Mac OS Gujarati is based on IS 13194:1991 (ISCII-91), with the
 #   addition of several punctuation and symbol characters. However,
 #   Mac OS Gujarati does not support the ATR (attribute) mechanism of
 #   ISCII-91.
 #
 # 1. ISCII-91 features in Mac OS Gujarati include:
 #
 #  a) Overloading of nukta
 #
 #     In addition to using the nukta (0xE9) like a combining dot below,
 #     nukta is overloaded to function as a general character modifier.
 #     In this role, certain code points followed by 0xE9 are treated as
 #     a two-byte code point representing a character which may be
 #     rather different than the characters represented by either of
 #     the code points alone. For example, the character GUJARATI OM
 #     (U+0AD0) is represented in ISCII-91 as candrabindu + nukta.
 #
 #  b) Explicit halant and soft halant
 #
 #     A double halant (0xE8 + 0xE8) constitutes an "explicit halant",
 #     which will always appear as a halant instead of causing formation
 #     of a ligature or half-form consonant.
 #
 #     Halant followed by nukta (0xE8 + 0xE9) constitutes a "soft
 #     halant", which prevents formation of a ligature and instead
 #     retains the half-form of the first consonant.
 #
 #  c) Invisible consonant
 #
 #     The byte 0xD9 (called INV in ISCII-91) is an invisible consonant:
 #     It behaves like a consonant but has no visible appearance. It is
 #     intended to be used (often in combination with halant) to display
 #     dependent forms in isolation, such as the RA forms or consonant
 #     half-forms.
 #
 #  d) Extensions for Vedic, etc.
 #
 #     The byte 0xF0 (called EXT in ISCII-91) followed by any byte in
 #     the range 0xA1-0xEE constitutes a two-byte code point which can
 #     be used to represent additional characters for Vedic (or other
 #     extensions); 0xF0 followed by any other byte value constitutes
 #     malformed text. Mac OS Gujarati supports this mechanism, but
 #     does not currently map any of these two-byte code points to
 #     anything.
 #
 # 2. Mac OS Gujarati additions
 #
 #   Mac OS Gujarati adds characters using the code points
 #   0x80-0x8A and 0x90.
 #
 # 3. Unused code points
 #
 #   The following code points are currently unused, and are not shown
 #   here: 0x8B-0x8F, 0x91-0xA0, 0xAB, 0xAF, 0xC7, 0xCE, 0xD0, 0xD3,
 #   0xE0, 0xE4, 0xEB-0xEF, 0xFB-0xFF. In addition, 0xF0 is not shown
 #   here, but it has a special function as described above.
 #
 # Unicode mapping issues and notes:
 # ---------------------------------
 #
 # 1. Mapping the byte pairs
 #
 #   If one of the following byte values is encountered when mapping
 #   Mac OS Gujarati text - xA1, xAA, xDF, or 0xE8 - then the next
 #   byte (if there is one) should be examined. If the next byte is
 #   0xE9 - or also 0xE8, if the first byte was 0xE8 - then the byte
 #   pair should be mapped using the first section of the mapping
 #   table below. Otherwise, each byte should be mapped using the
 #   second section of the mapping table below.
 #
 #   - The Unicode Standard, Version 2.0, specifies how explicit
 #     halant and soft halant should be represented in Unicode;
 #     these mappings are used below.
 #
 #   If the byte value 0xF0 is encountered when mapping Mac OS
 #   Gujarati text, then the next byte should be examined. If there
 #   is no next byte (e.g. 0xF0 at end of buffer), the mapping
 #   process should indicate incomplete character. If there is a next
 #   byte but it is not in the range 0xA1-0xEE, the mapping process
 #   should indicate malformed text. Otherwise, the mapping process
 #   should treat the byte pair as a valid two-byte code point with no
 #   mapping (e.g. map it to QUESTION MARK, REPLACEMENT CHARACTER,
 #   etc.).
 #
 # 2. Mapping the invisible consonant
 #
 #   It has been suggested that INV in ISCII-91 should map to ZERO
 #   WIDTH NON-JOINER in Unicode. However, this causes problems with
 #   roundtrip fidelity: The ISCII-91 sequences 0xE8+0xE8 and 0xE8+0xD9
 #   would map to the same sequence of Unicode characters. We have
 #   instead mapped INV to LEFT-TO-RIGHT MARK, which avoids these
 #   problems.
 #
 # Details of mapping changes in each version:
 # -------------------------------------------
 #
 ##################
 */

import Foundation

let macGujaratiEncoding: [UVBMP] = [
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
    0x00D7,       /* 80  MULTIPLICATION SIGN */
    0x2212,       /* 81  MINUS SIGN */
    0x2013,       /* 82  EN DASH */
    0x2014,       /* 83  EM DASH */
    0x2018,       /* 84  LEFT SINGLE QUOTATION MARK */
    0x2019,       /* 85  RIGHT SINGLE QUOTATION MARK */
    0x2026,       /* 86  HORIZONTAL ELLIPSIS */
    0x2022,       /* 87  BULLET */
    0x00A9,       /* 88  COPYRIGHT SIGN */
    0x00AE,       /* 89  REGISTERED SIGN */
    0x2122,       /* 8A  TRADE MARK SIGN */
    .undefined,   /* 8B */
    .undefined,   /* 8C */
    .undefined,   /* 8D */
    .undefined,   /* 8E */
    .undefined,   /* 8F */
    0x0965,       /* 90  DEVANAGARI DOUBLE DANDA */
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
    .undefined,   /* A0 */
    0x0A81,       /* A1  GUJARATI SIGN CANDRABINDU */
    0x0A82,       /* A2  GUJARATI SIGN ANUSVARA */
    0x0A83,       /* A3  GUJARATI SIGN VISARGA */
    0x0A85,       /* A4  GUJARATI LETTER A */
    0x0A86,       /* A5  GUJARATI LETTER AA */
    0x0A87,       /* A6  GUJARATI LETTER I */
    0x0A88,       /* A7  GUJARATI LETTER II */
    0x0A89,       /* A8  GUJARATI LETTER U */
    0x0A8A,       /* A9  GUJARATI LETTER UU */
    0x0A8B,       /* AA  GUJARATI LETTER VOCALIC R */
    .undefined,   /* AB */
    0x0A8F,       /* AC  GUJARATI LETTER E */
    0x0A90,       /* AD  GUJARATI LETTER AI */
    0x0A8D,       /* AE  GUJARATI VOWEL CANDRA E */
    .undefined,   /* AF */
    0x0A93,       /* B0  GUJARATI LETTER O */
    0x0A94,       /* B1  GUJARATI LETTER AU */
    0x0A91,       /* B2  GUJARATI VOWEL CANDRA O */
    0x0A95,       /* B3  GUJARATI LETTER KA */
    0x0A96,       /* B4  GUJARATI LETTER KHA */
    0x0A97,       /* B5  GUJARATI LETTER GA */
    0x0A98,       /* B6  GUJARATI LETTER GHA */
    0x0A99,       /* B7  GUJARATI LETTER NGA */
    0x0A9A,       /* B8  GUJARATI LETTER CA */
    0x0A9B,       /* B9  GUJARATI LETTER CHA */
    0x0A9C,       /* BA  GUJARATI LETTER JA */
    0x0A9D,       /* BB  GUJARATI LETTER JHA */
    0x0A9E,       /* BC  GUJARATI LETTER NYA */
    0x0A9F,       /* BD  GUJARATI LETTER TTA */
    0x0AA0,       /* BE  GUJARATI LETTER TTHA */
    0x0AA1,       /* BF  GUJARATI LETTER DDA */
    0x0AA2,       /* C0  GUJARATI LETTER DDHA */
    0x0AA3,       /* C1  GUJARATI LETTER NNA */
    0x0AA4,       /* C2  GUJARATI LETTER TA */
    0x0AA5,       /* C3  GUJARATI LETTER THA */
    0x0AA6,       /* C4  GUJARATI LETTER DA */
    0x0AA7,       /* C5  GUJARATI LETTER DHA */
    0x0AA8,       /* C6  GUJARATI LETTER NA */
    .undefined,   /* C7 */
    0x0AAA,       /* C8  GUJARATI LETTER PA */
    0x0AAB,       /* C9  GUJARATI LETTER PHA */
    0x0AAC,       /* CA  GUJARATI LETTER BA */
    0x0AAD,       /* CB  GUJARATI LETTER BHA */
    0x0AAE,       /* CC  GUJARATI LETTER MA */
    0x0AAF,       /* CD  GUJARATI LETTER YA */
    .undefined,   /* CE */
    0x0AB0,       /* CF  GUJARATI LETTER RA */
    .undefined,   /* D0 */
    0x0AB2,       /* D1  GUJARATI LETTER LA */
    0x0AB3,       /* D2  GUJARATI LETTER LLA */
    .undefined,   /* D3 */
    0x0AB5,       /* D4  GUJARATI LETTER VA */
    0x0AB6,       /* D5  GUJARATI LETTER SHA */
    0x0AB7,       /* D6  GUJARATI LETTER SSA */
    0x0AB8,       /* D7  GUJARATI LETTER SA */
    0x0AB9,       /* D8  GUJARATI LETTER HA */
    0x200E,       /* D9  LEFT-TO-RIGHT MARK (invisible consonant) */
    0x0ABE,       /* DA  GUJARATI VOWEL SIGN AA */
    0x0ABF,       /* DB  GUJARATI VOWEL SIGN I */
    0x0AC0,       /* DC  GUJARATI VOWEL SIGN II */
    0x0AC1,       /* DD  GUJARATI VOWEL SIGN U */
    0x0AC2,       /* DE  GUJARATI VOWEL SIGN UU */
    0x0AC3,       /* DF  GUJARATI VOWEL SIGN VOCALIC R */
    .undefined,   /* E0 */
    0x0AC7,       /* E1  GUJARATI VOWEL SIGN E */
    0x0AC8,       /* E2  GUJARATI VOWEL SIGN AI */
    0x0AC5,       /* E3  GUJARATI VOWEL SIGN CANDRA E */
    .undefined,   /* E4 */
    0x0ACB,       /* E5  GUJARATI VOWEL SIGN O */
    0x0ACC,       /* E6  GUJARATI VOWEL SIGN AU */
    0x0AC9,       /* E7  GUJARATI VOWEL SIGN CANDRA O */
    0x0ACD,       /* E8  GUJARATI SIGN VIRAMA (halant) */
    0x0ABC,       /* E9  GUJARATI SIGN NUKTA */
    0x0964,       /* EA  DEVANAGARI DANDA */
    .undefined,   /* EB */
    .undefined,   /* EC */
    .undefined,   /* ED */
    .undefined,   /* EE */
    .undefined,   /* EF */
    .undefined,   /* F0 */
    0x0AE6,       /* F1  GUJARATI DIGIT ZERO */
    0x0AE7,       /* F2  GUJARATI DIGIT ONE */
    0x0AE8,       /* F3  GUJARATI DIGIT TWO */
    0x0AE9,       /* F4  GUJARATI DIGIT THREE */
    0x0AEA,       /* F5  GUJARATI DIGIT FOUR */
    0x0AEB,       /* F6  GUJARATI DIGIT FIVE */
    0x0AEC,       /* F7  GUJARATI DIGIT SIX */
    0x0AED,       /* F8  GUJARATI DIGIT SEVEN */
    0x0AEE,       /* F9  GUJARATI DIGIT EIGHT */
    0x0AEF,       /* FA  GUJARATI DIGIT NINE */
    .undefined,   /* FB */
    .undefined,   /* FC */
    .undefined,   /* FD */
    .undefined,   /* FE */
    .undefined,   /* FF */
]
