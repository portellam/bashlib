#!/bin/bash sh

### disclaimer ###
#
# Author(s):    Alex Portell <github.com/portellam>
#
###

# <summary> Global parameters </summary>
# <params>
    declare -gl str_package_manager=""

    # <summary> Exit codes </summary>
    declare -gir int_code_var_is_null=255
    declare -gir int_code_var_is_empty=254
    declare -gir int_code_dir_is_null=253
    declare -gir int_code_file_is_null=252
    declare -gir int_code_var_is_NAN=251
    declare -gir int_code_cmd_is_null=251
    declare -gi int_exit_code="$?"

    # <summary> Color coding </summary>
    declare -gr var_reset='\033[0m'
    declare -gr var_red='\033[38;5;2m'
    declare -gr var_green='\033[38;5;2m'
    declare -gr var_yellow='\033[38;5;3m'

    # <summary> Append output </summary>
    declare -gr var_prefix_error="${var_yellow}Error:${var_reset}"
    declare -gr var_prefix_fail="${var_red}Failure:${var_reset}"
    declare -gr var_prefix_pass="${var_green}Success:${var_reset}"
    declare -gr var_prefix_warn="${var_yellow}Warning:${var_reset}"
    declare -gr var_suffix_fail="${var_red}Failure${var_reset}"
    declare -gr var_suffix_pass="${var_green}Success${var_reset}"
    declare -gr str_output_var_is_not_valid="${var_prefix_error} Invalid input."
# </params>

# <summary> Toggle Debug </summary>                             # not working
# <params>
    declare -g bool_debug_is_enabled=false
# </params>
# <code>
    # <summary> Append debug </summary>
    # <param name="$bool_debug_is_enabled"> the toggle </param>
    # <returns> void</returns>
    function ExecuteDebug
    {
        if [[ $bool_debug_is_enabled == true ]]; then
            "$@"
        else
            "$@" >/dev/null 2>&1
        fi
    }
# </code>

# <summary> Important </summary>
# <code>
    # <summary> Append Pass or Fail given exit code. If Fail, call SaveExitCode. </summary>
    # <returns> output statement </returns>
    function AppendPassOrFail
    {
        case "$?" in
            0)
                echo -e $var_suffix_pass
                return 0;;
            *)
                SaveExitCode
                echo -e $var_suffix_fail
                return $int_exit_code;;
        esac
    }

    # <summary> Save last exit code. </summary>
    # <param name="$int_exit_code"> the exit code </param>
    # <returns> void </returns>
    function SaveExitCode
    {
        int_exit_code="$?"
    }

# </code>

# <summary> Input validation </summary>
# <code>
    # <summary> Check if the command is installed. </summary>
    # <param name="$1"> the command </param>
    # <returns> exit code </returns>
    #
    function CheckIfCommandIsInstalled
    {
        # <params>
        local readonly str_output_cmd_is_null="${var_prefix_error} Command '$1' is not installed."
        # </params>

        # <summary> Validation </summary>
        if ! CheckIfVarIsValid $1; then
            return $?
        fi

        if ! CheckIfVarIsValid $( command -v $1 ); then
            echo -e $str_output_cmd_is_null
            return $int_code_cmd_is_null
        fi

        return 0
    }

    # <summary> Check if the value is valid. </summary>
    # <param name="$1"> the value </param>
    # <returns> exit code </returns>
    #
    function CheckIfVarIsValid
    {
        # <params>
        local readonly str_output_var_is_null="${var_prefix_error} Null string."
        local readonly str_output_var_is_empty="${var_prefix_error} Empty string."
        # </params>

        if [[ -z "$1" ]]; then
            echo -e $str_output_var_is_null
            return $int_code_var_is_null
        fi

        if [[ "$1" == "" ]]; then
            echo -e $str_output_var_is_empty
            return $int_code_var_is_empty
        fi

        return 0
    }

    # <summary> Check if the value is a valid number. </summary>
    # <param name="$1"> the value </param>
    # <returns> exit code </returns>
    #
    function CheckIfVarIsNum
    {
        # <params>
        local readonly str_output_var_is_NAN="${var_prefix_error} NaN."
        # </params>

        # <summary> Validation </summary>
        if ! CheckIfVarIsValid $1; then
            return $?
        fi

        # <summary> main </summary>
        case $1 in
            ''|*[!0-9]*)
                echo -e $str_output_var_is_NAN
                return $int_code_var_is_NAN
                ;;
        esac

        return
    }

    # <summary> Check if the directory exists. </summary>
    # <param name="$1"> the value </param>
    # <returns> exit code </returns>
    #
    function CheckIfDirExists
    {
        # <params>
        local readonly str_output_dir_is_null="${var_prefix_error} Directory '$1' does not exist."
        # </params>

        # <summary> Validation </summary>
        if ! CheckIfVarIsValid $1; then
            return $?
        fi

        # <summary> main </summary>
        if [[ ! -d "$1" ]]; then
            echo -e $str_output_dir_is_null
            return $int_code_dir_is_null
        fi

        return
    }

    # <summary> Check if the file exists. </summary>
    # <param name="$1"> the value </param>
    # <returns> exit code </returns>
    #
    function CheckIfFileExists
    {
        # <params>
        local readonly str_output_file_is_null="${var_prefix_error} File '$1' does not exist."
        # </params>

        # <summary> Validation </summary>
        if ! CheckIfVarIsValid $1; then
            return $?
        fi

        # <summary> main </summary>
        if [[ ! -e "$1" ]]; then
            echo -e $str_output_file_is_null
            return $int_code_file_is_null
        fi

        return
    }
