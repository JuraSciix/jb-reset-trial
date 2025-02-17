<?php

// Этот скрипт сбрасывает Trial у IDE продуктов JetBrains в Windows 10.
// Поддерживаются следующие продукты:
// IntelliJ IDEA
// PhpStorm
// WebStorm
// PyCharm
// Rider
// CLion 
// GoLand

$ideList = ["intellij", "phpstorm", "webstorm", "pycharm", "rider", "clion", "goland"];
$jetbrains = getenv('APPDATA') . "/JetBrains";

echo "Вычисление файлов: $jetbrains \n";

$delete = [];

$delete[] = "PermanentUserId";

foreach (scandir($jetbrains) as $file) {
	if (in_array($file, ['.', '..'], true)) {
		continue;
	}
	
	$ide = false;
	foreach ($ideList as $prefix) {
		if (stripos($file, $prefix) === 0) {
			$ide = true;
			break;
		}
	}
	
	if ($ide) {
		$delete[] = "$file/options/other.xml";
	}
}

$map = [];
foreach ($delete as $file) {
	$realpath = "$jetbrains/$file";
	if (file_exists($realpath)) {
		$map[chr(65 + sizeof($map))] = $file;
	}
}

if (!empty($map)) {
	echo "Файлы к удалению: \n";
	foreach ($map as $sym => $file) {
		echo "* $sym: $file \n";
	}
	echo "Отправьте символы, соответствующие файлам, которые не следует удалять (или пропустите):\n";
	$input = trim(fgets(STDIN));
	foreach (str_split($input) as $sym) {
		unset($map[$sym]);
	}
}

echo "Удаление файлов...\n";
foreach ($map as $file) {
	echo "- $file\n";
	unlink("$jetbrains/$file");
}

reg:
echo "Удаляю значения из реестра... \n";
$regDelete = array(
	"HKEY_CURRENT_USER\\Software\\JavaSoft\\Prefs" => ["/Jet/Brains./User/Id/On/Machine"],
	"HKEY_CURRENT_USER\\Software\\JavaSoft\\Prefs\\jetbrains" => ["user_id_on_machine"]
);
$promptQueue = [];
foreach ($regDelete as $path => $entries) {
	if (empty($entries)) {
		$promptQueue[] = "REG DELETE \"$path\" /f";
	} else {
		foreach ($entries as $entry) {
			$promptQueue[] = "REG DELETE \"$path\" /v \"$entry\" /f";
		}
	}
}
foreach ($promptQueue as $prompt) {
	echo "> $prompt \n";
	echo "< ";
	system($prompt);
}

echo "Готово! Trial сброшен.\n";

