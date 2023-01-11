## Description
Collection of custom functions to be used as a library for Bash scripts.

## Functions
* Important
    * Append a Pass or Fail given return code. Call this function inside another function.
    * Save last exit return code, for semi-permanence in verbose functions.

* Input validation
    * Check if variable is null or empty
    * Check if number is valid
    * Check if directory exists
    * Check if file exists
    * Check if command exists

* Device validation
    * Test network connection (URL and DNS)

* File operation
    * Create directory
    * Create file
    * Delete file (or directory)
    * Write input to file*

* User input
    * Read input (Y/n)
    * Read input from range of numbers*
    * Read multiple-choice (ignore-case or match-case)*

## Key
* (*) == out-of-scope; declare variable with exact name before calling the given function

## How-to
Copy the code above to your bash script.

:)