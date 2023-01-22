#!/bin/bash sh

#
# Author(s):    Alex Portell <github.com/portellam>
#

# <summary> #1 - Command operation and validation, and Miscellaneous </summary>
# <code>
    # <summary> Append Pass or Fail given exit code. </summary>
    # <param name="${int_exit_code}"> the last exit code </param>
    # <param name="${1}"> string: the output statement </param>
    # <returns> output statement </returns>
    function AppendPassOrFail
    {
        SaveExitCode
        CheckIfVarIsValid "${1}" &> /dev/null && echo -en "${1} "

        case "${int_exit_code}" in
            0 )
                echo -e "${var_suffix_pass}"
                ;;

            "${int_code_partial_completion}" )
                echo -e "${var_suffix_maybe}"
                ;;

            "${int_code_skipped_operation}" )
                echo -e "${var_suffix_skip}"
                ;;

            * )
                echo -e "${var_suffix_fail}"
                ;;
        esac

        return "${int_exit_code}"
    }

    # <summary> Redirect current directory to shell script root directory. </summary>
    # <param name="${1}"> string: the shell script name </param>
    # <returns> exit code </returns>
    function GoToScriptDir
    {
        cd $( dirname "${0}" ) || return 1
        return 0
    }

    # <summary> Parse and execute from a list of command(s) </summary>
    # <param name="${1}"> array: the list of command(s) </param>
    # <param name="${2}"> array: the list of output statements for each command call </param>
    # <returns> exit code </returns>
    function ParseAndExecuteListOfCommands
    {
        CheckIfVarIsValid "${1}" || return "${?}"

        # <params>
        local readonly var_delimiter='|'
        declare -a arr_commands=()
        declare -a arr_commands_output=()
        local readonly str_output_fail="${var_prefix_error} Execution of command failed."
        # </params>

        readarray -t -d ${var_delimiter} <<< ${1} &> /dev/null
        readonly arr_commands=( "${MAPFILE[@]}" )
        CheckIfVarIsValid "${arr_commands[@]}" || return "${?}"

        if CheckIfVarIsValid "${2}" &> /dev/null && readarray -t -d ${var_delimiter} <<< ${2} &> /dev/null; then
            readonly arr_commands_output=( "${MAPFILE[@]}" )
        fi

        for int_key in ${!arr_commands[@]}; do
            local var_command="${arr_commands[$int_key]}"
            local var_command_output="${arr_commands_output[$int_key]}"
            local str_output="Execute '${var_command}'?"

            if CheckIfVarIsValid "${var_command_output}" &> /dev/null; then
                str_output="${var_command_output}"
            fi

            if ReadInput "${str_output}"; then
                ( eval "${var_command}" ) || ( SaveExitCode; echo -e "${str_output_fail}" )
            fi
        done

        return "${int_exit_code}"
    }

    # <summary> Save last exit code. </summary>
    # <param name=""${int_exit_code}""> the exit code </param>
    # <returns> void </returns>
    function SaveExitCode
    {
        int_exit_code="${?}"
    }

    # <summary> Attempt given command a given number of times before failure. </summary>
    # <param name="${1}"> string: the command to execute </param>
    # <returns> exit code </returns>
    function TryThisXTimesBeforeFail
    {
        CheckIfVarIsValid "${1}" || return "${?}"

        # <params>
        declare -ir int_min_count=1
        declare -ir int_max_count=3
        declare -ar arr_count=$( eval echo {$int_min_count..$int_max_count} )
        local readonly str_output_fail="${var_prefix_error} Execution of command failed."
        # </params>

        for int_count in ${arr_count[@]}; do
            eval "${1}" && return 0 || echo -e "${str_output_fail}"
        done

        return 1
    }
# </code>

