//
//  macGurmukhiEncoding.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/1/2026.
//

/* Copyright 2014 Adobe Systems Incorporated (http://www.adobe.com/). All Rights Reserved.
   This software is licensed as OpenSource, under the Apache License, Version 2.0.
   This license is available at: http://opensource.org/licenses/Apache-2.0. */

/* Mac OS Gurmukhi aggregate Unicode initializer.

   Element values are UVs. UV_UNDEF is 0xFFFF. Index by code, get UV.
   Source: ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/APPLE/GURMUKHI.TXT
   as of 9/9/99.

   1 entry is mapped to regular Unicode values for which Apple has defined
   a transcoding hint sequence. The full transcoding hint sequence is shown in
   parentheses for such mappings. */

/*
 # Format:
 # -------
 #
 #   Three tab-separated columns;
 #   '#' begins a comment which continues to the end of the line.
 #     Column #1 is the Mac OS Gurmukhi code or code sequence
 #       (in hex as 0xNN or 0xNN+0xNN)
 #     Column #2 is the corresponding Unicode or Unicode sequence
 #       (in hex as 0xNNNN or 0xNNNN+0xNNNN).
 #     Column #3 is a comment containing the Unicode name or sequence
 #       of names. In some cases an additional comment follows the
 #       Unicode name(s).
 #
 #   The entries are in two sections. The first section is for pairs of
 #   Mac OS Gurmukhi code points that must be mapped in a special way.
 #   The second section maps individual code points.
 #
 #   Within each section, the entries are in Mac OS Gurmukhi code order.
 #
 #   Control character mappings are not shown in this table, following
 #   the conventions of the standard UTC mapping tables. However, the
 #   Mac OS Gurmukhi character set uses the standard control characters
 #   at 0x00-0x1F and 0x7F.
 #
 # Notes on Mac OS Gurmukhi:
 # -------------------------
 #
 #   This is a legacy Mac OS encoding; in the Mac OS X Carbon and Cocoa
 #   environments, it is only supported via transcoding to and from
 #   Unicode.
 #
 #   Mac OS Gurmukhi is based on IS 13194:1991 (ISCII-91), with the
 #   addition of several punctuation and symbol characters. However,
 #   Mac OS Gurmukhi does not support the ATR (attribute) mechanism of
 #   ISCII-91.
 #
 # 1. ISCII-91 features in Mac OS Gurmukhi include:
 #
 #  a) Explicit halant and soft halant
 #
 #     A double halant (0xE8 + 0xE8) constitutes an "explicit halant",
 #     which will always appear as a halant instead of causing formation
 #     of a ligature or half-form consonant.
 #
 #     Halant followed by nukta (0xE8 + 0xE9) constitutes a "soft
 #     halant", which prevents formation of a ligature and instead
 #     retains the half-form of the first consonant.
 #
 #  b) Invisible consonant
 #
 #     The byte 0xD9 (called INV in ISCII-91) is an invisible consonant:
 #     It behaves like a consonant but has no visible appearance. It is
 #     intended to be used (often in combination with halant) to display
 #     dependent forms in isolation, such as the RA forms or consonant
 #     half-forms.
 #
 #  c) Extensions for Vedic, etc.
 #
 #     The byte 0xF0 (called EXT in ISCII-91) followed by any byte in
 #     the range 0xA1-0xEE constitutes a two-byte code point which can
 #     be used to represent additional characters for Vedic (or other
 #     extensions); 0xF0 followed by any other byte value constitutes
 #     malformed text. Mac OS Gurmukhi supports this mechanism, but
 #     does not currently map any of these two-byte code points to
 #     anything.
 #
 # 2. Mac OS Gurmukhi additions
 #
 #   Mac OS Gurmukhi adds characters using the code points
 #   0x80-0x8A and 0x90-0x94 (the latter are some Gurmukhi additions).
 #
 # 3. Unused code points
 #
 #   The following code points are currently unused, and are not shown
 #   here: 0x8B-0x8F, 0x95-0xA1, 0xA3, 0xAA-0xAB, 0xAE-0xAF, 0xB2,
 #   0xC7, 0xCE, 0xD0, 0xD2-0xD3, 0xD6, 0xDF-0xE0, 0xE3-0xE4, 0xE7,
 #   0xEB-0xEF, 0xFB-0xFF. In addition, 0xF0 is not shown here, but it
 #   has a special function as described above.
 #
 # Unicode mapping issues and notes:
 # ---------------------------------
 #
 # 1. Mapping the byte pairs
 #
 #   If the byte value 0xE8 is encountered when mapping Mac OS
 #   Gurmukhi text, then the next byte (if there is one) should be
 #   examined. If the next byte is 0xE8 or 0xE9, then the byte pair
 #   should be mapped using the first section of the mapping table
 #   below. Otherwise, each byte should be mapped using the second
 #   section of the mapping table below.
 #
 #   - The Unicode Standard, Version 2.0, specifies how explicit
 #     halant and soft halant should be represented in Unicode;
 #     these mappings are used below.
 #
 #   If the byte value 0xF0 is encountered when mapping Mac OS
 #   Gurmukhi text, then the next byte should be examined. If there
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
 # 3. Mappings using corporate characters
 #
 #   Mapping the GURMUKHI LETTER SHA 0xD5 presents an interesting
 #   problem. At first glance, we could map it to the single Unicode
 #   character 0x0A36.
 #
 #   However, our goal is that the mappings provided here should also
 #   be able to generate the mappings to maximally decomposed Unicode
 #   by simple recursive substitution of the canonical decompositions
 #   in the Unicode database. We want mapping tables derived this way
 #   to retain full roundtrip fidelity.
 #
 #   Since the canonical decomposition of 0x0A36 is 0x0A38+0x0A3C,
 #   the decomposition mapping for 0xD5 would be identical with the
 #   decomposition mapping for 0xD7+0xE9, and roundtrip fidelity would
 #   be lost.
 #
 #   We solve this problem by using a grouping hint (one of the set of
 #   transcoding hints defined by Apple).
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
 #   The transcoding coding hint used in this mapping table is:
 #     0xF860 group next 2 characters
 #
 #   Then we can map 0x91 as follows:
 #     0xD5 -> 0xF860+0x0A38+0x0A3C
 #
 #   We could also have used a variant tag such as 0xF87F and mapped it
 #   this way:
 #     0xD5 -> 0x0A36+0xF87F
 #
 # 4. Additional loose mappings from Unicode
 #
 #   These are not preserved in roundtrip mappings.
 #
 #   0A59 -> 0xB4+0xE9   # GURMUKHI LETTER KHHA
 #   0A5A -> 0xB5+0xE9   # GURMUKHI LETTER GHHA
 #   0A5B -> 0xBA+0xE9   # GURMUKHI LETTER ZA
 #   0A5E -> 0xC9+0xE9   # GURMUKHI LETTER FA
 #
 #   0A70 -> 0xA2    # GURMUKHI TIPPI
 #
 #   Loose mappings from Unicode should also map U+0A71 (GURMUKHI ADDAK)
 #   followed by any Gurmukhi consonant to the equivalent ISCII-91
 #   consonant plus halant plus the consonant again. For example:
 #
 #   0A71+0A15 -> 0xB3+0xE8+0xB3
 #   0A71+0A16 -> 0xB4+0xE8+0xB4
 #   ...
 #
 # Details of mapping changes in each version:
 # -------------------------------------------
 #
 #   Changes from version b02 to version b03/c01:
 #
 #   - Change mapping of 0x91 from 0xF860+0x0A21+0x0A3C to 0x0A5C GURMUKHI
 #     LETTER RRA, now that the canonical decomposition of 0x0A5C to
 #     0x0A21+0x0A3C has been deleted
 #
 #   - Change mapping of 0xD5 from 0x0A36 GURMUKHI LETTER SHA to
 #     0xF860+0x0A38+0x0A3C, now that a canonical decomposition of 0x0A36
 #     to 0x0A38+0x0A3C has been added.
 #
 ##################
 */

