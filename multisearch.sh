#!/bin/bash

print_help() {
    echo "Multisearch script v3.0 by alex-decode@github"
    echo ""
    echo "Script outputs paths to files that contain at least two of the given strings."
    echo "Additionally, it can output the lines in those files that contain the given strings."
    echo ""
    echo "Usage: $0 [options] search_string1 search_string2 [search_string3 ...]"
    echo ""
    echo "Options:"
    echo "    -p, --path         Specify the search path (default is current directory)."
    echo "    -h, --help         Print this help message."
    echo "    -l, --lines        Print the lines that contain the given strings."
    echo "    -n, --line-numbers Show line numbers."
    echo "    -t, --type <ext>   Search only files with the given extension."
    echo "    -i, --ignore-case  Perform case-insensitive search."
    echo "    -s, --strict       Show results only when all of the listed strings are present in a file."
    echo "    -m, --match-type   Specify match type: 'any' (default), 'two', or 'all'."
    echo "    -B <n>             Print n lines of leading context before matching lines."
    echo "    -A <n>             Print n lines of trailing context after matching lines."
    echo ""
    echo "Examples:"
    echo "    multisearch apple pear banana"
    echo "    multisearch pear banana -p ~/foo/bar"
    echo "    multisearch apple banana -l"
    echo "    multisearch apple banana -t txt -i"
    echo "    multisearch apple banana -s"
    echo "    multisearch apple banana -l -B 2 -A 2"
}

# Default values
search_path="."
print_lines=false
file_extension=""
ignore_case=true
match_type="two"
context_before=0
context_after=0
show_line_numbers=false

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -p|--path)
            search_path="$2"
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        -l|--lines)
            print_lines=true
            ;;
        -t|--type)
            file_extension="$2"
            shift
            ;;
        -i|--ignore-case)
            ignore_case=true
            ;;
        -s|--strict)
            match_type="all"
            ;;
        -m|--match-type)
            match_type="$2"
            shift
            ;;
        -B)
            context_before="$2"
            shift
            ;;
        -A)
            context_after="$2"
            shift
            ;;
        -n|--line-numbers)
            show_line_numbers=true
            ;;
        *)
            if [[ "$1" =~ ^- ]]; then
                echo "Unknown option: $1"
                print_help
                exit 1
            else
                search_strings+=("$1")
            fi
            ;;
    esac
    shift
done

if [ ${#search_strings[@]} -lt 1 ]; then
    echo "Error: At least one search string is required."
    print_help
    exit 1
fi

# Function to check if a file contains all search strings
contains_all_strings() {
    local file="$1"
    shift
    for string in "$@"; do
        if ! grep $grep_options -q "$string" "$file"; then
            return 1
        fi
    done
    return 0
}

# Function to check if a file contains at least two search strings
contains_at_least_two_strings() {
    local file="$1"
    shift
    local match_count=0
    for string in "$@"; do
        if grep $grep_options -q "$string" "$file"; then
            match_count=$((match_count + 1))
        fi
        if [ "$match_count" -ge 2 ]; then
            return 0
        fi
    done
    return 1
}

# Function to check if a file contains at least one search string
contains_at_least_one_string() {
    local file="$1"
    shift
    for string in "$@"; do
        if grep $grep_options -q "$string" "$file"; then
            return 0
        fi
    done
    return 1
}

# Function to print lines containing the search strings based on match type
print_matching_lines() {
    local file="$1"
    shift
    local pattern=$(IFS="|"; echo "${*}")
    local grep_command="grep --color=always"
    [ "$show_line_numbers" = true ] && grep_command+=" -n"
    grep_command+=" $grep_options -E \"$pattern\" \"$file\""
    eval "$grep_command"
}

# Find command to search files with optional extension filtering
find_command="find \"$search_path\" -type f"
if [ -n "$file_extension" ]; then
    find_command+=" -name \"*.$file_extension\""
fi

# Set grep options based on flags
grep_options=""
[ "$ignore_case" = true ] && grep_options+=" -i"
[ "$context_before" -gt 0 ] && grep_options+=" -B $context_before"
[ "$context_after" -gt 0 ] && grep_options+=" -A $context_after"

# Execute find command and process each file
eval "$find_command" | while read -r file; do
    case "$match_type" in
        all)
            if contains_all_strings "$file" "${search_strings[@]}"; then
                echo "$file"
                [ "$print_lines" = true ] && print_matching_lines "$file" "${search_strings[@]}"
            fi
            ;;
        two)
            if contains_at_least_two_strings "$file" "${search_strings[@]}"; then
                echo "$file"
                [ "$print_lines" = true ] && print_matching_lines "$file" "${search_strings[@]}"
            fi
            ;;
        any)
            if contains_at_least_one_string "$file" "${search_strings[@]}"; then
                echo "$file"
                [ "$print_lines" = true ] && print_matching_lines "$file" "${search_strings[@]}"
            fi
            ;;
        *)
            echo "Unknown match type: $match_type"
            print_help
            exit 1
            ;;
    esac
done