# <summary> #2 - Data-type and variable validation </summary>
# <code>
    # <summary> Check if the command is installed. </summary>
    # <param name="${1}"> string: the command </param>
    # <returns> exit code </returns>
    #
    function CheckIfCommandIsInstalled
    {
        CheckIfVarIsValid "${1}" || return "${?}"

        # <params>
        local readonly str_output_fail="${var_prefix_error} Command '${1}' is not installed."
        local readonly var_actual_install_path=$( command -v "${1}" )
        local readonly var_expected_install_path="/usr/bin/${1}"
        # </params>

        # if $( ! CheckIfFileExists $var_actual_install_path ) &> /dev/null || [[ "${var_actual_install_path}" != "${var_expected_install_path}" ]]; then
        # if ! CheckIfFileExists $var_actual_install_path &> /dev/null; then

        if [[ "${var_actual_install_path}" != "${var_expected_install_path}" ]]; then
            echo -e "${str_output_fail}"
            return "${int_code_cmd_is_null}"
        fi

        return 0
    }

    # <summary> Check if the value is a valid bool. </summary>
    # <param name="${1}"> var: the boolean </param>
    # <returns> exit code </returns>
    #
    function CheckIfVarIsBool
    {
        CheckIfVarIsValid "${1}" || return "${?}"

        # <params>
        local readonly str_output_fail="${var_prefix_error} Not a boolean."
        # </params>

        case "${1}" in
            "true" | "false" )
                return 0
                ;;

            * )
                echo -e "${str_output_fail}"
                return "${int_code_var_is_not_bool}"
                ;;
        esac
    }

    # <summary> Check if the value is a valid number. </summary>
    # <param name="${1}"> var: the number </param>
    # <returns> exit code </returns>
    #
    function CheckIfVarIsNum
    {
        CheckIfVarIsValid "${1}" || return "${?}"

        # <params>
        local readonly str_num_regex='^[0-9]+$'
        local readonly str_output_fail="${var_prefix_error} NaN."
        # </params>

        if ! [[ "${1}" =~ $str_num_regex ]]; then
            echo -e "${str_output_fail}"
            return "${int_code_var_is_NAN}"
        fi

        return 0
    }

    # <summary> Check if the value is valid. </summary>
    # <param name="${1}"> string: the variable </param>
    # <returns> exit code </returns>
    #
    function CheckIfVarIsValid
    {
        # <params>
        local readonly str_output_var_is_null="${var_prefix_error} Null string."
        local readonly str_output_var_is_empty="${var_prefix_error} Empty string."
        # </params>

        if [[ -z "${1}" ]]; then
            echo -e "${str_output_var_is_null}"
            return "${int_code_var_is_null}"
        fi

        if [[ "${1}" == "" ]]; then
            echo -e "${str_output_var_is_empty}"
            return "${int_code_var_is_empty}"
        fi

        return 0
    }

    # <summary> Check if the directory exists. </summary>
    # <param name="${1}"> string: the directory </param>
    # <returns> exit code </returns>
    #
    function CheckIfDirExists
    {
        CheckIfVarIsValid "${1}" || return "${?}"

        # <params>
        local readonly str_output_fail="${var_prefix_error} Directory '${1}' does not exist."
        # </params>

        if [[ ! -d "${1}" ]]; then
            echo -e "${str_output_fail}"
            return "${int_code_dir_is_null}"
        fi

        return 0
    }

    # <summary> Check if the file exists. </summary>
    # <param name="${1}"> string: the file </param>
    # <returns> exit code </returns>
    #
    function CheckIfFileExists
    {
        CheckIfVarIsValid "${1}" || return "${?}"

        # <params>
        local readonly str_output_fail="${var_prefix_error} File '${1}' does not exist."
        # </params>

        if [[ ! -e "${1}" ]]; then
            echo -e "${str_output_fail}"
            return "${int_code_file_is_null}"
        fi

        return 0
    }

    # <summary> Check if the file is executable. </summary>
    # <param name="${1}"> string: the file </param>
    # <returns> exit code </returns>
    #
    function CheckIfFileIsExecutable
    {
        CheckIfFileExists "${1}" || return "${?}"

        # <params>
        local readonly str_output_fail="${var_prefix_error} File '${1}' is not executable."
        # </params>

        if [[ ! -x "${1}" ]]; then
            echo -e "${str_output_fail}"
            return "${int_code_file_is_not_executable}"
        fi

        return 0
    }

    # <summary> Check if the file is readable. </summary>
    # <param name="${1}"> string: the file </param>
    # <returns> exit code </returns>
    #
    function CheckIfFileIsReadable
    {
        CheckIfFileExists "${1}" || return "${?}"

        # <params>
        local readonly str_output_fail="${var_prefix_error} File '${1}' is not readable."
        # </params>

        if [[ ! -r "${1}" ]]; then
            echo -e "${str_output_fail}"
            return "${int_code_file_is_not_readable}"
        fi

        return 0
    }

    # <summary> Check if the file is writable. </summary>
    # <param name="${1}"> string: the file </param>
    # <returns> exit code </returns>
    #
    function CheckIfFileIsWritable
    {
        CheckIfFileExists "${1}" || return "${?}"

        # <params>
        local readonly str_output_fail="${var_prefix_error} File '${1}' is not writable."
        # </params>

        if [[ ! -w "${1}" ]]; then
            echo -e "${str_output_fail}"
            return $int_code_file_is_not_writable
        fi

        return 0
    }

    # <summary> Parse exit code as boolean. If non-zero, return false. </summary>
    # <param name="${?}"> int: the exit code </param>
    # <returns> boolean </returns>
    function ParseExitCodeAsBool
    {
        if [[ "${?}" -ne 0 ]]; then
            echo false
            return 1
        fi

        echo true
        return 0
    }
# </code>

