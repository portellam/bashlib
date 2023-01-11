#!/bin/bash sh

### disclaimer ###
#
# Author(s):    Alex Portell <github.com/portellam>
#
###

# <summary> Global parameters </summary>
# <params>
    declare -gir int_errorCode_varIsNull=255
    declare -gir int_errorCode_varIsEmpty=254
    declare -gir int_errorCode_dirIsNull=253
    declare -gir int_errorCode_fileIsNull=252
    declare -gir int_errorCode_varIsNAN=251
    declare -gir int_errorCode_cmdIsNull=251
    declare -gi int_exitCode="$?"
    declare -gr str_prefix_error="\e[33mError:\e[0m"
    declare -gr str_prefix_fail="\e[31mFailure:\e[0m"
    declare -gr str_prefix_pass="\e[32mSuccess:\e[0m"
    declare -gr str_prefix_warn="\e[33mWarning:\e[0m"
    declare -gr str_output_varIsNotValid="${str_prefix_error} Invalid input."
    local declare -gl str_packageManager=""
# </params>

# <summary> Important </summary>
# <code>
    # <summary> Append Pass or Fail given exit code. If Fail, call SaveExitCode. </summary>
    # <returns> output statement </returns>
    function AppendPassOrFail
    {
        case "$?" in
            0)
                echo -e "\e[32mPassed.\e[0m"
                return 0;;
            *)
                SaveExitCode
                echo -e "\e[31mFailed.\e[0m"
                return $int_exitCode;;
        esac
    }

    # <summary> Save last exit code. </summary>
    # <param name="$int_exitCode"> the exit code </param>
    # <returns> void </returns>
    function SaveExitCode
    {
        int_exitCode="$?"
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
        local readonly str_output_cmdIsNull="${str_prefix_error} Command '$1' is not installed."
        # </params>

        # <summary> Nested validation </summary>
        CheckIfVarIsValid $1 &> /dev/null

        if [[ "$?" -ne 0 ]]; then
            return $?
        fi

        # <summary> main </summary>
        CheckIfVarIsValid $( command -v $1 ) &> /dev/null

        if [[ "$?" -ne 0 ]]; then
            echo -e $str_output_cmdIsNull
            return $int_errorCode_cmdIsNull
        fi

        return
    }

    # <summary> Check if the value is valid. </summary>
    # <param name="$1"> the value </param>
    # <returns> exit code </returns>
    #
    function CheckIfVarIsValid
    {
        # <params>
        local readonly str_output_varIsNull="${str_prefix_error} Null string."
        local readonly str_output_varIsEmpty="${str_prefix_error} Empty string."
        # </params>

        if [[ -z "$1" ]]; then
            echo -e $str_output_varIsNull
            return $int_errorCode_varIsNull
        fi

        if [[ "$1" == "" ]]; then
            echo -e $str_output_varIsEmpty
            return $int_errorCode_varIsEmpty
        fi

        return "$?"
    }

    # <summary> Check if the value is a valid number. </summary>
    # <param name="$1"> the value </param>
    # <returns> exit code </returns>
    #
    function CheckIfVarIsNum
    {
        # <params>
        local readonly str_output_varIsNAN="${str_prefix_error} NaN."
        # </params>

        # <summary> Nested validation </summary>
        CheckIfVarIsValid $1

        if [[ "$?" -ne 0 ]]; then
            return $?
        fi

        # <summary> main </summary>
        case $1 in
            ''|*[!0-9]*)
                echo -e $str_output_varIsNAN
                return $int_errorCode_varIsNAN
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
        local readonly str_output_dirIsNull="${str_prefix_error} Directory '$1' does not exist."
        # </params>

        # <summary> Nested validation </summary>
        CheckIfVarIsValid $1

        if [[ "$?" -ne 0 ]]; then
            return $?
        fi

        # <summary> main </summary>
        if [[ ! -d "$1" ]]; then
            echo -e $str_output_dirIsNull
            return $int_errorCode_dirIsNull
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
        local readonly str_output_fileIsNull="${str_prefix_error} File '$1' does not exist."
        # </params>

        # <summary> Nested validation </summary>
        CheckIfVarIsValid $1

        if [[ "$?" -ne 0 ]]; then
            return $?
        fi

        # <summary> main </summary>
        if [[ ! -e "$1" ]]; then
            echo -e $str_output_fileIsNull
            return $int_errorCode_fileIsNull
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
        local declare -lr str_kernel=$( uname -o )
        local declare -lr str_OS=$( lsb_release -is )
        # local declare -gl str_packageManager=""

        local readonly str_output_distroIsNotValid="${str_prefix_error} Distribution '${str_OS}' is not supported."
        local readonly str_output_kernelIsNotValid="${str_prefix_error} Kernel '${str_kernel}' is not supported."

        local declare -alr arr_packageManagers=(
            "apt"
            "dnf yum"
            "pacman"
            "portage"
            "urpmi"
            "zypper"
        )

        local declare -alr arr_sortOS_byPackageManager=(
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

        # <summary> Nested validation </summary>
        while [[ "$?" -eq 0 ]]; do
            CheckIfVarIsValid $str_kernel &> /dev/null
            CheckIfVarIsValid $str_OS &> /dev/null
            break
        done

        if [[ "$?" -ne 0 ]]; then
            return $?
        fi

        if [["${str_kernel}" != *"linux"* ]]; then
            echo -e $str_output_kernelIsNotValid
            return 1
        fi

        # <summary> Match the package manager with the current distro. If it is installed, return true. Else, false. </summary>
        for var_key in ${!arr_sortOS_byPackageManager[@]}; do
            local var_element1=${arr_sortOS_byPackageManager[$var_key]}
            local bool=false

            if [[ "${str_OS}" == "${var_element1}" ]]; then
                bool=true
            fi

            while [[ $bool == true ]]; do
                local declare -i int_delimiter=1
                local var_element2=$( echo ${arr_packageManagers[$var_key]} | cut -d ' ' -f $int_delimiter )

                CheckIfVarIsValid $var_element2

                if [[ "$?" -ne 0 ]]; then
                    bool=false
                fi

                CheckIfCommandIsInstalled $var_element2

                if [[ "$?" -eq 0 ]]; then
                    str_packageManager=$var_element2
                    (return 0); break
                fi

                $(( int_delimiter++ ))
                (return 1)
            done

            (return 1)
        done

        if [[ "$?" -ne 0 ]]; then
            echo -e $str_output_distroIsNotValid
            return 1
        fi

        return
    }

    # <summary> Test network connection to Internet. Ping DNS servers by address and name. </summary>
    # <returns> exit code </returns>
    function TestNetwork
    {
        echo -en "Testing Internet connection...\t"
        ( ping -q -c 1 8.8.8.8 &> /dev/null || ping -q -c 1 1.1.1.1 &> /dev/null ) || false
        AppendPassOrFail

        echo -en "Testing connection to DNS...\t"
        ( ping -q -c 1 www.google.com &> /dev/null && ping -q -c 1 www.yandex.com &> /dev/null ) || false
        AppendPassOrFail

        if [[ $int_exitCode -ne 0 ]]; then
            echo -e "Failed to ping Internet/DNS servers. Check network settings or firewall, and try again."
            return $int_exitCode
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
        local readonly str_output_fail="${str_prefix_fail} Could not create directory '$1'."
        # </params>

        # <summary> Nested validation </summary>
        CheckIfDirExists $1

        if [[ "$?" -eq 0 ]]; then
            return "$?"
        fi

        # <summary> main </summary>
        mkdir -p $1 &> /dev/null || (
            echo -e $str_output_fail
            false
        )

        return "$?"
    }

    # <summary> Create a file. </summary>
    # <param name="$1"> the file </param>
    # <returns> exit code </returns>
    #
    function CreateFile
    {
        # <params>
        local readonly str_output_fail="${str_prefix_fail} Could not create file '$1'."
        # </params>

        # <summary> Nested validation; If file does exist, stop. </summary>
        CheckIfFileExists $1 &> /dev/null

        if [[ "$?" -eq 0 ]]; then
            return "$?"
        fi

        # <summary> main </summary>
        touch $1 &> /dev/null || (
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
        local readonly str_output_fail="${str_prefix_fail} Could not delete file '$1'."
        # </params>

        # <summary> Nested validation; If file does not exist, stop. </summary>
        CheckIfFileExists $1 &> /dev/null

        if [[ "$?" -ne 0 ]]; then
            return "$?"
        fi

        # <summary> main </summary>
        rm $1 &> /dev/null || (
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
        local readonly str_output_fail="${str_prefix_fail} Could not write to file '$1'."
        local var_output=$( echo -e "${var_file[@]}" )
        # </params>

        # <summary> Nested validation </summary>
        while [[ "$?" -eq 0 ]]; do
            CheckIfFileExists $1
            CheckIfVarIsValid $var_output
            break
        done

        if [[ "$?" -ne 0 ]]; then
            return "$?"
        fi

        # <summary> main </summary>
        ( printf "%s\n" "${var_output[@]}" >> $1 ) &> /dev/null || (
            echo -e $str_output_fail
            false
        )

        return "$?"
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
        declare -ir int_maxCount=3
        local str_output=""
        # </params>

        # <summary> Nested validation </summary>
        CheckIfVarIsValid $1 &> /dev/null

        if [[ "$?" -eq 0 ]]; then
            str_output="$1 "
        fi

        declare -r str_output+="\e[30;43m[Y/n]:\e[0m"

        while [[ $int_count -le $int_maxCount ]]; do

            # <summary> After given number of attempts, input is set to default. </summary>
            if [[ $int_count -ge $int_maxCount ]]; then
                echo -e "${str_prefix_warn} Exceeded max attempts. Choice is set to default: N"
                return 1
            fi

            # <summary> Append output. </summary>
            echo -en "${str_output} "
            read var_input
            var_input=$( echo $var_input | tr '[:lower:]' '[:upper:]' )

            # <summary> Input validation </summary>
            CheckIfVarIsValid $var_input &> /dev/null

            if [[ "$?" -eq 0 ]]; then

                # <summary> Check if input is valid. </summary>
                case $var_input in
                    "Y")
                        return 0;;
                    "N")
                        return 1;;
                esac
            fi

            # <summary> Input is not valid. </summary>
            echo -e "${str_output_varIsNotValid}"
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
        declare -ir int_maxCount=3
        declare -ir int_min=$2
        declare -ir int_max=$3
        local str_output=""
        var_input=""
        # </params>

        # <summary> Multiple choice validation (mininum is two choices) </summary>
        while [[ "$?" -eq 0 ]]; do
            CheckIfVarIsNum $int_min
            CheckIfVarIsNum $int_max
            break
        done

        if [[ "$?" -ne 0 ]]; then
            return 1
        fi

        # <summary> Output statement validation </summary>
        CheckIfVarIsValid $1 &> /dev/null

        if [[ "$?" -eq 0 ]]; then
            str_output="$1 "
        fi

        readonly str_output+="\e[30;43m[${int_min}-${int_max}]:\e[0m"

        # <summary> Read input </summary>
        while [[ $int_count -le $int_maxCount ]]; do

            # <summary> After given number of attempts, input is set to first choice. </summary>
            if [[ $int_count -ge $int_maxCount ]]; then
                var_input=$int_min
                echo -e "Exceeded max attempts. Choice is set to default: ${var_input}"
                break
            fi

            # <summary> Append output. </summary>
            echo -en "${str_output} "
            read var_input

            # <summary> Input validation </summary>
            CheckIfVarIsNum $var_input &> /dev/null

            if [[ "$?" -eq 0 && $var_input -ge $int_min && $var_input -le $int_max ]]; then
                return 0
            fi

            # <summary> Input is not valid. </summary>
            echo -e "${str_output_varIsNotValid}"
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
        declare -ir int_maxCount=3
        local str_output=""
        var_input=""
        # </params>

        # <summary> Multiple choice validation </summary>
        while [[ "$?" -eq 0 ]]; do
            CheckIfVarIsValid $2 &> /dev/null; arr_input+=( $2 )
            CheckIfVarIsValid $3 &> /dev/null; arr_input+=( $3 )
            CheckIfVarIsValid $3 &> /dev/null; arr_input+=( $4 )
            CheckIfVarIsValid $5 &> /dev/null; arr_input+=( $5 )
            CheckIfVarIsValid $6 &> /dev/null; arr_input+=( $6 )
            CheckIfVarIsValid $7 &> /dev/null; arr_input+=( $7 )
            CheckIfVarIsValid $8 &> /dev/null; arr_input+=( $8 )
            CheckIfVarIsValid $9 &> /dev/null; arr_input+=( $9 )
            break
        done

        if [[ "$?" -ne 0 ]]; then
            return 1
        fi

        # <summary> Output statement validation </summary>
        CheckIfVarIsValid $1 &> /dev/null

        if [[ "$?" -eq 0 ]]; then
            str_output="$1 "
        fi

        readonly str_output+="\e[30;43m[${arr_input[@]}]:\e[0m"

        # <summary> Read input </summary>
        while [[ $int_count -le $int_maxCount ]]; do

            # <summary> After given number of attempts, input is set to first choice. </summary>
            if [[ $int_count -ge $int_maxCount ]]; then
                var_input=${arr_input[0]}
                echo -e "Exceeded max attempts. Choice is set to default: ${var_input}"
                break
            fi

            # <summary> Append output. </summary>
            echo -en "${str_output} "
            read var_input

            # <summary> Input validation </summary>
            CheckIfVarIsValid $var_input &> /dev/null

            if [[ "$?" -eq 0 ]]; then
                var_input=$( echo $var_input | tr '[:lower:]' '[:upper:]' )

                # <summary> Check if input is valid. </summary>
                for var_element in ${arr_input[@]}; do
                    if [[ "${var_input}" == $( echo $var_element | tr '[:lower:]' '[:upper:]' ) ]]; then
                        var_input=$var_element
                        return 0
                    fi
                done
            fi

            # <summary> Input is not valid. </summary>
            echo -e "${str_output_varIsNotValid}"
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
        declare -ir int_maxCount=3
        local str_output=""
        var_input=""
        # </params>

        # <summary> Multiple choice validation </summary>
        while [[ "$?" -eq 0 ]]; do
            CheckIfVarIsValid $2 &> /dev/null; arr_input+=( $2 )
            CheckIfVarIsValid $3 &> /dev/null; arr_input+=( $3 )
            CheckIfVarIsValid $3 &> /dev/null; arr_input+=( $4 )
            CheckIfVarIsValid $5 &> /dev/null; arr_input+=( $5 )
            CheckIfVarIsValid $6 &> /dev/null; arr_input+=( $6 )
            CheckIfVarIsValid $7 &> /dev/null; arr_input+=( $7 )
            CheckIfVarIsValid $8 &> /dev/null; arr_input+=( $8 )
            CheckIfVarIsValid $9 &> /dev/null; arr_input+=( $9 )
            break
        done

        if [[ "$?" -ne 0 ]]; then
            return 1
        fi

        # <summary> Output statement validation </summary>
        CheckIfVarIsValid $1 &> /dev/null

        if [[ "$?" -eq 0 ]]; then
            str_output="$1 "
        fi

        readonly str_output+="\e[30;43m[${arr_input[@]}]:\e[0m"

        # <summary> Read input </summary>
        while [[ $int_count -le $int_maxCount ]]; do

            # <summary> After given number of attempts, input is set to first choice. </summary>
            if [[ $int_count -ge $int_maxCount ]]; then
                var_input=${arr_input[0]}
                echo -en " Exceeded max attempts. Choice is set to default: ${var_input}"
                break
            fi

            # <summary> Append output. </summary>
            echo -en "${str_output} "
            read var_input

            # <summary> Input validation </summary>
            CheckIfVarIsValid $var_input &> /dev/null

            if [[ "$?" -eq 0 ]]; then

                # <summary> Check if input is valid. </summary>
                for var_element in ${arr_input[@]}; do
                    if [[ "${var_input}" == "${var_element}" ]]; then
                        var_input=$var_element
                        return 0
                    fi
                done
            fi

            # <summary> Input is not valid. </summary>
            echo -e "${str_output_varIsNotValid}"
            (( int_count++ ))
        done

        return 1
    }
# </code>

### debug

# ReadInput "Hello world."                                      # works as intended
# echo $?

# var_input="-1"
# ReadInputFromRangeOfTwoNums "Enter an 8-bit value." 0 255     # works as intended
# echo $var_input

# var_input=""
# ReadMultipleChoiceIgnoreCase "Multiple choice." "a" "B" "c"   # works as intended
# echo $var_input

# ReadMultipleChoiceMatchCase "Multiple choice." "a" "B" "c"    # works as intended
# echo $var_input

# str="newfile.txt"
# echo $str

# CreateFile $str                                               # works as intended
# echo "$?"

# # declare -a var_file=( "Hello" "World" )                     # works as intended
# var_file="Hello\nWorld"
# WriteToFile $str

# cat $str

# DeleteFile $str
# echo "$?"

# TestNetwork                                                   # works as intended

# CheckIfCommandIsInstalled "apt"                               # works as intended
# CheckIfCommandIsInstalled "windows-nt"

CheckLinuxDistro        # not working

exit 0