# </code>

# <summary> Device validation </summary>
# <code>
    # <summary> Check if current kernel and distro are supported, and if the expected Package Manager is installed. </summary>
    # <returns> exit code </returns>
    function CheckLinuxDistro
    {
        # <params>
        local bool=false
        local readonly str_kernel="$( uname -o )"
        local readonly str_OS="$( lsb_release -is )"
        local str_package_manager=""
        local readonly str_output_distro_is_not_valid="${var_prefix_error} OS '${str_OS}' is not supported."
        local readonly str_output_kernel_is_not_valid="${var_prefix_error} Kernel '${str_kernel}' is not supported."

        local readonly arr_package_managers=(
            "apt"
            "dnf yum"
            "pacman"
            "portage"
            "urpmi"
            "zypper"
        )

        local readonly arr_sort_OS_by_package_manager=(
            # apt       (debian)
            "debian bodhi deepin knoppix mint peppermint pop ubuntu kubuntu lubuntu xubuntu "

            # dnf/yum   (redhat)
            "redhat berry centos cern clearos elastix fedora fermi frameos mageia opensuse oracle scientific suse"

            # pacman    (arch)
            "arch manjaro"

            # # portage   (gentoo)
            # "gentoo"

            # # urpmi     (openSUSE)
            # "opensuse"

            # # zypper
            # "mandriva mageia"
        )
        # </params>

        # <summary> Validation </summary>
        if ! CheckIfVarIsValid $str_kernel; then
            return $?
        fi

        if ! CheckIfVarIsValid $str_OS; then
            return $?
        fi

        if [[ $( echo $str_kernel | tr '[:upper:]' '[:lower:]' ) != *"linux"* ]]; then
            echo -e $str_output_kernel_is_not_valid
            return 1
        fi

        # <summary> Match the package manager with the current distro. If it is installed, return true. Else, false. </summary>
        for var_key in ${!arr_sort_OS_by_package_manager[@]}; do
            local int_delimiter=1
            local var_element1=${arr_sort_OS_by_package_manager[$var_key]}
            local var_element2=$( echo ${arr_package_managers[$var_key]} | cut -d ' ' -f $int_delimiter )

            if [[ "${var_element1}" == *$( echo $str_OS | tr '[:upper:]' '[:lower:]' )* ]]; then
                while CheckIfVarIsValid $var_element2; do
                    if [[ "$?" -eq 0 ]]; then
                        bool=true
                        break
                    fi

                    bool=false
                    $(( int_delimiter++ ))
                done
            fi

            if [[ $bool == true ]]; then
                str_package_manager=$var_element2
                break
            fi
        done

        if [[ $bool == false ]]; then
            echo -e $str_output_distro_is_not_valid
            return 1
        fi

        return
    }

    # <summary> Test network connection to Internet. Ping DNS servers by address and name. </summary>
    # <returns> exit code </returns>
    function TestNetwork
    {
        echo -en "Testing Internet connection...\t"
        ( ping -q -c 1 8.8.8.8 || ping -q -c 1 1.1.1.1 ) || false
        AppendPassOrFail

        echo -en "Testing connection to DNS...\t"
        ( ping -q -c 1 www.google.com && ping -q -c 1 www.yandex.com ) || false
        AppendPassOrFail

        if [[ $int_exit_code -ne 0 ]]; then
            echo -e "Failed to ping Internet/DNS servers. Check network settings or firewall, and try again."
            return $int_exit_code
        fi

        SaveExitCode; return 0
    }
