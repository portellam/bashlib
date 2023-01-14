## Description
Collection of custom functions to be used as a library for Bash scripts.

## Functions
### 1 - Exit codes
    * Append a Pass or Fail given return code. Call this function inside another function.
    * Save last exit return code, for semi-permanence in verbose functions.

### 2 - Data-type and variable validation
    * Check if variable is null or empty.
    * Check if number is valid.
    * Check if directory exists.
    * Check if file exists.
    * Check if command exists.

### 3 - User validation
    * Check if current user is sudo or root.

### 4 - File operation and validation
    * Create directory.
    * Create file.
    * Delete file (or directory).
    * Read from a file.
    * Write input to file.*

### 5 - Device validation
    * Check for current OS and OS kernel, and Package Manager.
    * Test network connection (URL and DNS).

### 6 - User input
    * Read input (Y/n).
    * Read input from range of numbers.*
    * Read multiple-choice (ignore-case or match-case).*


## Key
* (*) == out-of-scope; call function before calling variable of exact name.

## How-to
Copy the code above to your bash script.