import Foundation

let macGurmukhiEncoding: [UVBMP] = [
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
    0x0A71,     /* 90  GURMUKHI ADDAK */
    0x0A5C,     /* 91  GURMUKHI LETTER RRA, alternate (0xF860+0x0A21+0x0A3C) */
    0x0A73,     /* 92  GURMUKHI URA */
    0x0A72,     /* 93  GURMUKHI IRI */
    0x0A74,     /* 94  GURMUKHI EK ONKAR */
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
    UV_UNDEF,   /* A1 */
    0x0A02,     /* A2  GURMUKHI SIGN BINDI */
    UV_UNDEF,   /* A3 */
    0x0A05,     /* A4  GURMUKHI LETTER A */
    0x0A06,     /* A5  GURMUKHI LETTER AA */
    0x0A07,     /* A6  GURMUKHI LETTER I */
    0x0A08,     /* A7  GURMUKHI LETTER II */
    0x0A09,     /* A8  GURMUKHI LETTER U */
    0x0A0A,     /* A9  GURMUKHI LETTER UU */
    UV_UNDEF,   /* AA */
    UV_UNDEF,   /* AB */
    0x0A0F,     /* AC  GURMUKHI LETTER EE */
    0x0A10,     /* AD  GURMUKHI LETTER AI */
    UV_UNDEF,   /* AE */
    UV_UNDEF,   /* AF */
    0x0A13,     /* B0  GURMUKHI LETTER OO */
    0x0A14,     /* B1  GURMUKHI LETTER AU */
    UV_UNDEF,   /* B2 */
    0x0A15,     /* B3  GURMUKHI LETTER KA */
    0x0A16,     /* B4  GURMUKHI LETTER KHA */
    0x0A17,     /* B5  GURMUKHI LETTER GA */
    0x0A18,     /* B6  GURMUKHI LETTER GHA */
    0x0A19,     /* B7  GURMUKHI LETTER NGA */
    0x0A1A,     /* B8  GURMUKHI LETTER CA */
    0x0A1B,     /* B9  GURMUKHI LETTER CHA */
    0x0A1C,     /* BA  GURMUKHI LETTER JA */
    0x0A1D,     /* BB  GURMUKHI LETTER JHA */
    0x0A1E,     /* BC  GURMUKHI LETTER NYA */
    0x0A1F,     /* BD  GURMUKHI LETTER TTA */
    0x0A20,     /* BE  GURMUKHI LETTER TTHA */
    0x0A21,     /* BF  GURMUKHI LETTER DDA */
    0x0A22,     /* C0  GURMUKHI LETTER DDHA */
    0x0A23,     /* C1  GURMUKHI LETTER NNA */
    0x0A24,     /* C2  GURMUKHI LETTER TA */
    0x0A25,     /* C3  GURMUKHI LETTER THA */
    0x0A26,     /* C4  GURMUKHI LETTER DA */
    0x0A27,     /* C5  GURMUKHI LETTER DHA */
    0x0A28,     /* C6  GURMUKHI LETTER NA */
    UV_UNDEF,   /* C7 */
    0x0A2A,     /* C8  GURMUKHI LETTER PA */
    0x0A2B,     /* C9  GURMUKHI LETTER PHA */
    0x0A2C,     /* CA  GURMUKHI LETTER BA */
    0x0A2D,     /* CB  GURMUKHI LETTER BHA */
    0x0A2E,     /* CC  GURMUKHI LETTER MA */
    0x0A2F,     /* CD  GURMUKHI LETTER YA */
    UV_UNDEF,   /* CE */
    0x0A30,     /* CF  GURMUKHI LETTER RA */
    UV_UNDEF,   /* D0 */
    0x0A32,     /* D1  GURMUKHI LETTER LA */
    UV_UNDEF,   /* D2 */
    UV_UNDEF,   /* D3 */
    0x0A35,     /* D4  GURMUKHI LETTER VA */
    0x0A36,     /* D5  GURMUKHI LETTER SHA */
    UV_UNDEF,   /* D6 */
    0x0A38,     /* D7  GURMUKHI LETTER SA */
    0x0A39,     /* D8  GURMUKHI LETTER HA */
    0x200E,     /* D9  LEFT-TO-RIGHT MARK (invisible consonant) */
    0x0A3E,     /* DA  GURMUKHI VOWEL SIGN AA */
    0x0A3F,     /* DB  GURMUKHI VOWEL SIGN I */
    0x0A40,     /* DC  GURMUKHI VOWEL SIGN II */
    0x0A41,     /* DD  GURMUKHI VOWEL SIGN U */
    0x0A42,     /* DE  GURMUKHI VOWEL SIGN UU */
    UV_UNDEF,   /* DF */
    UV_UNDEF,   /* E0 */
    0x0A47,     /* E1  GURMUKHI VOWEL SIGN EE */
    0x0A48,     /* E2  GURMUKHI VOWEL SIGN AI */
    UV_UNDEF,   /* E3 */
    UV_UNDEF,   /* E4 */
    0x0A4B,     /* E5  GURMUKHI VOWEL SIGN OO */
    0x0A4C,     /* E6  GURMUKHI VOWEL SIGN AU */
    UV_UNDEF,   /* E7 */
    0x0A4D,     /* E8  GURMUKHI SIGN VIRAMA (halant) */
    0x0A3C,     /* E9  GURMUKHI SIGN NUKTA */
    0x0964,     /* EA  DEVANAGARI DANDA */
    UV_UNDEF,   /* EB */
    UV_UNDEF,   /* EC */
    UV_UNDEF,   /* ED */
    UV_UNDEF,   /* EE */
    UV_UNDEF,   /* EF */
    UV_UNDEF,   /* F0 */
    0x0A66,     /* F1  GURMUKHI DIGIT ZERO */
    0x0A67,     /* F2  GURMUKHI DIGIT ONE */
    0x0A68,     /* F3  GURMUKHI DIGIT TWO */
    0x0A69,     /* F4  GURMUKHI DIGIT THREE */
    0x0A6A,     /* F5  GURMUKHI DIGIT FOUR */
    0x0A6B,     /* F6  GURMUKHI DIGIT FIVE */
    0x0A6C,     /* F7  GURMUKHI DIGIT SIX */
    0x0A6D,     /* F8  GURMUKHI DIGIT SEVEN */
    0x0A6E,     /* F9  GURMUKHI DIGIT EIGHT */
    0x0A6F,     /* FA  GURMUKHI DIGIT NINE */
    UV_UNDEF,   /* FB */
    UV_UNDEF,   /* FC */
    UV_UNDEF,   /* FD */
    UV_UNDEF,   /* FE */
    UV_UNDEF,   /* FF */
]