# <summary> #3 - User validation </summary>
# <code>
    # <summary> Check if current user is sudo or root. </summary>
    # <returns> exit code </returns>
    function CheckIfUserIsRoot
    {
        # <params>
        local readonly str_file=$( basename "${0}" )
        local readonly str_output_user_is_not_root="${var_prefix_warn} User is not Sudo/Root. In terminal, enter: ${var_yellow}'sudo bash ${str_file}' ${var_reset_color}"
        # </params>

        if [[ $( whoami ) != "root" ]]; then
            echo -e "${str_output}"_user_is_not_root
            return 1
        fi

        return 0
    }
# </code>

# <summary> #4 - File operation and validation </summary>
# <code>
    # <summary> Check if two given files are the same. </summary>
    # <parameter name="${1}"> string: the file </parameter>
    # <parameter name="${2}"> string: the file </parameter>
    # <returns> exit code </returns>
    function CheckIfTwoFilesAreSame
    {
        ( CheckIfFileExists "${1}" && CheckIfFileExists "${2}" ) || return "${?}"
        cmp -s "${1}" "${2}" || return 1
        return 0
    }

    # <summary> Create latest backup of given file (do not exceed given maximum count). </summary>
    # <parameter name="${1}"> string: the file </parameter>
    # <returns> exit code </returns>
    function CreateBackupFile
    {
        function CreateBackupFile_Main
        {
            CheckIfFileExists "${1}" || return "${?}"

            # <params>
            declare -ir int_max_count=4
            local readonly str_dir1=$( dirname "${1}" )
            local readonly str_suffix=".old"
            local readonly var_command='ls "${str_dir1}" | grep "${1}" | grep $str_suffix | uniq | sort -V'
            declare -a arr_dir1=( $( eval "${var_command}" ) )
            # </params>

            # <summary> Create backup file if none exist. </summary>
            if [[ "${#arr_dir1[@]}" -eq 0 ]]; then
                cp "${1}" "${1}.${var_first_index}${str_suffix}" || return 1
                return 0
            fi

            # <summary> Oldest backup file is same as original file. </summary>
            CheckIfTwoFilesAreSame "${1}" "${arr_dir1[0]}" && return 0

            # <summary> Get index of oldest backup file. </summary>
            local str_oldest_file="${arr_dir1[0]}"
            str_oldest_file="${str_oldest_file%%"${str_suffix}"*}"
            local var_first_index="${str_oldest_file##*.}"
            CheckIfVarIsNum "$var_first_index" || return "${?}"

            # <summary> Delete older backup files, if total matches/exceeds maximum. </summary>
            while [[ "${#arr_dir1[@]}" -gt "$int_max_count" ]]; do
                DeleteFile "${arr_dir1[0]}" || return "${?}"
                arr_dir1=( $( eval "${var_command}" ) )
            done

            # <summary> Increment number of last backup file index. </summary>
            local str_newest_file="${arr_dir1[-1]}"
            str_newest_file="${str_newest_file%%"${str_suffix}"*}"
            local var_last_index="${str_newest_file##*.}"
            CheckIfVarIsNum "${var_last_index}" || return "${?}"
            (( var_last_index++ ))

            # <summary> Newest backup file is different and newer than original file. </summary>
            if ( ! CheckIfTwoFilesAreSame "${1}" "${arr_dir1[-1]}" &> /dev/null ) && [[ "${1}" -nt "${arr_dir1[-1]}" ]]; then
                cp "${1}" "${1}.${var_last_index}${str_suffix}" || return 1
            fi

            return 0
        }

        # <params>
        local readonly str_output="Creating backup file..."
        # </params>

        echo -e "${str_output}"
        CreateBackupFile_Main "${1}"
        AppendPassOrFail "${str_output}"
        return "${int_exit_code}"
    }

    # <summary> Create a directory. </summary>
    # <param name="${1}"> string: the directory </param>
    # <returns> exit code </returns>
    function CreateDir
    {
        CheckIfDirExists "${1}" || return "${?}"

        # <params>
        local readonly str_output_fail="${var_prefix_fail} Could not create directory '${1}'."
        # </params>

        mkdir -p "${1}" || (
            echo -e "${str_output_fail}"
            return 1
        )

        return 0
    }

    # <summary> Create a file. </summary>
    # <param name="${1}"> string: the file </param>
    # <returns> exit code </returns>
    function CreateFile
    {
        CheckIfFileExists "${1}" &> /dev/null && return 0

        # <params>
        local readonly str_output_fail="${var_prefix_fail} Could not create file '${1}'."
        # </params>

        touch "${1}" || (
            echo -e "${str_output_fail}"
            return 1
        )

        return 0
    }

    # <summary> Delete a dir/file. </summary>
    # <param name="${1}"> string: the file </param>
    # <returns> exit code </returns>
    function DeleteFile
    {
        CheckIfFileExists "${1}" || return 0

        # <params>
        local readonly str_output_fail="${var_prefix_fail} Could not delete file '${1}'."
        # </params>

        rm "${1}" || (
            echo -e "${str_output_fail}"
            return 1
        )

        return 0
    }

    # <summary> Read input from a file. Call '$var_file' after calling this function. </summary>
    # <param name="${1}"> string: the file </param>
    # <param name="${2}"> array: the file contents </param>
    # <returns> exit code </returns>
    function ReadFromFile
    {
        CheckIfFileExists "${1}" || return "${?}"

        # <params>
        local readonly str_output_fail="${var_prefix_fail} Could not read from file '${1}'."
        local readonly var_command='cat "${1}"'
        # </params>

        eval "${var_command}" || return 1
        return 0
    }

    # <summary> Restore latest valid backup of given file. </summary>
    # <parameter name="${1}"> string: the file </parameter>
    # <returns> exit code </returns>
    function RestoreBackupFile
    {
        function RestoreBackupFile_Main
        {
            CheckIfFileExists "${1}" || return "${?}"

            # <params>
            local readonly str_dir1=$( dirname "${1}" )
            local readonly str_suffix=".old"
            var_command='ls "${str_dir1}" | grep "${1}" | grep $str_suffix | uniq | sort -rV'
            declare -a arr_dir1=( $( eval "${var_command}" ) )
            # </params>

            CheckIfVarIsValid ${arr_dir1[@]} || return "${?}"

            for var_element1 in ${arr_dir1[@]}; do
                CheckIfFileExists "${var_element1}" && cp "${var_element1}" "${1}" && return 0
            done

            return 1
        }

        # <params>
        local readonly str_output="Restoring backup file..."
        # </params>

        echo -e "${str_output}"
        RestoreBackupFile_Main "${1}"
        AppendPassOrFail "${str_output}"
        return "${int_exit_code}"
    }

    # <summary> Write output to a file. Call '$var_file' after calling this function. </summary>
    # <param name="${1}"> string: the file </param>
    # <param name="${2}"> array: the file contents </param>
    # <returns> exit code </returns>
    function WriteToFile
    {
        CheckIfFileExists "${1}" || return "${?}"

        # <params>
        IFS=$'\n'
        declare -a arr_file=()
        local readonly str_output_fail="${var_prefix_fail} Could not write to file '${1}'."
        local readonly var_delimiter='|'
        # </params>

        if readarray -t -d ${var_delimiter} <<< ${1} &> /dev/null; then
            readonly arr_file=( "${MAPFILE[@]}" )
        fi

        CheckIfVarIsValid "${arr_file[@]}" || return "${?}"

        # ( printf "%s\n" "${arr_file[@]}" >> "${1}" ) || (
        #     echo -e "${str_output_fail}"
        #     return 1
        # )

        for var_element in ${arr_file[@]}; do
            echo -e "${var_element}" >> "${1}" || (
                echo -e "${str_output_fail}"
                return 1
            )
        done

        return 0
    }
