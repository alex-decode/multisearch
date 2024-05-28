# multisearch

```
Script outputs paths to files that contain at least two of the given strings.
Additionally, it can output the lines in those files that contain the given strings.

Usage: multisearch [options] search_string1 search_string2 [search_string3 ...]

Options:
    -p, --path         Specify the search path (default is current directory).
    -h, --help         Print this help message.
    -l, --lines        Print the lines that contain the given strings.
    -t, --type <ext>   Search only files with the given extension.
    -i, --ignore-case  Perform case-insensitive search.
    -s, --strict       Show results only when all of the listed strings are present in a file.
    -m, --match-type   Specify match type: 'any' (default), 'two', or 'all'.
    -B <n>             Print n lines of leading context before matching lines.
    -A <n>             Print n lines of trailing context after matching lines.

Examples:
    multisearch apple pear banana
    multisearch pear banana -p ~/foo/bar
    multisearch apple banana -l
    multisearch apple banana -t txt -i
    multisearch apple banana -s
    multisearch apple banana -l -B 2 -A 2
```