# </code>

# <summary> File operation </summary>
# <code>
    # <summary> Create a directory. </summary>
    # <param name="$1"> the directory </param>
    # <returns> exit code </returns>
    #
    function CreateDir
    {
        # <params>
        local readonly str_output_fail="${var_prefix_fail} Could not create directory '$1'."
        # </params>

        # <summary> Validation </summary>
        if ! CheckIfDirExists $1; then
            return $?
        fi

        # <summary> main </summary>
        mkdir -p $1 || (
            echo -e $str_output_fail
            return 1
        )

        return 0
    }

    # <summary> Create a file. </summary>
    # <param name="$1"> the file </param>
    # <returns> exit code </returns>
    #
    function CreateFile
    {
        # <params>
        local readonly str_output_fail="${var_prefix_fail} Could not create file '$1'."
        # </params>

        # <summary> Validation </summary>
        if CheckIfFileExists $1; then
            return 0
        fi

        # <summary> main </summary>
        touch $1 || (
            echo -e $str_output_fail
            return 1
        )

        return 0
    }

    # <summary> Delete a dir/file. </summary>
    # <param name="$1"> the file </param>
    # <returns> exit code </returns>
    #
    function DeleteFile
    {
        # <params>
        local readonly str_output_fail="${var_prefix_fail} Could not delete file '$1'."
        # </params>

        # <summary> Validation </summary>
        if ! CheckIfFileExists $1; then
            return 0
        fi

        # <summary> main </summary>
        rm $1 || (
            echo -e $str_output_fail
            return 1
        )

        return 0
    }

    # <summary> Write output to a file. Declare '$var_file' before calling this function. </summary>
    # <param name="$1"> the file </param>
    # <param name="$2"> the output </param>
    # <param name="$var_file"> the file contents </param>
    # <returns> exit code </returns>
    #
    function WriteToFile
    {
        # <params>
        local readonly str_output_fail="${var_prefix_fail} Could not write to file '$1'."
        local var_output=$( echo -e "${var_file[@]}" )
        # </params>

        # <summary> Validation </summary>
        if ! CheckIfFileExists $1; then
            return "$?"
        fi

        if ! CheckIfVarIsValid $var_output; then
            return "$?"
        fi

        # <summary> main </summary>
        ( printf "%s\n" "${var_output[@]}" >> $1 ) || (
            echo -e $str_output_fail
            return 1
        )

        return 0
    }
# </code>

