#!/bin/bash sh

#
# Author(s):    Alex Portell <github.com/portellam>
#

# <summary> #1 - Command operation validation </summary>
# <code>
    # <summary> Append Pass or Fail given exit code. If Fail, call SaveExitCode. </summary>
    # <param name="$1"> the output statement </param>
    # <returns> output statement </returns>
    function AppendPassOrFail
    {
        if CheckIfVarIsValid $1 &> /dev/null; then
            echo -en "$1 "
        fi

        case $? in
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
    # <returns> exit code </returns>
    function SaveExitCode
    {
        int_exit_code=$?
    }

    # <summary> Attempt given command a given number of times before failure. </summary>
    # <param name="$1"> the command to execute </param>
    # <returns> exit code </returns>
    function TryThisXTimesBeforeFail
    {
        # <params>
        declare -i int_count=0
        declare -ir int_max_count_of_tries=3
        # </params>

        if ! CheckIfVarIsValid $1; then
            return $?
        fi

        while [[ $int_count -lt $int_max_count_of_tries ]]; do
            if eval $1; then
                return 0
            fi

            (( int_count++ ))
        done

        return 1
    }
# </code>

# <summary> #2 - Data-type and variable validation </summary>
# <code>
    # <summary> Check if the command is installed. </summary>
    # <param name="$1"> the command </param>
    # <returns> exit code </returns>
    #
    function CheckIfCommandIsInstalled
    {
        # <params>
        local readonly str_output_cmd_is_null="${var_prefix_error} Command '$1' is not installed."
        local readonly var_actual_install_path=$( command -v $1 )
        local readonly var_expected_install_path="/usr/bin/$1"
        # </params>

        if ! CheckIfVarIsValid $1; then
            return $?
        fi

        # if $( ! CheckIfVarIsValid $var_actual_install_path ) &> /dev/null || [[ "${var_actual_install_path}" != "${var_expected_install_path}" ]]; then
        if $( ! CheckIfVarIsValid $var_actual_install_path ) &> /dev/null; then
            echo -e $str_output_cmd_is_null
            return $int_code_cmd_is_null
        fi

        return 0
    }

    # <summary> Check if the value is a valid bool. </summary>
    # <param name="$1"> the value </param>
    # <returns> exit code </returns>
    #
    function CheckIfVarIsBool
    {
        # <params>
        local readonly str_output_var_is_incorrect_type="${var_prefix_error} Not a boolean."
        # </params>

        if ! CheckIfVarIsValid $1; then
            return $?
        fi

        case $1 in
            "true" | "false" )
                return 0;;

            * )
                echo -e $str_output_var_is_incorrect_type
                return $int_code_var_is_not_bool;;
        esac
    }

    # <summary> Check if the value is a valid number. </summary>
    # <param name="$1"> the value </param>
    # <returns> exit code </returns>
    #
    function CheckIfVarIsNum
    {
        # <params>
        local readonly str_output_var_is_NAN="${var_prefix_error} NaN."
        local readonly str_num_regex='^[0-9]+$'
        # </params>

        if ! CheckIfVarIsValid $1; then
            return $?
        fi

        if ! [[ $1 =~ $str_num_regex ]]; then
            echo -e $str_output_var_is_NAN
            return $int_code_var_is_NAN
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

    # <summary> Check if the directory exists. </summary>
    # <param name="$1"> the value </param>
    # <returns> exit code </returns>
    #
    function CheckIfDirExists
    {
        # <params>
        local readonly str_output_dir_is_null="${var_prefix_error} Directory '$1' does not exist."
        # </params>

        if ! CheckIfVarIsValid $1; then
            return $?
        fi

        if [[ ! -d "$1" ]]; then
            echo -e $str_output_dir_is_null
            return $int_code_dir_is_null
        fi

        return 0
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

        if ! CheckIfVarIsValid $1; then
            return $?
        fi

        if [[ ! -e "$1" ]]; then
            echo -e $str_output_file_is_null
            return $int_code_file_is_null
        fi

        return 0
    }

    # <summary> Parse exit code as boolean. If non-zero, return false. </summary>
    # <returns> boolean </returns>
    function ParseExitCodeAsBool
    {
        if [[ "$?" -ne 0 ]]; then
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
        local readonly str_file=$( basename $0 )
        local readonly str_output_user_is_not_root="${var_prefix_warn} User is not Sudo/Root. In terminal, enter: ${var_yellow}'sudo bash ${str_file}' ${var_reset_color}"
        # </params>

        if [[ $( whoami ) != "root" ]]; then
            echo -e $str_output_user_is_not_root
            return 1
        fi

        return 0
    }
# </code>

# <summary> #4 - File operation and validation </summary>
# <code>
    # <summary> Create a directory. </summary>
    # <param name="$1"> the directory </param>
    # <returns> exit code </returns>
    function CreateDir
    {
        # <params>
        local readonly str_output_fail="${var_prefix_fail} Could not create directory '$1'."
        # </params>

        if ! CheckIfDirExists $1; then
            return $?
        fi

        mkdir -p $1 || (
            echo -e $str_output_fail
            return 1
        )

        return 0
    }

    # <summary> Create a file. </summary>
    # <param name="$1"> the file </param>
    # <returns> exit code </returns>
    function CreateFile
    {
        # <params>
        local readonly str_output_fail="${var_prefix_fail} Could not create file '$1'."
        # </params>

        if CheckIfFileExists $1 &> /dev/null; then
            return 0
        fi

        touch $1 || (
            echo -e $str_output_fail
            return 1
        )

        return 0
    }

    # <summary> Delete a dir/file. </summary>
    # <param name="$1"> the file </param>
    # <returns> exit code </returns>
    function DeleteFile
    {
        # <params>
        local readonly str_output_fail="${var_prefix_fail} Could not delete file '$1'."
        # </params>

        if ! CheckIfFileExists $1; then
            return 0
        fi

        rm $1 || (
            echo -e $str_output_fail
            return 1
        )

        return 0
    }

    # <summary> Read input from a file. Declare '$var_file' before calling this function. </summary>
    # <param name="$1"> the file </param>
    # <param name="$var_file"> the file contents </param>
    # <returns> exit code </returns>
    function ReadFromFile
    {
        # <params>
        local readonly str_output_fail="${var_prefix_fail} Could not read from file '$1'."
        var_file=$( cat $1 )
        # </params>

        if ! CheckIfFileExists $1; then
            return $?
        fi

        if ! CheckIfVarIsValid ${var_file[@]}; then
            return $?
        fi

        return 0
    }

    # <summary> Write output to a file. Declare '$var_file' before calling this function. </summary>
    # <param name="$1"> the file </param>
    # <param name="$var_file"> the file contents </param>
    # <returns> exit code </returns>
    function WriteToFile
    {
        # <params>
        IFS=$'\n'
        local readonly str_output_fail="${var_prefix_fail} Could not write to file '$1'."
        # </params>

        if ! CheckIfFileExists $1; then
            return $?
        fi

        if ! CheckIfVarIsValid $var_file; then
            return $?
        fi

        # ( printf "%s\n" "${var_file[@]}" >> $1 ) || (
            # echo -e $str_output_fail
            # return 1
        # )

        for var_element in ${var_file[@]}; do
            echo -e $var_element >> $1 || (
                echo -e $str_output_fail
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
        # local str_package_manager=""
        local readonly str_output_distro_is_not_valid="${var_prefix_error} Distribution '$( lsb_release -is )' is not supported."
        local readonly str_output_kernel_is_not_valid="${var_prefix_error} Kernel '$( uname -o )' is not supported."
        local readonly str_OS_with_apt="debian bodhi deepin knoppix mint peppermint pop ubuntu kubuntu lubuntu xubuntu "
        local readonly str_OS_with_dnf_yum="redhat berry centos cern clearos elastix fedora fermi frameos mageia opensuse oracle scientific suse"
        local readonly str_OS_with_pacman="arch manjaro"
        local readonly str_OS_with_portage="gentoo"
        local readonly str_OS_with_urpmi="opensuse"
        local readonly str_OS_with_zypper="mandriva mageia"
        # </params>

        if ! CheckIfVarIsValid $str_kernel &> /dev/null; then
            return $?
        fi

        if ! CheckIfVarIsValid $str_operating_system &> /dev/null; then
            return $?
        fi

        if [[ "${str_kernel}" != *"linux"* ]]; then
            echo -e $str_output_kernel_is_not_valid
            return 1
        fi

        # <summary> Check if current Operating System matches Package Manager, and Check if PM is installed. </summary>
        # <returns> exit code </returns>
        function CheckLinuxDistro_GetPackageManagerByOS
        {
            if [[ ${str_OS_with_apt} =~ .*"${str_operating_system}".* ]]; then
                str_package_manager="apt"
                CheckIfCommandIsInstalled $str_package_manager &> /dev/null && return 0

            elif [[ ${str_OS_with_dnf_yum} =~ .*"${str_operating_system}".* ]]; then
                str_package_manager="dnf"
                CheckIfCommandIsInstalled $str_package_manager &> /dev/null && return 0

                str_package_manager="yum"
                CheckIfCommandIsInstalled $str_package_manager &> /dev/null && return 0

            elif [[ ${str_OS_with_pacman} =~ .*"${str_operating_system}".* ]]; then
                str_package_manager="pacman"
                CheckIfCommandIsInstalled $str_package_manager &> /dev/null && return 0

            elif [[ ${str_OS_with_portage} =~ .*"${str_operating_system}".* ]]; then
                str_package_manager="portage"
                CheckIfCommandIsInstalled $str_package_manager &> /dev/null && return 0

            elif [[ ${str_OS_with_urpmi} =~ .*"${str_operating_system}".* ]]; then
                str_package_manager="urpmi"
                CheckIfCommandIsInstalled $str_package_manager &> /dev/null && return 0

            elif [[ ${str_OS_with_zypper} =~ .*"${str_operating_system}".* ]]; then
                str_package_manager="zypper"
                CheckIfCommandIsInstalled $str_package_manager &> /dev/null && return 0

            else
                str_package_manager=""
                return 1
            fi

            return 1
        }

        if ! CheckLinuxDistro_GetPackageManagerByOS; then
            echo -e $str_output_distro_is_not_valid
            return 1
        fi

        return 0
    }

    # <summary> Test network connection to Internet. Ping DNS servers by address and name. </summary>
    # <param name="$1"> boolean to toggle verbosity </param>
    # <returns> exit code </returns>
    function TestNetwork
    {
        # <params>
        local bool=false
        # </params>

        if CheckIfVarIsBool $1 &> /dev/null && $1; then
            local bool=$1
        fi

        if $bool; then
            echo -en "Testing Internet connection...\t"
        fi

        ( ping -q -c 1 8.8.8.8 || ping -q -c 1 1.1.1.1 ) &> /dev/null || false

        if $bool; then
            AppendPassOrFail
            echo -en "Testing connection to DNS...\t"
        else
            SaveExitCode
        fi

        ( ping -q -c 1 www.google.com && ping -q -c 1 www.yandex.com ) &> /dev/null || false

        if $bool; then
            AppendPassOrFail
        else
            SaveExitCode
        fi

        if [[ $int_exit_code -ne 0 ]]; then
            echo -e "Failed to ping Internet/DNS servers. Check network settings or firewall, and try again."
        fi

        return $int_exit_code
    }
# </code>

# <summary> #6 - User input </summary>
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

        if CheckIfVarIsValid $1 &> /dev/null; then
            str_output="$1 "
        fi

        declare -r str_output+="${var_green}[Y/n]:${var_reset_color}"

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
        local readonly var_min=$2
        local readonly var_max=$3
        local str_output=""
        local readonly str_output_extrema_are_not_valid="${var_prefix_error} Extrema are not valid."
        var_input=""
        # </params>

        if ( ! CheckIfVarIsNum $var_min || ! CheckIfVarIsNum $var_max ) &> /dev/null ; then
            echo -e $str_output_extrema_are_not_valid
            return 1
        fi

        if CheckIfVarIsValid $1 &> /dev/null; then
            str_output="$1 "
        fi

        readonly str_output+="${var_green}[${var_min}-${var_max}]:${var_reset_color}"

        # <summary> Read input </summary>
        while [[ $int_count -le $int_max_count ]]; do

            # <summary> After given number of attempts, input is set to first choice. </summary>
            if [[ $int_count -ge $int_max_count ]]; then
                var_input=$var_min
                echo -e "Exceeded max attempts. Choice is set to default: ${var_input}"
                break
            fi

            # <summary> Append output. </summary>
            echo -en "${str_output} "
            read var_input

            # <summary> Check if input is valid. </summary>
            if CheckIfVarIsNum $var_input && [[ $var_input -ge $var_min && $var_input -le $var_max ]]; then
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

        # <summary> Minimum multiple choice are two answers. </summary>
        if ( ! CheckIfVarIsValid $2 || ! CheckIfVarIsValid $3 ) &> /dev/null; then
            SaveExitCode
            echo -e $str_output_multiple_choice_not_valid
            return $int_exit_code
        fi

        arr_input+=( $2 )
        arr_input+=( $3 )

        if CheckIfVarIsValid $4 &> /dev/null; then arr_input+=( $4 ); fi
        if CheckIfVarIsValid $5 &> /dev/null; then arr_input+=( $5 ); fi
        if CheckIfVarIsValid $6 &> /dev/null; then arr_input+=( $6 ); fi
        if CheckIfVarIsValid $7 &> /dev/null; then arr_input+=( $7 ); fi
        if CheckIfVarIsValid $8 &> /dev/null; then arr_input+=( $8 ); fi
        if CheckIfVarIsValid $9 &> /dev/null; then arr_input+=( $9 ); fi

        if CheckIfVarIsValid $1 &> /dev/null; then
            str_output="$1 "
        fi

        readonly str_output+="${var_green}[${arr_input[@]}]:${var_reset_color}"

        # <summary> Read input </summary>
        for int_count in {0..2}; do
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
    # <parameter name="$1"> nullable output statement </parameter>
    # <param name="$2" name="$3" name="$4" name="$5" name="$6" name="$7" name="$8"> multiple choice </param>
    # <param name="$var_input"> the answer </param>
    # <returns> the answer </returns>
    #
    function ReadMultipleChoiceMatchCase
    {
        # <params>
        declare -a arr_input=()
        local str_output=""
        local readonly str_output_multiple_choice_not_valid="${var_prefix_error} Insufficient multiple choice answers."
        var_input=""
        # </params>

        # <summary> Minimum multiple choice are two answers. </summary>
        if ( ! CheckIfVarIsValid $2 || ! CheckIfVarIsValid $3 ) &> /dev/null; then
            echo -e $str_output_multiple_choice_not_valid
            return 1;
        fi

        arr_input+=( $2 )
        arr_input+=( $3 )

        if CheckIfVarIsValid $4 &> /dev/null; then arr_input+=( $4 ); fi
        if CheckIfVarIsValid $5 &> /dev/null; then arr_input+=( $5 ); fi
        if CheckIfVarIsValid $6 &> /dev/null; then arr_input+=( $6 ); fi
        if CheckIfVarIsValid $7 &> /dev/null; then arr_input+=( $7 ); fi
        if CheckIfVarIsValid $8 &> /dev/null; then arr_input+=( $8 ); fi
        if CheckIfVarIsValid $9 &> /dev/null; then arr_input+=( $9 ); fi

        if CheckIfVarIsValid $1 &> /dev/null; then
            str_output="$1 "
        fi

        readonly str_output+="${var_green}[${arr_input[@]}]:${var_reset_color}"

        # <summary> Read input </summary>
        for int_count in {0..2}; do
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
    # <returns> exit code </returns>
    function CheckIfPackageExists
    {
        # <params>
        local str_commands_to_execute=""
        local readonly str_output="${var_prefix_fail}: Command '${str_package_manager}' is not supported."
        # </params>

        if ! CheckIfVarIsValid $1; then
            return 1
        fi

        if ! CheckIfVarIsValid $str_package_manager; then
            return $?
        fi

        case $str_package_manager in
            "apt" )
                str_commands_to_execute="apt list $1"
                ;;

            "dnf" )
                str_commands_to_execute="dnf search $1"
                ;;

            "pacman" )
                str_commands_to_execute="pacman -Ss $1"
                ;;

            "gentoo" )
                str_commands_to_execute="emerge --search $1"
                ;;

            "urpmi" )
                str_commands_to_execute="urpmq $1"
                ;;

            "yum" )
                str_commands_to_execute="yum search $1"
                ;;

            "zypper" )
                str_commands_to_execute="zypper se $1"
                ;;

            * )
                echo -e $str_output
                return 1
                ;;
        esac

        eval $str_commands_to_execute || return 1
    }

    # <summary> Distro-agnostic, Install a software package. </summary>
    # <returns> exit code </returns>
    function InstallPackage
    {
        # <params>
        local str_commands_to_execute=""
        local readonly str_output="${var_prefix_fail}: Command '${str_package_manager}' is not supported."
        # </params>

        if ! CheckIfVarIsValid $1; then
            return 1
        fi

        if ! CheckIfVarIsValid $str_package_manager; then
            return $?
        fi

        # <summary> Auto-update and auto-install selected packages </summary>
        case $str_package_manager in
            "apt" )
                str_commands_to_execute="apt update && apt full-upgrade -y && apt install -y $1"
                ;;

            "dnf" )
                str_commands_to_execute="dnf upgrade && dnf install $1"
                ;;

            "pacman" )
                str_commands_to_execute="pacman -Syu && pacman -S $1"
                ;;

            "gentoo" )
                str_commands_to_execute="emerge -u @world && emerge www-client/$1"
                ;;

            "urpmi" )
                str_commands_to_execute="urpmi --auto-update && urpmi $1"
                ;;

            "yum" )
                str_commands_to_execute="yum update && yum install $1"
                ;;

            "zypper" )
                str_commands_to_execute="zypper refresh && zypper in $1"
                ;;

            * )
                echo -e $str_output
                return 1
                ;;
        esac

        eval $str_commands_to_execute || return 1
    }

    # <summary> Update or Clone repository given if it exists or not. </summary>
    # <param name="$1"> the directory </param>
    # <param name="$2"> the full repo name </param>
    # <param name="$3"> the username </param>
    # <returns> exit code </returns>
    function UpdateOrCloneGitRepo
    {
        # <summary> Update existing GitHub repository. </summary>
        if CheckIfDirExists "$1$2"; then
            cd "$1$2" && TryThisXTimesBeforeFail "git pull"
            return $?

        # <summary> Clone new GitHub repository. </summary>
        else
            if ReadInput "Clone repo '$2'?"; then
                cd "$1$3" && TryThisXTimesBeforeFail "git clone https://github.com/$2"
                return $?
            fi
        fi
    }
# </code>

# <summary> Global parameters </summary>
# <params>
    # <summary> Exit codes </summary>
    declare -gir int_code_partial_completion=255
    declare -gir int_code_var_is_null=253
    declare -gir int_code_var_is_empty=252
    declare -gir int_code_var_is_not_bool=251
    declare -gir int_code_var_is_NAN=250
    declare -gir int_code_dir_is_null=249
    declare -gir int_code_file_is_null=248
    declare -gir int_code_cmd_is_null=247
    declare -gi int_exit_code="$?"

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
    declare -gr var_suffix_pass="${var_green}Success${var_reset_color}"

    # <summary> Output statement </summary>
    declare -gr str_output_partial_completion="${var_prefix_warn} One or more operations failed."
    declare -gr str_output_var_is_not_valid="${var_prefix_error} Invalid input."
# </params>

#
# YOUR CODE BELOW
#

exit 0