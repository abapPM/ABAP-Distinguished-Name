CLASS ltcl_tests DEFINITION FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT FINAL.

  PRIVATE SECTION.
    METHODS:
      parse FOR TESTING,
      parse_with_separator FOR TESTING,
      format FOR TESTING,
      format_with_separator FOR TESTING.

ENDCLASS.

CLASS ltcl_tests IMPLEMENTATION.

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
      ( key = 'O'  name = '"Alibaba (China) Technology Co., Ltd."' )
      ( key = 'L'  name = 'HangZhou' )
      ( key = 'SP' name = 'ZheJiang' )
      ( key = 'C'  name = 'CN' ) ).

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
