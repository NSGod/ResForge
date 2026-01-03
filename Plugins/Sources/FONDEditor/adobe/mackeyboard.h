/*
 # Format:
 # -------
 #
 #   Three tab-separated columns;
 #   '#' begins a comment which continues to the end of the line.
 #     Column #1 is the Mac OS Keyboard code (in hex as 0xNN)
 #     Column #2 is the corresponding Unicode or Unicode sequence
 #       (in hex as 0xNNNN or 0xNNNN+0xNNNN, etc.).
 #     Column #3 is a comment containing the Unicode name.
 #       In some cases an additional comment follows the Unicode name.
 #
 #   The entries are in Mac OS Keyboard code order.
 #
 #   Some of these mappings require the use of corporate characters.
 #   See the file "CORPCHAR.TXT" and notes below.
 #
 #   The Mac OS Keyboard character set uses the ranges normally set aside
 #   for controls, so those ranges are present in this table.
 #
 # Notes on Mac OS Keyboard:
 # -------------------------
 #
 #   This is the encoding for the legacy font named ".Keyboard". Before
 #   Mac OS X, this font was used by the user-interface system to display
 #   glyphs for special keys on the keyboard. In Mac OS X, that font is
 #   not present and this mapping is not associated with a font; it is
 #   only used as a way to map from a set of Menu Manager constants to
 #   associated Unicode sequences. As such, new mappings added for Mac OS
 #   X only may be one-way mappings: From the Keyboard glyph "encoding"
 #   to Unicode, but not back.
 #
 #   The Mac OS Keyboard encoding shares the script code smRoman
 #   (0) with the Mac OS Roman encoding. To determine if the Keyboard
 #   encoding is being used in Mac OS 8 or Mac OS 9, you must check if
 #   the font name is ".Keyboard".
 #
 # Unicode mapping issues and notes:
 # ---------------------------------
 #
 #   The goals in the mappings provided here are:
 #   - For mappings used in Mac OS 8 and Mac OS 9, ensure roundtrip
 #     mapping from every character in the Mac OS  Keyboard character set
 #     to Unicode and back. This consideration does not apply to mappings
 #     added for Mac OS X only (noted below).
 #   - Use standard Unicode characters as much as possible, to
 #     maximize interchangeability of the resulting Unicode text.
 #     Whenever possible, avoid having content carried by private-use
 #     characters.
 #
 #   Some of the characters in the Mac OS Keyboard character set do not
 #   correspond to distinct, single Unicode characters. To map these
 #   and satisfy both goals above, we employ various strategies.
 #
 #   a) If possible, use private use characters in combination with
 #   standard Unicode characters to mark variants of the standard
 #   Unicode character.
 #
 #   Apple has defined a block of 32 corporate characters as "transcoding
 #   hints." These are used in combination with standard Unicode
 #   characters to force them to be treated in a special way for mapping
 #   to other encodings; they have no other effect. Sixteen of these
 #   transcoding hints are "grouping hints" - they indicate that the next
 #   2-4 Unicode characters should be treated as a single entity for
 #   transcoding. The other sixteen transcoding hints are "variant tags"
 #   - they are like combining characters, and can follow a standard
 #   Unicode (or a sequence consisting of a base character and other
 #   combining characters) to cause it to be treated in a special way for
 #   transcoding. These always terminate a combining-character sequence.
 #
 #   The transcoding coding hints used in this mapping table are two
 #   grouping tags, 0xF860-61, and one variant tag, 0xF87F. Since these
 #   are combined with standard Unicode characters, some characters in
 #   the Mac OS Keyboard character set map to a sequence of two to four
 #   Unicodes instead of a single Unicode character.
 #
 #   For example, the Mac OS Keyboard character at 0x6F, representing the
 #   F1 key, is mapped to Unicode using the grouping tag F860 (group next
 #   two) followed by U+0046 (LATIN CAPITAL LETTER F) and U+0031 (DIGIT
 #   ONE).
 #
 #   b) Otherwise, use private use characters by themselves to map Mac OS
 #   Keyboard characters which have no relationship to any standard
 #   Unicode character.
 #
 #   The following additional corporate zone Unicode characters are
 #   used for this purpose here:
 #
 #     0xF802  Lower left pencil
 #     0xF803  Contextual menu key symbol
 #     0xF8FF  Apple logo
 #
 #   NOTE: The graphic image associated with the Apple logo character
 #   is not authorized for use without permission of Apple, and
 #   unauthorized use might constitute trademark infringement.
 #
 # Details of mapping changes in each version:
 # -------------------------------------------
 #
 #   Changes from version c01 to version c02:
 #
 #   - Mapping for 0x09 changed from 0x0009 (wrong) to 0x2423
 #   - Mapping for 0x0F changed from 0x270E (wrong) to 0xF802
 #   - Mapping for 0x8C changed from 0xF804 to 0x23CF (Unicode 4.0)
 #   - Add Mac OS X-only mappings for 0x8D-0x8F
 #
 */