# </code>

# <summary> #5 - Device validation </summary>
# <code>
    # <summary> Check if current kernel and distro are supported, and if the expected Package Manager is installed. </summary>
    # <returns> exit code </returns>
    function CheckLinuxDistro
    {
        # <params>
        local readonly str_kernel="$( uname -o | tr '[:upper:]' '[:lower:]' )"
        local readonly str_operating_system="$( lsb_release -is | tr '[:upper:]' '[:lower:]' )"
        local readonly str_output_distro_is_not_valid="${var_prefix_error} Distribution '$( lsb_release -is )' is not supported."
        local readonly str_output_kernel_is_not_valid="${var_prefix_error} Kernel '$( uname -o )' is not supported."
        local readonly str_OS_with_apt="debian bodhi deepin knoppix mint peppermint pop ubuntu kubuntu lubuntu xubuntu "
        local readonly str_OS_with_dnf_yum="redhat berry centos cern clearos elastix fedora fermi frameos mageia opensuse oracle scientific suse"
        local readonly str_OS_with_pacman="arch manjaro"
        local readonly str_OS_with_portage="gentoo"
        local readonly str_OS_with_urpmi="opensuse"
        local readonly str_OS_with_zypper="mandriva mageia"
        # </params>

        ( CheckIfVarIsValid "${str_kernel}" &> /dev/null && CheckIfVarIsValid "${str_operating_system}" &> /dev/null ) || return "${?}"

        if [[ "${str_kernel}" != *"linux"* ]]; then
            echo -e "${str_output_kernel_is_not_valid}"
            return 1
        fi

        # <summary> Check if current Operating System matches Package Manager, and Check if PM is installed. </summary>
        # <returns> exit code </returns>
        function CheckLinuxDistro_GetPackageManagerByOS
        {
            if [[ "${str_OS_with_apt}" =~ .*"${str_operating_system}".* ]]; then
                str_package_manager="apt"

            elif [[ "${str_OS_with_dnf_yum}" =~ .*"${str_operating_system}".* ]]; then
                str_package_manager="dnf"
                CheckIfCommandIsInstalled "${str_package_manager}" &> /dev/null && return 0
                str_package_manager="yum"

            elif [[ "${str_OS_with_pacman}" =~ .*"${str_operating_system}".* ]]; then
                str_package_manager="pacman"

            elif [[ "${str_OS_with_portage}" =~ .*"${str_operating_system}".* ]]; then
                str_package_manager="portage"

            elif [[ "${str_OS_with_urpmi}" =~ .*"${str_operating_system}".* ]]; then
                str_package_manager="urpmi"

            elif [[ "${str_OS_with_zypper}" =~ .*"${str_operating_system}".* ]]; then
                str_package_manager="zypper"

            else
                str_package_manager=""
                return 1
            fi

            CheckIfCommandIsInstalled "${str_package_manager}" &> /dev/null && return 0
            return 1
        }

        if ! CheckLinuxDistro_GetPackageManagerByOS; then
            echo -e "${str_output_distro_is_not_valid}"
            return 1
        fi

        return 0
    }

    # <summary> Test network connection to Internet. Ping DNS servers by address and name. </summary>
    # <param name="${1}"> boolean: true/false set/unset verbosity </param>
    # <returns> exit code </returns>
    function TestNetwork
    {
        # <params>
        local bool=false
        # </params>

        if CheckIfVarIsBool "${1}" &> /dev/null && "${1}"; then
            local bool="${1}"
        fi

        if $bool; then
            echo -en "Testing Internet connection...\t"
        fi

        ( ping -q -c 1 8.8.8.8 || ping -q -c 1 1.1.1.1 ) &> /dev/null || false

        SaveExitCode

        if $bool; then
            ( return "${int_exit_code}" )
            AppendPassOrFail
            echo -en "Testing connection to DNS...\t"
        fi

        ( ping -q -c 1 www.google.com && ping -q -c 1 www.yandex.com ) &> /dev/null || false

        SaveExitCode

        if $bool; then
            ( return "${int_exit_code}" )
            AppendPassOrFail
        fi

        if [[ "${int_exit_code}" -ne 0 ]]; then
            echo -e "Failed to ping Internet/DNS servers. Check network settings or firewall, and try again."
        fi

        return "${int_exit_code}"
    }
