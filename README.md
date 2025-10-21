# MD5 Hashing

This library implements the MD5 hashing algorithm in a PLC-compatible structured text language for Siemens S7-1500 PLCs. The implementation follows the standard MD5 algorithm, processing input strings into 128-bit hash values.

> [!CAUTION]
> Use at your own risk.
> MD5 has been found to suffer from extensive vulnerabilities, and therefore should not be used as a crypthographic hash function! If you need a crypthographic hash funciton, we recommend using a state of the art algorithm. There is also a crypto-library for SIMATIC AX - see [the official documentation](https://docs.industrial-operations-x.siemens.cloud/r/en-us/ax/simatic-1500-crypto/3.0.2/siemens.simatic.s71500.crypto).

## Install this package

Enter:

```cli
apax add @simatic-ax/md5
```

> to install this package you need to login into the GitHub registry. You'll find more information [here](https://github.com/simatic-ax/.github/blob/main/docs/personalaccesstoken.md)

## Usage
1. Call `Hash(InputString := InputText, HashOutput => HashedValue)` with the `inputText` as string to be hashed.
2. The function returns a 32-character hexadecimal MD5 hash and writes it to `HashedValue`.

```iec-st
VAR
    InputText : STRING := 'P@ssw0rd!';  // Example input string
    HashedValue : STRING;               // Variable to hold the hashed output
    hasher : hash.md5;
END_VAR

// Call the Hash method to compute the MD5 hash
md5.Hash(InputString := InputText, HashOutput => HashedValue);
```

## Limitations
- No built-in error handling
- Maximum number of characters to be used in an input string: 247
- Only usable with standard ASCII strings - no complete unicode support (see disclaimer)

When working with strings or passwords that contain special characters such as **`$`**, **`\`** or Unicode characters (e.g., **`é`**, **`ü`**, **non-Latin scripts**, or **emoji**), be aware that PLCs may not handle these characters correctly due to parsing or string handling limitations. In particular:

 - `$$` (double dollar signs) may be misinterpreted or cause parsing issues.
 - `\\` (double backslashes) can be collapsed, rejected, or mishandled if not escaped properly.
 - Unicode characters like `é` may result in inconsistent MD5 hashes due to incorrect or unsupported encoding (e.g., using Latin-1 instead of UTF-8).

**Recommended Workarounds:**

 - Avoid using these characters where possible.
 - Sanitize input strings before passing them into PLC logic.
 - Use UTF-8 encoding consistently when generating MD5 hashes outside the PLC.
 - If needed, consider encoding special characters (e.g., replace `$` with `%24` or use ASCII-based functions like `CharsToString([36])` for `$`).

Always test your string handling on your specific PLC setup to ensure correct behavior.


## Methods
### `Hash(InputString: STRING) : STRING`
Hashes the input string using the MD5 algorithm and returns the computed hash as a hexadecimal string.

### `PadInputString(inpString: STRING)`
Pads the input string to fit into 512-bit blocks as required by MD5.

### `LoadBlock(StartIndex: INT)`
Loads a 512-bit block of the padded input string into the message array.

### `ProcessBlock()`
Processes a single 512-bit block using the MD5 transformation algorithm.

### `ConvertToHex(Value: DWORD) : STRING`
Converts a DWORD value into an 8-character hexadecimal string representation.

### MD5 Auxiliary Functions
- `F(X, Y, Z) : DWORD`
- `G(X, Y, Z) : DWORD`
- `H(X, Y, Z) : DWORD`
- `I(X, Y, Z) : DWORD`
These functions implement the fundamental bitwise operations required for MD5.

## Disclaimer
The code has been tested with unit tests (see test folder) for various cases, but it must be used at your own risk. While functionality has been verified, unforeseen issues or limitations may arise in different configurations, software versions, or for different input strings. It is strongly recommended that the code be thoroughly tested in your own system before being used in production to ensure proper behavior. Any potential issues arising from its use are not the responsibility of the author.

## Contribution
Thanks for your interest in contributing. Anybody is free to report bugs, unclear documentation, and other problems regarding this repository in the Issues section or, even better, is free to propose any changes to this repository using Merge Requests.

## License and Legal information
Please read the [Legal information](license.md)

