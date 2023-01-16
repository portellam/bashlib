## Description
Collection of custom functions to be used as a library for Bash scripts.

## Functions
### 1 - Command operation validation
    * Append a "Pass" or "Fail" given return code.
    * Save last exit return code.
    * Try last action X times before failure. ( Example: useful for important pre-requisites that other actions depend upon )

### 2 - Data-type and variable validation
    * Check if variable is a valid string, null or empty.
    * Check if variable is a valid boolean.
    * Check if variable is a valid number.
    * Check if directory exists.
    * Check if file exists.
    * Check if command exists.
    * Parse last exit code as a boolean.

### 3 - User validation
    * Check if current user is sudo or root.

### 4 - File operation and validation
    * Create directory.
    * Create file.
    * Delete file (or directory).
    * Read from a file.
    * Write input to file.*

### 5 - Device validation
    * Find package manager by the system Linux distribution.
    * Test network connection (URL and DNS). Toggle verbosity.

### 6 - User input
    * Read input (Y/n).
    * Read input from range of numbers.*
    * Read multiple-choice (ignore-case or match-case).*

### 7 - Software Validation
    * Check if software package(s) exists within the package manager repository.
    * Install software package(s) from the package manager repository.
    * Update or Clone a Git repository.

### Global parameters
    * Exit codes, for consistency in catching exceptions, error-checking,etc.
    * Opertation status statements. ( Example: "Pass", "Fail", prefixes and suffixes )

## Key
    (*) == out-of-scope; call function before calling variable of exact name.

## How-to
Copy the code above to your bash script.