#To fill an array $words with just the matches, use the command
$string1 = "woo hoo, let's go to the zoo."
$words1 = ([regex]::matches($string1, "\woo") | %{$_.value})
$words1

$string2 = "Cookbook"
$words2 = ([regex]::matches($string2, "\woo\w") | %{$_.value})
$words2

# For example, the code will match “Cook” and “book“, whereas
# without the IgnoreCase option only “book” would match.
[regex]::matches($string2, "[a-z]ook", "IgnoreCase")


# Notice the single quotes around the replacement pattern.
# This is to keep PowerShell from interpreting “$1” before
# passing passing it to the Regex class. We could use double
# quotes if we also put back ticks in front of the dollar
# signs to escape them.
$string3 = “<i>big</i>”
$words3 = [regex]::Replace($string3 , "<i>(\w+)</i>", '$1 $1')
$words3