0x0000,		/* 00	control - NUL */
UV_UNDEF,   /* 01 */
0x21E5,		/* 02	RIGHTWARDS ARROW TO BAR # Tab right (left-to-right text) */
0x21E4,		/* 03	LEFTWARDS ARROW TO BAR # Tab left (right-to-left text) */
0x2324,		/* 04	UP ARROWHEAD BETWEEN TWO HORIZONTAL BARS # Enter key */
0x21E7,		/* 05	UPWARDS WHITE ARROW # Shift key */
0x2303,		/* 06	UP ARROWHEAD # Control key */
0x2325,		/* 07	OPTION KEY # Option key */
0x0008,		/* 08	control - BS */
0x2423,		/* 09	OPEN BOX # Space key (Mac OS X mapping, duplicates mapping for 0x61, hence no round-trip) */
0x2326,		/* 0A	ERASE TO THE RIGHT # Delete right (right-to-left text) */
0x21A9,		/* 0B	LEFTWARDS ARROW WITH HOOK # Return key (left-to-right text) */
0x21AA,		/* 0C	RIGHTWARDS ARROW WITH HOOK # Return key (right-to-left text) */
0x000D,		/* 0D	control - CR */
UV_UNDEF,   /* 0E */
0xF802,		/* 0F	lower left pencil */
0x21E3,		/* 10	DOWNWARDS DASHED ARROW */
0x2318,		/* 11	PLACE OF INTEREST SIGN # Command key */
0x2713,		/* 12	CHECK MARK */
0x25C6,		/* 13	BLACK DIAMOND */
0xF8FF,		/* 14	Apple logo */
UV_UNDEF,   /* 15 */
UV_UNDEF,   /* 16 */
0x232B,		/* 17	ERASE TO THE LEFT # Delete left (left-to-right text) */
0x21E0,		/* 18	LEFTWARDS DASHED ARROW */
0x21E1,		/* 19	UPWARDS DASHED ARROW */
0x21E2,		/* 1A	RIGHTWARDS DASHED ARROW */
0x238B,		/* 1B	BROKEN CIRCLE WITH NORTHWEST ARROW # Escape key; for Unicode 3.0 and later */
0x2327,		/* 1C	X IN A RECTANGLE BOX # Clear key */
UV_UNDEF,   /* 1D */
UV_UNDEF,   /* 1E */
UV_UNDEF,   /* 1F */
0x0020,		/* 20	SPACE */
UV_UNDEF,   /* 21 */
UV_UNDEF,   /* 22 */
UV_UNDEF,   /* 23 */
UV_UNDEF,   /* 24 */
UV_UNDEF,   /* 25 */
UV_UNDEF,   /* 26 */
UV_UNDEF,   /* 27 */
UV_UNDEF,   /* 28 */
UV_UNDEF,   /* 29 */
UV_UNDEF,   /* 2A */
UV_UNDEF,   /* 2B */
UV_UNDEF,   /* 2C */
UV_UNDEF,   /* 2D */
UV_UNDEF,   /* 2E */
UV_UNDEF,   /* 2F */
0x0030,		/* 30	DIGIT ZERO */
0x0031,		/* 31	DIGIT ONE */
0x0032,		/* 32	DIGIT TWO */
0x0033,		/* 33	DIGIT THREE */
0x0034,		/* 34	DIGIT FOUR */
0x0035,		/* 35	DIGIT FIVE */
0x0036,		/* 36	DIGIT SIX */
0x0037,		/* 37	DIGIT SEVEN */
0x0038,		/* 38	DIGIT EIGHT */
0x0039,		/* 39	DIGIT NINE */
UV_UNDEF,   /* 3A */
UV_UNDEF,   /* 3B */
UV_UNDEF,   /* 3C */
UV_UNDEF,   /* 3D */
UV_UNDEF,   /* 3E */
UV_UNDEF,   /* 3F */
UV_UNDEF,   /* 40 */
UV_UNDEF,   /* 41 */
UV_UNDEF,   /* 42 */
UV_UNDEF,   /* 43 */
UV_UNDEF,   /* 44 */
UV_UNDEF,   /* 45 */
0x0046,		/* 46	LATIN CAPITAL LETTER F */
UV_UNDEF,   /* 47 */
UV_UNDEF,   /* 48 */
UV_UNDEF,   /* 49 */
UV_UNDEF,   /* 4A */
UV_UNDEF,   /* 4B */
UV_UNDEF,   /* 4C */
UV_UNDEF,   /* 4D */
UV_UNDEF,   /* 4E */
UV_UNDEF,   /* 4F */
UV_UNDEF,   /* 50 */
UV_UNDEF,   /* 51 */
UV_UNDEF,   /* 52 */
UV_UNDEF,   /* 53 */
UV_UNDEF,   /* 54 */
UV_UNDEF,   /* 55 */
UV_UNDEF,   /* 56 */
UV_UNDEF,   /* 57 */
UV_UNDEF,   /* 58 */
UV_UNDEF,   /* 59 */
UV_UNDEF,   /* 5A */
UV_UNDEF,   /* 5B */
UV_UNDEF,   /* 5C */
UV_UNDEF,   /* 5D */
UV_UNDEF,   /* 5E */
UV_UNDEF,   /* 5F */
UV_UNDEF,   /* 60 */
0x2423,		/* 61	OPEN BOX # Blank key */
0x21DE,		/* 62	UPWARDS ARROW WITH DOUBLE STROKE # Page up key */
0x21EA,		/* 63	UPWARDS WHITE ARROW FROM BAR # Caps lock key */
0x2190,		/* 64	LEFTWARDS ARROW */
0x2192,		/* 65	RIGHTWARDS ARROW */
0x2196,		/* 66	NORTH WEST ARROW */
0x67	0x003F+0x20DD	# QUESTION MARK + COMBINING ENCLOSING CIRCLE # Help key
0x2191,		/* 68	UPWARDS ARROW */
0x2198,		/* 69	SOUTH EAST ARROW */
0x2193,		/* 6A	DOWNWARDS ARROW */
0x21DF,		/* 6B	DOWNWARDS ARROW WITH DOUBLE STROKE # Page down key */
0x6C	0xF8FF+0xF87F	# Apple logo, outline
0xF803,		/* 6D	Contextual menu key symbol */
0x6E	0x2758+0x20DD	# LIGHT VERTICAL BAR + COMBINING ENCLOSING CIRCLE # Power key
0x6F	0xF860+0x0046+0x0031	# group_2 + F + 1 # F1 key
0x70	0xF860+0x0046+0x0032	# group_2 + F + 2 # F2 key
0x71	0xF860+0x0046+0x0033	# group_2 + F + 3 # F3 key
0x72	0xF860+0x0046+0x0034	# group_2 + F + 4 # F4 key
0x73	0xF860+0x0046+0x0035	# group_2 + F + 5 # F5 key
0x74	0xF860+0x0046+0x0036	# group_2 + F + 6 # F6 key
0x75	0xF860+0x0046+0x0037	# group_2 + F + 7 # F7 key
0x76	0xF860+0x0046+0x0038	# group_2 + F + 8 # F8 key
0x77	0xF860+0x0046+0x0039	# group_2 + F + 9 # F9 key
0x78	0xF861+0x0046+0x0031+0x0030	# group_3 + F + 1 + 0 # F10 key
0x79	0xF861+0x0046+0x0031+0x0031	# group_3 + F + 1 + 1 # F11 key
0x7A	0xF861+0x0046+0x0031+0x0032	# group_3 + F + 1 + 2 # F12 key
#
0x87	0xF861+0x0046+0x0031+0x0033	# group_3 + F + 1 + 3 # F13 key
0x88	0xF861+0x0046+0x0031+0x0034	# group_3 + F + 1 + 4 # F14 key
0x89	0xF861+0x0046+0x0031+0x0035	# group_3 + F + 1 + 5 # F15 key
0x2388,		/* 8A	HELM SYMBOL # Control key (ISO standard), Unicode 3.0 and later */
0x2387,		/* 8B	ALTERNATIVE KEY SYMBOL # Unicode 3.0 and later */
0x23CF,		/* 8C	EJECT SYMBOL # Unicode 4.0 and later, Mac OS X only */
0x8D	0x82F1+0x6570	# Japanese "eisu" key symbol # Mac OS X only
0x8E	0x304B+0x306A	# Japanese "kana" key symbol # Mac OS X only
0x8F	0xF861+0x0046+0x0031+0x0036	# group_3 + F + 1 + 6 # F16 key, Mac OS X only
#

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
0x0020,		/* 20  SPACE */
0x2701,		/* 21  UPPER BLADE SCISSORS */
0x2702,		/* 22  BLACK SCISSORS */
0x2703,		/* 23  LOWER BLADE SCISSORS */
0x2704,		/* 24  WHITE SCISSORS */
0x260E,		/* 25  BLACK TELEPHONE */
0x2706,		/* 26  TELEPHONE LOCATION SIGN */
0x2707,		/* 27  TAPE DRIVE */
0x2708,		/* 28  AIRPLANE */
0x2709,		/* 29  ENVELOPE */
0x261B,		/* 2A  BLACK RIGHT POINTING INDEX */
0x261E,		/* 2B  WHITE RIGHT POINTING INDEX */
0x270C,		/* 2C  VICTORY HAND */
0x270D,		/* 2D  WRITING HAND */
0x270E,		/* 2E  LOWER RIGHT PENCIL */
0x270F,		/* 2F  PENCIL */
0x2710,		/* 30  UPPER RIGHT PENCIL */
0x2711,		/* 31  WHITE NIB */
0x2712,		/* 32  BLACK NIB */
0x2713,		/* 33  CHECK MARK */
0x2714,		/* 34  HEAVY CHECK MARK */
0x2715,		/* 35  MULTIPLICATION X */
0x2716,		/* 36  HEAVY MULTIPLICATION X */
0x2717,		/* 37  BALLOT X */
0x2718,		/* 38  HEAVY BALLOT X */
0x2719,		/* 39  OUTLINED GREEK CROSS */
0x271A,		/* 3A  HEAVY GREEK CROSS */
0x271B,		/* 3B  OPEN CENTRE CROSS */
0x271C,		/* 3C  HEAVY OPEN CENTRE CROSS */
0x271D,		/* 3D  LATIN CROSS */
0x271E,		/* 3E  SHADOWED WHITE LATIN CROSS */
0x271F,		/* 3F  OUTLINED LATIN CROSS */
0x2720,		/* 40  MALTESE CROSS */
0x2721,		/* 41  STAR OF DAVID */
0x2722,		/* 42  FOUR TEARDROP-SPOKED ASTERISK */
0x2723,		/* 43  FOUR BALLOON-SPOKED ASTERISK */
0x2724,		/* 44  HEAVY FOUR BALLOON-SPOKED ASTERISK */
0x2725,		/* 45  FOUR CLUB-SPOKED ASTERISK */
0x2726,		/* 46  BLACK FOUR POINTED STAR */
0x2727,		/* 47  WHITE FOUR POINTED STAR */
0x2605,		/* 48  BLACK STAR */
0x2729,		/* 49  STRESS OUTLINED WHITE STAR */
0x272A,		/* 4A  CIRCLED WHITE STAR */
0x272B,		/* 4B  OPEN CENTRE BLACK STAR */
0x272C,		/* 4C  BLACK CENTRE WHITE STAR */
0x272D,		/* 4D  OUTLINED BLACK STAR */
0x272E,		/* 4E  HEAVY OUTLINED BLACK STAR */
0x272F,		/* 4F  PINWHEEL STAR */
0x2730,		/* 50  SHADOWED WHITE STAR */
0x2731,		/* 51  HEAVY ASTERISK */
0x2732,		/* 52  OPEN CENTRE ASTERISK */
0x2733,		/* 53  EIGHT SPOKED ASTERISK */
0x2734,		/* 54  EIGHT POINTED BLACK STAR */
0x2735,		/* 55  EIGHT POINTED PINWHEEL STAR */
0x2736,		/* 56  SIX POINTED BLACK STAR */
0x2737,		/* 57  EIGHT POINTED RECTILINEAR BLACK STAR */
0x2738,		/* 58  HEAVY EIGHT POINTED RECTILINEAR BLACK STAR */
0x2739,		/* 59  TWELVE POINTED BLACK STAR */
0x273A,		/* 5A  SIXTEEN POINTED ASTERISK */
0x273B,		/* 5B  TEARDROP-SPOKED ASTERISK */
0x273C,		/* 5C  OPEN CENTRE TEARDROP-SPOKED ASTERISK */
0x273D,		/* 5D  HEAVY TEARDROP-SPOKED ASTERISK */
0x273E,		/* 5E  SIX PETALLED BLACK AND WHITE FLORETTE */
0x273F,		/* 5F  BLACK FLORETTE */
0x2740,		/* 60  WHITE FLORETTE */
0x2741,		/* 61  EIGHT PETALLED OUTLINED BLACK FLORETTE */
0x2742,		/* 62  CIRCLED OPEN CENTRE EIGHT POINTED STAR */
0x2743,		/* 63  HEAVY TEARDROP-SPOKED PINWHEEL ASTERISK */
0x2744,		/* 64  SNOWFLAKE */
0x2745,		/* 65  TIGHT TRIFOLIATE SNOWFLAKE */
0x2746,		/* 66  HEAVY CHEVRON SNOWFLAKE */
0x2747,		/* 67  SPARKLE */
0x2748,		/* 68  HEAVY SPARKLE */
0x2749,		/* 69  BALLOON-SPOKED ASTERISK */
0x274A,		/* 6A  EIGHT TEARDROP-SPOKED PROPELLER ASTERISK */
0x274B,		/* 6B  HEAVY EIGHT TEARDROP-SPOKED PROPELLER ASTERISK */
0x25CF,		/* 6C  BLACK CIRCLE */
0x274D,		/* 6D  SHADOWED WHITE CIRCLE */
0x25A0,		/* 6E  BLACK SQUARE */
0x274F,		/* 6F  LOWER RIGHT DROP-SHADOWED WHITE SQUARE */
0x2750,		/* 70  UPPER RIGHT DROP-SHADOWED WHITE SQUARE */
0x2751,		/* 71  LOWER RIGHT SHADOWED WHITE SQUARE */
0x2752,		/* 72  UPPER RIGHT SHADOWED WHITE SQUARE */
0x25B2,		/* 73  BLACK UP-POINTING TRIANGLE */
0x25BC,		/* 74  BLACK DOWN-POINTING TRIANGLE */
0x25C6,		/* 75  BLACK DIAMOND */
0x2756,		/* 76  BLACK DIAMOND MINUS WHITE X */
0x25D7,		/* 77  RIGHT HALF BLACK CIRCLE */
0x2758,		/* 78  LIGHT VERTICAL BAR */
0x2759,		/* 79  MEDIUM VERTICAL BAR */
0x275A,		/* 7A  HEAVY VERTICAL BAR */
0x275B,		/* 7B  HEAVY SINGLE TURNED COMMA QUOTATION MARK ORNAMENT */
0x275C,		/* 7C  HEAVY SINGLE COMMA QUOTATION MARK ORNAMENT */
0x275D,		/* 7D  HEAVY DOUBLE TURNED COMMA QUOTATION MARK ORNAMENT */
0x275E,		/* 7E  HEAVY DOUBLE COMMA QUOTATION MARK ORNAMENT */
UV_UNDEF,	/* 7F */
0x2768,		/* 80  MEDIUM LEFT PARENTHESIS ORNAMENT # for Unicode 3.2 and later */
0x2769,		/* 81  MEDIUM RIGHT PARENTHESIS ORNAMENT # for Unicode 3.2 and later */
0x276A,		/* 82  MEDIUM FLATTENED LEFT PARENTHESIS ORNAMENT # for Unicode 3.2 and later */
0x276B,		/* 83  MEDIUM FLATTENED RIGHT PARENTHESIS ORNAMENT # for Unicode 3.2 and later */
0x276C,		/* 84  MEDIUM LEFT-POINTING ANGLE BRACKET ORNAMENT # for Unicode 3.2 and later */
0x276D,		/* 85  MEDIUM RIGHT-POINTING ANGLE BRACKET ORNAMENT # for Unicode 3.2 and later */
0x276E,		/* 86  HEAVY LEFT-POINTING ANGLE QUOTATION MARK ORNAMENT # for Unicode 3.2 and later */
0x276F,		/* 87  HEAVY RIGHT-POINTING ANGLE QUOTATION MARK ORNAMENT # for Unicode 3.2 and later */
0x2770,		/* 88  HEAVY LEFT-POINTING ANGLE BRACKET ORNAMENT # for Unicode 3.2 and later */
0x2771,		/* 89  HEAVY RIGHT-POINTING ANGLE BRACKET ORNAMENT # for Unicode 3.2 and later */
0x2772,		/* 8A  LIGHT LEFT TORTOISE SHELL BRACKET ORNAMENT # for Unicode 3.2 and later */
0x2773,		/* 8B  LIGHT RIGHT TORTOISE SHELL BRACKET ORNAMENT # for Unicode 3.2 and later */
0x2774,		/* 8C  MEDIUM LEFT CURLY BRACKET ORNAMENT # for Unicode 3.2 and later */
0x2775,		/* 8D  MEDIUM RIGHT CURLY BRACKET ORNAMENT # for Unicode 3.2 and later */
UV_UNDEF,	/* 8E */
UV_UNDEF,	/* 8F */
UV_UNDEF,	/* 90 */
UV_UNDEF,	/* 91 */
UV_UNDEF,	/* 92 */
UV_UNDEF,	/* 93 */
UV_UNDEF,	/* 94 */
UV_UNDEF,	/* 95 */
UV_UNDEF,	/* 96 */
UV_UNDEF,	/* 97 */
UV_UNDEF,	/* 98 */
UV_UNDEF,	/* 99 */
UV_UNDEF,	/* 9A */
UV_UNDEF,	/* 9B */
UV_UNDEF,	/* 9C */
UV_UNDEF,	/* 9D */
UV_UNDEF,	/* 9E */
UV_UNDEF,	/* 9F */
UV_UNDEF,	/* A0 */
0x2761,		/* A1  CURVED STEM PARAGRAPH SIGN ORNAMENT */
0x2762,		/* A2  HEAVY EXCLAMATION MARK ORNAMENT */
0x2763,		/* A3  HEAVY HEART EXCLAMATION MARK ORNAMENT */
0x2764,		/* A4  HEAVY BLACK HEART */
0x2765,		/* A5  ROTATED HEAVY BLACK HEART BULLET */
0x2766,		/* A6  FLORAL HEART */
0x2767,		/* A7  ROTATED FLORAL HEART BULLET */
0x2663,		/* A8  BLACK CLUB SUIT */
0x2666,		/* A9  BLACK DIAMOND SUIT */
0x2665,		/* AA  BLACK HEART SUIT */
0x2660,		/* AB  BLACK SPADE SUIT */
0x2460,		/* AC  CIRCLED DIGIT ONE */
0x2461,		/* AD  CIRCLED DIGIT TWO */
0x2462,		/* AE  CIRCLED DIGIT THREE */
0x2463,		/* AF  CIRCLED DIGIT FOUR */
0x2464,		/* B0  CIRCLED DIGIT FIVE */
0x2465,		/* B1  CIRCLED DIGIT SIX */
0x2466,		/* B2  CIRCLED DIGIT SEVEN */
0x2467,		/* B3  CIRCLED DIGIT EIGHT */
0x2468,		/* B4  CIRCLED DIGIT NINE */
0x2469,		/* B5  CIRCLED NUMBER TEN */
0x2776,		/* B6  DINGBAT NEGATIVE CIRCLED DIGIT ONE */
0x2777,		/* B7  DINGBAT NEGATIVE CIRCLED DIGIT TWO */
0x2778,		/* B8  DINGBAT NEGATIVE CIRCLED DIGIT THREE */
0x2779,		/* B9  DINGBAT NEGATIVE CIRCLED DIGIT FOUR */
0x277A,		/* BA  DINGBAT NEGATIVE CIRCLED DIGIT FIVE */
0x277B,		/* BB  DINGBAT NEGATIVE CIRCLED DIGIT SIX */
0x277C,		/* BC  DINGBAT NEGATIVE CIRCLED DIGIT SEVEN */
0x277D,		/* BD  DINGBAT NEGATIVE CIRCLED DIGIT EIGHT */
0x277E,		/* BE  DINGBAT NEGATIVE CIRCLED DIGIT NINE */
0x277F,		/* BF  DINGBAT NEGATIVE CIRCLED NUMBER TEN */
0x2780,		/* C0  DINGBAT CIRCLED SANS-SERIF DIGIT ONE */
0x2781,		/* C1  DINGBAT CIRCLED SANS-SERIF DIGIT TWO */
0x2782,		/* C2  DINGBAT CIRCLED SANS-SERIF DIGIT THREE */
0x2783,		/* C3  DINGBAT CIRCLED SANS-SERIF DIGIT FOUR */
0x2784,		/* C4  DINGBAT CIRCLED SANS-SERIF DIGIT FIVE */
0x2785,		/* C5  DINGBAT CIRCLED SANS-SERIF DIGIT SIX */
0x2786,		/* C6  DINGBAT CIRCLED SANS-SERIF DIGIT SEVEN */
0x2787,		/* C7  DINGBAT CIRCLED SANS-SERIF DIGIT EIGHT */
0x2788,		/* C8  DINGBAT CIRCLED SANS-SERIF DIGIT NINE */
0x2789,		/* C9  DINGBAT CIRCLED SANS-SERIF NUMBER TEN */
0x278A,		/* CA  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT ONE */
0x278B,		/* CB  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT TWO */
0x278C,		/* CC  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT THREE */
0x278D,		/* CD  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT FOUR */
0x278E,		/* CE  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT FIVE */
0x278F,		/* CF  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT SIX */
0x2790,		/* D0  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT SEVEN */
0x2791,		/* D1  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT EIGHT */
0x2792,		/* D2  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT NINE */
0x2793,		/* D3  DINGBAT NEGATIVE CIRCLED SANS-SERIF NUMBER TEN */
0x2794,		/* D4  HEAVY WIDE-HEADED RIGHTWARDS ARROW */
0x2192,		/* D5  RIGHTWARDS ARROW */
0x2194,		/* D6  LEFT RIGHT ARROW */
0x2195,		/* D7  UP DOWN ARROW */
0x2798,		/* D8  HEAVY SOUTH EAST ARROW */
0x2799,		/* D9  HEAVY RIGHTWARDS ARROW */
0x279A,		/* DA  HEAVY NORTH EAST ARROW */
0x279B,		/* DB  DRAFTING POINT RIGHTWARDS ARROW */
0x279C,		/* DC  HEAVY ROUND-TIPPED RIGHTWARDS ARROW */
0x279D,		/* DD  TRIANGLE-HEADED RIGHTWARDS ARROW */
0x279E,		/* DE  HEAVY TRIANGLE-HEADED RIGHTWARDS ARROW */
0x279F,		/* DF  DASHED TRIANGLE-HEADED RIGHTWARDS ARROW */
0x27A0,		/* E0  HEAVY DASHED TRIANGLE-HEADED RIGHTWARDS ARROW */
0x27A1,		/* E1  BLACK RIGHTWARDS ARROW */
0x27A2,		/* E2  THREE-D TOP-LIGHTED RIGHTWARDS ARROWHEAD */
0x27A3,		/* E3  THREE-D BOTTOM-LIGHTED RIGHTWARDS ARROWHEAD */
0x27A4,		/* E4  BLACK RIGHTWARDS ARROWHEAD */
0x27A5,		/* E5  HEAVY BLACK CURVED DOWNWARDS AND RIGHTWARDS ARROW */
0x27A6,		/* E6  HEAVY BLACK CURVED UPWARDS AND RIGHTWARDS ARROW */
0x27A7,		/* E7  SQUAT BLACK RIGHTWARDS ARROW */
0x27A8,		/* E8  HEAVY CONCAVE-POINTED BLACK RIGHTWARDS ARROW */
0x27A9,		/* E9  RIGHT-SHADED WHITE RIGHTWARDS ARROW */
0x27AA,		/* EA  LEFT-SHADED WHITE RIGHTWARDS ARROW */
0x27AB,		/* EB  BACK-TILTED SHADOWED WHITE RIGHTWARDS ARROW */
0x27AC,		/* EC  FRONT-TILTED SHADOWED WHITE RIGHTWARDS ARROW */
0x27AD,		/* ED  HEAVY LOWER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW */
0x27AE,		/* EE  HEAVY UPPER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW */
0x27AF,		/* EF  NOTCHED LOWER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW */
UV_UNDEF,	/* F0 */
0x27B1,		/* F1  NOTCHED UPPER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW */
0x27B2,		/* F2  CIRCLED HEAVY WHITE RIGHTWARDS ARROW */
0x27B3,		/* F3  WHITE-FEATHERED RIGHTWARDS ARROW */
0x27B4,		/* F4  BLACK-FEATHERED SOUTH EAST ARROW */
0x27B5,		/* F5  BLACK-FEATHERED RIGHTWARDS ARROW */
0x27B6,		/* F6  BLACK-FEATHERED NORTH EAST ARROW */
0x27B7,		/* F7  HEAVY BLACK-FEATHERED SOUTH EAST ARROW */
0x27B8,		/* F8  HEAVY BLACK-FEATHERED RIGHTWARDS ARROW */
0x27B9,		/* F9  HEAVY BLACK-FEATHERED NORTH EAST ARROW */
0x27BA,		/* FA  TEARDROP-BARBED RIGHTWARDS ARROW */
0x27BB,		/* FB  HEAVY TEARDROP-SHANKED RIGHTWARDS ARROW */
0x27BC,		/* FC  WEDGE-TAILED RIGHTWARDS ARROW */
0x27BD,		/* FD  HEAVY WEDGE-TAILED RIGHTWARDS ARROW */
0x27BE,		/* FE  OPEN-OUTLINED RIGHTWARDS ARROW */
UV_UNDEF,	/* FF */
