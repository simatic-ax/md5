USING System.Strings;

NAMESPACE hash

    {TestFixture}
    CLASS MyTestFixture
        VAR CONSTANT
            NUM_TESTS : INT := 28;
        END_VAR
        VAR
            md5 : md5;
            result : STRING;
            testCases : ARRAY[0..NUM_TESTS-1, 0..1] OF STRING := [
                'hallo', '598d4c200461b81522a3328565c25f7c',
                '', 'd41d8cd98f00b204e9800998ecf8427e',
                'a', '0cc175b9c0f1b6a831c399e269772661',
                'abc', '900150983cd24fb0d6963f7d28e17f72',
                'message digest', 'f96b697d7cb7938d525a2f31aaf161d0',
                'abcdefghijklmnopqrstuvwxyz', 'c3fcd3d76192e4007dfb496cca67e13b',
                'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789', 'd174ab98d277d9f5a5611c2c9f419d9f',
                '12345678901234567890123456789012345678901234567890123456789012345678901234567890', '57edf4a22be3c955ac49da2e2107b67a',
                'ikqwerqwperiuizuzweorzuqwzeruzozuwzqo1234912348jklmnopqrstuvwxyz0123456789ABCDEFGHOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz012', '925de4f62f605e32535f1b2765f5671a',

                // Edge cases
                ' ', '7215ee9c7d9dc229d2921a40e899ec5f',                // single space
                '   ', '628631f07321b22d8c176c200c855e1b',              // three spaces
                '\n', '1d78758685e5e2f4efeeb490f8521abd',               // newline
                'pass\nword', '639b1d3bff100344e40b67a61686ca21',       // newline inside string
                'Hello World', 'b10a8db164e0754105b7a99be72e3fe5',
                'hello world', '5eb63bbbe01eeed093cb22bb8f5acdc3',      // lowercase
                'hello  world', 'fd27fbb9872ba413320c606fdfb98db1',     // double space
                '  hello world  ', 'f92838bb21496410e7c8f8ff8f3b3d7f',  // padded spaces
                'null', '37a6259cc0c1dae299a7866489dff0bd',             // literal "null" string
                'NULL', '6c3e226b4d4795d518ab341b0824ec29',
                '\0', '7309af63395717d5b9f8aa6619301937',               // null byte (if processed as string)

                // Special characters - typical for passwords
                'P@ssw0rd!', '8a24367a1f46c141048752f2d5bbd14b',
                '123456!@#', 'b814b812ec4b322e19fae7bb78d4d330',
                '!@#%^&*()', '171ada0d987a84d6b80d4de7aee2906c',
                '~`<>?/|\', '7c246bacbfb03bca48b920be763afdee',
                'Passw0rd!2024', '0de47a65d90bf01da1cc548929698018',
                '#hashtag', '628ade65edc4b9b46facdf5652f3d51e',
                'letmein123!', '161ad8daea9c525db7acc1b2de10792d',
                'CorrectHorseBatteryStaple!', 'd887e0b4402e96ad0da114d98ba1c9e7'
            ];
        END_VAR

        {Test}
        METHOD PUBLIC myTestCases
            VAR_TEMP
                i : INT;
            END_VAR
            
            FOR i := 0 TO NUM_TESTS-1 DO
                md5.Hash(testCases[i, 0], result);
                AxUnit.myAssert.cmpStrings(actual := result, expected := testCases[i, 1], inp := testCases[i, 0]);
            END_FOR;
        END_METHOD
    END_CLASS    
END_NAMESPACE