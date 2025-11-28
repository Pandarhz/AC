$dir = 'c:\Users\arhzf\AC\pictures'
Get-ChildItem -Path $dir -File | Sort-Object Name | ForEach-Object -Begin { $i = 1 } -Process {
    $ext = $_.Extension
    $newName = "$i$ext"
    Rename-Item -LiteralPath $_.FullName -NewName $newName
    $i++
}
Write-Output "Renaming complete."