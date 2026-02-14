//
//  macDingbatsEncoding.swift
//  CoreFont
//
//  Created by Mark Douma on 1/1/2026.
//

/*
 # Format:
 # -------
 #
 #   Three tab-separated columns;
 #   '#' begins a comment which continues to the end of the line.
 #     Column #1 is the Mac OS Dingbats code (in hex as 0xNN)
 #     Column #2 is the corresponding Unicode or Unicode sequence
 #       (in hex as 0xNNNN).
 #     Column #3 is a comment containing the Unicode name.
 #       In some cases an additional comment follows the Unicode name.
 #
 #   The entries are in Mac OS Dingbats code order.
 #
 #   Some of these mappings require the use of corporate characters.
 #   See the file "CORPCHAR.TXT" and notes below.
 #
 #   Control character mappings are not shown in this table, following
 #   the conventions of the standard UTC mapping tables. However, the
 #   Mac OS Dingbats character set uses the standard control characters
 #   at 0x00-0x1F and 0x7F.
 #
 # Notes on Mac OS Dingbats:
 # -------------------------
 #
 #   This is a legacy Mac OS encoding; in the Mac OS X Carbon and Cocoa
 #   environments, it is only supported directly in programming
 #   interfaces for QuickDraw Text, the Script Manager, and related
 #   Text Utilities. For other purposes it is supported via transcoding
 #   to and from Unicode.
 #
 #   The Mac OS Dingbats encoding shares the script code smRoman
 #   (0) with the standard Mac OS Roman encoding. To determine if
 #   the Dingbats encoding is being used, you must check if the
 #   font name is "Zapf Dingbats".
 #
 #   The layout of the Dingbats character set is identical to or
 #   a superset of the layout of the Adobe Zapf Dingbats encoding
 #   vector.
 #
 #   The following code points are unused, and are not shown here:
 #   0x8E-0xA0, 0xF0, 0xFF.
 #
 # Unicode mapping issues and notes:
 # ---------------------------------
 #
 # Details of mapping changes in each version:
 # -------------------------------------------
 #
 #   Changes from version b02 to version b03/c01:
 #
 #   - The mappings for the following Mac OS Dingbats characters
 #   were changed to use standard Unicode characters added for
 #   Unicode 3.2: 0x80-0x8D.
 #
 #   Changes from version n03 to version n05:
 #
 #   - The mappings for the following Mac OS Dingbats characters
 #   were changed from single corporate-zone Unicode characters
 #   to standard Unicode characters:
 #   0x80-0x81, 0x84-0x87, 0x8A-0x8D.
 #
 #   - The mappings for the following Mac OS Dingbats characters
 #   were changed from single corporate-zone Unicode characters
 #   to combinations of a standard Unicode and a transcoding hint:
 #   0x82-0x83, 0x88-0x89.
 #
 */

import Foundation

