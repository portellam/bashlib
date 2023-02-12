#!/bin/bash sh

#
# Filename:         your_script_name_here
# Description:      your_script_description_here
# Author(s):        your_name_here
# Maintainer(s):    your_name_here
#

# =========================================================================================== #

#
# Filename:         bash-libraries.bash
# Description:      Collection of custom functions to be used as a library for Bash scripts.
# Author(s):        Alex Portell <github.com/portellam>
# Maintainer(s):    Alex Portell <github.com/portellam>
#

# <remarks> bash-libraries </remarks>
    # <summary> #0 - User validation </summary>
    # <code>
        # <summary> Check if current user is sudo or root. </summary>
        # <returns> exit code </returns>
        function IsSudoUser
        {
            # <params>
            local readonly str_file=$( basename "${0}" )
            local readonly str_fail="${var_prefix_warn} User is not sudo/root. In terminal, enter: ${var_yellow}'sudo bash ${str_file}'${var_reset_color}."
            local readonly var_command='$( whoami ) == "root"'
            # </params>
            
            if ! eval "${var_command}"; then
                echo -e "${str_fail}"
                return 1
            fi

            return 0
        }
    # </code>

    # <summary> #1 - Setup and command operation/validation </summary>
    # <code>
        # <summary> Append Pass or Fail given exit code. </summary>
        # <param name="${int_exit_code}"> the last exit code </param>
        # <param name="${1}"> string: the output statement </param>
        # <returns> output statement </returns>
        function PrintPassOrFail
        {
            SaveExitCode
            IsNotEmptyVar "${1}" &> /dev/null && echo -en "${1} "

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
        # <param name="${0}"> string: the shell script name </param>
        # <returns> exit code </returns>
        function GoToScriptDir
        {
            # <params>
            local readonly str_dir=$( dirname "${0}" )
            # </params>

            cd "${str_dir}" || return 1
            return 0
        }

        # <summary> Parse exit code as boolean. If zero, return true. Else, return false. </summary>
        # <param name="${?}"> int: the exit code </param>
        # <returns> boolean </returns>
        function ParseExitCodeAsBool
        {
            if [[ "${?}" -ne 0 ]]; then
                echo "false"
                return 1
            fi

            echo "true"
            return 0
        }

        # <summary> Save last exit code. </summary>
        # <param name=""${int_exit_code}""> the exit code </param>
        # <returns> void </returns>
        function SaveExitCode
        {
            # <params>
            int_exit_code="${?}"
            # </params>
        }

        # <summary> Attempt given command a given number of times before failure. </summary>
        # <param name="${1}"> string: the command to execute </param>
        # <returns> exit code </returns>
        function StopEvalAfterThriceFail
        {
            IsNotEmptyVar "${1}" || return "${?}"

            # <params>
            declare -ir int_min_count=1
            declare -ir int_max_count=3
            declare -ar arr_count=$( eval echo {$int_min_count..$int_max_count} )
            local readonly str_fail="${var_prefix_error} Execution of command failed."
            # </params>

            for int_count in ${arr_count[@]}; do
                eval "${1}" && return 0 || echo -e "${str_fail}"
            done

            return 1
        }
    # </code>

    # <summary> #2 - Data-type and variable validation </summary>
    # <code>
        # <summary> Check if the array is empty. </summary>
        # <paramref name="${1}"> string: name of the array </paramref>
        # <returns> exit code </returns>
        function IsNotEmptyArray
        {
            IsNotNullVar "${1}" || return "${?}"

            # <params>
            local readonly str_name_ref="${1}"
            # declare -ar arr=$( "${str_name_ref[@]}" )
            # </params>

            for var_element in "${str_name_ref[@]}"; do
                IsNotNullVar "${var_element}" &> /dev/null && return 0
            done

            echo -e "${str_output_var_is_empty}"
            return "${int_code_var_is_empty}"
        }

        # <summary> Check if the variable is not empty. If true, pass. </summary>
        # <param name="${1}"> var: the variable </param>
        # <returns> exit code </returns>
        function IsNotEmptyVar
        {
            # <params>
            local readonly str_fail="${var_prefix_error} Empty string."
            local readonly var_command='"${1}" == ""'
            # </params>

            if ! eval "${var_command}"; then
                echo -e "${str_fail}"
                return "${int_code_var_is_empty}"
            fi

            return 0
        }

        # <summary> Check if the variable is not null. If true, pass. </summary>
        # <param name="${1}"> var: the variable </param>
        # <returns> exit code </returns>
        function IsNotNullVar
        {
            # <params>
            local readonly str_fail="${var_prefix_error} Null string."
            # </params>

            if [[ -z "${1}" ]]; then
                echo -e "${str_fail}"
                return "${int_code_var_is_null}"
            fi

            return 0
        }

        # <summary> Check if the value is a valid bool. </summary>
        # <param name="${1}"> var: the boolean </param>
        # <returns> exit code </returns>
        function IsValidBool
        {
            IsNotEmptyVar "${1}" || return "${?}"

            # <params>
            local readonly str_fail="${var_prefix_error} Not a boolean."
            # </params>

            case "${1}" in
                "true" | "false" )
                    return 0
                    ;;

                * )
                    echo -e "${str_fail}"
                    return "${int_code_var_is_not_bool}"
                    ;;
            esac
        }

        # <summary> Check if the value is a valid number. If true, pass.</summary>
        # <param name="${1}"> var: the number </param>
        # <returns> exit code </returns>
        function IsValidNum
        {
            IsNotEmptyVar "${1}" || return "${?}"

            # <params>
            local readonly str_num_regex='^[0-9]+$'
            local readonly str_fail="${var_prefix_error} NaN."
            local readonly var_command='"${1}" =~ $str_num_regex'       ## add brackets?
            # </params>

            if ! eval "${var_command}"; then
                echo -e "${str_fail}"
                return "${int_code_var_is_NAN}"
            fi

            return 0
        }
       
        # <summary> Check if the variable is valid. If true, pass. </summary>
        # <param name="${1}"> var: the variable </param>
        # <returns> exit code </returns>
        function IsValidString
        {
            IsNotNullVar "${1}" || return "${?}"
            IsNotEmptyVar "${1}" || return "${?}"
            return 0
        }
        
        # <summary> Check if the variable is writable. If true, pass. </summary>
        # <param name="${1}"> string: the name of a variable </param>
        # <returns> exit code </returns>
        function IsWritableVar
        {
            IsNotEmptyVar "${1}" || return "${?}"
        
            # <params>
            local readonly var_command='"${1}+=" >2/dev/null'
            # </params>
            
            eval "${var_command}"
            return "${?}"
        }    
    # </code>

    # <summary> #3 - Process/library validation </summary>
    # <code>
        # <summary> Check if the daemon is active or not. </summary>
        # <param name="${1}"> string: the command </param>
        # <returns> exit code </returns>
        function IsActiveDaemon
        {
            IsNotEmptyVar "${1}" || return "${?}"

            # <params>
            local readonly str_active='active'
            local readonly str_failed='failed'
            local readonly str_inactive='inactive'
            local readonly var_command='systemctl status ${1} | grep "${str_active}"'
            local readonly str_output=$( eval "${var_command}" )
            # </params>

            IsNotEmptyVar "${var_command}" || return "${?}"

            case $( eval "${var_command}" ) in
                *"${str_failed}"* | *"${str_inactive}"* )
                    return "${int_code_partial_completion}"
                    ;;

                * )
                    return 1
                    ;;
            esac

            return 0
        }

        # <summary> Check if the command is installed. </summary>
        # <param name="${1}"> string: the command </param>
        # <returns> exit code </returns>
        function IsInstalledCommand
        {
            IsNotEmptyVar "${1}" || return "${?}"

            # <params>
            local readonly str_fail="${var_prefix_error} Command '${1}' is not installed."
            local readonly str_actual=$( command -v "${1}" )
            local readonly str_expected="/usr/bin/${1}"
            local readonly var_command='"${str_actual}" == "${str_expected}"'
            # </params>

            if ! eval "${var_command}"; then
                echo -e "${str_fail}"
                return "${int_code_cmd_is_null}"
            fi

            return 0
        }

        # <summary> Check if the daemon is installed. </summary>
        # <param name="${1}"> string: the command </param>
        # <returns> exit code </returns>
        function IsInstalledDaemon
        {
            IsNotEmptyVar "${1}" || return "${?}"

            # <params>
            local readonly str_fail="${var_prefix_error} Daemon '${1}' is not installed."
            local readonly var_command='systemctl status ${1} | grep -Eiv "not"'
            local readonly str_output=$( eval "${var_command}" )
            # </params>

            if ! IsValidValid "${str_output}"; then
                echo -e "${str_fail}"
                return "${int_code_cmd_is_null}"
            fi

            return 0
        }

        # <summary> Check if the process is active. </summary>
        # <param name="${1}"> string: the command </param>
        # <returns> exit code </returns>
        function IsInstalledProcess
        {
            IsValidValid "${1}" || return "${?}"

            # <params>
            local readonly str_fail="${var_prefix_error} Process '${1}' is not active."
            local readonly var_command='ps -e | grep ${1}'
            local readonly str_output=$( eval "${var_command}" )
            # </params>

            if ! IsValidValid "${str_output}"; then
                echo -e "${str_fail}"
                return "${int_code_cmd_is_null}"
            fi

            return 0
        }
    # </code>

    # <summary> #4 - File operation and validation </summary>
    # <code>
        # <summary> Check if two given files are the same. If true, pass. </summary>
        # <parameter name="${1}"> string: the file </parameter>
        # <parameter name="${2}"> string: the other file </parameter>
        # <returns> exit code </returns>
        function AreEqualFiles
        {
            FindFile "${2}" || return "${?}"
            FindFile "${1}" || return "${?}"

            # <params>
            local readonly var_command='cmp -s "${1}" "${2}"'
            # </params>

            eval ! "${var_command}" || return 1
            return 0
        }
        
        # <summary> Create latest backup of given file (do not exceed given maximum count). </summary>
        # <parameter name="${1}"> string: the file </parameter>
        # <returns> exit code </returns>
        function BackupFile
        {
            function BackupFile_Main
            {
                FindFile "${1}" || return "${?}"

                # <params>
                declare -ir int_max_count=4
                local readonly str_dir=$( dirname "${1}" )
                local readonly str_suffix=".old"
                local readonly var_command='ls "${str_dir}" | grep "${1}" | grep $str_suffix | uniq | sort -V'
                declare -a arr_dir=( $( eval "${var_command}" ) )
                # </params>

                IsNotEmptyArray "arr_dir" &> /dev/null || return "${?}"

                # <remarks> Create backup file if none exist. </remarks>
                if [[ "${#arr_dir[@]}" -eq 0 ]]; then
                    cp "${1}" "${1}.${var_first_index}${str_suffix}" || return 1
                    return 0
                fi

                # <remarks> Oldest backup file is same as original file. </remarks>
                AreEqualFiles "${1}" "${arr_dir[0]}" && return 0

                # <remarks> Get index of oldest backup file. </remarks>
                local str_oldest_file="${arr_dir[0]}"
                str_oldest_file="${str_oldest_file%%"${str_suffix}"*}"
                local var_first_index="${str_oldest_file##*.}"
                IsValidNum "$var_first_index" || return "${?}"

                # <remarks> Delete older backup files, if total matches/exceeds maximum. </remarks>
                while [[ "${#arr_dir[@]}" -gt "$int_max_count" ]]; do
                    DeleteFile "${arr_dir[0]}" || return "${?}"
                    arr_dir=( $( eval "${var_command}" ) )
                done

                # <remarks> Increment number of last backup file index. </remarks>
                local str_newest_file="${arr_dir[-1]}"
                str_newest_file="${str_newest_file%%"${str_suffix}"*}"
                local var_last_index="${str_newest_file##*.}"
                IsValidNum "${var_last_index}" || return "${?}"
                (( var_last_index++ ))

                # <remarks> Newest backup file is different and newer than original file. </remarks>
                if ( ! AreEqualFiles "${1}" "${arr_dir[-1]}" &> /dev/null ) && [[ "${1}" -nt "${arr_dir[-1]}" ]]; then
                    cp "${1}" "${1}.${var_last_index}${str_suffix}" || return 1
                fi

                return 0
            }

            # <params>
            local readonly str_output="Creating backup file..."
            # </params>

            echo -e "${str_output}"
            BackupFile_Main "${1}"
            PrintPassOrFail "${str_output}"
            return "${?}"
        }

        # <summary> Create a directory. </summary>
        # <param name="${1}"> string: the directory </param>
        # <returns> exit code </returns>
        function CreateDir
        {
            IsNotEmptyVar "${1}" || return "${?}"
            FindDir "${1}" &> /dev/null && return 0

            # <params>
            local readonly str_fail="${var_prefix_fail} Could not create directory '${1}'."
            local readonly var_command='mkdir -p "${1}"'
            # </params>

            if ! eval "${var_command}"; then
                echo -e "${str_fail}"
                return 1
            fi

            return 0
        }

        # <summary> Create a file. </summary>
        # <param name="${1}"> string: the file </param>
        # <returns> exit code </returns>
        function CreateFile
        {
            IsNotEmptyVar "${1}" || return "${?}"
            FindFile "${1}" &> /dev/null && return 0

            # <params>
            local readonly str_fail="${var_prefix_fail} Could not create file '${1}'."
            local readonly var_command='touch "${1}" &> /dev/null"'
            # </params>

            if ! eval "${var_command}"; then
                echo -e "${str_fail}"
                return 1
            fi

            return 0
        }

        # <summary> Delete a dir/file. </summary>
        # <param name="${1}"> string: the file </param>
        # <returns> exit code </returns>
        function DeleteFile
        {
            IsNotEmptyVar "${1}" || return "${?}"
            FindFile "${1}" &> /dev/null && return 0

            # <params>
            local readonly str_fail="${var_prefix_fail} Could not delete file '${1}'."
            local readonly var_command='rm "${1}"'
            # </params>

            if ! eval "${var_command}"; then
                echo -e "${str_fail}"
                return 1
            fi

            return 0
        }

        # <summary> Create a file. If true, pass. </summary>
        # <param name="${1}"> string: the file </param>
        # <param name="${2}"> string: the line </param>
        # <returns> exit code </returns>
        function FindLine
        {
            IsValidValid "${2}" || return "${?}"
            FindFile "${1}" || return "${?}"

            # <params>
            local readonly var_command='! -z $( grep -iF "${2}" "${1}" )'
            # </params>

            ! eval "${var_command}" || return 1
            return 0
        }

        # <summary> Check if the directory exists. If true, pass. </summary>
        # <param name="${1}"> string: the directory name </param>
        # <returns> exit code </returns>
        function FindDir
        {
            IsNotEmptyVar "${1}" || return "${?}"

            # <params>
            local readonly str_fail="${var_prefix_error} Directory '${1}' does not exist."
            local readonly var_command='-d "${1}"'
            # </params>

            if ! eval "${var_command}"; then
                echo -e "${str_fail}"
                return "${int_code_dir_is_null}"
            fi

            return 0
        }

        # <summary> Check if the file exists. If true, pass. </summary>
        # <param name="${1}"> string: the file name </param>
        # <returns> exit code </returns>
        function FindFile
        {
            IsNotEmptyVar "${1}" || return "${?}"

            # <params>
            local readonly str_fail="${var_prefix_error} File '${1}' does not exist."
            local readonly var_command='-e "${1}"'
            # </params>

            if ! eval "${var_command}"; then
                echo -e "${str_fail}"
                return "${int_code_dir_is_null}"
            fi

            return 0
        }

        # <summary> Check if the file is executable. If true, pass. </summary>
        # <param name="${1}"> string: the file name </param>
        # <returns> exit code </returns>
        function IsExecutableFile
        {
            FindFile "${1}" || return "${?}"

            # <params>
            local readonly str_fail="${var_prefix_error} File '${1}' is not executable."
            local readonly var_command='-x "${1}"'
            # </params>

            if ! eval "${var_command}"; then
                echo -e "${str_fail}"
                return "${int_code_file_is_not_executable}"
            fi

            return 0
        }

        # <summary> Check if the file is readable. If true, pass. </summary>
        # <param name="${1}"> string: the file name </param>
        # <returns> exit code </returns>
        function IsReadableFile
        {
            FindFile "${1}" || return "${?}"

            # <params>
            local readonly str_fail="${var_prefix_error} File '${1}' is not readable."
            local readonly var_command='-r "${1}"'
            # </params>

            if ! eval "${var_command}"; then
                echo -e "${str_fail}"
                return "${int_code_file_is_not_readable}"
            fi

            return 0
        }

        # <summary> Check if the file is writable. If true, pass. </summary>
        # <param name="${1}"> string: the file name </param>
        # <returns> exit code </returns>
        function IsWritableFile
        {
            FindFile "${1}" || return "${?}"

            # <params>
            local readonly str_fail="${var_prefix_error} File '${1}' is not writable."
            local readonly var_command='-w "${1}"'
            # </params>

            if ! eval "${var_command}"; then
                echo -e "${str_fail}"
                return "${int_code_file_is_not_writable}"
            fi

            return 0
        }
                
        # <summary> Overwrite output to a file. Declare inherited params before calling this function. </summary>
        # <paramref name="${1}"> string: the name of the array </paramref>
        # <param name="${2}"> string: the name of the file </param>
        # <returns> exit code </returns>
        function OverwriteFile
        {
            IsNotEmptyArray "${1}" || return "${?}"
            DeleteFile "${2}"
            CreateFile "${2}" || return "${?}"
            WriteFile "${1}" "${2}"
            return "${?}"
        }
        
        # <summary> Output a file. </summary>
        # <param name="${1}"> string: the file </param>
        # <returns> exit code </returns>
        function PrintFile
        {
            FindFile "${1}" || return "${?}"

            # <params>
            declare -a arr_print_file=()
            local readonly str_output="Contents for file ${var_yellow}'${1}'${var_reset_color}:"
            local readonly var_command='cat "${1}"'
            # </params>

            echo -e "${str_output}"
            ReadFile "arr_print_file" "${1}" || return "${?}"
            PrintArray "arr_print_file" || return "${?}"
            return 0
        }

        # <summary> Output an array. Declare inherited params before calling this function. </summary>
        # <paramref name="${1}"> string: name of the array </paramref>
        # <returns> exit code </returns>
        function PrintArray
        {
            IsNotEmptyVar "${1}" || return "${?}"

            # <params>
            IFS=$'\n'
            local readonly str_name_ref="${1}"
            declare -ar arr_output=$( "${str_name_ref[@]}" )
            local readonly var_command='echo -e "${var_yellow}${arr_output[*]}${var_reset_color}"'
            # </params>

            if ! IsNotEmptyArray "arr_output" &> /dev/null; then
                return 1
            fi

            echo
            eval "${var_command}" || return 1
            return 0
        }

        # <summary> Read input from a file. Declare inherited params before calling this function. </summary>
        # <paramref name="${1}"> string: the name of the array </paramref>
        # <param name="${2}"> string: the name of the file </param>
        # <returns> exit code </returns>
        function ReadFile
        {
            FindFile "${2}" || return "${?}"
            IsNotEmptyVar "${1}" || return "${?}"
            
            # <params>
            IFS=$'\n'
            local readonly str_fail="${var_prefix_fail} Could not read from file '${2}'."
            local readonly var_get_file='cat "${2}"'
            local readonly var_set_param="${1}"'=( $( echo -e "${arr_read_file[@]}" ) )'
            declare -a arr_read_file=( $( eval "${var_get_file}" ) )
            # </params>

            if ! IsNotEmptyArray "arr_read_file" &> /dev/null; then
                echo -e "${str_fail}"
                return 1
            fi

            eval "${var_set_param}" || return 1
            return 0
        }

        # <summary> Restore latest valid backup of given file. </summary>
        # <parameter name="${1}"> string: the name of the file </param>
        # <returns> exit code </returns>
        function RestoreFile
        {
            function RestoreFile_Main
            {
                FindFile "${1}" || return "${?}"

                # <params>
                local bool=false
                local readonly str_dir=$( dirname "${1}" )
                local readonly str_suffix=".old"
                var_command='ls "${str_dir}" | grep "${1}" | grep $str_suffix | uniq | sort -rV'
                declare -a arr_dir=( $( eval "${var_command}" ) )
                # </params>

                IsNotEmptyArray "arr_dir" || return "${?}"

                for var_element in "${arr_dir[@]}"; do
                    FindFile "${var_element}" && cp "${var_element}" "${1}" && return 0
                done

                return 1
            }

            # <params>
            local readonly str_output="Restoring backup file..."
            # </params>

            echo -e "${str_output}"
            RestoreFile_Main "${1}"
            PrintPassOrFail "${str_output}"

            return "${int_exit_code}"
        }

        # <summary> Write output to a file. Declare inherited params before calling this function. </summary>
        # <paramref name="${1}"> string: the name of the array </paramref>
        # <param name="${2}"> string: the name of the file </param>
        # <returns> exit code </returns>
        function WriteFile
        {
            FindFile "${2}" || return "${?}"
            IsNotEmptyArray "${1}" || return "${?}"
            
            # <params>
            local readonly str_fail="${var_prefix_fail} Could not write to file '${1}'."
            local readonly str_name_ref="${1}"
            local readonly var_get_arr='( $( echo -e "${str_name_ref[@]}" ) )'
            local readonly var_set_file='printf "%s\n" "${arr[@]}" >> "${2}"'
            declare -ar arr=( $( eval "${var_get_arr}" ) )
            # </params>

            if ! eval "${var_set_file}"; then
                echo -e "${str_fail}"
                return 1
            fi

            return 0
        }    
    # </code>

    # <summary> #5 - Device validation </summary>
    # <code>
        # <summary> Test network connection to Internet. Ping DNS servers by address and name. </summary>
        # <param name="${1}"> boolean: true/false toggle verbosity </param>
        # <returns> exit code </returns>
        function GetInternetStatus
        {
            function GetInternetStatus_PingServer
            {
                IsNotEmptyVar "${1}" || return "${?}"
                ping -q -c 1 "${1}" &> /dev/null || return 1
                return 0
            }
            
            # <params>
            local bool=false
            # </params>

            if IsValidBool "${1}" &> /dev/null && "${1}"; then
                bool="${1}"
            fi

            if $bool; then
                echo -en "Testing Internet connection...\t"
            fi

            if ! GetInternetStatus_PingServer "8.8.8.8" || ! GetInternetStatus_PingServer "1.1.1.1"; then
                false
            fi

            SaveExitCode

            if $bool; then
                ( return "${int_exit_code}" )
                PrintPassOrFail
                echo -en "Testing connection to DNS...\t"
            fi

            if ! GetInternetStatus_PingServer "www.google.com" || ! GetInternetStatus_PingServer "www.yandex.com"; then
                false
            fi

            SaveExitCode

            if $bool; then
                ( return "${int_exit_code}" )
                PrintPassOrFail
            fi

            if [[ "${int_exit_code}" -ne 0 ]]; then
                echo -e "Failed to ping Internet/DNS servers. Check network settings or firewall, and try again."
            fi

            return "${int_exit_code}"
        }

        # <summary> Check if current kernel and distro are supported, and if the expected Package Manager is installed. </summary>
        # <returns> exit code </returns>
        function GetLinuxDistro
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
            
            if ! IsValidValid "${str_kernel}" &> /dev/null || ! IsValidValid "${str_operating_system}" &> /dev/null; then
                return "${?}"
            fi

            if [[ "${str_kernel}" != *"linux"* ]]; then
                echo -e "${str_output_kernel_is_not_valid}"
                return 1
            fi

            # <summary> Check if current Operating System matches Package Manager, and Check if PM is installed. </summary>
            # <returns> exit code </returns>
            function GetLinuxDistro_GetPackageManagerByOS
            {
                if [[ "${str_OS_with_apt}" =~ .*"${str_operating_system}".* ]]; then
                    str_package_manager="apt"

                elif [[ "${str_OS_with_dnf_yum}" =~ .*"${str_operating_system}".* ]]; then
                    str_package_manager="dnf"
                    IsInstalledCommand "${str_package_manager}" &> /dev/null && return 0
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

                IsInstalledCommand "${str_package_manager}" &> /dev/null && return 0
                return 1
            }

            if ! GetLinuxDistro_GetPackageManagerByOS; then
                echo -e "${str_output_distro_is_not_valid}"
                return 1
            fi

            return 0
        }

        # <summary> Update GetInternetStatus </summary>
        # <param name="${bool_is_connected_to_Internet}"> boolean: network status </param>
        # <returns> exit code </returns>
        function SetInternetStatus
        {
            ( StopEvalAfterThriceFail "GetInternetStatus true" && bool_is_connected_to_Internet=true ) || bool_is_connected_to_Internet=false
        }
    # </code>

    # <summary> #6 - User input </summary>
    # <code>
        # <summary> Ask user Yes/No, read input and return exit code given answer. </summary>
        # <param name="${1}"> string: the output statement </param>
        # <returns> exit code </returns>
        function ReadInput
        {
            # <params>
            declare -i int_max_tries=3
            declare -ar arr_count=( $( seq 0 "${int_max_tries}" ) )
            local readonly str_no="N"
            local readonly str_yes="Y"
            local str_output=""
            # </params>

            IsValidValid "${1}" &> /dev/null && str_output="${1} "
            str_output+="${var_green}[Y/n]:${var_reset_color}"

            for int_count in ${arr_count[@]}; do

                # <summary> Append output. </summary>
                echo -en "${str_output} "
                read var_input
                var_input=$( echo $var_input | tr '[:lower:]' '[:upper:]' )

                # <summary> Check if input is valid. </summary>
                if IsValidValid $var_input; then
                    case $var_input in
                        ""${str_yes}"" )
                            return 0;;
                        "${str_no}" )
                            return 1;;
                    esac
                fi

                # <summary> Input is not valid. </summary>
                echo -e "${str_output_var_is_not_valid}"
            done

            # <summary> After given number of attempts, input is set to default. </summary>
            str_output="Exceeded max attempts. Choice is set to default: ${var_yellow}${str_no}${var_reset_color}"
            echo -e "${str_output}"
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
            declare -i int_max_tries=3
            declare -ar arr_count=( $( seq 0 "${int_max_tries}" ) )
            local readonly var_min="${2}"
            local readonly var_max="${3}"
            local str_output=""
            local readonly str_fail="${var_prefix_error} Extrema are not valid."
            var_input=""
            # </params>

            if ( ! IsValidNum $var_min || ! IsValidNum $var_max ) &> /dev/null; then
                echo -e "${str_output}"_extrema_are_not_valid
                return 1
            fi

            IsValidValid "${1}" &> /dev/null && str_output="${1} "

            str_output+="${var_green}[${var_min}-${var_max}]:${var_reset_color}"

            for int_count in ${arr_count[@]}; do

                # <summary> Append output. </summary>
                echo -en "${str_output} "
                read var_input

                # <summary> Check if input is valid. </summary>
                if IsValidNum $var_input && [[ $var_input -ge $var_min && $var_input -le $var_max ]]; then
                    return 0
                fi

                # <summary> Input is not valid. </summary>
                echo -e "${str_fail}"
            done

            var_input=$var_min
            str_output="Exceeded max attempts. Choice is set to default: ${var_yellow}${var_input}${var_reset_color}"
            echo -e "${str_output}"
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
        function ReadMultipleChoiceIgnoreCase
        {
            # <params>
            declare -i int_max_tries=3
            declare -ar arr_count=( $( seq 0 "${int_max_tries}" ) )
            declare -a arr_input=()
            local str_output=""
            local readonly str_fail="${var_prefix_error} Insufficient multiple choice answers."
            var_input=""
            # </params>

            # <summary> Minimum multiple choice are two answers. </summary>
            if ( ! IsValidValid "${2}" || ! IsValidValid "${3}" ) &> /dev/null; then
                SaveExitCode
                echo -e "${str_fail}"
                return "${int_exit_code}"
            fi

            arr_input+=( "${2}" )
            arr_input+=( "${3}" )

            if IsValidValid "${4}" &> /dev/null; then arr_input+=( "${4}" ); fi
            if IsValidValid "${5}" &> /dev/null; then arr_input+=( "${5}" ); fi
            if IsValidValid "${6}" &> /dev/null; then arr_input+=( "${6}" ); fi
            if IsValidValid "${7}" &> /dev/null; then arr_input+=( "${7}" ); fi
            if IsValidValid "${8}" &> /dev/null; then arr_input+=( "${8}" ); fi
            if IsValidValid "${9}" &> /dev/null; then arr_input+=( "${9}" ); fi

            IsValidValid "${1}" &> /dev/null && str_output="${1} "
            str_output+="${var_green}[${arr_input[@]}]:${var_reset_color}"

            for int_count in ${arr_count[@]}; do
                echo -en "${str_output} "
                read var_input

                if IsValidValid $var_input; then
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
            str_output="Exceeded max attempts. Choice is set to default: ${var_yellow}${var_input}${var_reset_color}"
            echo -e "${str_output}"
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
        function ReadMultipleChoiceMatchCase
        {
            # <params>
            declare -i int_max_tries=3
            declare -ar arr_count=( $( seq 0 "${int_max_tries}" ) )
            declare -a arr_input=()
            local str_output=""
            local readonly str_fail="${var_prefix_error} Insufficient multiple choice answers."
            var_input=""
            # </params>

            # <summary> Minimum multiple choice are two answers. </summary>
            if ( ! IsValidValid "${2}" || ! IsValidValid "${3}" ) &> /dev/null; then
                echo -e "${str_fail}"
                return 1;
            fi

            arr_input+=( "${2}" )
            arr_input+=( "${3}" )

            if IsValidValid "${4}" &> /dev/null; then arr_input+=( "${4}" ); fi
            if IsValidValid "${5}" &> /dev/null; then arr_input+=( "${5}" ); fi
            if IsValidValid "${6}" &> /dev/null; then arr_input+=( "${6}" ); fi
            if IsValidValid "${7}" &> /dev/null; then arr_input+=( "${7}" ); fi
            if IsValidValid "${8}" &> /dev/null; then arr_input+=( "${8}" ); fi
            if IsValidValid "${9}" &> /dev/null; then arr_input+=( "${9}" ); fi

            IsValidValid "${1}" &> /dev/null && str_output="${1} "
            str_output+="${var_green}[${arr_input[@]}]:${var_reset_color}"

            for int_count in ${arr_count[@]}; do
                echo -en "${str_output} "
                read var_input

                if IsValidValid $var_input &> /dev/null; then
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
            str_output="Exceeded max attempts. Choice is set to default: ${var_yellow}${var_input}${var_reset_color}"
            echo -e "${str_output}"
            return 1
        }
    # </code>

    # <summary> #7 - Software installation and validation </summary>
    # <code>
        # <summary> Distro-agnostic, Check if package exists on-line. </summary>
        # <param name="${1}"> string: the software package(s) </param>
        # <returns> exit code </returns>
        function FindPackage
        {
            ( IsValidValid "${1}" && IsValidValid "${str_package_manager}" )|| return "${?}"

            # <params>
            local str_commands_to_execute=""
            local readonly str_output_invalid_package_manager="${var_prefix_fail}: Command '${str_package_manager}' is not supported."
            local readonly str_output_invalid_package="${var_prefix_fail}: Package(s) '${str_package_manager}' was/were not found."
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
                    echo -e "${str_output_invalid_package_manager}"
                    return 1
                    ;;
            esac

            if ! eval "${str_commands_to_execute}" &> /dev/null; then
                echo -e "${str_output_invalid_package}"
                return 1
            fi

            return 0
        }

        # <summary> Check if system file is original or not. </summary>
        # <parameter name="${1}"> string: the system file </parameter>
        # <parameter name="${2}"> string: the software package(s) to install </parameter>
        # <parameter name="${bool_is_connected_to_Internet}"> boolean: GetInternetStatus </parameter>
        # <returns> exit code </returns>
        function IsFileOriginal
        {
            IsValidValid "${2}" || return "${?}"
            IsValidValid "${1}" || return "${?}"

            # <params>
            local bool_backup_file_exists=false
            local bool_system_file_is_original=false
            local readonly str_backup_file="${1}.bak"
            # </params>

            # <summary> Original system file does not exist. </summary>
            if $bool_is_connected_to_Internet && ! FindFile "${1}"; then
                InstallPackage "${2}" true && bool_system_file_is_original=true
            fi

            # if BackupFile "${1}"; then                                      # BackupFile is broken?
            #     bool_backup_file_exists=true
            # fi

            if cp "${1}" "${str_backup_file}" && FindFile "${1}"; then
                bool_backup_file_exists=true
            else
                return 1
            fi

            # <summary> It is unknown if system file *is* original. </summary>
            if $bool_is_connected_to_Internet && $bool_backup_file_exists && ! $bool_system_file_is_original; then
                DeleteFile "${1}"
                InstallPackage "${2}" true && bool_system_file_is_original=true
            fi

            # <summary> System file *is not* original. Attempt to restore backup. </summary>
            if $bool_backup_file_exists && ! $bool_system_file_is_original; then
                # RestoreFile "${1}"                                          # RestoreFile is broken?
                cp "${str_backup_file}" "${1}" || return 1
            fi

            # <summary> Do no work. </summary>
            # if ! $bool_backup_file_exists || ! $bool_system_file_is_original; then
            #     return 1
            # fi

            if ! $bool_system_file_is_original; then
                return 1
            fi

            return 0
        }

        # <summary> Distro-agnostic, Install a software package. </summary>
        # <param name="${1}"> string: the software package(s) </param>
        # <param name="${2}"> boolean: true/false do/don't reinstall software package and configuration files (if possible) </param>
        # <param name="${str_package_manager}"> string: the package manager </param>
        # <returns> exit code </returns>
        function InstallPackage
        {
            IsValidValid "${str_package_manager}" || return "${?}"
            IsValidValid "${1}" || return "${?}"

            # <params>
            local bool_option_reinstall=false
            local str_commands_to_execute=""
            local readonly str_output="Installing software packages..."
            local readonly str_fail="${var_prefix_fail}: Command '${str_package_manager}' is not supported."
            # </params>

            IsValidBool "${2}" &> /dev/null && bool_option_reinstall=true

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
                    echo -e "${str_fail}"
                    return 1
                    ;;
            esac

            echo "${str_output}"
            eval "${str_commands_to_execute}" || ( return 1 )
            PrintPassOrFail "${str_output}"
            return "${?}"
        }

        # <summary> Distro-agnostic, Uninstall a software package. </summary>
        # <param name="${1}"> string: the software package(s) </param>
        # <param name="${str_package_manager}"> string: the package manager </param>
        # <returns> exit code </returns>
        function UninstallPackage
        {
            IsValidValid "${str_package_manager}" || return "${?}"
            IsValidValid "${1}" || return "${?}"

            # <params>
            local str_commands_to_execute=""
            local readonly str_output="Uninstalling software packages..."
            local readonly str_fail="${var_prefix_fail}: Command '${str_package_manager}' is not supported."
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
                    echo -e "${str_fail}"
                    return 1
                    ;;
            esac

            echo "${str_output}"
            eval "${str_commands_to_execute}" &> /dev/null || ( return 1 )
            PrintPassOrFail "${str_output}"
            return "${?}"
        }

        # <summary> Update or Clone repository given if it exists or not. </summary>
        # <param name="${1}"> string: the directory </param>
        # <param name="${2}"> string: the full repo name </param>
        # <param name="${3}"> string: the username </param>
        # <returns> exit code </returns>
        function UpdateOrCloneGitRepo
        {
            CreateDir "${1}${3}"

            # <summary> Update existing GitHub repository. </summary>
            if FindDir "${1}${2}" &> /dev/null; then
                local readonly var_command="git pull"

                cd "${1}${2}" && StopEvalAfterThriceFail $( eval "${var_command}" ) &> /dev/null
                return "${?}"

            # <summary> Clone new GitHub repository. </summary>
            elif FindDir "${1}${3}" &> /dev/null; then
                if ReadInput "Clone repo '${2}'?"; then
                    local readonly var_command="git clone https://github.com/${2}"

                    cd "${1}${3}" && StopEvalAfterThriceFail $( eval "${var_command}" ) &> /dev/null
                    return "${?}"
                fi
            else
                return 1
            fi
        }
    # </code>

    # <summary> Global parameters </summary>
    # <params>
        # <summary> Getters and Setters </summary>
            declare -g bool_is_installed_systemd=false
            IsInstalledCommand "systemd" &> /dev/null && bool_is_installed_systemd=true

            # declare -g bool_is_user_root=false
            # IsSudoUser &> /dev/null && bool_is_user_root=true

            declare -gl str_package_manager=""
            GetLinuxDistro &> /dev/null

        # <summary> Setters </summary>
            # <summary> Exit codes </summary>
            declare -gir int_code_partial_completion=255
            declare -gir int_code_skipped_operation=254
            declare -gir int_code_var_is_null=253
            declare -gir int_code_var_is_empty=252
            declare -gir int_code_var_is_not_bool=251
            declare -gir int_code_var_is_NAN=250
            declare -gir int_code_pointer_is_var=249
            declare -gir int_code_dir_is_null=248
            declare -gir int_code_file_is_null=247
            declare -gir int_code_file_is_not_executable=246
            declare -gir int_code_file_is_not_writable=245
            declare -gir int_code_file_is_not_readable=244
            declare -gir int_code_cmd_is_null=243
            declare -gi int_exit_code="${?}"

            # <summary>
            # Color coding
            # Reference URL: 'https://www.shellhacks.com/bash-colors'
            # </summary>
            declare -gr var_blinking_red='\033[0;31;5m'
            declare -gr var_blinking_yellow='\033[0;33;5m'
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
            declare -gr var_suffix_maybe="${var_yellow}Incomplete${var_reset_color}"
            declare -gr var_suffix_pass="${var_green}Success${var_reset_color}"
            declare -gr var_suffix_skip="${var_yellow}Skipped${var_reset_color}"

            # <summary> Output statement </summary>
            declare -gr str_output_partial_completion="${var_prefix_warn} One or more operations failed."
            declare -gr str_output_please_wait="The following operation may take a moment. ${var_blinking_yellow}Please wait.${var_reset_color}"
            declare -gr str_output_var_is_not_valid="${var_prefix_error} Invalid input."
    # </params>

# =========================================================================================== #

#
# YOUR CODE BELOW
#

exit 0