# </code>

# <summary> #6 - User input </summary>
# <code>
    # <summary> Ask user Yes/No, read input and return exit code given answer. </summary>
    # <param name="${1}"> string: the output statement </param>
    # <returns> exit code </returns>
    #
    function ReadInput
    {
        # <params>
        declare -ir int_min_count=1
        declare -ir int_max_count=3
        declare -ar arr_count=$( eval echo {$int_min_count..$int_max_count} )
        local str_output=""
        # </params>

        CheckIfVarIsValid "${1}" &> /dev/null && str_output="${1} "
        declare -r str_output+="${var_green}[Y/n]:${var_reset_color}"

        for int_count in ${arr_count[@]}; do

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
        done

        # <summary> After given number of attempts, input is set to default. </summary>
        echo -e "${var_prefix_warn} Exceeded max attempts. Choice is set to default: N"
        return 1
    }

    # <summary>
    # Ask for a number, within a given range, and return given number.
    # If input is not valid, return minimum value. Declare '$var_input' before calling this function.
    # </summary>
    # <parameter name="${1}"> string: the output statement </parameter>
    # <parameter name="${2}"> num: absolute minimum </parameter>
    # <parameter name="${3}"> num: absolute maximum </parameter>
    # <parameter name="$var_input"> the answer </parameter>
    # <returns> $var_input </returns>
    function ReadInputFromRangeOfTwoNums
    {
        # <params>
        declare -ir int_min_count=1
        declare -ir int_max_count=3
        declare -ar arr_count=$( eval echo {$int_min_count..$int_max_count} )
        local readonly var_min=${2}
        local readonly var_max=${3}
        local str_output=""
        local readonly str_output_extrema_are_not_valid="${var_prefix_error} Extrema are not valid."
        var_input=""
        # </params>

        if ( ! CheckIfVarIsNum $var_min || ! CheckIfVarIsNum $var_max ) &> /dev/null; then
            echo -e "${str_output}"_extrema_are_not_valid
            return 1
        fi

        CheckIfVarIsValid "${1}" &> /dev/null && str_output="${1} "

        readonly str_output+="${var_green}[${var_min}-${var_max}]:${var_reset_color}"

        for int_count in ${arr_count[@]}; do

            # <summary> Append output. </summary>
            echo -en "${str_output} "
            read var_input

            # <summary> Check if input is valid. </summary>
            if CheckIfVarIsNum $var_input && [[ $var_input -ge $var_min && $var_input -le $var_max ]]; then
                return 0
            fi

            # <summary> Input is not valid. </summary>
            echo -e "${str_output_var_is_not_valid}"
        done

        var_input=$var_min
        echo -e "Exceeded max attempts. Choice is set to default: ${var_input}"
        return 1
    }

    # <summary>
    # Ask user for multiple choice, and return choice given answer.
    # If input is not valid, return first value. Declare '$var_input' before calling this function.
    # </summary>
    # <parameter name="${1}"> string: the output statement </parameter>
    # <param name="${2}" name="${3}" name="${4}" name="${5}" name="${6}" name="${7}" name="${8}"> multiple choice </param>
    # <param name="$var_input"> the answer </param>
    # <returns> the answer </returns>
    #
    function ReadMultipleChoiceIgnoreCase
    {
        # <params>
        declare -ir int_min_count=1
        declare -ir int_max_count=3
        declare -ar arr_count=$( eval echo {$int_min_count..$int_max_count} )
        declare -a arr_input=()
        local str_output=""
        local readonly str_output_multiple_choice_not_valid="${var_prefix_error} Insufficient multiple choice answers."
        var_input=""
        # </params>

        # <summary> Minimum multiple choice are two answers. </summary>
        if ( ! CheckIfVarIsValid "${2}" || ! CheckIfVarIsValid "${3}" ) &> /dev/null; then
            SaveExitCode
            echo -e "${str_output}"_multiple_choice_not_valid
            return "${int_exit_code}"
        fi

        arr_input+=( "${2}" )
        arr_input+=( "${3}" )

        if CheckIfVarIsValid "${4}" &> /dev/null; then arr_input+=( "${4}" ); fi
        if CheckIfVarIsValid "${5}" &> /dev/null; then arr_input+=( "${5}" ); fi
        if CheckIfVarIsValid "${6}" &> /dev/null; then arr_input+=( "${6}" ); fi
        if CheckIfVarIsValid "${7}" &> /dev/null; then arr_input+=( "${7}" ); fi
        if CheckIfVarIsValid "${8}" &> /dev/null; then arr_input+=( "${8}" ); fi
        if CheckIfVarIsValid "${9}" &> /dev/null; then arr_input+=( "${9}" ); fi

        CheckIfVarIsValid "${1}" &> /dev/null && str_output="${1} "
        readonly str_output+="${var_green}[${arr_input[@]}]:${var_reset_color}"

        for int_count in ${arr_count[@]}; do
            echo -en "${str_output} "
            read var_input

            if CheckIfVarIsValid $var_input; then
                var_input=$( echo $var_input | tr '[:lower:]' '[:upper:]' )

                for var_element in ${arr_input[@]}; do
                    if [[ "${var_input}" == $( echo $var_element | tr '[:lower:]' '[:upper:]' ) ]]; then
                        var_input=$var_element
                        return 0
                    fi
                done
            fi

            echo -e "${str_output_var_is_not_valid}"
        done

        var_input=${arr_input[0]}
        echo -e "Exceeded max attempts. Choice is set to default: ${var_input}"
        return 1
    }

    # <summary>
    # Ask user for multiple choice, and return given choice.
    # If input is not valid, return first value.
    # Declare '$var_input' before calling this function.
    # </summary>
    # <parameter name="${1}"> string: the output statement </parameter>
    # <param name="${2}" name="${3}" name="${4}" name="${5}" name="${6}" name="${7}" name="${8}"> multiple choice </param>
    # <param name="$var_input"> the answer </param>
    # <returns> the answer </returns>
    #
    function ReadMultipleChoiceMatchCase
    {
        # <params>
        declare -ir int_min_count=1
        declare -ir int_max_count=3
        declare -ar arr_count=$( eval echo {$int_min_count..$int_max_count} )
        declare -a arr_input=()
        local str_output=""
        local readonly str_output_multiple_choice_not_valid="${var_prefix_error} Insufficient multiple choice answers."
        var_input=""
        # </params>

        # <summary> Minimum multiple choice are two answers. </summary>
        if ( ! CheckIfVarIsValid "${2}" || ! CheckIfVarIsValid "${3}" ) &> /dev/null; then
            echo -e "${str_output}"_multiple_choice_not_valid
            return 1;
        fi

        arr_input+=( "${2}" )
        arr_input+=( "${3}" )

        if CheckIfVarIsValid "${4}" &> /dev/null; then arr_input+=( "${4}" ); fi
        if CheckIfVarIsValid "${5}" &> /dev/null; then arr_input+=( "${5}" ); fi
        if CheckIfVarIsValid "${6}" &> /dev/null; then arr_input+=( "${6}" ); fi
        if CheckIfVarIsValid "${7}" &> /dev/null; then arr_input+=( "${7}" ); fi
        if CheckIfVarIsValid "${8}" &> /dev/null; then arr_input+=( "${8}" ); fi
        if CheckIfVarIsValid "${9}" &> /dev/null; then arr_input+=( "${9}" ); fi

        CheckIfVarIsValid "${1}" &> /dev/null && str_output="${1} "
        readonly str_output+="${var_green}[${arr_input[@]}]:${var_reset_color}"

        for int_count in ${arr_count[@]}; do
            echo -en "${str_output} "
            read var_input

            if CheckIfVarIsValid $var_input &> /dev/null; then
                for var_element in ${arr_input[@]}; do
                    if [[ "${var_input}" == "${var_element}" ]]; then
                        var_input=$var_element
                        return 0
                    fi
                done
            fi

            echo -e "${str_output_var_is_not_valid}"
        done

        var_input=${arr_input[0]}
        echo -e "Exceeded max attempts. Choice is set to default: ${var_input}"
        return 1
    }