let macDingbatsEncoding: [UVBMP] = [
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
    0x2701,       /* 21  UPPER BLADE SCISSORS */
    0x2702,       /* 22  BLACK SCISSORS */
    0x2703,       /* 23  LOWER BLADE SCISSORS */
    0x2704,       /* 24  WHITE SCISSORS */
    0x260E,       /* 25  BLACK TELEPHONE */
    0x2706,       /* 26  TELEPHONE LOCATION SIGN */
    0x2707,       /* 27  TAPE DRIVE */
    0x2708,       /* 28  AIRPLANE */
    0x2709,       /* 29  ENVELOPE */
    0x261B,       /* 2A  BLACK RIGHT POINTING INDEX */
    0x261E,       /* 2B  WHITE RIGHT POINTING INDEX */
    0x270C,       /* 2C  VICTORY HAND */
    0x270D,       /* 2D  WRITING HAND */
    0x270E,       /* 2E  LOWER RIGHT PENCIL */
    0x270F,       /* 2F  PENCIL */
    0x2710,       /* 30  UPPER RIGHT PENCIL */
    0x2711,       /* 31  WHITE NIB */
    0x2712,       /* 32  BLACK NIB */
    0x2713,       /* 33  CHECK MARK */
    0x2714,       /* 34  HEAVY CHECK MARK */
    0x2715,       /* 35  MULTIPLICATION X */
    0x2716,       /* 36  HEAVY MULTIPLICATION X */
    0x2717,       /* 37  BALLOT X */
    0x2718,       /* 38  HEAVY BALLOT X */
    0x2719,       /* 39  OUTLINED GREEK CROSS */
    0x271A,       /* 3A  HEAVY GREEK CROSS */
    0x271B,       /* 3B  OPEN CENTRE CROSS */
    0x271C,       /* 3C  HEAVY OPEN CENTRE CROSS */
    0x271D,       /* 3D  LATIN CROSS */
    0x271E,       /* 3E  SHADOWED WHITE LATIN CROSS */
    0x271F,       /* 3F  OUTLINED LATIN CROSS */
    0x2720,       /* 40  MALTESE CROSS */
    0x2721,       /* 41  STAR OF DAVID */
    0x2722,       /* 42  FOUR TEARDROP-SPOKED ASTERISK */
    0x2723,       /* 43  FOUR BALLOON-SPOKED ASTERISK */
    0x2724,       /* 44  HEAVY FOUR BALLOON-SPOKED ASTERISK */
    0x2725,       /* 45  FOUR CLUB-SPOKED ASTERISK */
    0x2726,       /* 46  BLACK FOUR POINTED STAR */
    0x2727,       /* 47  WHITE FOUR POINTED STAR */
    0x2605,       /* 48  BLACK STAR */
    0x2729,       /* 49  STRESS OUTLINED WHITE STAR */
    0x272A,       /* 4A  CIRCLED WHITE STAR */
    0x272B,       /* 4B  OPEN CENTRE BLACK STAR */
    0x272C,       /* 4C  BLACK CENTRE WHITE STAR */
    0x272D,       /* 4D  OUTLINED BLACK STAR */
    0x272E,       /* 4E  HEAVY OUTLINED BLACK STAR */
    0x272F,       /* 4F  PINWHEEL STAR */
    0x2730,       /* 50  SHADOWED WHITE STAR */
    0x2731,       /* 51  HEAVY ASTERISK */
    0x2732,       /* 52  OPEN CENTRE ASTERISK */
    0x2733,       /* 53  EIGHT SPOKED ASTERISK */
    0x2734,       /* 54  EIGHT POINTED BLACK STAR */
    0x2735,       /* 55  EIGHT POINTED PINWHEEL STAR */
    0x2736,       /* 56  SIX POINTED BLACK STAR */
    0x2737,       /* 57  EIGHT POINTED RECTILINEAR BLACK STAR */
    0x2738,       /* 58  HEAVY EIGHT POINTED RECTILINEAR BLACK STAR */
    0x2739,       /* 59  TWELVE POINTED BLACK STAR */
    0x273A,       /* 5A  SIXTEEN POINTED ASTERISK */
    0x273B,       /* 5B  TEARDROP-SPOKED ASTERISK */
    0x273C,       /* 5C  OPEN CENTRE TEARDROP-SPOKED ASTERISK */
    0x273D,       /* 5D  HEAVY TEARDROP-SPOKED ASTERISK */
    0x273E,       /* 5E  SIX PETALLED BLACK AND WHITE FLORETTE */
    0x273F,       /* 5F  BLACK FLORETTE */
    0x2740,       /* 60  WHITE FLORETTE */
    0x2741,       /* 61  EIGHT PETALLED OUTLINED BLACK FLORETTE */
    0x2742,       /* 62  CIRCLED OPEN CENTRE EIGHT POINTED STAR */
    0x2743,       /* 63  HEAVY TEARDROP-SPOKED PINWHEEL ASTERISK */
    0x2744,       /* 64  SNOWFLAKE */
    0x2745,       /* 65  TIGHT TRIFOLIATE SNOWFLAKE */
    0x2746,       /* 66  HEAVY CHEVRON SNOWFLAKE */
    0x2747,       /* 67  SPARKLE */
    0x2748,       /* 68  HEAVY SPARKLE */
    0x2749,       /* 69  BALLOON-SPOKED ASTERISK */
    0x274A,       /* 6A  EIGHT TEARDROP-SPOKED PROPELLER ASTERISK */
    0x274B,       /* 6B  HEAVY EIGHT TEARDROP-SPOKED PROPELLER ASTERISK */
    0x25CF,       /* 6C  BLACK CIRCLE */
    0x274D,       /* 6D  SHADOWED WHITE CIRCLE */
    0x25A0,       /* 6E  BLACK SQUARE */
    0x274F,       /* 6F  LOWER RIGHT DROP-SHADOWED WHITE SQUARE */
    0x2750,       /* 70  UPPER RIGHT DROP-SHADOWED WHITE SQUARE */
    0x2751,       /* 71  LOWER RIGHT SHADOWED WHITE SQUARE */
    0x2752,       /* 72  UPPER RIGHT SHADOWED WHITE SQUARE */
    0x25B2,       /* 73  BLACK UP-POINTING TRIANGLE */
    0x25BC,       /* 74  BLACK DOWN-POINTING TRIANGLE */
    0x25C6,       /* 75  BLACK DIAMOND */
    0x2756,       /* 76  BLACK DIAMOND MINUS WHITE X */
    0x25D7,       /* 77  RIGHT HALF BLACK CIRCLE */
    0x2758,       /* 78  LIGHT VERTICAL BAR */
    0x2759,       /* 79  MEDIUM VERTICAL BAR */
    0x275A,       /* 7A  HEAVY VERTICAL BAR */
    0x275B,       /* 7B  HEAVY SINGLE TURNED COMMA QUOTATION MARK ORNAMENT */
    0x275C,       /* 7C  HEAVY SINGLE COMMA QUOTATION MARK ORNAMENT */
    0x275D,       /* 7D  HEAVY DOUBLE TURNED COMMA QUOTATION MARK ORNAMENT */
    0x275E,       /* 7E  HEAVY DOUBLE COMMA QUOTATION MARK ORNAMENT */
    .undefined,   /* 7F */
    0x2768,       /* 80  MEDIUM LEFT PARENTHESIS ORNAMENT # for Unicode 3.2 and later */
    0x2769,       /* 81  MEDIUM RIGHT PARENTHESIS ORNAMENT # for Unicode 3.2 and later */
    0x276A,       /* 82  MEDIUM FLATTENED LEFT PARENTHESIS ORNAMENT # for Unicode 3.2 and later */
    0x276B,       /* 83  MEDIUM FLATTENED RIGHT PARENTHESIS ORNAMENT # for Unicode 3.2 and later */
    0x276C,       /* 84  MEDIUM LEFT-POINTING ANGLE BRACKET ORNAMENT # for Unicode 3.2 and later */
    0x276D,       /* 85  MEDIUM RIGHT-POINTING ANGLE BRACKET ORNAMENT # for Unicode 3.2 and later */
    0x276E,       /* 86  HEAVY LEFT-POINTING ANGLE QUOTATION MARK ORNAMENT # for Unicode 3.2 and later */
    0x276F,       /* 87  HEAVY RIGHT-POINTING ANGLE QUOTATION MARK ORNAMENT # for Unicode 3.2 and later */
    0x2770,       /* 88  HEAVY LEFT-POINTING ANGLE BRACKET ORNAMENT # for Unicode 3.2 and later */
    0x2771,       /* 89  HEAVY RIGHT-POINTING ANGLE BRACKET ORNAMENT # for Unicode 3.2 and later */
    0x2772,       /* 8A  LIGHT LEFT TORTOISE SHELL BRACKET ORNAMENT # for Unicode 3.2 and later */
    0x2773,       /* 8B  LIGHT RIGHT TORTOISE SHELL BRACKET ORNAMENT # for Unicode 3.2 and later */
    0x2774,       /* 8C  MEDIUM LEFT CURLY BRACKET ORNAMENT # for Unicode 3.2 and later */
    0x2775,       /* 8D  MEDIUM RIGHT CURLY BRACKET ORNAMENT # for Unicode 3.2 and later */
    .undefined,   /* 8E */
    .undefined,   /* 8F */
    .undefined,   /* 90 */
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
    0x2761,       /* A1  CURVED STEM PARAGRAPH SIGN ORNAMENT */
    0x2762,       /* A2  HEAVY EXCLAMATION MARK ORNAMENT */
    0x2763,       /* A3  HEAVY HEART EXCLAMATION MARK ORNAMENT */
    0x2764,       /* A4  HEAVY BLACK HEART */
    0x2765,       /* A5  ROTATED HEAVY BLACK HEART BULLET */
    0x2766,       /* A6  FLORAL HEART */
    0x2767,       /* A7  ROTATED FLORAL HEART BULLET */
    0x2663,       /* A8  BLACK CLUB SUIT */
    0x2666,       /* A9  BLACK DIAMOND SUIT */
    0x2665,       /* AA  BLACK HEART SUIT */
    0x2660,       /* AB  BLACK SPADE SUIT */
    0x2460,       /* AC  CIRCLED DIGIT ONE */
    0x2461,       /* AD  CIRCLED DIGIT TWO */
    0x2462,       /* AE  CIRCLED DIGIT THREE */
    0x2463,       /* AF  CIRCLED DIGIT FOUR */
    0x2464,       /* B0  CIRCLED DIGIT FIVE */
    0x2465,       /* B1  CIRCLED DIGIT SIX */
    0x2466,       /* B2  CIRCLED DIGIT SEVEN */
    0x2467,       /* B3  CIRCLED DIGIT EIGHT */
    0x2468,       /* B4  CIRCLED DIGIT NINE */
    0x2469,       /* B5  CIRCLED NUMBER TEN */
    0x2776,       /* B6  DINGBAT NEGATIVE CIRCLED DIGIT ONE */
    0x2777,       /* B7  DINGBAT NEGATIVE CIRCLED DIGIT TWO */
    0x2778,       /* B8  DINGBAT NEGATIVE CIRCLED DIGIT THREE */
    0x2779,       /* B9  DINGBAT NEGATIVE CIRCLED DIGIT FOUR */
    0x277A,       /* BA  DINGBAT NEGATIVE CIRCLED DIGIT FIVE */
    0x277B,       /* BB  DINGBAT NEGATIVE CIRCLED DIGIT SIX */
    0x277C,       /* BC  DINGBAT NEGATIVE CIRCLED DIGIT SEVEN */
    0x277D,       /* BD  DINGBAT NEGATIVE CIRCLED DIGIT EIGHT */
    0x277E,       /* BE  DINGBAT NEGATIVE CIRCLED DIGIT NINE */
    0x277F,       /* BF  DINGBAT NEGATIVE CIRCLED NUMBER TEN */
    0x2780,       /* C0  DINGBAT CIRCLED SANS-SERIF DIGIT ONE */
    0x2781,       /* C1  DINGBAT CIRCLED SANS-SERIF DIGIT TWO */
    0x2782,       /* C2  DINGBAT CIRCLED SANS-SERIF DIGIT THREE */
    0x2783,       /* C3  DINGBAT CIRCLED SANS-SERIF DIGIT FOUR */
    0x2784,       /* C4  DINGBAT CIRCLED SANS-SERIF DIGIT FIVE */
    0x2785,       /* C5  DINGBAT CIRCLED SANS-SERIF DIGIT SIX */
    0x2786,       /* C6  DINGBAT CIRCLED SANS-SERIF DIGIT SEVEN */
    0x2787,       /* C7  DINGBAT CIRCLED SANS-SERIF DIGIT EIGHT */
    0x2788,       /* C8  DINGBAT CIRCLED SANS-SERIF DIGIT NINE */
    0x2789,       /* C9  DINGBAT CIRCLED SANS-SERIF NUMBER TEN */
    0x278A,       /* CA  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT ONE */
    0x278B,       /* CB  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT TWO */
    0x278C,       /* CC  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT THREE */
    0x278D,       /* CD  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT FOUR */
    0x278E,       /* CE  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT FIVE */
    0x278F,       /* CF  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT SIX */
    0x2790,       /* D0  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT SEVEN */
    0x2791,       /* D1  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT EIGHT */
    0x2792,       /* D2  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT NINE */
    0x2793,       /* D3  DINGBAT NEGATIVE CIRCLED SANS-SERIF NUMBER TEN */
    0x2794,       /* D4  HEAVY WIDE-HEADED RIGHTWARDS ARROW */
    0x2192,       /* D5  RIGHTWARDS ARROW */
    0x2194,       /* D6  LEFT RIGHT ARROW */
    0x2195,       /* D7  UP DOWN ARROW */
    0x2798,       /* D8  HEAVY SOUTH EAST ARROW */
    0x2799,       /* D9  HEAVY RIGHTWARDS ARROW */
    0x279A,       /* DA  HEAVY NORTH EAST ARROW */
    0x279B,       /* DB  DRAFTING POINT RIGHTWARDS ARROW */
    0x279C,       /* DC  HEAVY ROUND-TIPPED RIGHTWARDS ARROW */
    0x279D,       /* DD  TRIANGLE-HEADED RIGHTWARDS ARROW */
    0x279E,       /* DE  HEAVY TRIANGLE-HEADED RIGHTWARDS ARROW */
    0x279F,       /* DF  DASHED TRIANGLE-HEADED RIGHTWARDS ARROW */
    0x27A0,       /* E0  HEAVY DASHED TRIANGLE-HEADED RIGHTWARDS ARROW */
    0x27A1,       /* E1  BLACK RIGHTWARDS ARROW */
    0x27A2,       /* E2  THREE-D TOP-LIGHTED RIGHTWARDS ARROWHEAD */
    0x27A3,       /* E3  THREE-D BOTTOM-LIGHTED RIGHTWARDS ARROWHEAD */
    0x27A4,       /* E4  BLACK RIGHTWARDS ARROWHEAD */
    0x27A5,       /* E5  HEAVY BLACK CURVED DOWNWARDS AND RIGHTWARDS ARROW */
    0x27A6,       /* E6  HEAVY BLACK CURVED UPWARDS AND RIGHTWARDS ARROW */
    0x27A7,       /* E7  SQUAT BLACK RIGHTWARDS ARROW */
    0x27A8,       /* E8  HEAVY CONCAVE-POINTED BLACK RIGHTWARDS ARROW */
    0x27A9,       /* E9  RIGHT-SHADED WHITE RIGHTWARDS ARROW */
    0x27AA,       /* EA  LEFT-SHADED WHITE RIGHTWARDS ARROW */
    0x27AB,       /* EB  BACK-TILTED SHADOWED WHITE RIGHTWARDS ARROW */
    0x27AC,       /* EC  FRONT-TILTED SHADOWED WHITE RIGHTWARDS ARROW */
    0x27AD,       /* ED  HEAVY LOWER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW */
    0x27AE,       /* EE  HEAVY UPPER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW */
    0x27AF,       /* EF  NOTCHED LOWER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW */
    .undefined,   /* F0 */
    0x27B1,       /* F1  NOTCHED UPPER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW */
    0x27B2,       /* F2  CIRCLED HEAVY WHITE RIGHTWARDS ARROW */
    0x27B3,       /* F3  WHITE-FEATHERED RIGHTWARDS ARROW */
    0x27B4,       /* F4  BLACK-FEATHERED SOUTH EAST ARROW */
    0x27B5,       /* F5  BLACK-FEATHERED RIGHTWARDS ARROW */
    0x27B6,       /* F6  BLACK-FEATHERED NORTH EAST ARROW */
    0x27B7,       /* F7  HEAVY BLACK-FEATHERED SOUTH EAST ARROW */
    0x27B8,       /* F8  HEAVY BLACK-FEATHERED RIGHTWARDS ARROW */
    0x27B9,       /* F9  HEAVY BLACK-FEATHERED NORTH EAST ARROW */
    0x27BA,       /* FA  TEARDROP-BARBED RIGHTWARDS ARROW */
    0x27BB,       /* FB  HEAVY TEARDROP-SHANKED RIGHTWARDS ARROW */
    0x27BC,       /* FC  WEDGE-TAILED RIGHTWARDS ARROW */
    0x27BD,       /* FD  HEAVY WEDGE-TAILED RIGHTWARDS ARROW */
    0x27BE,       /* FE  OPEN-OUTLINED RIGHTWARDS ARROW */
    .undefined,   /* FF */
]