# <summary> User input </summary>
# <code>
    # <summary> Ask user Yes/No, read input and return exit code given answer. </summary>
    # <param name="$1"> the (nullable) output statement </param>
    # <returns> exit code </returns>
    #
    function ReadInput
    {
        # <params>
        declare -i int_count=0
        declare -ir int_max_count=3
        local str_output=""
        # </params>

        # <summary> Validation </summary>
        if CheckIfVarIsValid $1; then
            str_output="$1 "
        fi

        declare -r str_output+="${var_green}[Y/n]:${var_reset}"

        while [[ $int_count -le $int_max_count ]]; do

            # <summary> After given number of attempts, input is set to default. </summary>
            if [[ $int_count -ge $int_max_count ]]; then
                echo -e "${var_prefix_warn} Exceeded max attempts. Choice is set to default: N"
                return 1
            fi

            # <summary> Append output. </summary>
            echo -en "${str_output} "
            read var_input
            var_input=$( echo $var_input | tr '[:lower:]' '[:upper:]' )

            # <summary> Check if input is valid. </summary>
            if CheckIfVarIsValid $var_input; then
                case $var_input in
                    "Y")
                        return 0;;
                    "N")
                        return 1;;
                esac
            fi

            # <summary> Input is not valid. </summary>
            echo -e "${str_output_var_is_not_valid}"
            (( int_count++ ))
        done
    }

    # <summary>
    # Ask for a number, within a given range, and return given number.
    # If input is not valid, return minimum value. Declare '$var_input' before calling this function.
    # </summary>
    # <parameter name="$1"> nullable output statement </parameter>
    # <parameter name="$2"> absolute minimum </parameter>
    # <parameter name="$3"> absolute maximum </parameter>
    # <parameter name="$var_input"> the answer </parameter>
    # <returns> $var_input </returns>
    function ReadInputFromRangeOfTwoNums
    {
        # <params>
        declare -i int_count=0
        declare -ir int_max_count=3
        declare -ir int_min=$2
        declare -ir int_max=$3
        local str_output=""
        local readonly str_output_extrema_are_not_valid="${var_prefix_error} Extrema are not valid."
        var_input=""
        # </params>

        # <summary> Validation </summary>
        if ! CheckIfVarIsNum $int_min; then
            echo -e $str_output_extrema_are_not_valid
            return 1
        fi

        if ! CheckIfVarIsNum $int_max; then
            echo -e $str_output_extrema_are_not_valid
            return 1
        fi

        if CheckIfVarIsValid $1; then
            str_output="$1 "
        fi

        readonly str_output+="${var_green}[${int_min}-${int_max}]:${var_reset}"

        # <summary> Read input </summary>
        while [[ $int_count -le $int_max_count ]]; do

            # <summary> After given number of attempts, input is set to first choice. </summary>
            if [[ $int_count -ge $int_max_count ]]; then
                var_input=$int_min
                echo -e "Exceeded max attempts. Choice is set to default: ${var_input}"
                break
            fi

            # <summary> Append output. </summary>
            echo -en "${str_output} "
            read var_input

            # <summary> Check if input is valid. </summary>
            if CheckIfVarIsNum $var_input && [[ $var_input -ge $int_min && $var_input -le $int_max ]]; then
                return 0
            fi

            # <summary> Input is not valid. </summary>
            echo -e "${str_output_var_is_not_valid}"
            (( int_count++ ))
        done

        return 1
    }

    # <summary>
    # Ask user for multiple choice, and return choice given answer.
    # If input is not valid, return first value. Declare '$var_input' before calling this function.
    # </summary>
    # <parameter name="$1"> nullable output statement </parameter>
    # <param name="$2" name="$3" name="$4" name="$5" name="$6" name="$7" name="$8"> multiple choice </param>
    # <param name="$var_input"> the answer </param>
    # <returns> the answer </returns>
    #
    function ReadMultipleChoiceIgnoreCase
    {
        # <params>
        declare -a arr_input=()
        declare -i int_count=0
        declare -ir int_max_count=3
        local str_output=""
        local readonly str_output_multiple_choice_not_valid="${var_prefix_error} Insufficient multiple choice answers."
        var_input=""
        # </params>

        # <summary> Multiple choice validation </summary>
        if CheckIfVarIsValid $2; then
            arr_input+=( $2 )
        else
            echo -e $str_output_multiple_choice_not_valid
            return 1;
        fi

        if CheckIfVarIsValid $3; then
            arr_input+=( $3 )
        else
            echo -e $str_output_multiple_choice_not_valid
            return 1;
        fi

        if CheckIfVarIsValid $4; then arr_input+=( $4 ); fi
        if CheckIfVarIsValid $5; then arr_input+=( $5 ); fi
        if CheckIfVarIsValid $6; then arr_input+=( $6 ); fi
        if CheckIfVarIsValid $7; then arr_input+=( $7 ); fi
        if CheckIfVarIsValid $8; then arr_input+=( $8 ); fi
        if CheckIfVarIsValid $9; then arr_input+=( $9 ); fi

        # <summary> Output statement validation </summary>
        if CheckIfVarIsValid $1; then
            str_output="$1 "
        fi

        readonly str_output+="${var_green}[${arr_input[@]}]:${var_reset}"

        # <summary> Read input </summary>
        while [[ $int_count -le $int_max_count ]]; do

            # <summary> After given number of attempts, input is set to first choice. </summary>
            if [[ $int_count -ge $int_max_count ]]; then
                var_input=${arr_input[0]}
                echo -e "Exceeded max attempts. Choice is set to default: ${var_input}"
                break
            fi

            # <summary> Append output. </summary>
            echo -en "${str_output} "
            read var_input

            # <summary> Check if input is valid. </summary>
            if CheckIfVarIsValid $var_input; then
                var_input=$( echo $var_input | tr '[:lower:]' '[:upper:]' )

                for var_element in ${arr_input[@]}; do
                    if [[ "${var_input}" == $( echo $var_element | tr '[:lower:]' '[:upper:]' ) ]]; then
                        var_input=$var_element
                        return 0
                    fi
                done
            fi

            # <summary> Input is not valid. </summary>
            echo -e "${str_output_var_is_not_valid}"
            (( int_count++ ))
        done

        return 1
    }

    # <summary>
    # Ask user for multiple choice, and return given choice.
    # If input is not valid, return first value.
    # Declare '$var_input' before calling this function.
    # </summary>
    # <parameter name="$1"> nullable output statement </parameter>
    # <param name="$2" name="$3" name="$4" name="$5" name="$6" name="$7" name="$8"> multiple choice </param>
    # <param name="$var_input"> the answer </param>
    # <returns> the answer </returns>
    #
    function ReadMultipleChoiceMatchCase
    {
        # <params>
        declare -a arr_input=()
        declare -i int_count=0
        declare -ir int_max_count=3
        local str_output=""
        local readonly str_output_multiple_choice_not_valid="${var_prefix_error} Insufficient multiple choice answers."
        var_input=""
        # </params>

        # <summary> Multiple choice validation </summary>
        if CheckIfVarIsValid $2; then
            arr_input+=( $2 )
        else
            echo -e $str_output_multiple_choice_not_valid
            return 1;
        fi

        if CheckIfVarIsValid $3; then
            arr_input+=( $3 )
        else
            echo -e $str_output_multiple_choice_not_valid
            return 1;
        fi

        if CheckIfVarIsValid $4; then arr_input+=( $4 ); fi
        if CheckIfVarIsValid $5; then arr_input+=( $5 ); fi
        if CheckIfVarIsValid $6; then arr_input+=( $6 ); fi
        if CheckIfVarIsValid $7; then arr_input+=( $7 ); fi
        if CheckIfVarIsValid $8; then arr_input+=( $8 ); fi
        if CheckIfVarIsValid $9; then arr_input+=( $9 ); fi

        # <summary> Output statement validation </summary>
        if CheckIfVarIsValid $1; then
            str_output="$1 "
        fi

        readonly str_output+="${var_green}[${arr_input[@]}]:${var_reset}"

        # <summary> Read input </summary>
        while [[ $int_count -le $int_max_count ]]; do

            # <summary> After given number of attempts, input is set to first choice. </summary>
            if [[ $int_count -ge $int_max_count ]]; then
                var_input=${arr_input[0]}
                echo -e "Exceeded max attempts. Choice is set to default: ${var_input}"
                break
            fi

            # <summary> Append output. </summary>
            echo -en "${str_output} "
            read var_input

            # <summary> Check if input is valid. </summary>
            if CheckIfVarIsValid $var_input; then
                for var_element in ${arr_input[@]}; do
                    if [[ "${var_input}" == "${var_element}" ]]; then
                        var_input=$var_element
                        return 0
                    fi
                done
            fi

            # <summary> Input is not valid. </summary>
            echo -e "${str_output_var_is_not_valid}"
            (( int_count++ ))
        done

        return 1
    }
# </code>

### debug
#   TODO: test each function!

# ReadInput "Hello world."
# echo $?

# ReadInput
# echo $?

# var_input=""
# ReadInputFromRangeOfTwoNums "Enter an 8-bit value." 0 255
# echo $var_input

# var_input=""
# ReadInputFromRangeOfTwoNums "This range is not correct" "A" "B"
# echo $var_input

# var_input=""
# ReadMultipleChoiceIgnoreCase "Multiple choice." "a" "B" "c"
# echo $var_input

# ReadMultipleChoiceMatchCase "Multiple choice." "a" "B" "c"
# echo $var_input

# str="newfile.txt"
# echo $str

# CreateFile $str
# echo "$?"

# declare -a var_file=( "Hello" "World" )
# WriteToFile $str
# echo "$?"

# cat $str

# DeleteFile $str
# echo "$?"

# TestNetwork

# CheckIfCommandIsInstalled "apt"
# CheckIfCommandIsInstalled "windows-nt"

CheckLinuxDistro      # not working

exit 0

# NOTES
#   function to retry given command x times before giving up
#   example: if a download fails five times, test network, and then quit.
#
#