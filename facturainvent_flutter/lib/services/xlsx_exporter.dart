import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/producto_import.dart';

/// Port de exportarExcel.swift.
/// Genera un XLSX con tres columnas (código, precio, cantidad) sin encabezado,
/// aplicando descuentos y división por paquetes. Devuelve la URL del archivo.
Future<File?> exportarExcel(List<ProductoImport> productos) async {
  try {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet == null) return null;

    excel.rename(defaultSheet, 'Productos');
    final sheet = excel['Productos'];

    for (int i = 0; i < productos.length; i++) {
      final p = productos[i];
      final cantidadDouble = double.tryParse(p.cantidad) ?? 0;
      final cantidadInt = cantidadDouble.toInt();
      final totalPaquetes = cantidadInt * p.cantidadPaquetes;
      final codigo = p.codigoInterno.isEmpty ? 'Sin código' : p.codigoInterno;
      final precioRaw =
          double.tryParse(p.precioSinIVA.replaceAll(',', '.')) ?? 0;
      final precioConDescuento = (p.tieneDescuento && p.porcentajeDescuento > 0)
          ? precioRaw * (1 - p.porcentajeDescuento / 100)
          : precioRaw;
      final paquetes = p.cantidadPaquetes > 0 ? p.cantidadPaquetes : 1;
      final precioUnidad = precioConDescuento / paquetes;
      final precioFormateado = p.precioSinIVA.isEmpty
          ? '0.00'
          : precioUnidad.toStringAsFixed(2);

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i))
          .value = TextCellValue(codigo);

      final precioCell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i));
      precioCell.value = DoubleCellValue(double.parse(precioFormateado));
      precioCell.cellStyle = CellStyle(numberFormat: NumFormat.standard_2);

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i))
          .value = IntCellValue(totalPaquetes);
    }

    final bytes = excel.save();
    if (bytes == null) return null;

    final fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dir = await getApplicationDocumentsDirectory();
    final outFile = File('${dir.path}/productos-$fecha.xlsx');
    if (await outFile.exists()) {
      await outFile.delete();
    }
    await outFile.writeAsBytes(bytes);
    return outFile;
  } catch (e) {
    // ignore: avoid_print
    print('Error generando XLSX: $e');
    return null;
  }
}
