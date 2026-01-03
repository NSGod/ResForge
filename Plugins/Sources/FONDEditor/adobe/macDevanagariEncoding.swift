//
//  macDevanagariEncoding.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/1/2026.
//

/* Copyright 2014 Adobe Systems Incorporated (http://www.adobe.com/). All Rights Reserved.
   This software is licensed as OpenSource, under the Apache License, Version 2.0.
   This license is available at: http://opensource.org/licenses/Apache-2.0. */

/* Mac OS Devanagari aggregate Unicode initializer.

   Element values are UVs. UV_UNDEF is 0xFFFF. Index by code, get UV.
   Source: ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/APPLE/DEVANAGA.TXT
   as of 9/9/99. */

/*
 # Format:
 # -------
 #
 #   Three tab-separated columns;
 #   '#' begins a comment which continues to the end of the line.
 #     Column #1 is the Mac OS Devanagari code or code sequence
 #       (in hex as 0xNN or 0xNN+0xNN)
 #     Column #2 is the corresponding Unicode or Unicode sequence
 #       (in hex as 0xNNNN or 0xNNNN+0xNNNN).
 #     Column #3 is a comment containing the Unicode name or sequence
 #       of names. In some cases an additional comment follows the
 #       Unicode name(s).
 #
 #   The entries are in two sections. The first section is for pairs of
 #   Mac OS Devanagari code points that must be mapped in a special way.
 #   The second section maps individual code points.
 #
 #   Within each section, the entries are in Mac OS Devanagari code order.
 #
 #   Control character mappings are not shown in this table, following
 #   the conventions of the standard UTC mapping tables. However, the
 #   Mac OS Devanagari character set uses the standard control characters
 #   at 0x00-0x1F and 0x7F.
 #
 # Notes on Mac OS Devanagari:
 # ---------------------------
 #
 #   This is a legacy Mac OS encoding; in the Mac OS X Carbon and Cocoa
 #   environments, it is only supported via transcoding to and from
 #   Unicode.
 #
 #   Mac OS Devanagari is based on IS 13194:1991 (ISCII-91), with the
 #   addition of several punctuation and symbol characters. However,
 #   Mac OS Devanagari does not support the ATR (attribute) mechanism of
 #   ISCII-91.
 #
 # 1. ISCII-91 features in Mac OS Devanagari include:
 #
 #  a) Overloading of nukta
 #
 #     In addition to using the nukta (0xE9) like a combining dot below,
 #     nukta is overloaded to function as a general character modifier.
 #     In this role, certain code points followed by 0xE9 are treated as
 #     a two-byte code point representing a character which may be
 #     rather different than the characters represented by either of
 #     the code points alone. For example, the character DEVANAGARI OM
 #     (U+0950) is represented in ISCII-91 as candrabindu + nukta.
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
 #     malformed text. Mac OS Devanagari supports this mechanism, but
 #     does not currently map any of these two-byte code points to
 #     anything.
 #
 # 2. Mac OS Devanagari additions
 #
 #   Mac OS Devanagari adds characters using the code points
 #   0x80-0x8A and 0x90-0x91 (the latter are some Devanagari additions
 #   from Unicode).
 #
 # 3. Unused code points
 #
 #   The following code points are currently unused, and are not shown
 #   here: 0x8B-0x8F, 0x92-0xA0, 0xEB-0xEF, 0xFB-0xFF. In addition,
 #   0xF0 is not shown here, but it has a special function as described
 #   above.
 #
 # Unicode mapping issues and notes:
 # ---------------------------------
 #
 # 1. Mapping the byte pairs
 #
 #   If one of the following byte values is encountered when mapping
 #   Mac OS Devanagari text - 0xA1, 0xA6, 0xA7, 0xAA, 0xDB, 0xDC, 0xDF,
 #   0xE8, or 0xEA - then the next byte (if there is one) should be
 #   examined. If the next byte is 0xE9 - or also 0xE8, if the first
 #   byte was 0xE8 - then the byte pair should be mapped using the
 #   first section of the mapping table below. Otherwise, each byte
 #   should be mapped using the second section of the mapping table
 #   below.
 #
 #   - The Unicode Standard, Version 2.0, specifies how explicit
 #     halant and soft halant should be represented in Unicode;
 #     these mappings are used below.
 #
 #   If the byte value 0xF0 is encountered when mapping Mac OS
 #   Devanagari text, then the next byte should be examined. If there
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
 # 3. Additional loose mappings from Unicode
 #
 #   These are not preserved in roundtrip mappings.
 #
 #   U+0958  0xB3+0xE9  # DEVANAGARI LETTER QA
 #   U+0959  0xB4+0xE9  # DEVANAGARI LETTER KHHA
 #   U+095A  0xB5+0xE9  # DEVANAGARI LETTER GHHA
 #   U+095B  0xBA+0xE9  # DEVANAGARI LETTER ZA
 #   U+095C  0xBF+0xE9  # DEVANAGARI LETTER DDDHA
 #   U+095D  0xC0+0xE9  # DEVANAGARI LETTER RHA
 #   U+095E  0xC9+0xE9  # DEVANAGARI LETTER FA
 #
 # 4. Roundtrip considerations when mapping to decomposed Unicode
 #
 #   Both ISCII-91 (hence Mac OS Devanagari) and Unicode provide multiple
 #   ways of representing certain Devanagari consonants. For example,
 #   DEVANAGARI LETTER NNNA can be represented in Unicode as the single
 #   character 0x0929 or as the sequence 0x0928 0x093C; similarly, this
 #   consonant can be represented in Mac OS Devanagari as 0xC7 or as the
 #   sequence 0xC6 0xE9. This leads to some roundtrip problems. First
 #   note that we have the following mappings without such problems:
 #
 #   ISCII/  standard                  decomposition of  reverse mapping
 #   Mac OS  Unicode mapping           standard mapping  of decomposition
 #   ------  -----------------------   ----------------  ----------------
 #   0xC6    0x0928  ... LETTER NA     0x0928 (same)     0xC6
 #   0xCD    0x092F  ... LETTER YA     0x092F (same)     0xCD
 #   0xCF    0x0930  ... LETTER RA     0x0930 (same)     0xCF
 #   0xD2    0x0933  ... LETTER LLA    0x0933 (same)     0xD2
 #   0xE9    0x093C  ... SIGN NUKTA    0x093C (same)     0xE9
 #
 #   However, those mappings above cause roundtrip problems for the
 #   the following mappings if they are decomposed:
 #
 #   ISCII/  standard                  decomposition of  reverse mapping
 #   Mac OS  Unicode mapping           standard mapping  of decomposition
 #   ------  -----------------------   ----------------  ----------------
 #   0xC7    0x0929  ... LETTER NNNA   0x0928 0x093C     0xC6 0xE9
 #   0xCE    0x095F  ... LETTER YYA    0x092F 0x093C     0xCD 0xE9
 #   0xD0    0x0931  ... LETTER RRA    0x0930 0x093C     0xCF 0xE9
 #   0xD3    0x0934  ... LETTER LLLA   0x0933 0x093C     0xD2 0xE9
 #
 #   One solution is to use a grouping transcoding hint with the four
 #   decompositions above to mark the decomposed sequence for special
 #   treatment in transcoding. This yields the following mappings to
 #   decomposed Unicode:
 #
 #   ISCII/                     decomposed
 #   Mac OS                     Unicode mapping
 #   ------                     ----------------
 #   0xC7                       0xF860 0x0928 0x093C
 #   0xCE                       0xF860 0x092F 0x093C
 #   0xD0                       0xF860 0x0930 0x093C
 #   0xD3                       0xF860 0x0933 0x093C
 #
 */

