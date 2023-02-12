## Description
Collection of custom functions to be used as a library for Bash scripts.

## Functions
### 0 - User validation
    * Check if current user is sudo or root.

### 1 - Setup and command operation/validation

    * Append a "Pass" or "Fail" given return code.
    * Go to script directory.
    * Parse given return code as boolean.
    * Save last exit return code.
    * Try last action X times before failure. ( Example: useful for important pre-requisites that other actions depend upon )

### 2 - Data-type and variable validation

    * Check if array is empty. ***
    * Check if variable is bool.
    * Check if var is number.
    * Check if var is empty.
    * Check if var is null.
    * Check if string is empty.
    * Check if var is readonly.

### 3 - Process/library validation

    * Check if command is installed.
    * Check if daemon (systemd service) is active.
    * Check if daemon is installed.
    * Check if process is active.

### 4 - File operation and validation

    * Check if file contains given line.
    * Check if directory exists.
    * Check if file exists.
    * Check if file is...
        * executable
        * readable
        * writable
    * Check if two file are the same.
    * Create backup file (up to set value).
    * Create dir.
    * Create file.
    * Delete file (or dir).
    * Print array. ***
    * Print file. ***
    * Read file. ***
    * Restore backup file (up to set value).
    * Write or overwrite file with line(s) (string or array). ***

### 5 - Device validation

    * Find package manager (set global string) by the system Linux distribution.
    * Get status of Internet connection (URL and DNS). Toggle verbosity.
    * Update status of Internet connection and set global bool.

### 6 - User input

    * Read input (Y/n).
    * Read input from range of numbers. *
    * Read multiple-choice (ignore-case or match-case). *

### 7 - Software Validation

    * Check if software package(s) exists within the package repository.
    * Check if system file is original, and reinstall if false (requires connection to package repository).
    * Install software package(s) from the package epository.
    * Uninstall software package(s).
    * Update or Clone a Git repository.

### Global parameters

    * Exit codes, for consistency in catching exceptions, error-checking, etc.
    * Global variable for status of given functions ( Example: Device validation, Software validation).
    * Operation status statements ( Ex: "Pass", "Fail", prefixes and suffixes ).
    

## Key

    (*)     == out-of-scope; call function before calling variable of exact name.
    (***)   == input parameter is a reference ( Example: "variable_name" ), and is not "called" ( Ex: "${variable_name}" ).

## How-to
Copy the code above to your bash script.

## TO-DO

    * remove out-of-scope variables. Replace with references (see Key).
    * test ability to use "source" or ability to call this script, like a using statement for libraries in Compiled languages.