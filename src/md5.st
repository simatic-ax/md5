USING System.Strings;

NAMESPACE hash

/// MD5 Hashing Class
/// Implements the MD5 hashing algorithm to generate a 128-bit hash.
CLASS md5
    VAR 
        A, B, C, D : DWORD;     // MD5 buffer registers (128-bit state divided into 4 DWORDs)
        AA, BB, CC, DD : DWORD; // Temporary variables used to store intermediate values during processing
    
        M : ARRAY[0..15] OF DWORD;  // Array to store the 512-bit message block split into 16 DWORDs
    
        PaddedInput : STRING;               // Input string after padding to fit into 512-bit blocks
        InputLength, PaddedLength : INT;    // Input string length and padded length
        BitLength : DWORD;                  // Input length in bits (needed for MD5 padding)
    
        MD5_T : ARRAY [0..63] OF DWORD := [  // MD5 predefined constants (T-table)
            DWORD#16#d76aa478, DWORD#16#e8c7b756, DWORD#16#242070db, DWORD#16#c1bdceee,
            DWORD#16#f57c0faf, DWORD#16#4787c62a, DWORD#16#a8304613, DWORD#16#fd469501,
            DWORD#16#698098d8, DWORD#16#8b44f7af, DWORD#16#ffff5bb1, DWORD#16#895cd7be,
            DWORD#16#6b901122, DWORD#16#fd987193, DWORD#16#a679438e, DWORD#16#49b40821,
            DWORD#16#f61e2562, DWORD#16#c040b340, DWORD#16#265e5a51, DWORD#16#e9b6c7aa,
            DWORD#16#d62f105d, DWORD#16#02441453, DWORD#16#d8a1e681, DWORD#16#e7d3fbc8,
            DWORD#16#21e1cde6, DWORD#16#c33707d6, DWORD#16#f4d50d87, DWORD#16#455a14ed,
            DWORD#16#a9e3e905, DWORD#16#fcefa3f8, DWORD#16#676f02d9, DWORD#16#8d2a4c8a,
            DWORD#16#fffa3942, DWORD#16#8771f681, DWORD#16#6d9d6122, DWORD#16#fde5380c,
            DWORD#16#a4beea44, DWORD#16#4bdecfa9, DWORD#16#f6bb4b60, DWORD#16#bebfbc70,
            DWORD#16#289b7ec6, DWORD#16#eaa127fa, DWORD#16#d4ef3085, DWORD#16#04881d05,
            DWORD#16#d9d4d039, DWORD#16#e6db99e5, DWORD#16#1fa27cf8, DWORD#16#c4ac5665,
            DWORD#16#f4292244, DWORD#16#432aff97, DWORD#16#ab9423a7, DWORD#16#fc93a039,
            DWORD#16#655b59c3, DWORD#16#8f0ccc92, DWORD#16#ffeff47d, DWORD#16#85845dd1,
            DWORD#16#6fa87e4f, DWORD#16#fe2ce6e0, DWORD#16#a3014314, DWORD#16#4e0811a1,
            DWORD#16#f7537e82, DWORD#16#bd3af235, DWORD#16#2ad7d2bb, DWORD#16#eb86d391
        ];  
    
        MD5_S : ARRAY[0..63] OF INT := [  // MD5 predefined shift amounts for bitwise operations
            7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
            5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
            4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
            6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21
        ];  
    END_VAR

    /// Hashes the input string using the MD5 algorithm and returns the hash as a hexadecimal string.
    METHOD PUBLIC Hash
        VAR_INPUT
            InputString : STRING; // The original input string to be hashed
        END_VAR
        VAR_OUTPUT
            HashOutput : STRING; // The final MD5 hash output as a hexadecimal string
        END_VAR
        VAR_TEMP
            i : INT;
        END_VAR
        
        // Step 1: Initialize MD5 buffer
        A := DWORD#16#67452301;
        B := DWORD#16#EFCDAB89;
        C := DWORD#16#98BADCFE;
        D := DWORD#16#10325476;

        // Step 2: Pad the input string
        this.PadInputString(InputString);

        // Step 3: Process the input in 512-bit blocks
        FOR i := 0 TO LengthOf(PaddedInput) - 1 BY 64 DO
            this.LoadBlock(i);
            this.ProcessBlock();
        END_FOR;

        // Step 4: Convert to hexadecimal string
        HashOutput := Concat(Concat(Concat(this.ConvertToHex(A), this.ConvertToHex(B)), this.ConvertToHex(C)), this.ConvertToHex(D));
    END_METHOD

    /// Pads the input string to ensure it fits into 512-bit blocks as required by MD5.
    METHOD PRIVATE PadInputString
        VAR_INPUT
            inpString : STRING;
        END_VAR
        VAR_TEMP
            i : INT;
        END_VAR
        
        // Compute the padding needed
        InputLength := LengthOf(inpString);
        PaddedLength := TO_INT(TO_DWORD(InputLength + 8) AND DWORD#16#FFFFFFC0) + 56;
        IF PaddedLength < (InputLength + 1) THEN
            PaddedLength := PaddedLength + 64;
        END_IF;

        // Copy original input
        PaddedInput := inpString;

        // Append '1' bit (0x80 in hex)
        PaddedInput[InputLength + 1] := CHAR#16#80;

        // Append '0' bits until 56 bytes (448 bits)
        FOR i := InputLength + 2 TO PaddedLength DO
            PaddedInput[i] := CHAR#16#00;
        END_FOR;

        // Append original message length in bits (little-endian)
        BitLength := TO_DWORD(InputLength * 8);
        PaddedInput[PaddedLength + 1] := TO_CHAR(TO_BYTE(BitLength AND DWORD#16#FF));
        PaddedInput[PaddedLength + 2] := TO_CHAR(TO_BYTE(SHR(BitLength, UINT#8) AND DWORD#16#FF));
        PaddedInput[PaddedLength + 3] := TO_CHAR(TO_BYTE(SHR(BitLength, UINT#16) AND DWORD#16#FF));
        PaddedInput[PaddedLength + 4] := TO_CHAR(TO_BYTE(SHR(BitLength, UINT#24) AND DWORD#16#FF));
    END_METHOD

    /// Loads a 512-bit block of the padded input string into the message array (M).
    METHOD PRIVATE LoadBlock
        VAR_INPUT
            StartIndex : INT;
        END_VAR
        VAR_TEMP
            j : INT;
        END_VAR
        
        FOR j := 0 TO 15 DO
            M[j] := TO_DWORD(PaddedInput[StartIndex + j * 4 + 1]) OR 
            SHL(TO_DWORD(PaddedInput[StartIndex + j * 4 + 2]), UINT#8) OR
            SHL(TO_DWORD(PaddedInput[StartIndex + j * 4 + 3]), UINT#16) OR
            SHL(TO_DWORD(PaddedInput[StartIndex + j * 4 + 4]), UINT#24);
        END_FOR;
    END_METHOD

    /// Processes a single 512-bit block using the MD5 transformation algorithm.
    METHOD PRIVATE ProcessBlock
        VAR
            i : INT;
            Temp : DWORD;
        END_VAR
        
        // Copy initial values
        AA := A;
        BB := B;
        CC := C;
        DD := D;

        // Perform MD5 main loop
        FOR i := 0 TO 63 DO
            IF i < 16 THEN
                // Round 1
                A := TO_DWORD(TO_DINT(B) + TO_DINT(ROL(TO_DWORD(TO_DINT(A) + TO_DINT(this.F(B, C, D)) + TO_DINT(M[i MOD 16]) + TO_DINT(MD5_T[i])), TO_UINT(MD5_S[i]))));
            ELSIF i < 32 THEN
                // Round 2
                A := TO_DWORD(TO_DINT(B) + TO_DINT(ROL(TO_DWORD(TO_DINT(A) + TO_DINT(this.G(B, C, D)) + TO_DINT(M[(5 * i + 1) MOD 16]) + TO_DINT(MD5_T[i])), TO_UINT(MD5_S[i]))));
            ELSIF i < 48 THEN
                // Round 3
                A := TO_DWORD(TO_DINT(B) + TO_DINT(ROL(TO_DWORD(TO_DINT(A) + TO_DINT(this.H(B, C, D)) + TO_DINT(M[(3 * i + 5) MOD 16]) + TO_DINT(MD5_T[i])), TO_UINT(MD5_S[i]))));
            ELSE
                // Round 4
                A := TO_DWORD(TO_DINT(B) + TO_DINT(ROL(TO_DWORD(TO_DINT(A) + TO_DINT(this.I(B, C, D)) + TO_DINT(M[(7 * i) MOD 16]) + TO_DINT(MD5_T[i])), TO_UINT(MD5_S[i]))));
            END_IF;

            // Perform the rotation
            Temp := A;
            A := D;
            D := C;
            C := B;
            B := Temp;
        END_FOR;

        // Add transformed values to hash buffer
        A := TO_DWORD(TO_DINT(A) + TO_DINT(AA));
        B := TO_DWORD(TO_DINT(B) + TO_DINT(BB));
        C := TO_DWORD(TO_DINT(C) + TO_DINT(CC));
        D := TO_DWORD(TO_DINT(D) + TO_DINT(DD));
    END_METHOD

    /// Converts a DWORD value to an 8-character hexadecimal string.
    METHOD PRIVATE ConvertToHex : STRING
        VAR_INPUT
            Value : DWORD;  // The DWORD value to be converted to a hex string
        END_VAR
        VAR
            Val : DWORD;  // Variable to store byte-swapped DWORD
            HexChars : STRING := '0123456789abcdef';  // Hexadecimal character lookup table
            HexStr : STRING := '';  // Stores the final hex string result
            ByteVal : BYTE;  // Stores extracted byte from DWORD
            i : INT;  // Loop counter for byte processing
            HighNibble : INT;  // Upper 4 bits of the byte (nibble)
            LowNibble : INT;  // Lower 4 bits of the byte (nibble)
        END_VAR

        // Reverse byte order to match expected MD5 output format
        Val := (SHL(Value AND DWORD#16#000000FF, UINT#24)) OR 
                (SHL(Value AND DWORD#16#0000FF00, UINT#8)) OR 
                (SHR(Value AND DWORD#16#00FF0000, UINT#8)) OR 
                (SHR(Value AND DWORD#16#FF000000, UINT#24));
        
        // Convert each byte in the DWORD to hexadecimal
        FOR i := 3 TO 0 BY -1 DO  // Process each byte in DWORD from most to least significant
            ByteVal := TO_BYTE(SHR(Val, TO_UINT(i * 8)) AND DWORD#16#FF);  // Extract each byte
            
            // Extract hex characters from lookup table
            HighNibble := TO_INT(SHR(ByteVal, UINT#4) AND DWORD#16#F);  // Upper 4 bits
            LowNibble := TO_INT(ByteVal AND BYTE#16#F);  // Lower 4 bits
        
            // Append corresponding hex characters to result string
            HexStr := Concat(HexStr, Substring(HexChars, HighNibble + 1, 1));
            HexStr := Concat(HexStr, Substring(HexChars, LowNibble + 1, 1));
        END_FOR;
        
        ConvertToHex := HexStr;  // Return the final hex string
    END_METHOD

    /// Performs the MD5 auxiliary function F(X, Y, Z) = (X AND Y) OR (NOT X AND Z).
    METHOD PRIVATE F : DWORD
        VAR_INPUT
            X, Y, Z : DWORD;
        END_VAR
        F := (X AND Y) OR (NOT X AND Z);
    END_METHOD

    /// Performs the MD5 auxiliary function G(X, Y, Z) = (X AND Z) OR (Y AND NOT Z).
    METHOD PRIVATE G : DWORD
        VAR_INPUT
            X, Y, Z : DWORD;
        END_VAR
        G := (X AND Z) OR (Y AND NOT Z);
    END_METHOD

    /// Performs the MD5 auxiliary function H(X, Y, Z) = X XOR Y XOR Z.
    METHOD PRIVATE H : DWORD
        VAR_INPUT
            X, Y, Z : DWORD;
        END_VAR
        H := X XOR Y XOR Z;
    END_METHOD

    /// Performs the MD5 auxiliary function I(X, Y, Z) = Y XOR (X OR NOT Z).
    METHOD PRIVATE I : DWORD
        VAR_INPUT
            X, Y, Z : DWORD;
        END_VAR
        I := Y XOR (X OR NOT Z);
    END_METHOD
END_CLASS

END_NAMESPACE