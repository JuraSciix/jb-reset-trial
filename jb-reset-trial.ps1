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

$jetbrains = $env:APPDATA + "\JetBrains";

Write-Host "Вычисление файлов: $jetbrains";

$delete = @();

$delete += "PermanentUserId";

Get-ChildItem -Path $jetbrains | ForEach-Object {
    $ide = $false
    foreach($prefix in $ideList){ 
        if($_ -like "$prefix*") {
            $ide = $true;
            break;
        }
    }
    if($ide){
        $delete += "$_\options\other.xml";
    }
}

$map = @{}
foreach($file in $delete){
    $realpath = "$jetbrains/$file"
    if(Test-Path $realpath -PathType Leaf){
        $map[[char](65 + $map.Count)] = $file
    }
}

if($map.Count -ne 0){
    Write-Host "Файлы к удалению: "
    foreach($key in $map.Keys){
        Write-Host "* ${key}: $($map[$key])" -ForegroundColor Red
    }
    Write-Host "" -NoNewline -ForegroundColor White
    
    $input_ = Read-Host -Prompt "Отправьте символы, соответствующие файлам, которые не следует удалять (или пропустите):`n";
    foreach ($sym in $input_.ToCharArray()) {
        $map.Remove($sym)
    }
    
    Write-Host "Удаление файлов...";
    foreach($file in $map.Values){
        $realpath = "$jetbrains\$file"
        Write-Host "- $realpath" -ForegroundColor Red
        Remove-Item -Path $realpath
    }
}

<# reg: #>

Write-Host "Удаляю значения из реестра... "
$regDelete = @{
    "HKEY_CURRENT_USER\Software\JavaSoft\Prefs" = @("/Jet/Brains./User/Id/On/Machine")
    "HKEY_CURRENT_USER\Software\JavaSoft\Prefs\jetbrains" = @("user_id_on_machine")
}
$promptQueue = New-Object System.Collections.Generic.List[System.Object];

foreach($path in $regDelete.Keys){
    if ($null -eq $regDelete[$path] -or ($regDelete[$path].Count -eq 0)) {
        $promptQueue.Add("EG RDELETE `"$path`" /f")
    }
    else {
        foreach ($entry in $regDelete[$path]) {
            $promptQueue.Add("REG DELETE `"$path`" /v `"$entry`" /f")
        }
    }
}

foreach ($prompt in $promptQueue) {
    Write-Host "> $prompt" -ForegroundColor Green
    Write-Host "< " -NoNewline -ForegroundColor Green
    cmd.exe /c $prompt 
}

Write-Host "Готово! Trial сброшен.\n";
