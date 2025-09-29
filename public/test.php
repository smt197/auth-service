<?php
echo "FrankenPHP fonctionne !<br>";
echo "Répertoire courant: " . getcwd() . "<br>";
echo "Document root: " . $_SERVER['DOCUMENT_ROOT'] ?? 'Non défini' . "<br>";
echo "Request URI: " . $_SERVER['REQUEST_URI'] ?? 'Non défini' . "<br>";
echo "PHP Version: " . phpversion() . "<br>";

// Test Laravel autoloader
if (file_exists(__DIR__ . '/../vendor/autoload.php')) {
    echo "Autoloader Laravel: ✅ Trouvé<br>";
} else {
    echo "Autoloader Laravel: ❌ Non trouvé<br>";
}

// Test fichier index.php
if (file_exists(__DIR__ . '/index.php')) {
    echo "Index.php: ✅ Trouvé<br>";
} else {
    echo "Index.php: ❌ Non trouvé<br>";
}