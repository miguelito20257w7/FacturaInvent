import 'package:flutter_test/flutter_test.dart';

import 'package:facturainvent/services/xml_factura_parser.dart';

void main() {
  test('XMLFacturaParser sin CDATA devuelve null', () {
    final parser = XMLFacturaParser();
    final result = parser.parseContenidoXML('<root>no cdata</root>');
    expect(result, isNull);
  });

  test('XMLFacturaParser extrae empresa de CDATA mínimo', () {
    const xml = '''
<root>
<![CDATA[
<Invoice>
  <AccountingSupplierParty>
    <Party>
      <PartyTaxScheme>
        <CompanyID>900123456</CompanyID>
        <RegistrationName>Test S.A.</RegistrationName>
      </PartyTaxScheme>
    </Party>
  </AccountingSupplierParty>
</Invoice>
]]>
</root>
''';
    final parser = XMLFacturaParser();
    final result = parser.parseContenidoXML(xml);
    expect(result, isNotNull);
    expect(result!.nit, '900123456');
    expect(result.nombreEmpresa, 'Test S.A.');
    expect(result.productos, isEmpty);
  });

  test('XMLFacturaParser extrae InvoiceLine simple', () {
    const xml = '''
<root>
<![CDATA[
<Invoice>
  <AccountingSupplierParty>
    <Party>
      <PartyTaxScheme>
        <CompanyID>900</CompanyID>
        <RegistrationName>Test</RegistrationName>
      </PartyTaxScheme>
    </Party>
  </AccountingSupplierParty>
  <InvoiceLine>
    <InvoicedQuantity>6</InvoicedQuantity>
    <LineExtensionAmount>12000</LineExtensionAmount>
    <Item>
      <Description>PRODUCTO X</Description>
      <SellersItemIdentification>
        <ID>1001</ID>
      </SellersItemIdentification>
      <StandardItemIdentification>
        <ID schemeID="010">7702085012062</ID>
      </StandardItemIdentification>
    </Item>
  </InvoiceLine>
</Invoice>
]]>
</root>
''';
    final parser = XMLFacturaParser();
    final result = parser.parseContenidoXML(xml);
    expect(result!.productos, hasLength(1));
    final p = result.productos.first;
    expect(p.codigo, '1001');
    expect(p.codigoBarras, '7702085012062');
    expect(p.nombre, 'PRODUCTO X');
    expect(p.cantidad, '6');
    expect(p.precioSinIVA, '2000.00');
  });
}
