$script:bookmarks_paths_by_key = @{}
$script:bookmarks_keys_by_path = @{}

function Set-Bookmark {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Id,
        [string] $Path = (Get-Location),
        [bool] $Persistent = $true)
    if (!(Test-Path $Path)) {
        Write-Error "Unable to set bookmark; path not found: $Path"
        return
    }
    $bookmark = Resolve-Path $Path
    $script:bookmarks_paths_by_key[$Id] = $Path
    $script:bookmarks_keys_by_path[$bookmark.ProviderPath] = $Id
    
    if ($Persistent) {
        Save-BookmarkStatus
    }
}

Set-Alias sb Set-Bookmark

function Use-Bookmark {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Id)
    $bookmark = $script:bookmarks_paths_by_key[$Id]
    if (!$bookmark) {
        Write-Error "No bookmark found for Id $Id"
        return
    }
    Set-Location $bookmark
}

Set-Alias ub Use-Bookmark
Set-Alias go Use-Bookmark

function Get-Bookmark {
    param(
        [string] $Id = $null)
    if ([string]::IsNullOrWhiteSpace($Id)) {
        $script:bookmarks_paths_by_key
    } else {
        $script:bookmarks_paths_by_key[$Id]
    }
}

Set-Alias gb Get-Bookmark

function Get-BookmarkKeys {
    $script:bookmarks_keys_by_path
}

function Clear-Bookmark {
    param(
        [string] $Id = $null,
        [bool] $Persistent = $true)
    if ([string]::IsNullOrWhiteSpace($Id)) {
        $path = (Get-Location).Path
        $bookmarkKey = $script:bookmarks_keys_by_path[$path]
        if ($bookmarkKey -ne $null) {
            $script:bookmarks_paths_by_key.Remove($bookmarkKey)
            $script:bookmarks_keys_by_path.Remove($path)
        }
    } else {
        $path = $script:bookmarks_paths_by_key[$Id]
        $script:bookmarks_paths_by_key.Remove($Id)
        $script:bookmarks_keys_by_path.Remove($path)
    }
    
    if ($Persistent) {
        Save-BookmarkStatus
    }
}

Set-Alias cb Clear-Bookmark

function Write-BookmarkStatus {
    $location = (Get-Location)
    $bookmarkKey = (Get-BookmarkKeys)[$location.Path]
    if ($bookmarkKey -ne $null) {
        write-host "[$bookmarkKey]" -Foreground Green
    }
}

function Save-BookmarkStatus {
    [CmdletBinding()]
    param()
    $filename = Join-Path $env:userprofile "PoshBookmarks.json"
    write-Verbose "Saving bookmarks to $filename..."
    $script:bookmarks_paths_by_key | convertto-json | out-file $filename    
}

function Restore-BookmarkStatus {
    [CmdletBinding()]
    param()
    $filename = Join-Path $env:userprofile "PoshBookmarks.json"
    
    if (Test-Path $filename) {    
        write-Verbose "Loading bookmarks from $filename..."
        $content = (get-content $filename | out-string)
        $obj = ConvertFrom-Json $content
        
        $obj.psobject.properties | 
            %{
                Set-Bookmark $_.Name $_.Value $false 
            }
    }    
}

Export-ModuleMember -Function *-*
Export-ModuleMember -Alias *
