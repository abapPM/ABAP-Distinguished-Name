CLASS ltcl_distinguished_name DEFINITION FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT FINAL.

  PRIVATE SECTION.

    METHODS:
      parse FOR TESTING RAISING zcx_error,
      parse_semicolon FOR TESTING RAISING zcx_error,
      parse_keep_order FOR TESTING RAISING zcx_error,
      parse_uncommon FOR TESTING RAISING zcx_error,
      format FOR TESTING RAISING zcx_error,
      format_semicolon FOR TESTING RAISING zcx_error,
      format_with_spaces FOR TESTING RAISING zcx_error,
      format_keep_order FOR TESTING RAISING zcx_error,
      format_uncommon FOR TESTING RAISING zcx_error.

ENDCLASS.

CLASS ltcl_distinguished_name IMPLEMENTATION.

  METHOD parse.

    DATA(dn) = 'CN=Sectigo ECC Domain Validation Secure Server CA, O=Sectigo Limited, L=Salford, SP=Greater Manchester, C=GB'.

    DATA(exp) = VALUE zcl_distinguished_name=>ty_distinguished_name(
      ( key = 'CN' name = 'Sectigo ECC Domain Validation Secure Server CA' )
      ( key = 'O'  name = 'Sectigo Limited' )
      ( key = 'L'  name = 'Salford' )
      ( key = 'SP' name = 'Greater Manchester' )
      ( key = 'C'  name = 'GB' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_distinguished_name=>parse( dn )
      exp = exp ).

  ENDMETHOD.

  METHOD parse_semicolon.

    DATA(dn) = 'CN=Sectigo ECC Domain Validation Secure Server CA; O=Sectigo Limited; L=Salford; SP=Greater Manchester; C=GB'.

    DATA(exp) = VALUE zcl_distinguished_name=>ty_distinguished_name(
      ( key = 'CN' name = 'Sectigo ECC Domain Validation Secure Server CA' )
      ( key = 'O'  name = 'Sectigo Limited' )
      ( key = 'L'  name = 'Salford' )
      ( key = 'SP' name = 'Greater Manchester' )
      ( key = 'C'  name = 'GB' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_distinguished_name=>parse( name = dn separator = ';' )
      exp = exp ).

  ENDMETHOD.

  METHOD parse_keep_order.

    DATA(dn) = 'O=Sectigo Limited, CN=Sectigo ECC Domain Validation Secure Server CA, SP=Greater Manchester, L=Salford, C=GB'.

    DATA(exp) = VALUE zcl_distinguished_name=>ty_distinguished_name(
      ( key = 'O'  name = 'Sectigo Limited' )
      ( key = 'CN' name = 'Sectigo ECC Domain Validation Secure Server CA' )
      ( key = 'SP' name = 'Greater Manchester' )
      ( key = 'L'  name = 'Salford' )
      ( key = 'C'  name = 'GB' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_distinguished_name=>parse( name = dn common_order = abap_false )
      exp = exp ).

  ENDMETHOD.

  METHOD parse_uncommon.

    DATA(dn) = 'dNSName=github.com, dNSName=*.github.com'.

    DATA(exp) = VALUE zcl_distinguished_name=>ty_distinguished_name(
      ( key = 'dNSName' name = 'github.com' )
      ( key = 'dNSName' name = '*.github.com' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_distinguished_name=>parse( dn )
      exp = exp ).

  ENDMETHOD.

  METHOD format.

    DATA(dn) = VALUE zcl_distinguished_name=>ty_distinguished_name(
      ( key = 'CN' name = 'Sectigo ECC Domain Validation Secure Server CA' )
      ( key = 'SP' name = 'Greater Manchester' )
      ( key = 'L'  name = 'Salford' )
      ( key = 'O'  name = 'Sectigo Limited' )
      ( key = 'C'  name = 'GB' ) ).

    DATA(exp) = 'CN=Sectigo ECC Domain Validation Secure Server CA, O=Sectigo Limited, L=Salford, SP=Greater Manchester, C=GB'.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_distinguished_name=>format( dn )
      exp = exp ).

    DATA(dn_2) = VALUE zcl_distinguished_name=>ty_distinguished_name(
      ( key = 'O'  name = 'DigiCert, Inc.' )
      ( key = 'CN' name = 'DigiCert High Assurance TLS Hybrid ECC SHA256 2020 CA1' )
      ( key = 'C'  name = 'US' ) ).

    DATA(exp_2) = 'CN=DigiCert High Assurance TLS Hybrid ECC SHA256 2020 CA1, O="DigiCert\, Inc.", C=US'.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_distinguished_name=>format( dn_2 )
      exp = exp_2 ).

  ENDMETHOD.

  METHOD format_semicolon.

    DATA(dn) = VALUE zcl_distinguished_name=>ty_distinguished_name(
      ( key = 'CN' name = 'Sectigo ECC Domain Validation Secure Server CA' )
      ( key = 'SP' name = 'Greater Manchester' )
      ( key = 'L'  name = 'Salford' )
      ( key = 'O'  name = 'Sectigo Limited' )
      ( key = 'C'  name = 'GB' ) ).

    DATA(exp) = 'CN=Sectigo ECC Domain Validation Secure Server CA; O=Sectigo Limited; L=Salford; SP=Greater Manchester; C=GB'.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_distinguished_name=>format( name = dn separator = ';' )
      exp = exp ).

  ENDMETHOD.

  METHOD format_with_spaces.

    DATA(dn) = VALUE zcl_distinguished_name=>ty_distinguished_name(
      ( key = 'CN' name = 'Hello   World' ) ).

    DATA(exp) = 'CN="Hello   World"'.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_distinguished_name=>format( dn )
      exp = exp ).

  ENDMETHOD.

  METHOD format_keep_order.

    DATA(dn) = VALUE zcl_distinguished_name=>ty_distinguished_name(
      ( key = 'O'  name = 'Sectigo Limited' )
      ( key = 'CN' name = 'Sectigo ECC Domain Validation Secure Server CA' )
      ( key = 'SP' name = 'Greater Manchester' )
      ( key = 'L'  name = 'Salford' )
      ( key = 'C'  name = 'GB' ) ).

    DATA(exp) = 'O=Sectigo Limited, CN=Sectigo ECC Domain Validation Secure Server CA, SP=Greater Manchester, L=Salford, C=GB'.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_distinguished_name=>format( name = dn common_order = abap_false )
      exp = exp ).

    DATA(dn_2) = VALUE zcl_distinguished_name=>ty_distinguished_name(
      ( key = 'O'  name = 'DigiCert, Inc.' )
      ( key = 'CN' name = 'DigiCert High Assurance TLS Hybrid ECC SHA256 2020 CA1' )
      ( key = 'C'  name = 'US' ) ).

    DATA(exp_2) = 'O="DigiCert\, Inc.", CN=DigiCert High Assurance TLS Hybrid ECC SHA256 2020 CA1, C=US'.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_distinguished_name=>format( name = dn_2 common_order = abap_false )
      exp = exp_2 ).

  ENDMETHOD.

  METHOD format_uncommon.

    DATA(dn) = VALUE zcl_distinguished_name=>ty_distinguished_name(
      ( key = 'dNSName' name = 'github.com' )
      ( key = 'dNSName' name = '*.github.com' ) ).

    DATA(exp) = 'dNSName=github.com, dNSName=*.github.com'.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_distinguished_name=>format( dn )
      exp = exp ).

  ENDMETHOD.

ENDCLASS.