# </code>

# <summary> #7 - Software installation </summary>
# <code>
    # <summary> Distro-agnostic, Check if package exists on-line. </summary>
    # <param name="${1}"> string: the software package(s) </param>
    # <returns> exit code </returns>
    function CheckIfPackageExists
    {
        ( CheckIfVarIsValid "${1}" && CheckIfVarIsValid "${str_package_manager}" )|| return "${?}"

        # <params>
        local str_commands_to_execute=""
        local readonly str_output="${var_prefix_fail}: Command '${str_package_manager}' is not supported."
        # </params>

        case "${str_package_manager}" in
            "apt" )
                str_commands_to_execute="apt list ${1}"
                ;;

            "dnf" )
                str_commands_to_execute="dnf search ${1}"
                ;;

            "pacman" )
                str_commands_to_execute="pacman -Ss ${1}"
                ;;

            "gentoo" )
                str_commands_to_execute="emerge --search ${1}"
                ;;

            "urpmi" )
                str_commands_to_execute="urpmq ${1}"
                ;;

            "yum" )
                str_commands_to_execute="yum search ${1}"
                ;;

            "zypper" )
                str_commands_to_execute="zypper se ${1}"
                ;;

            * )
                echo -e "${str_output}"
                return 1
                ;;
        esac

        eval "${str_commands_to_execute}" || return 1
    }

    # <summary> Distro-agnostic, Install a software package. </summary>
    # <param name="${1}"> string: the software package(s) </param>
    # <param name="${2}"> boolean: true/false do/don't reinstall software package and configuration files (if possible) </param>
    # <returns> exit code </returns>
    function InstallPackage
    {
        ( CheckIfVarIsValid "${1}" && CheckIfVarIsValid "${str_package_manager}" )|| return "${?}"

        # <params>
        ( CheckIfVarIsBool "${2}" &> /dev/null && local bool_option_reinstall=${2} )
        local str_commands_to_execute=""
        local readonly str_output="Installing software packages..."
        local readonly str_output_fail="${var_prefix_fail}: Command '${str_package_manager}' is not supported."
        # </params>

        # <summary> Auto-update and auto-install selected packages </summary>
        case "${str_package_manager}" in
            "apt" )
                local readonly str_option="--reinstall -o Dpkg::Options::=--force-confmiss"
                str_commands_to_execute="apt update && apt full-upgrade -y && apt install ${str_option} -y ${1}"
                ;;

            "dnf" )
                str_commands_to_execute="dnf upgrade && dnf install ${1}"
                ;;

            "pacman" )
                str_commands_to_execute="pacman -Syu && pacman -S ${1}"
                ;;

            "gentoo" )
                str_commands_to_execute="emerge -u @world && emerge ${1}"
                ;;

            "urpmi" )
                str_commands_to_execute="urpmi --auto-update && urpmi ${1}"
                ;;

            "yum" )
                str_commands_to_execute="yum update && yum install ${1}"
                ;;

            "zypper" )
                str_commands_to_execute="zypper refresh && zypper in ${1}"
                ;;

            * )
                echo -e "${str_output_fail}"
                return 1
                ;;
        esac

        echo "${str_output}"
        eval "${str_commands_to_execute}" &> /dev/null || ( return 1 )
        AppendPassOrFail "${str_output}"
        return "${int_exit_code}"
    }

    # <summary> Distro-agnostic, Uninstall a software package. </summary>
    # <param name="${1}"> string: the software package(s) </param>
    # <returns> exit code </returns>
    function UninstallPackage
    {
        ( CheckIfVarIsValid "${1}" && CheckIfVarIsValid "${str_package_manager}" )|| return "${?}"

        # <params>
        local str_commands_to_execute=""
        local readonly str_output="Uninstalling software packages..."
        local readonly str_output_fail="${var_prefix_fail}: Command '${str_package_manager}' is not supported."
        # </params>

        # <summary> Auto-update and auto-install selected packages </summary>
        case "${str_package_manager}" in
            "apt" )
                str_commands_to_execute="apt uninstall -y ${1}"
                ;;

            "dnf" )
                str_commands_to_execute="dnf remove ${1}"
                ;;

            "pacman" )
                str_commands_to_execute="pacman -R ${1}"
                ;;

            "gentoo" )
                str_commands_to_execute="emerge -Cv ${1}"
                ;;

            "urpmi" )
                str_commands_to_execute="urpme ${1}"
                ;;

            "yum" )
                str_commands_to_execute="yum remove ${1}"
                ;;

            "zypper" )
                str_commands_to_execute="zypper remove ${1}"
                ;;

            * )
                echo -e "${str_output_fail}"
                return 1
                ;;
        esac

        echo "${str_output}"
        eval "${str_commands_to_execute}" &> /dev/null || ( return 1 )
        AppendPassOrFail "${str_output}"
        return "${int_exit_code}"
    }

    # <summary> Update or Clone repository given if it exists or not. </summary>
    # <param name="${1}"> string: the directory </param>
    # <param name="${2}"> string: the full repo name </param>
    # <param name="${3}"> string: the username </param>
    # <returns> exit code </returns>
    function UpdateOrCloneGitRepo
    {
        # <summary> Update existing GitHub repository. </summary>
        if CheckIfDirExists "${1}${2}"; then
            local var_command="git pull"
            cd "${1}${2}" && TryThisXTimesBeforeFail $( eval "${var_command}" )
            return "${?}"

        # <summary> Clone new GitHub repository. </summary>
        else
            if ReadInput "Clone repo '${2}'?"; then
                local var_command="git clone https://github.com/${2}"

                cd "${1}${3}" && TryThisXTimesBeforeFail $( eval "${var_command}" )
                return "${?}"
            fi
        fi
    }
