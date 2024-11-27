# Этот скрипт сбрасывает Trial у IDE продуктов JetBrains в Windows 10.
# Поддерживаются следующие продукты:
# IntelliJ IDEA
# PhpStorm
# WebStorm
# PyCharm
# Rider
# CLion 
# GoLand

$ideList = @("intellij", "phpstorm", "webstorm", "pycharm", "rider", "clion", "goland");

$jetbrains = $env:APPDATA + "/JetBrains";

Write-Host "Вычисление файлов: $jetbrains \n";

$delete = @();

$delete += "PermanentUserId";

Get-ChildItem -Path $jetbrains 
| ForEach-Object {
    $ide = $false
    foreach($prefix in $ideList){ 
        if($_ -notlike "$prefix*") {
            continue;
        }
    }
    if(-not $ide){
        exit 1;
    }

    $delete += "$file/options/others.xml"
}

$map = @{}
foreach($file in $delete){
    $realpath = "$jetbrains/$file"
    if(-not (Test-Path $realpath -PathType Leaf)){
        continue;
    }
    $map[[char](65 + $map.Count)] = $file
}

if($map.Count -eq 0){
    exit 1
}

Write-Host "Файлы к удалению: "
foreach($key in $map.Keys){
    Write-Host "* ${key}: $($map.Keys[$key])" -ForegroundColor Red
}
Write-Host "" -NoNewline -ForegroundColor White

$input_ = Read-Host -Prompt "Отправьте символы, соответствующие файлам, которые не следует удалять (или пропустите):`n";
foreach ($sym in $input_.ToCharArray()) {
    $map.Remove($sym)
}
Write-Host "Удаление файлов...";
foreach($file in $map.Values){
    Write-Host "- $file" -ForegroundColor Red
    Remove-Item -Path $file
}

<# reg: #>

Write-Host "Удаляю значения из реестра... "
$regDelete = @{
    "HKEY_CURRENT_USER\Software\JavaSoft\Prefs" = @("/Jet/Brains./User/Id/On/Machine")
    "HKEY_CURRENT_USER\Software\JavaSoft\Prefs\jetbrains" = @("user_id_on_machine")
}
$promptQueue = @();

foreach($path in $regDelete.Keys){
    if ($null -eq $regDelete[$path] -or ($regDelete[$path].Count -eq 0)) {
        $promptQueue += @("DELETE", "`"$path`"", "/f")
    }
    else {
        foreach ($entries in $regDelete[$path]) {
            $promptQueue +=  @("DELETE", "`"$path`"", "/v", "`"$entry`"", "/f")
        }
    }
}


foreach ($regArgs in $promptQueue) {
    Write-Host "> $($regArgs -join " ") `n< " -NoNewline -ForegroundColor Green
    Start-Process reg.exe -ArgumentList $regArgs
}
Write-Host "Готово! Trial сброшен.\n";