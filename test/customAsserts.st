USING AxUnit.ResultFunctions;

NAMESPACE AxUnit.myAssert
    FUNCTION PUBLIC cmpStrings
        VAR_IN_OUT
            actual : STRING;
            expected : STRING;
        END_VAR
        VAR_INPUT
            {CallerFilePath}
            file : WSTRING[1024];
            {CallerLineNumber}
            line : INT;
            inp : STRING;
        END_VAR
        VAR_TEMP
            ret : STRING;
        END_VAR
        

        IF actual = expected THEN
            axunit_Succeed();
        ELSE
            ret := System.Strings.Concat(inp ,': act: ', actual);
            axunit_Fail(ret, file, line);
        END_IF;

    END_FUNCTION
END_NAMESPACE