import Foundation

let macDevanagariEncoding: [UVBMP] = [
    UV_UNDEF,   /* 00 */
    UV_UNDEF,   /* 01 */
    UV_UNDEF,   /* 02 */
    UV_UNDEF,   /* 03 */
    UV_UNDEF,   /* 04 */
    UV_UNDEF,   /* 05 */
    UV_UNDEF,   /* 06 */
    UV_UNDEF,   /* 07 */
    UV_UNDEF,   /* 08 */
    UV_UNDEF,   /* 09 */
    UV_UNDEF,   /* 0A */
    UV_UNDEF,   /* 0B */
    UV_UNDEF,   /* 0C */
    UV_UNDEF,   /* 0D */
    UV_UNDEF,   /* 0E */
    UV_UNDEF,   /* 0F */
    UV_UNDEF,   /* 10 */
    UV_UNDEF,   /* 11 */
    UV_UNDEF,   /* 12 */
    UV_UNDEF,   /* 13 */
    UV_UNDEF,   /* 14 */
    UV_UNDEF,   /* 15 */
    UV_UNDEF,   /* 16 */
    UV_UNDEF,   /* 17 */
    UV_UNDEF,   /* 18 */
    UV_UNDEF,   /* 19 */
    UV_UNDEF,   /* 1A */
    UV_UNDEF,   /* 1B */
    UV_UNDEF,   /* 1C */
    UV_UNDEF,   /* 1D */
    UV_UNDEF,   /* 1E */
    UV_UNDEF,   /* 1F */
    0x0020,     /* 20  SPACE */
    0x0021,     /* 21  EXCLAMATION MARK */
    0x0022,     /* 22  QUOTATION MARK */
    0x0023,     /* 23  NUMBER SIGN */
    0x0024,     /* 24  DOLLAR SIGN */
    0x0025,     /* 25  PERCENT SIGN */
    0x0026,     /* 26  AMPERSAND */
    0x0027,     /* 27  APOSTROPHE */
    0x0028,     /* 28  LEFT PARENTHESIS */
    0x0029,     /* 29  RIGHT PARENTHESIS */
    0x002A,     /* 2A  ASTERISK */
    0x002B,     /* 2B  PLUS SIGN */
    0x002C,     /* 2C  COMMA */
    0x002D,     /* 2D  HYPHEN-MINUS */
    0x002E,     /* 2E  FULL STOP */
    0x002F,     /* 2F  SOLIDUS */
    0x0030,     /* 30  DIGIT ZERO */
    0x0031,     /* 31  DIGIT ONE */
    0x0032,     /* 32  DIGIT TWO */
    0x0033,     /* 33  DIGIT THREE */
    0x0034,     /* 34  DIGIT FOUR */
    0x0035,     /* 35  DIGIT FIVE */
    0x0036,     /* 36  DIGIT SIX */
    0x0037,     /* 37  DIGIT SEVEN */
    0x0038,     /* 38  DIGIT EIGHT */
    0x0039,     /* 39  DIGIT NINE */
    0x003A,     /* 3A  COLON */
    0x003B,     /* 3B  SEMICOLON */
    0x003C,     /* 3C  LESS-THAN SIGN */
    0x003D,     /* 3D  EQUALS SIGN */
    0x003E,     /* 3E  GREATER-THAN SIGN */
    0x003F,     /* 3F  QUESTION MARK */
    0x0040,     /* 40  COMMERCIAL AT */
    0x0041,     /* 41  LATIN CAPITAL LETTER A */
    0x0042,     /* 42  LATIN CAPITAL LETTER B */
    0x0043,     /* 43  LATIN CAPITAL LETTER C */
    0x0044,     /* 44  LATIN CAPITAL LETTER D */
    0x0045,     /* 45  LATIN CAPITAL LETTER E */
    0x0046,     /* 46  LATIN CAPITAL LETTER F */
    0x0047,     /* 47  LATIN CAPITAL LETTER G */
    0x0048,     /* 48  LATIN CAPITAL LETTER H */
    0x0049,     /* 49  LATIN CAPITAL LETTER I */
    0x004A,     /* 4A  LATIN CAPITAL LETTER J */
    0x004B,     /* 4B  LATIN CAPITAL LETTER K */
    0x004C,     /* 4C  LATIN CAPITAL LETTER L */
    0x004D,     /* 4D  LATIN CAPITAL LETTER M */
    0x004E,     /* 4E  LATIN CAPITAL LETTER N */
    0x004F,     /* 4F  LATIN CAPITAL LETTER O */
    0x0050,     /* 50  LATIN CAPITAL LETTER P */
    0x0051,     /* 51  LATIN CAPITAL LETTER Q */
    0x0052,     /* 52  LATIN CAPITAL LETTER R */
    0x0053,     /* 53  LATIN CAPITAL LETTER S */
    0x0054,     /* 54  LATIN CAPITAL LETTER T */
    0x0055,     /* 55  LATIN CAPITAL LETTER U */
    0x0056,     /* 56  LATIN CAPITAL LETTER V */
    0x0057,     /* 57  LATIN CAPITAL LETTER W */
    0x0058,     /* 58  LATIN CAPITAL LETTER X */
    0x0059,     /* 59  LATIN CAPITAL LETTER Y */
    0x005A,     /* 5A  LATIN CAPITAL LETTER Z */
    0x005B,     /* 5B  LEFT SQUARE BRACKET */
    0x005C,     /* 5C  REVERSE SOLIDUS */
    0x005D,     /* 5D  RIGHT SQUARE BRACKET */
    0x005E,     /* 5E  CIRCUMFLEX ACCENT */
    0x005F,     /* 5F  LOW LINE */
    0x0060,     /* 60  GRAVE ACCENT */
    0x0061,     /* 61  LATIN SMALL LETTER A */
    0x0062,     /* 62  LATIN SMALL LETTER B */
    0x0063,     /* 63  LATIN SMALL LETTER C */
    0x0064,     /* 64  LATIN SMALL LETTER D */
    0x0065,     /* 65  LATIN SMALL LETTER E */
    0x0066,     /* 66  LATIN SMALL LETTER F */
    0x0067,     /* 67  LATIN SMALL LETTER G */
    0x0068,     /* 68  LATIN SMALL LETTER H */
    0x0069,     /* 69  LATIN SMALL LETTER I */
    0x006A,     /* 6A  LATIN SMALL LETTER J */
    0x006B,     /* 6B  LATIN SMALL LETTER K */
    0x006C,     /* 6C  LATIN SMALL LETTER L */
    0x006D,     /* 6D  LATIN SMALL LETTER M */
    0x006E,     /* 6E  LATIN SMALL LETTER N */
    0x006F,     /* 6F  LATIN SMALL LETTER O */
    0x0070,     /* 70  LATIN SMALL LETTER P */
    0x0071,     /* 71  LATIN SMALL LETTER Q */
    0x0072,     /* 72  LATIN SMALL LETTER R */
    0x0073,     /* 73  LATIN SMALL LETTER S */
    0x0074,     /* 74  LATIN SMALL LETTER T */
    0x0075,     /* 75  LATIN SMALL LETTER U */
    0x0076,     /* 76  LATIN SMALL LETTER V */
    0x0077,     /* 77  LATIN SMALL LETTER W */
    0x0078,     /* 78  LATIN SMALL LETTER X */
    0x0079,     /* 79  LATIN SMALL LETTER Y */
    0x007A,     /* 7A  LATIN SMALL LETTER Z */
    0x007B,     /* 7B  LEFT CURLY BRACKET */
    0x007C,     /* 7C  VERTICAL LINE */
    0x007D,     /* 7D  RIGHT CURLY BRACKET */
    0x007E,     /* 7E  TILDE */
    UV_UNDEF,   /* 7F */
    0x00D7,     /* 80  MULTIPLICATION SIGN */
    0x2212,     /* 81  MINUS SIGN */
    0x2013,     /* 82  EN DASH */
    0x2014,     /* 83  EM DASH */
    0x2018,     /* 84  LEFT SINGLE QUOTATION MARK */
    0x2019,     /* 85  RIGHT SINGLE QUOTATION MARK */
    0x2026,     /* 86  HORIZONTAL ELLIPSIS */
    0x2022,     /* 87  BULLET */
    0x00A9,     /* 88  COPYRIGHT SIGN */
    0x00AE,     /* 89  REGISTERED SIGN */
    0x2122,     /* 8A  TRADE MARK SIGN */
    UV_UNDEF,   /* 8B */
    UV_UNDEF,   /* 8C */
    UV_UNDEF,   /* 8D */
    UV_UNDEF,   /* 8E */
    UV_UNDEF,   /* 8F */
    0x0965,     /* 90  DEVANAGARI DOUBLE DANDA */
    0x0970,     /* 91  DEVANAGARI ABBREVIATION SIGN */
    UV_UNDEF,   /* 92 */
    UV_UNDEF,   /* 93 */
    UV_UNDEF,   /* 94 */
    UV_UNDEF,   /* 95 */
    UV_UNDEF,   /* 96 */
    UV_UNDEF,   /* 97 */
    UV_UNDEF,   /* 98 */
    UV_UNDEF,   /* 99 */
    UV_UNDEF,   /* 9A */
    UV_UNDEF,   /* 9B */
    UV_UNDEF,   /* 9C */
    UV_UNDEF,   /* 9D */
    UV_UNDEF,   /* 9E */
    UV_UNDEF,   /* 9F */
    UV_UNDEF,   /* A0 */
    0x0901,     /* A1  DEVANAGARI SIGN CANDRABINDU */
    0x0902,     /* A2  DEVANAGARI SIGN ANUSVARA */
    0x0903,     /* A3  DEVANAGARI SIGN VISARGA */
    0x0905,     /* A4  DEVANAGARI LETTER A */
    0x0906,     /* A5  DEVANAGARI LETTER AA */
    0x0907,     /* A6  DEVANAGARI LETTER I */
    0x0908,     /* A7  DEVANAGARI LETTER II */
    0x0909,     /* A8  DEVANAGARI LETTER U */
    0x090A,     /* A9  DEVANAGARI LETTER UU */
    0x090B,     /* AA  DEVANAGARI LETTER VOCALIC R */
    0x090E,     /* AB  DEVANAGARI LETTER SHORT E */
    0x090F,     /* AC  DEVANAGARI LETTER E */
    0x0910,     /* AD  DEVANAGARI LETTER AI */
    0x090D,     /* AE  DEVANAGARI LETTER CANDRA E */
    0x0912,     /* AF  DEVANAGARI LETTER SHORT O */
    0x0913,     /* B0  DEVANAGARI LETTER O */
    0x0914,     /* B1  DEVANAGARI LETTER AU */
    0x0911,     /* B2  DEVANAGARI LETTER CANDRA O */
    0x0915,     /* B3  DEVANAGARI LETTER KA */
    0x0916,     /* B4  DEVANAGARI LETTER KHA */
    0x0917,     /* B5  DEVANAGARI LETTER GA */
    0x0918,     /* B6  DEVANAGARI LETTER GHA */
    0x0919,     /* B7  DEVANAGARI LETTER NGA */
    0x091A,     /* B8  DEVANAGARI LETTER CA */
    0x091B,     /* B9  DEVANAGARI LETTER CHA */
    0x091C,     /* BA  DEVANAGARI LETTER JA */
    0x091D,     /* BB  DEVANAGARI LETTER JHA */
    0x091E,     /* BC  DEVANAGARI LETTER NYA */
    0x091F,     /* BD  DEVANAGARI LETTER TTA */
    0x0920,     /* BE  DEVANAGARI LETTER TTHA */
    0x0921,     /* BF  DEVANAGARI LETTER DDA */
    0x0922,     /* C0  DEVANAGARI LETTER DDHA */
    0x0923,     /* C1  DEVANAGARI LETTER NNA */
    0x0924,     /* C2  DEVANAGARI LETTER TA */
    0x0925,     /* C3  DEVANAGARI LETTER THA */
    0x0926,     /* C4  DEVANAGARI LETTER DA */
    0x0927,     /* C5  DEVANAGARI LETTER DHA */
    0x0928,     /* C6  DEVANAGARI LETTER NA */
    0x0929,     /* C7  DEVANAGARI LETTER NNNA */
    0x092A,     /* C8  DEVANAGARI LETTER PA */
    0x092B,     /* C9  DEVANAGARI LETTER PHA */
    0x092C,     /* CA  DEVANAGARI LETTER BA */
    0x092D,     /* CB  DEVANAGARI LETTER BHA */
    0x092E,     /* CC  DEVANAGARI LETTER MA */
    0x092F,     /* CD  DEVANAGARI LETTER YA */
    0x095F,     /* CE  DEVANAGARI LETTER YYA */
    0x0930,     /* CF  DEVANAGARI LETTER RA */
    0x0931,     /* D0  DEVANAGARI LETTER RRA */
    0x0932,     /* D1  DEVANAGARI LETTER LA */
    0x0933,     /* D2  DEVANAGARI LETTER LLA */
    0x0934,     /* D3  DEVANAGARI LETTER LLLA */
    0x0935,     /* D4  DEVANAGARI LETTER VA */
    0x0936,     /* D5  DEVANAGARI LETTER SHA */
    0x0937,     /* D6  DEVANAGARI LETTER SSA */
    0x0938,     /* D7  DEVANAGARI LETTER SA */
    0x0939,     /* D8  DEVANAGARI LETTER HA */
    0x200E,     /* D9  LEFT-TO-RIGHT MARK (invisible consonant) */
    0x093E,     /* DA  DEVANAGARI VOWEL SIGN AA */
    0x093F,     /* DB  DEVANAGARI VOWEL SIGN I */
    0x0940,     /* DC  DEVANAGARI VOWEL SIGN II */
    0x0941,     /* DD  DEVANAGARI VOWEL SIGN U */
    0x0942,     /* DE  DEVANAGARI VOWEL SIGN UU */
    0x0943,     /* DF  DEVANAGARI VOWEL SIGN VOCALIC R */
    0x0946,     /* E0  DEVANAGARI VOWEL SIGN SHORT E */
    0x0947,     /* E1  DEVANAGARI VOWEL SIGN E */
    0x0948,     /* E2  DEVANAGARI VOWEL SIGN AI */
    0x0945,     /* E3  DEVANAGARI VOWEL SIGN CANDRA E */
    0x094A,     /* E4  DEVANAGARI VOWEL SIGN SHORT O */
    0x094B,     /* E5  DEVANAGARI VOWEL SIGN O */
    0x094C,     /* E6  DEVANAGARI VOWEL SIGN AU */
    0x0949,     /* E7  DEVANAGARI VOWEL SIGN CANDRA O */
    0x094D,     /* E8  DEVANAGARI SIGN VIRAMA (halant) */
    0x093C,     /* E9  DEVANAGARI SIGN NUKTA */
    0x0964,     /* EA  DEVANAGARI DANDA */
    UV_UNDEF,   /* EB */
    UV_UNDEF,   /* EC */
    UV_UNDEF,   /* ED */
    UV_UNDEF,   /* EE */
    UV_UNDEF,   /* EF */
    UV_UNDEF,   /* F0 */
    0x0966,     /* F1  DEVANAGARI DIGIT ZERO */
    0x0967,     /* F2  DEVANAGARI DIGIT ONE */
    0x0968,     /* F3  DEVANAGARI DIGIT TWO */
    0x0969,     /* F4  DEVANAGARI DIGIT THREE */
    0x096A,     /* F5  DEVANAGARI DIGIT FOUR */
    0x096B,     /* F6  DEVANAGARI DIGIT FIVE */
    0x096C,     /* F7  DEVANAGARI DIGIT SIX */
    0x096D,     /* F8  DEVANAGARI DIGIT SEVEN */
    0x096E,     /* F9  DEVANAGARI DIGIT EIGHT */
    0x096F,     /* FA  DEVANAGARI DIGIT NINE */
    UV_UNDEF,   /* FB */
    UV_UNDEF,   /* FC */
    UV_UNDEF,   /* FD */
    UV_UNDEF,   /* FE */
    UV_UNDEF,   /* FF */
]
