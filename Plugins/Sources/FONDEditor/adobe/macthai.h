/* Copyright 2014 Adobe Systems Incorporated (http://www.adobe.com/). All Rights Reserved.
   This software is licensed as OpenSource, under the Apache License, Version 2.0.
   This license is available at: http://opensource.org/licenses/Apache-2.0. */

/* Mac OS Thai aggregate Unicode initializer.

   Element values are UVs. UV_UNDEF is 0xFFFF. Index by code, get UV.
   Source: ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/APPLE/THAI.TXT
   as of 9/9/99.

   22 entries are mapped to Corporate Use Area Unicode values that Apple has
   deprecated. The full transcoding hint sequence is shown in parentheses for
   such mappings. */

/*
 # Format:
 # -------
 #
 #   Three tab-separated columns;
 #   '#' begins a comment which continues to the end of the line.
 #     Column #1 is the Mac OS Thai code (in hex as 0xNN)
 #     Column #2 is the corresponding Unicode or Unicode sequence
 #       (in hex as 0xNNNN or 0xNNNN+0xNNNN).
 #     Column #3 is a comment containing the Unicode name
 #
 #   The entries are in Mac OS Thai code order.
 #
 #   Some of these mappings require the use of corporate characters.
 #   See the file "CORPCHAR.TXT" and notes below.
 #
 #   Control character mappings are not shown in this table, following
 #   the conventions of the standard UTC mapping tables. However, the
 #   Mac OS Thai character set uses the standard control characters at
 #   0x00-0x1F and 0x7F.
 #
 # Notes on Mac OS Thai:
 # ---------------------
 #
 #   This is a legacy Mac OS encoding; in the Mac OS X Carbon and Cocoa
 #   environments, it is only supported via transcoding to and from
 #   Unicode.
 #
 #   Codes 0xA1-0xDA and 0xDF-0xFB are the character set from Thai
 #   standard TIS 620-2533, except that the following changes are
 #   made:
 #     0xEE is TRADE MARK SIGN (instead of THAI CHARACTER YAMAKKAN)
 #     0xFA is REGISTERED SIGN (instead of THAI CHARACTER ANGKHANKHU)
 #     0xFB is COPYRIGHT SIGN (instead of THAI CHARACTER KHOMUT)
 #
 #   Codes 0x80-0x82, 0x8D-0x8E, 0x91, 0x9D-0x9E, and 0xDB-0xDE are
 #   various additional punctuation marks (e.g. curly quotes,
 #   ellipsis), no-break space, and two special characters "word join"
 #   and "word break".
 #
 #   Codes 0x83-0x8C, 0x8F, and 0x92-0x9C are for positional variants
 #   of the upper vowels, tone marks, and other signs at 0xD1,
 #   0xD4-0xD7, and 0xE7-0xED. The positional variants would normally
 #   be considered presentation forms only and not characters. In most
 #   cases they are not typed directly; they are selected automatically
 #   at display time by the WorldScript software. However, using the
 #   Thai-DTP keyboard, the presentation forms can in fact be typed
 #   directly using dead keys. Thus they must be treated as real
 #   characters in the Mac OS Thai encoding. They are mapped using
 #   variant tags; see below.
 #
 #   Several code points are undefined and unused (they cannot be
 #   typed using any of the Mac OS Thai keyboard layouts): 0x90, 0x9F,
 #   0xFC-0xFE. These are not shown in the table below.
 #
 # Unicode mapping issues and notes:
 # ---------------------------------
 #
 #   The goals in the Apple mappings provided here are:
 #   - Ensure roundtrip mapping from every character in the Mac OS Thai
 #   character set to Unicode and back
 #   - Use standard Unicode characters as much as possible, to maximize
 #   interchangeability of the resulting Unicode text. Whenever possible,
 #   avoid having content carried by private-use characters.
 #
 #   To satisfy both goals, we use private use characters to mark variants
 #   that are similar to a sequence of one or more standard Unicode
 #   characters.
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
 #   The transcoding coding hints used in this mapping table are four
 #   variant tags in the range 0xF873-75. Since these are combined with
 #   standard Unicode characters, some characters in the Mac OS Thai
 #   character set map to a sequence of two Unicodes instead of a single
 #   Unicode character. For example, the Mac OS Thai character at 0x83 is a
 #   low-left positional variant of THAI CHARACTER MAI EK (the standard
 #   mapping is for the abstract character at 0xE8). So 0x83 is mapped to
 #   0x0E48 (THAI CHARACTER MAI EK) + 0xF875 (a variant tag).
 #
 # Details of mapping changes in each version:
 # -------------------------------------------
 #
 #   Changes from version b02 to version b03/c01:
 #
 #   - Update mapping for 0xDB to use new Unicode 3.2 character U+2060
 #     WORD JOINER instead of U+FEFF ZERO WIDTH NO-BREAK SPACE (BOM)
 #
 #   Changes from version n04 to version n07:
 #
 #   - Changed mappings of the positional variants to use standard
 #   Unicodes + transcoding hint, instead of using single corporate
 #   zone characters. This affected the mappings for the following:
 #   0x83-08C, 0x8F, 0x92-0x9C
 #
 #   - Just comment out unused code points in the table, instead
 #   of mapping them to U+FFFD.
 #
 ##################
 */

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
0x00AB,     /* 80  LEFT-POINTING DOUBLE ANGLE QUOTATION MARK */
0x00BB,     /* 81  RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK */
0x2026,     /* 82  HORIZONTAL ELLIPSIS */
0xF88C,     /* 83  THAI CHARACTER MAI EK, low left position (0x0E48+0xF875) */
0xF88F,     /* 84  THAI CHARACTER MAI THO, low left position (0x0E49+0xF875) */
0xF892,     /* 85  THAI CHARACTER MAI TRI, low left position (0x0E4A+0xF875) */
0xF895,     /* 86  THAI CHARACTER MAI CHATTAWA, low left position (0x0E4B+0xF875) */
0xF898,     /* 87  THAI CHARACTER THANTHAKHAT, low left position (0x0E4C+0xF875) */
0xF88B,     /* 88  THAI CHARACTER MAI EK, low position (0x0E48+0xF873) */
0xF88E,     /* 89  THAI CHARACTER MAI THO, low position (0x0E49+0xF873) */
0xF891,     /* 8A  THAI CHARACTER MAI TRI, low position (0x0E4A+0xF873) */
0xF894,     /* 8B  THAI CHARACTER MAI CHATTAWA, low position (0x0E4B+0xF873) */
0xF897,     /* 8C  THAI CHARACTER THANTHAKHAT, low position (0x0E4C+0xF873) */
0x201C,     /* 8D  LEFT DOUBLE QUOTATION MARK */
0x201D,     /* 8E  RIGHT DOUBLE QUOTATION MARK */
0xF899,     /* 8F  THAI CHARACTER NIKHAHIT, left position (0x0E4D+0xF874) */
UV_UNDEF,   /* 90 */
0x2022,     /* 91  BULLET */
0xF884,     /* 92  THAI CHARACTER MAI HAN-AKAT, left position (0x0E31+0xF874) */
0xF889,     /* 93  THAI CHARACTER MAITAIKHU, left position (0x0E47+0xF874) */
0xF885,     /* 94  THAI CHARACTER SARA I, left position (0x0E34+0xF874) */
0xF886,     /* 95  THAI CHARACTER SARA II, left position (0x0E35+0xF874) */
0xF887,     /* 96  THAI CHARACTER SARA UE, left position (0x0E36+0xF874) */
0xF888,     /* 97  THAI CHARACTER SARA UEE, left position (0x0E37+0xF874) */
0xF88A,     /* 98  THAI CHARACTER MAI EK, left position (0x0E48+0xF874) */
0xF88D,     /* 99  THAI CHARACTER MAI THO, left position (0x0E49+0xF874) */
0xF890,     /* 9A  THAI CHARACTER MAI TRI, left position (0x0E4A+0xF874) */
0xF893,     /* 9B  THAI CHARACTER MAI CHATTAWA, left position (0x0E4B+0xF874) */
0xF896,     /* 9C  THAI CHARACTER THANTHAKHAT, left position (0x0E4C+0xF874) */
0x2018,     /* 9D  LEFT SINGLE QUOTATION MARK */
0x2019,     /* 9E  RIGHT SINGLE QUOTATION MARK */
UV_UNDEF,   /* 9F */
0x00A0,     /* A0  NO-BREAK SPACE */
0x0E01,     /* A1  THAI CHARACTER KO KAI */
0x0E02,     /* A2  THAI CHARACTER KHO KHAI */
0x0E03,     /* A3  THAI CHARACTER KHO KHUAT */
0x0E04,     /* A4  THAI CHARACTER KHO KHWAI */
0x0E05,     /* A5  THAI CHARACTER KHO KHON */
0x0E06,     /* A6  THAI CHARACTER KHO RAKHANG */
0x0E07,     /* A7  THAI CHARACTER NGO NGU */
0x0E08,     /* A8  THAI CHARACTER CHO CHAN */
0x0E09,     /* A9  THAI CHARACTER CHO CHING */
0x0E0A,     /* AA  THAI CHARACTER CHO CHANG */
0x0E0B,     /* AB  THAI CHARACTER SO SO */
0x0E0C,     /* AC  THAI CHARACTER CHO CHOE */
0x0E0D,     /* AD  THAI CHARACTER YO YING */
0x0E0E,     /* AE  THAI CHARACTER DO CHADA */
0x0E0F,     /* AF  THAI CHARACTER TO PATAK */
0x0E10,     /* B0  THAI CHARACTER THO THAN */
0x0E11,     /* B1  THAI CHARACTER THO NANGMONTHO */
0x0E12,     /* B2  THAI CHARACTER THO PHUTHAO */
0x0E13,     /* B3  THAI CHARACTER NO NEN */
0x0E14,     /* B4  THAI CHARACTER DO DEK */
0x0E15,     /* B5  THAI CHARACTER TO TAO */
0x0E16,     /* B6  THAI CHARACTER THO THUNG */
0x0E17,     /* B7  THAI CHARACTER THO THAHAN */
0x0E18,     /* B8  THAI CHARACTER THO THONG */
0x0E19,     /* B9  THAI CHARACTER NO NU */
0x0E1A,     /* BA  THAI CHARACTER BO BAIMAI */
0x0E1B,     /* BB  THAI CHARACTER PO PLA */
0x0E1C,     /* BC  THAI CHARACTER PHO PHUNG */
0x0E1D,     /* BD  THAI CHARACTER FO FA */
0x0E1E,     /* BE  THAI CHARACTER PHO PHAN */
0x0E1F,     /* BF  THAI CHARACTER FO FAN */
0x0E20,     /* C0  THAI CHARACTER PHO SAMPHAO */
0x0E21,     /* C1  THAI CHARACTER MO MA */
0x0E22,     /* C2  THAI CHARACTER YO YAK */
0x0E23,     /* C3  THAI CHARACTER RO RUA */
0x0E24,     /* C4  THAI CHARACTER RU */
0x0E25,     /* C5  THAI CHARACTER LO LING */
0x0E26,     /* C6  THAI CHARACTER LU */
0x0E27,     /* C7  THAI CHARACTER WO WAEN */
0x0E28,     /* C8  THAI CHARACTER SO SALA */
0x0E29,     /* C9  THAI CHARACTER SO RUSI */
0x0E2A,     /* CA  THAI CHARACTER SO SUA */
0x0E2B,     /* CB  THAI CHARACTER HO HIP */
0x0E2C,     /* CC  THAI CHARACTER LO CHULA */
0x0E2D,     /* CD  THAI CHARACTER O ANG */
0x0E2E,     /* CE  THAI CHARACTER HO NOKHUK */
0x0E2F,     /* CF  THAI CHARACTER PAIYANNOI */
0x0E30,     /* D0  THAI CHARACTER SARA A */
0x0E31,     /* D1  THAI CHARACTER MAI HAN-AKAT */
0x0E32,     /* D2  THAI CHARACTER SARA AA */
0x0E33,     /* D3  THAI CHARACTER SARA AM */
0x0E34,     /* D4  THAI CHARACTER SARA I */
0x0E35,     /* D5  THAI CHARACTER SARA II */
0x0E36,     /* D6  THAI CHARACTER SARA UE */
0x0E37,     /* D7  THAI CHARACTER SARA UEE */
0x0E38,     /* D8  THAI CHARACTER SARA U */
0x0E39,     /* D9  THAI CHARACTER SARA UU */
0x0E3A,     /* DA  THAI CHARACTER PHINTHU */
0xFEFF,     /* DB  ZERO WIDTH NO-BREAK SPACE */
0x200B,     /* DC  ZERO WIDTH SPACE */
0x2013,     /* DD  EN DASH */
0x2014,     /* DE  EM DASH */
0x0E3F,     /* DF  THAI CURRENCY SYMBOL BAHT */
0x0E40,     /* E0  THAI CHARACTER SARA E */
0x0E41,     /* E1  THAI CHARACTER SARA AE */
0x0E42,     /* E2  THAI CHARACTER SARA O */
0x0E43,     /* E3  THAI CHARACTER SARA AI MAIMUAN */
0x0E44,     /* E4  THAI CHARACTER SARA AI MAIMALAI */
0x0E45,     /* E5  THAI CHARACTER LAKKHANGYAO */
0x0E46,     /* E6  THAI CHARACTER MAIYAMOK */
0x0E47,     /* E7  THAI CHARACTER MAITAIKHU */
0x0E48,     /* E8  THAI CHARACTER MAI EK */
0x0E49,     /* E9  THAI CHARACTER MAI THO */
0x0E4A,     /* EA  THAI CHARACTER MAI TRI */
0x0E4B,     /* EB  THAI CHARACTER MAI CHATTAWA */
0x0E4C,     /* EC  THAI CHARACTER THANTHAKHAT */
0x0E4D,     /* ED  THAI CHARACTER NIKHAHIT */
0x2122,     /* EE  TRADE MARK SIGN */
0x0E4F,     /* EF  THAI CHARACTER FONGMAN */
0x0E50,     /* F0  THAI DIGIT ZERO */
0x0E51,     /* F1  THAI DIGIT ONE */
0x0E52,     /* F2  THAI DIGIT TWO */
0x0E53,     /* F3  THAI DIGIT THREE */
0x0E54,     /* F4  THAI DIGIT FOUR */
0x0E55,     /* F5  THAI DIGIT FIVE */
0x0E56,     /* F6  THAI DIGIT SIX */
0x0E57,     /* F7  THAI DIGIT SEVEN */
0x0E58,     /* F8  THAI DIGIT EIGHT */
0x0E59,     /* F9  THAI DIGIT NINE */
0x00AE,     /* FA  REGISTERED SIGN */
0x00A9,     /* FB  COPYRIGHT SIGN */
UV_UNDEF,   /* FC */
UV_UNDEF,   /* FD */
UV_UNDEF,   /* FE */
UV_UNDEF,   /* FF */
