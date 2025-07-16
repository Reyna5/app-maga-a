<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "embarques";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

$sql = "SELECT idalmacen, nombre_almacen FROM almacenes WHERE estado = 1 ORDER BY idalmacen ASC";
$result = $conn->query($sql);

$almacenes = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $almacenes[] = $row;
    }
}

$conn->close();

http_response_code(200);
echo json_encode($almacenes);
?>