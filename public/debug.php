<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h1>Debug Laravel</h1>";

// Test 1: Autoloader
echo "<h2>1. Autoloader Test</h2>";
if (file_exists(__DIR__ . '/../vendor/autoload.php')) {
    echo "✅ Autoloader trouvé<br>";
    require __DIR__ . '/../vendor/autoload.php';
    echo "✅ Autoloader chargé<br>";
} else {
    echo "❌ Autoloader non trouvé<br>";
    exit;
}

// Test 2: Bootstrap Laravel
echo "<h2>2. Bootstrap Laravel</h2>";
try {
    if (file_exists(__DIR__ . '/../bootstrap/app.php')) {
        echo "✅ Bootstrap trouvé<br>";
        $app = require_once __DIR__ . '/../bootstrap/app.php';
        echo "✅ Application Laravel créée<br>";
    } else {
        echo "❌ Bootstrap non trouvé<br>";
        exit;
    }
} catch (Exception $e) {
    echo "❌ Erreur bootstrap: " . $e->getMessage() . "<br>";
    exit;
}

// Test 3: Permissions
echo "<h2>3. Permissions</h2>";
$dirs = ['/app/storage', '/app/bootstrap/cache', '/app/storage/logs'];
foreach ($dirs as $dir) {
    if (is_writable($dir)) {
        echo "✅ $dir : Écriture OK<br>";
    } else {
        echo "❌ $dir : Pas d'écriture<br>";
    }
}

// Test 4: .env
echo "<h2>4. Configuration</h2>";
if (file_exists(__DIR__ . '/../.env')) {
    echo "✅ .env trouvé<br>";
} else {
    echo "❌ .env manquant<br>";
}

// Test 5: Clé application
try {
    $key = env('APP_KEY');
    if ($key) {
        echo "✅ APP_KEY définie<br>";
    } else {
        echo "❌ APP_KEY manquante<br>";
    }
} catch (Exception $e) {
    echo "❌ Erreur env: " . $e->getMessage() . "<br>";
}

echo "<p>Debug terminé.</p>";
?>