# PoshBookmarks
Simple PowerShell module to bookmark path locations in the shell.

# Available Functions
* `Set-Bookmark [name]` will create a bookmark at the current or specified location. (Alias: "sb")
* `Get-Bookmark` will return all saved bookmarks. (Alias: "gb")
* `Use-Bookmark [name]` will `Set-Location` to the current value of the bookmark. (Alias: "ub" and "go")
* `Clear-Bookmark [name]` will remove the bookmark entry for the specified name or current location (Alias: "cb")

# Details
* Bookmarks are saved to a file at `Join-Path $env:userprofile "PoshBookmarks.json"`

# Tips
If you override your `prompt` function (see PowerShell prompts) or otherwise include the following in your existing `prompt`, you will see an indicator when the current location is a bookmarked entry:

```powershell
function prompt {
    $result = ""

    $location = (Get-Location)
    $locationString = $location.ToString()
    if ($locationString.Length -gt 64) {
        $result += $locationString += "`r`n"
        $result += "PS"
    } else {
        $result += "PS $locationString"
    }

    $bookmarkKey = (Get-BookmarkKeys)[$location.Path]
    if ($bookmarkKey -ne $null) {
        $result += " [$bookmarkKey]"
    }

    "$result>"
}```