# </code>

# <summary> Global parameters </summary>
# <params>
    # <summary> Getters and Setters </summary>
        declare -g bool_is_installed_systemd=false
        CheckIfCommandIsInstalled "systemd" &> /dev/null && bool_is_installed_systemd=true

        declare -g bool_is_user_root=false
        CheckIfUserIsRoot &> /dev/null && bool_is_user_root=true

        declare -gl str_package_manager=""
        CheckLinuxDistro &> /dev/null

    # <summary> Setters </summary>
        # <summary> Exit codes </summary>
        declare -gir int_code_partial_completion=255
        declare -gir int_code_skipped_operation=254
        declare -gir int_code_var_is_null=253
        declare -gir int_code_var_is_empty=252
        declare -gir int_code_var_is_not_bool=251
        declare -gir int_code_var_is_NAN=250
        declare -gir int_code_dir_is_null=249
        declare -gir int_code_file_is_null=248
        declare -gir int_code_file_is_not_executable=247
        declare -gir int_code_file_is_not_writable=246
        declare -gir int_code_file_is_not_readable=245
        declare -gir int_code_cmd_is_null=244
        declare -gi int_exit_code="${?}"

        # <summary>
        # Color coding
        # Reference URL: 'https://www.shellhacks.com/bash-colors'
        # </summary>
        declare -gr var_blinking_red='\033[0;31;5m'
        declare -gr var_green='\033[0;32m'
        declare -gr var_red='\033[0;31m'
        declare -gr var_yellow='\033[0;33m'
        declare -gr var_reset_color='\033[0m'

        # <summary> Append output </summary>
        declare -gr var_prefix_error="${var_yellow}Error:${var_reset_color}"
        declare -gr var_prefix_fail="${var_red}Failure:${var_reset_color}"
        declare -gr var_prefix_pass="${var_green}Success:${var_reset_color}"
        declare -gr var_prefix_warn="${var_blinking_red}Warning:${var_reset_color}"
        declare -gr var_suffix_fail="${var_red}Failure${var_reset_color}"
        declare -gr var_suffix_maybe="${var_yellow}Successfully Incomplete${var_reset_color}"
        declare -gr var_suffix_pass="${var_green}Success${var_reset_color}"
        declare -gr var_suffix_skip="${var_yellow}Skipped${var_reset_color}"

        # <summary> Output statement </summary>
        declare -gr str_output_partial_completion="${var_prefix_warn} One or more operations failed."
        declare -gr str_output_var_is_not_valid="${var_prefix_error} Invalid input."
# </params>

#
# YOUR CODE BELOW
#

exit 0