let uvsToMacDingbats: [UVBMP: CharCode] = [
    0x0020:       0x20, /*  SPACE */
    0x2701:       0x21, /*  UPPER BLADE SCISSORS */
    0x2702:       0x22, /*  BLACK SCISSORS */
    0x2703:       0x23, /*  LOWER BLADE SCISSORS */
    0x2704:       0x24, /*  WHITE SCISSORS */
    0x260E:       0x25, /*  BLACK TELEPHONE */
    0x2706:       0x26, /*  TELEPHONE LOCATION SIGN */
    0x2707:       0x27, /*  TAPE DRIVE */
    0x2708:       0x28, /*  AIRPLANE */
    0x2709:       0x29, /*  ENVELOPE */
    0x261B:       0x2A, /*  BLACK RIGHT POINTING INDEX */
    0x261E:       0x2B, /*  WHITE RIGHT POINTING INDEX */
    0x270C:       0x2C, /*  VICTORY HAND */
    0x270D:       0x2D, /*  WRITING HAND */
    0x270E:       0x2E, /*  LOWER RIGHT PENCIL */
    0x270F:       0x2F, /*  PENCIL */
    0x2710:       0x30, /*  UPPER RIGHT PENCIL */
    0x2711:       0x31, /*  WHITE NIB */
    0x2712:       0x32, /*  BLACK NIB */
    0x2713:       0x33, /*  CHECK MARK */
    0x2714:       0x34, /*  HEAVY CHECK MARK */
    0x2715:       0x35, /*  MULTIPLICATION X */
    0x2716:       0x36, /*  HEAVY MULTIPLICATION X */
    0x2717:       0x37, /*  BALLOT X */
    0x2718:       0x38, /*  HEAVY BALLOT X */
    0x2719:       0x39, /*  OUTLINED GREEK CROSS */
    0x271A:       0x3A, /*  HEAVY GREEK CROSS */
    0x271B:       0x3B, /*  OPEN CENTRE CROSS */
    0x271C:       0x3C, /*  HEAVY OPEN CENTRE CROSS */
    0x271D:       0x3D, /*  LATIN CROSS */
    0x271E:       0x3E, /*  SHADOWED WHITE LATIN CROSS */
    0x271F:       0x3F, /*  OUTLINED LATIN CROSS */
    0x2720:       0x40, /*  MALTESE CROSS */
    0x2721:       0x41, /*  STAR OF DAVID */
    0x2722:       0x42, /*  FOUR TEARDROP-SPOKED ASTERISK */
    0x2723:       0x43, /*  FOUR BALLOON-SPOKED ASTERISK */
    0x2724:       0x44, /*  HEAVY FOUR BALLOON-SPOKED ASTERISK */
    0x2725:       0x45, /*  FOUR CLUB-SPOKED ASTERISK */
    0x2726:       0x46, /*  BLACK FOUR POINTED STAR */
    0x2727:       0x47, /*  WHITE FOUR POINTED STAR */
    0x2605:       0x48, /*  BLACK STAR */
    0x2729:       0x49, /*  STRESS OUTLINED WHITE STAR */
    0x272A:       0x4A, /*  CIRCLED WHITE STAR */
    0x272B:       0x4B, /*  OPEN CENTRE BLACK STAR */
    0x272C:       0x4C, /*  BLACK CENTRE WHITE STAR */
    0x272D:       0x4D, /*  OUTLINED BLACK STAR */
    0x272E:       0x4E, /*  HEAVY OUTLINED BLACK STAR */
    0x272F:       0x4F, /*  PINWHEEL STAR */
    0x2730:       0x50, /*  SHADOWED WHITE STAR */
    0x2731:       0x51, /*  HEAVY ASTERISK */
    0x2732:       0x52, /*  OPEN CENTRE ASTERISK */
    0x2733:       0x53, /*  EIGHT SPOKED ASTERISK */
    0x2734:       0x54, /*  EIGHT POINTED BLACK STAR */
    0x2735:       0x55, /*  EIGHT POINTED PINWHEEL STAR */
    0x2736:       0x56, /*  SIX POINTED BLACK STAR */
    0x2737:       0x57, /*  EIGHT POINTED RECTILINEAR BLACK STAR */
    0x2738:       0x58, /*  HEAVY EIGHT POINTED RECTILINEAR BLACK STAR */
    0x2739:       0x59, /*  TWELVE POINTED BLACK STAR */
    0x273A:       0x5A, /*  SIXTEEN POINTED ASTERISK */
    0x273B:       0x5B, /*  TEARDROP-SPOKED ASTERISK */
    0x273C:       0x5C, /*  OPEN CENTRE TEARDROP-SPOKED ASTERISK */
    0x273D:       0x5D, /*  HEAVY TEARDROP-SPOKED ASTERISK */
    0x273E:       0x5E, /*  SIX PETALLED BLACK AND WHITE FLORETTE */
    0x273F:       0x5F, /*  BLACK FLORETTE */
    0x2740:       0x60, /*  WHITE FLORETTE */
    0x2741:       0x61, /*  EIGHT PETALLED OUTLINED BLACK FLORETTE */
    0x2742:       0x62, /*  CIRCLED OPEN CENTRE EIGHT POINTED STAR */
    0x2743:       0x63, /*  HEAVY TEARDROP-SPOKED PINWHEEL ASTERISK */
    0x2744:       0x64, /*  SNOWFLAKE */
    0x2745:       0x65, /*  TIGHT TRIFOLIATE SNOWFLAKE */
    0x2746:       0x66, /*  HEAVY CHEVRON SNOWFLAKE */
    0x2747:       0x67, /*  SPARKLE */
    0x2748:       0x68, /*  HEAVY SPARKLE */
    0x2749:       0x69, /*  BALLOON-SPOKED ASTERISK */
    0x274A:       0x6A, /*  EIGHT TEARDROP-SPOKED PROPELLER ASTERISK */
    0x274B:       0x6B, /*  HEAVY EIGHT TEARDROP-SPOKED PROPELLER ASTERISK */
    0x25CF:       0x6C, /*  BLACK CIRCLE */
    0x274D:       0x6D, /*  SHADOWED WHITE CIRCLE */
    0x25A0:       0x6E, /*  BLACK SQUARE */
    0x274F:       0x6F, /*  LOWER RIGHT DROP-SHADOWED WHITE SQUARE */
    0x2750:       0x70, /*  UPPER RIGHT DROP-SHADOWED WHITE SQUARE */
    0x2751:       0x71, /*  LOWER RIGHT SHADOWED WHITE SQUARE */
    0x2752:       0x72, /*  UPPER RIGHT SHADOWED WHITE SQUARE */
    0x25B2:       0x73, /*  BLACK UP-POINTING TRIANGLE */
    0x25BC:       0x74, /*  BLACK DOWN-POINTING TRIANGLE */
    0x25C6:       0x75, /*  BLACK DIAMOND */
    0x2756:       0x76, /*  BLACK DIAMOND MINUS WHITE X */
    0x25D7:       0x77, /*  RIGHT HALF BLACK CIRCLE */
    0x2758:       0x78, /*  LIGHT VERTICAL BAR */
    0x2759:       0x79, /*  MEDIUM VERTICAL BAR */
    0x275A:       0x7A, /*  HEAVY VERTICAL BAR */
    0x275B:       0x7B, /*  HEAVY SINGLE TURNED COMMA QUOTATION MARK ORNAMENT */
    0x275C:       0x7C, /*  HEAVY SINGLE COMMA QUOTATION MARK ORNAMENT */
    0x275D:       0x7D, /*  HEAVY DOUBLE TURNED COMMA QUOTATION MARK ORNAMENT */
    0x275E:       0x7E, /*  HEAVY DOUBLE COMMA QUOTATION MARK ORNAMENT */
    0x2768:       0x80, /*  MEDIUM LEFT PARENTHESIS ORNAMENT # for Unicode 3.2 and later */
    0x2769:       0x81, /*  MEDIUM RIGHT PARENTHESIS ORNAMENT # for Unicode 3.2 and later */
    0x276A:       0x82, /*  MEDIUM FLATTENED LEFT PARENTHESIS ORNAMENT # for Unicode 3.2 and later */
    0x276B:       0x83, /*  MEDIUM FLATTENED RIGHT PARENTHESIS ORNAMENT # for Unicode 3.2 and later */
    0x276C:       0x84, /*  MEDIUM LEFT-POINTING ANGLE BRACKET ORNAMENT # for Unicode 3.2 and later */
    0x276D:       0x85, /*  MEDIUM RIGHT-POINTING ANGLE BRACKET ORNAMENT # for Unicode 3.2 and later */
    0x276E:       0x86, /*  HEAVY LEFT-POINTING ANGLE QUOTATION MARK ORNAMENT # for Unicode 3.2 and later */
    0x276F:       0x87, /*  HEAVY RIGHT-POINTING ANGLE QUOTATION MARK ORNAMENT # for Unicode 3.2 and later */
    0x2770:       0x88, /*  HEAVY LEFT-POINTING ANGLE BRACKET ORNAMENT # for Unicode 3.2 and later */
    0x2771:       0x89, /*  HEAVY RIGHT-POINTING ANGLE BRACKET ORNAMENT # for Unicode 3.2 and later */
    0x2772:       0x8A, /*  LIGHT LEFT TORTOISE SHELL BRACKET ORNAMENT # for Unicode 3.2 and later */
    0x2773:       0x8B, /*  LIGHT RIGHT TORTOISE SHELL BRACKET ORNAMENT # for Unicode 3.2 and later */
    0x2774:       0x8C, /*  MEDIUM LEFT CURLY BRACKET ORNAMENT # for Unicode 3.2 and later */
    0x2775:       0x8D, /*  MEDIUM RIGHT CURLY BRACKET ORNAMENT # for Unicode 3.2 and later */
    0x2761:       0xA1, /*  CURVED STEM PARAGRAPH SIGN ORNAMENT */
    0x2762:       0xA2, /*  HEAVY EXCLAMATION MARK ORNAMENT */
    0x2763:       0xA3, /*  HEAVY HEART EXCLAMATION MARK ORNAMENT */
    0x2764:       0xA4, /*  HEAVY BLACK HEART */
    0x2765:       0xA5, /*  ROTATED HEAVY BLACK HEART BULLET */
    0x2766:       0xA6, /*  FLORAL HEART */
    0x2767:       0xA7, /*  ROTATED FLORAL HEART BULLET */
    0x2663:       0xA8, /*  BLACK CLUB SUIT */
    0x2666:       0xA9, /*  BLACK DIAMOND SUIT */
    0x2665:       0xAA, /*  BLACK HEART SUIT */
    0x2660:       0xAB, /*  BLACK SPADE SUIT */
    0x2460:       0xAC, /*  CIRCLED DIGIT ONE */
    0x2461:       0xAD, /*  CIRCLED DIGIT TWO */
    0x2462:       0xAE, /*  CIRCLED DIGIT THREE */
    0x2463:       0xAF, /*  CIRCLED DIGIT FOUR */
    0x2464:       0xB0, /*  CIRCLED DIGIT FIVE */
    0x2465:       0xB1, /*  CIRCLED DIGIT SIX */
    0x2466:       0xB2, /*  CIRCLED DIGIT SEVEN */
    0x2467:       0xB3, /*  CIRCLED DIGIT EIGHT */
    0x2468:       0xB4, /*  CIRCLED DIGIT NINE */
    0x2469:       0xB5, /*  CIRCLED NUMBER TEN */
    0x2776:       0xB6, /*  DINGBAT NEGATIVE CIRCLED DIGIT ONE */
    0x2777:       0xB7, /*  DINGBAT NEGATIVE CIRCLED DIGIT TWO */
    0x2778:       0xB8, /*  DINGBAT NEGATIVE CIRCLED DIGIT THREE */
    0x2779:       0xB9, /*  DINGBAT NEGATIVE CIRCLED DIGIT FOUR */
    0x277A:       0xBA, /*  DINGBAT NEGATIVE CIRCLED DIGIT FIVE */
    0x277B:       0xBB, /*  DINGBAT NEGATIVE CIRCLED DIGIT SIX */
    0x277C:       0xBC, /*  DINGBAT NEGATIVE CIRCLED DIGIT SEVEN */
    0x277D:       0xBD, /*  DINGBAT NEGATIVE CIRCLED DIGIT EIGHT */
    0x277E:       0xBE, /*  DINGBAT NEGATIVE CIRCLED DIGIT NINE */
    0x277F:       0xBF, /*  DINGBAT NEGATIVE CIRCLED NUMBER TEN */
    0x2780:       0xC0, /*  DINGBAT CIRCLED SANS-SERIF DIGIT ONE */
    0x2781:       0xC1, /*  DINGBAT CIRCLED SANS-SERIF DIGIT TWO */
    0x2782:       0xC2, /*  DINGBAT CIRCLED SANS-SERIF DIGIT THREE */
    0x2783:       0xC3, /*  DINGBAT CIRCLED SANS-SERIF DIGIT FOUR */
    0x2784:       0xC4, /*  DINGBAT CIRCLED SANS-SERIF DIGIT FIVE */
    0x2785:       0xC5, /*  DINGBAT CIRCLED SANS-SERIF DIGIT SIX */
    0x2786:       0xC6, /*  DINGBAT CIRCLED SANS-SERIF DIGIT SEVEN */
    0x2787:       0xC7, /*  DINGBAT CIRCLED SANS-SERIF DIGIT EIGHT */
    0x2788:       0xC8, /*  DINGBAT CIRCLED SANS-SERIF DIGIT NINE */
    0x2789:       0xC9, /*  DINGBAT CIRCLED SANS-SERIF NUMBER TEN */
    0x278A:       0xCA, /*  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT ONE */
    0x278B:       0xCB, /*  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT TWO */
    0x278C:       0xCC, /*  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT THREE */
    0x278D:       0xCD, /*  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT FOUR */
    0x278E:       0xCE, /*  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT FIVE */
    0x278F:       0xCF, /*  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT SIX */
    0x2790:       0xD0, /*  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT SEVEN */
    0x2791:       0xD1, /*  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT EIGHT */
    0x2792:       0xD2, /*  DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT NINE */
    0x2793:       0xD3, /*  DINGBAT NEGATIVE CIRCLED SANS-SERIF NUMBER TEN */
    0x2794:       0xD4, /*  HEAVY WIDE-HEADED RIGHTWARDS ARROW */
    0x2192:       0xD5, /*  RIGHTWARDS ARROW */
    0x2194:       0xD6, /*  LEFT RIGHT ARROW */
    0x2195:       0xD7, /*  UP DOWN ARROW */
    0x2798:       0xD8, /*  HEAVY SOUTH EAST ARROW */
    0x2799:       0xD9, /*  HEAVY RIGHTWARDS ARROW */
    0x279A:       0xDA, /*  HEAVY NORTH EAST ARROW */
    0x279B:       0xDB, /*  DRAFTING POINT RIGHTWARDS ARROW */
    0x279C:       0xDC, /*  HEAVY ROUND-TIPPED RIGHTWARDS ARROW */
    0x279D:       0xDD, /*  TRIANGLE-HEADED RIGHTWARDS ARROW */
    0x279E:       0xDE, /*  HEAVY TRIANGLE-HEADED RIGHTWARDS ARROW */
    0x279F:       0xDF, /*  DASHED TRIANGLE-HEADED RIGHTWARDS ARROW */
    0x27A0:       0xE0, /*  HEAVY DASHED TRIANGLE-HEADED RIGHTWARDS ARROW */
    0x27A1:       0xE1, /*  BLACK RIGHTWARDS ARROW */
    0x27A2:       0xE2, /*  THREE-D TOP-LIGHTED RIGHTWARDS ARROWHEAD */
    0x27A3:       0xE3, /*  THREE-D BOTTOM-LIGHTED RIGHTWARDS ARROWHEAD */
    0x27A4:       0xE4, /*  BLACK RIGHTWARDS ARROWHEAD */
    0x27A5:       0xE5, /*  HEAVY BLACK CURVED DOWNWARDS AND RIGHTWARDS ARROW */
    0x27A6:       0xE6, /*  HEAVY BLACK CURVED UPWARDS AND RIGHTWARDS ARROW */
    0x27A7:       0xE7, /*  SQUAT BLACK RIGHTWARDS ARROW */
    0x27A8:       0xE8, /*  HEAVY CONCAVE-POINTED BLACK RIGHTWARDS ARROW */
    0x27A9:       0xE9, /*  RIGHT-SHADED WHITE RIGHTWARDS ARROW */
    0x27AA:       0xEA, /*  LEFT-SHADED WHITE RIGHTWARDS ARROW */
    0x27AB:       0xEB, /*  BACK-TILTED SHADOWED WHITE RIGHTWARDS ARROW */
    0x27AC:       0xEC, /*  FRONT-TILTED SHADOWED WHITE RIGHTWARDS ARROW */
    0x27AD:       0xED, /*  HEAVY LOWER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW */
    0x27AE:       0xEE, /*  HEAVY UPPER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW */
    0x27AF:       0xEF, /*  NOTCHED LOWER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW */
    0x27B1:       0xF1, /*  NOTCHED UPPER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW */
    0x27B2:       0xF2, /*  CIRCLED HEAVY WHITE RIGHTWARDS ARROW */
    0x27B3:       0xF3, /*  WHITE-FEATHERED RIGHTWARDS ARROW */
    0x27B4:       0xF4, /*  BLACK-FEATHERED SOUTH EAST ARROW */
    0x27B5:       0xF5, /*  BLACK-FEATHERED RIGHTWARDS ARROW */
    0x27B6:       0xF6, /*  BLACK-FEATHERED NORTH EAST ARROW */
    0x27B7:       0xF7, /*  HEAVY BLACK-FEATHERED SOUTH EAST ARROW */
    0x27B8:       0xF8, /*  HEAVY BLACK-FEATHERED RIGHTWARDS ARROW */
    0x27B9:       0xF9, /*  HEAVY BLACK-FEATHERED NORTH EAST ARROW */
    0x27BA:       0xFA, /*  TEARDROP-BARBED RIGHTWARDS ARROW */
    0x27BB:       0xFB, /*  HEAVY TEARDROP-SHANKED RIGHTWARDS ARROW */
    0x27BC:       0xFC, /*  WEDGE-TAILED RIGHTWARDS ARROW */
    0x27BD:       0xFD, /*  HEAVY WEDGE-TAILED RIGHTWARDS ARROW */
    0x27BE:       0xFE, /*  OPEN-OUTLINED RIGHTWARDS ARROW */
]
