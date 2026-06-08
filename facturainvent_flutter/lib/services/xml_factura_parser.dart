import 'package:xml/xml_events.dart';

class XMLProductoData {
  final String codigo;
  final String codigoBarras;
  final String nombre;
  final String cantidad;
  final String precioSinIVA;
  final bool tieneDescuento;
  final double porcentajeDescuento;

  XMLProductoData({
    required this.codigo,
    required this.codigoBarras,
    required this.nombre,
    required this.cantidad,
    required this.precioSinIVA,
    required this.tieneDescuento,
    required this.porcentajeDescuento,
  });
}

class XMLFacturaResultado {
  final String nit;
  final String nombreEmpresa;
  final List<XMLProductoData> productos;

  XMLFacturaResultado({
    required this.nit,
    required this.nombreEmpresa,
    required this.productos,
  });
}

/// Port directo de XMLFacturaParser.swift.
/// Procesa facturas DIAN (UBL Invoice envuelto en CDATA).
class XMLFacturaParser {
  final List<XMLProductoData> productos = [];
  String nit = '';
  String nombreEmpresa = '';

  String _codigoBarrasActual = '';
  String _codigoFacturaActual = '';
  String _nombreActual = '';
  String _cantidadActual = '';
  String _precioActual = '';
  String _lineExtensionActual = '';
  bool _tieneDescuentoTemp = false;

  String _etiquetaActual = '';
  bool _dentroDeItem = false;
  bool _dentroDeInvoiceLine = false;
  bool _dentroDeSellerID = false;
  bool _dentroDeStandardID = false;
  bool _dentroDeAdditionalID = false;
  bool _dentroDeSupplierParty = false;
  bool _dentroDeSenderParty = false;
  bool _dentroDeAllowanceCharge = false;
  String _schemeIDActual = '';

  /// Punto de entrada: lee el contenido completo del XML envoltorio,
  /// extrae el bloque CDATA (que contiene el `<Invoice>` real) y lo parsea.
  XMLFacturaResultado? parseContenidoXML(String contenido) {
    final inicio = contenido.indexOf('<![CDATA[');
    final fin = contenido.indexOf(']]>');
    if (inicio < 0 || fin < 0 || fin <= inicio) {
      return null;
    }

    final factura = contenido.substring(inicio + '<![CDATA['.length, fin);
    _procesarFacturaInterna(factura);

    return XMLFacturaResultado(
      nit: nit,
      nombreEmpresa: nombreEmpresa,
      productos: List.unmodifiable(productos),
    );
  }

  void _procesarFacturaInterna(String facturaXml) {
    final events = parseEvents(facturaXml);
    for (final event in events) {
      if (event is XmlStartElementEvent) {
        _onStartElement(event);
      } else if (event is XmlTextEvent) {
        _onCharacters(event.value);
      } else if (event is XmlCDATAEvent) {
        _onCharacters(event.value);
      } else if (event is XmlEndElementEvent) {
        _onEndElement(event);
      }
    }
  }

  void _onStartElement(XmlStartElementEvent event) {
    final name = _localName(event.name);
    _etiquetaActual = name;

    if (name == 'InvoiceLine') _dentroDeInvoiceLine = true;
    if (name == 'Item') _dentroDeItem = true;
    if (name == 'SellersItemIdentification') _dentroDeSellerID = true;
    if (name == 'StandardItemIdentification') _dentroDeStandardID = true;
    if (name == 'AdditionalItemIdentification') _dentroDeAdditionalID = true;
    if (name == 'AccountingSupplierParty') _dentroDeSupplierParty = true;
    if (name == 'SenderParty') _dentroDeSenderParty = true;
    if (name == 'AllowanceCharge') _dentroDeAllowanceCharge = true;

    if (name == 'ID') {
      _schemeIDActual = '';
      for (final attr in event.attributes) {
        if (attr.localName == 'schemeID' || attr.name == 'schemeID') {
          _schemeIDActual = attr.value;
          break;
        }
      }
    }
  }

  void _onCharacters(String texto) {
    final t = texto.trim();
    if (t.isEmpty) return;

    if ((_dentroDeSupplierParty || _dentroDeSenderParty) &&
        _etiquetaActual == 'CompanyID' &&
        nit.isEmpty) {
      nit += t;
    }
    if ((_dentroDeSupplierParty || _dentroDeSenderParty) &&
        _etiquetaActual == 'RegistrationName' &&
        nombreEmpresa.isEmpty) {
      nombreEmpresa += t;
    }

    if (!_dentroDeInvoiceLine) return;

    switch (_etiquetaActual) {
      case 'InvoicedQuantity':
        _cantidadActual += t;
      case 'ChargeIndicator':
        if (_dentroDeAllowanceCharge) {
          if (t == 'false') {
            _tieneDescuentoTemp = true;
          } else if (t == 'true') {
            _tieneDescuentoTemp = false;
          }
        }
      case 'LineExtensionAmount':
        if (_dentroDeInvoiceLine) {
          _lineExtensionActual += t;
        }
      case 'Description':
        if (_dentroDeItem) {
          _nombreActual += t.replaceAll('|', '').trim();
        }
      case 'ID':
        if (_dentroDeSellerID) {
          _codigoFacturaActual += t;
        } else if (_dentroDeStandardID) {
          if (_schemeIDActual == '010') {
            _codigoBarrasActual += t;
          } else if (_schemeIDActual == '999') {
            _codigoFacturaActual += t;
          }
        } else if (_dentroDeAdditionalID && _codigoFacturaActual.isEmpty) {
          _codigoFacturaActual += t;
        }
    }
  }

  void _onEndElement(XmlEndElementEvent event) {
    final name = _localName(event.name);

    if (name == 'Item') _dentroDeItem = false;
    if (name == 'SellersItemIdentification') _dentroDeSellerID = false;
    if (name == 'StandardItemIdentification') _dentroDeStandardID = false;
    if (name == 'AdditionalItemIdentification') _dentroDeAdditionalID = false;
    if (name == 'SenderParty') _dentroDeSenderParty = false;
    if (name == 'AccountingSupplierParty') _dentroDeSupplierParty = false;
    if (name == 'AllowanceCharge') _dentroDeAllowanceCharge = false;

    final cantidad = double.tryParse(_cantidadActual) ?? 1;
    final lineExtension = double.tryParse(_lineExtensionActual) ?? 0;
    final precioUnitario = cantidad > 0 ? lineExtension / cantidad : 0;
    _precioActual = precioUnitario.toStringAsFixed(2);

    if (name == 'InvoiceLine') {
      productos.add(XMLProductoData(
        codigo: _codigoFacturaActual,
        codigoBarras: _codigoBarrasActual,
        nombre: _nombreActual,
        cantidad: _cantidadActual,
        precioSinIVA: _precioActual,
        tieneDescuento: _tieneDescuentoTemp,
        porcentajeDescuento: 0.0,
      ));

      _codigoFacturaActual = '';
      _codigoBarrasActual = '';
      _nombreActual = '';
      _cantidadActual = '';
      _precioActual = '';
      _lineExtensionActual = '';
      _dentroDeInvoiceLine = false;
      _dentroDeItem = false;
      _tieneDescuentoTemp = false;
    }
  }

  String _localName(String qualifiedName) {
    final idx = qualifiedName.indexOf(':');
    return idx >= 0 ? qualifiedName.substring(idx + 1) : qualifiedName;
  }
}
