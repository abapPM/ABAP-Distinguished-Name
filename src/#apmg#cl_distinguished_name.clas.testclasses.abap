CLASS ltcl_tests DEFINITION FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT FINAL.

  PRIVATE SECTION.
    METHODS:
      test_trim FOR TESTING,
      test_escape FOR TESTING,
      test_unescape FOR TESTING,
      test_unquote FOR TESTING,
      parse FOR TESTING,
      parse_with_separator FOR TESTING,
      parse_with_escaped_chars FOR TESTING,
      format FOR TESTING,
      format_with_separator FOR TESTING.

ENDCLASS.

CLASS /apmg/cl_distinguished_name DEFINITION LOCAL FRIENDS ltcl_tests.

CLASS ltcl_tests IMPLEMENTATION.

  METHOD test_trim.

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_trim( `  Test` )
      exp = 'Test'
      msg = 'Remove leading spaces' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_trim( `Test  ` )
      exp = 'Test'
      msg = 'Remove trailing spaces' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_trim( `   Test  ` )
      exp = 'Test'
      msg = 'Remove leading and trailing spaces' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_trim( `  Test Me   All ` )
      exp = 'Test Me   All'
      msg = 'Preserve other spaces' ).

  ENDMETHOD.

  METHOD test_escape.

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_escape( value = 'Test,Value' separator = ',' )
      exp = '"Test,Value"'
      msg = 'Test escaping comma with comma separator' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_escape( value = 'Test;Value' separator = ';' )
      exp = '"Test;Value"'
      msg = 'Test escaping semicolon with semicolon separator' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_escape( value = 'City=Value' separator = ',' )
      exp = '"City=Value"'
      msg = 'Test escaping equals sign' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_escape( value = 'State+Value' separator = ',' )
      exp = '"State+Value"'
      msg = 'Test escaping plus sign' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_escape( value = 'Country<Value' separator = ',' )
      exp = '"Country<Value"'
      msg = 'Test escaping less than' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_escape( value = 'Unit>Value' separator = ',' )
      exp = '"Unit>Value"'
      msg = 'Test escaping greater than' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_escape( value = 'Street#Value' separator = ',' )
      exp = '"Street#Value"'
      msg = 'Test escaping hash' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_escape( value = 'Category"Value' separator = ',' )
      exp = '"Category\"Value"'
      msg = 'Test escaping quotes (should be escaped inside quoted string)' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_escape( value = 'Serial\Value' separator = ',' )
      exp = 'Serial\Value'
      msg = 'Test escaping backslash' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_escape( value = ` Title ` separator = ',' )
      exp = '" Title "'
      msg = 'Test leading/trailing spaces (should be quoted)' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_escape( value = 'Desc  Multiple  Spaces' separator = ',' )
      exp = '"Desc  Multiple  Spaces"'
      msg = 'Test multiple consecutive spaces (should be quoted)' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_escape( value = 'SimpleValue' separator = ',' )
      exp = 'SimpleValue'
      msg = 'Test simple value (no escaping needed)' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_escape( value = 'apm is great' separator = ',' )
      exp = 'apm is great'
      msg = 'Test value with individual spaces (no escaping needed)' ).

  ENDMETHOD.

  METHOD test_unescape.

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unescape( 'Test\\Value' )
      exp = 'Test\Value'
      msg = 'Test unescaping backslash' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unescape( 'Test\"Quote' )
      exp = 'Test"Quote'
      msg = 'Test unescaping quote' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unescape( 'Test\=Equal' )
      exp = 'Test=Equal'
      msg = 'Test unescaping equals' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unescape( 'Test\+Plus' )
      exp = 'Test+Plus'
      msg = 'Test unescaping plus' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unescape( 'Test\<Less' )
      exp = 'Test<Less'
      msg = 'Test unescaping less than' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unescape( 'Test\>Greater' )
      exp = 'Test>Greater'
      msg = 'Test unescaping greater than' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unescape( 'Test\#Hash' )
      exp = 'Test#Hash'
      msg = 'Test unescaping hash' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unescape( 'Test\;Semicolon' )
      exp = 'Test;Semicolon'
      msg = 'Test unescaping semicolon' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unescape( '"Test\"Quote"' )
      exp = 'Test"Quote'
      msg = 'Test unescaping from quoted string' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unescape( 'SimpleValue' )
      exp = 'SimpleValue'
      msg = 'Test value without escapes' ).

  ENDMETHOD.

  METHOD test_unquote.

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unquote( '"Quoted Value"' )
      exp = 'Quoted Value'
      msg = 'Test unquoting simple quoted value' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unquote( '"Value with spaces"' )
      exp = 'Value with spaces'
      msg = 'Test unquoting value with spaces' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unquote( '"Value,with,commas"' )
      exp = 'Value,with,commas'
      msg = 'Test unquoting value with commas' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unquote( '"Value with \"escaped\" quotes"' )
      exp = 'Value with \"escaped\" quotes'
      msg = 'Test unquoting value with escaped quotes inside' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unquote( 'SimpleValue' )
      exp = 'SimpleValue'
      msg = 'Test value without quotes (should remain unchanged)' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unquote( '"Incomplete quote' )
      exp = '"Incomplete quote'
      msg = 'Test value with only opening quote (should remain unchanged)' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unquote( 'Incomplete quote"' )
      exp = 'Incomplete quote"'
      msg = 'Test value with only closing quote (should remain unchanged)' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unquote( '""' )
      exp = ''
      msg = 'Test empty quoted string' ).

    cl_abap_unit_assert=>assert_equals(
      act = /apmg/cl_distinguished_name=>_unquote( '"A"' )
      exp = 'A'
      msg = 'Test single character quoted' ).

  ENDMETHOD.

  METHOD parse.

    DATA(dn) = 'CN=Sectigo ECC Domain Validation Secure Server CA, O=Sectigo Limited,'
      && ' L=Salford, SP=Greater Manchester, C=GB'.

    DATA(act) = /apmg/cl_distinguished_name=>parse( dn ).

    DATA(exp) = VALUE /apmg/cl_distinguished_name=>ty_distinguished_name(
      ( key = 'CN' name = 'Sectigo ECC Domain Validation Secure Server CA' )
      ( key = 'O'  name = 'Sectigo Limited' )
      ( key = 'L'  name = 'Salford' )
      ( key = 'SP' name = 'Greater Manchester' )
      ( key = 'C'  name = 'GB' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = act
      exp = exp ).

  ENDMETHOD.

  METHOD parse_with_separator.

    DATA(dn) = 'CN=*.dingtalk.com, O="Alibaba (China) Technology Co., Ltd.", L=HangZhou, SP=ZheJiang, C=CN'.

    DATA(act) = /apmg/cl_distinguished_name=>parse( dn ).

    DATA(exp) = VALUE /apmg/cl_distinguished_name=>ty_distinguished_name(
      ( key = 'CN' name = '*.dingtalk.com' )
      ( key = 'O'  name = 'Alibaba (China) Technology Co., Ltd.' )
      ( key = 'L'  name = 'HangZhou' )
      ( key = 'SP' name = 'ZheJiang' )
      ( key = 'C'  name = 'CN' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = act
      exp = exp ).

  ENDMETHOD.

  METHOD parse_with_escaped_chars.

    DATA(dn) = 'CN=test.com   ,    O=My Org\,with   Comma, L   =  More  Spaces   , SP=Toronto\=Ontario, C=CA'.

    DATA(act) = /apmg/cl_distinguished_name=>parse( dn ).

    DATA(exp) = VALUE /apmg/cl_distinguished_name=>ty_distinguished_name(
      ( key = 'CN' name = 'test.com' )
      ( key = 'O'  name = 'My Org,with   Comma' )
      ( key = 'L'  name = 'More  Spaces' )
      ( key = 'SP' name = 'Toronto=Ontario' )
      ( key = 'C'  name = 'CA' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = act
      exp = exp ).

  ENDMETHOD.

  METHOD format.

    DATA(dn) = VALUE /apmg/cl_distinguished_name=>ty_distinguished_name(
      ( key = 'CN' name = 'Sectigo ECC Domain Validation Secure Server CA' )
      ( key = 'O'  name = 'Sectigo Limited' )
      ( key = 'L'  name = 'Salford' )
      ( key = 'SP' name = 'Greater Manchester' )
      ( key = 'C'  name = 'GB' ) ).

    DATA(act) = /apmg/cl_distinguished_name=>format( dn ).

    DATA(exp) = 'CN=Sectigo ECC Domain Validation Secure Server CA, O=Sectigo Limited,'
      && ' L=Salford, SP=Greater Manchester, C=GB'.

    cl_abap_unit_assert=>assert_equals(
      act = act
      exp = exp ).

  ENDMETHOD.

  METHOD format_with_separator.

    DATA(dn) = VALUE /apmg/cl_distinguished_name=>ty_distinguished_name(
      ( key = 'CN' name = '*.dingtalk.com' )
      ( key = 'O'  name = '"Alibaba (China) Technology Co., Ltd."' )
      ( key = 'L'  name = 'HangZhou' )
      ( key = 'SP' name = 'ZheJiang' )
      ( key = 'C'  name = 'CN' ) ).

    DATA(act) = /apmg/cl_distinguished_name=>format( dn ).

    DATA(exp) = 'CN=*.dingtalk.com, O="Alibaba (China) Technology Co., Ltd.", L=HangZhou, SP=ZheJiang, C=CN'.

    cl_abap_unit_assert=>assert_equals(
      act = act
      exp = exp ).

  ENDMETHOD.
ENDCLASS.
