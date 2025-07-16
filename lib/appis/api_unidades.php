<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Configuración de la base de datos
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "embarques";

// Crear conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Consulta para obtener las unidades
$sql = "SELECT idunidad, unidad FROM unidades WHERE estado = 1";
$result = $conn->query($sql);

$unidades = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $unidades[] = $row;
    }
}

$conn->close();

http_response_code(200);
echo json_encode($unidades);
?>