import 'dart:async';
import 'dart:io';

import 'package:galileo_mysql/galileo_mysql.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:isolate';
import 'assets/jsonString.dart' as data;

void main() async {
  //GET JSON FROM API
  ReceivePort receiverPort = ReceivePort();
  bool bandera = true;
  var isolate;
  while (bandera) {
    print("Menú \n");
    print("1 -> Insertar 10,000 registros");
    print("2 -> Eliminar 10,000 registros");
    print("3 -> Salir y liberar Isolate");
    var opt = stdin.readLineSync(encoding: utf8);

    switch (int.parse(opt!)) {
      case 1:
        try {
          isolate = await Isolate.spawn(insertRows, receiverPort.sendPort);
          receiverPort.listen((message) {
            stdout.write('Receiving: ' + message.toString() + ', ');
          });
        } catch (e) {
          print(e.toString());
        }
        break;
      case 2:
        try {
          var res = await deleteTable();
          print("Datos borrados con éxito");
        } catch (e) {
          print(e);
        }
        break;
      case 3:
        if (isolate != null) {
          //print('Tiempo de execución: ' + time.toString() + ' milisegundos');
          stdout.writeln('Stopping Isolate.....');
          isolate.kill(priority: Isolate.immediate);
        }
        bandera = false;
        print('Adios');
    }
  }

  //Insertando los datos en la tabla

  //
}

Future<void> deleteTable() async {
  int count = 0;
  Timer.periodic(new Duration(milliseconds: 1), (Timer t) {
    count = t.tick;
  });
  MySqlConnection connection = await connectMysql();
  Results res = await connection.query('DELETE FROM ventas');
  print("Tiempo de ejecución de la eliminación: " +
      count.toString() +
      "milisegundos");
}

Future<MySqlConnection> connectMysql() async {
  var settings = ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'programador',
      password: '123456',
      db: 'practicaST');
  return await MySqlConnection.connect(settings);
}

Future<String> getJsonData() async {
  return await data.strin;
}

void insertRows(SendPort sendPort) async {
  MySqlConnection connection = await connectMysql();
  int rowsAfect = 0;
  Results? results;
  int downloads = 0;
  var api = await getJsonData();
  var jsonData = json.decode(api.toString());
  int count = 0;
  Timer.periodic(new Duration(seconds: 1), (Timer t) {
    count++;
  });
  while (downloads < 10) {
    //Decode string to JSON
    for (var item in jsonData) {
      results = await connection.query(
          'INSERT INTO ventas (genero, name, pais, ciudad, monto, etiqueta, teltrabajo, telmovil) values (?,?,?,?,?,?,?,?)',
          [
            item['genero'],
            item['name'],
            item['pais'],
            item['cuidad'],
            item['monto'],
            item['etiqueta'],
            item['teltrabajo'],
            item['telmovil'],
          ]);
      rowsAfect += 1;
    }
    downloads++;
  }
  // results = await connection.query(
  //     "LOAD DATA LOCAL INFILE 'C:/Users/Alberto Noche Rosas/Downloads/ActividadST2/assets/practica.csv' INTO TABLE ventas FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS (id, genero, name, pais, ciudad,monto,etiqueta,teltrabajo,telmovil);");
  //
  String msg = results!.affectedRows.toString() +
      " registros con tiempo de ejecución de " +
      count.toString() +
      " segundos";
  stdout.write('Se inserto:  ' + msg + ' - ');
  sendPort.send(rowsAfect);
}
