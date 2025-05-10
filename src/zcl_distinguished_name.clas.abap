CLASS zcl_distinguished_name DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

************************************************************************
* Distinguished Name
*
* https://www.rfc-editor.org/rfc/rfc1779
*
* Copyright 2025 apm.to Inc. <https://apm.to>
* SPDX-License-Identifier: MIT
************************************************************************
  PUBLIC SECTION.

    CONSTANTS c_version TYPE string VALUE '1.0.0' ##NEEDED.

    TYPES:
      BEGIN OF ty_name_component,
        key  TYPE string,
        name TYPE string,
      END OF ty_name_component,
      ty_distinguished_name TYPE STANDARD TABLE OF ty_name_component WITH KEY key.

    CONSTANTS:
      "! X.520
      BEGIN OF c_keywords,
        common_name              TYPE string VALUE 'CN',
        organizational_unit_name TYPE string VALUE 'OU',
        organization_name        TYPE string VALUE 'O',
        locality_name            TYPE string VALUE 'L',
        state_or_province_name   TYPE string VALUE 'SP',
        state_name               TYPE string VALUE 'ST',
        country_name             TYPE string VALUE 'C',
      END OF c_keywords,
      BEGIN OF c_separators,
        comma     TYPE c VALUE ',',
        semicolon TYPE c VALUE ';',
      END OF c_separators.

    CLASS-METHODS parse
      IMPORTING
        VALUE(name)   TYPE csequence
        !separator    TYPE c DEFAULT c_separators-comma
        !common_order TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE ty_distinguished_name.

    CLASS-METHODS format
      IMPORTING
        VALUE(name)   TYPE ty_distinguished_name
        !separator    TYPE c DEFAULT c_separators-comma
        !common_order TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE string
      RAISING
        zcx_error.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS c_special TYPE c LENGTH 8 VALUE '",=+<>#;'.

    TYPES ty_c1 TYPE c LENGTH 1.

    CLASS-METHODS _sort
      IMPORTING
        VALUE(name)   TYPE ty_distinguished_name
      RETURNING
        VALUE(result) TYPE ty_distinguished_name.

    CLASS-METHODS _escape
      IMPORTING
        value         TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS _unescape
      IMPORTING
        value         TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS _special_to_hex
      IMPORTING
        value         TYPE ty_c1
      RETURNING
        VALUE(result) TYPE ty_c1.

ENDCLASS.



CLASS zcl_distinguished_name IMPLEMENTATION.


  METHOD format.

    IF common_order = abap_true.
      name = _sort( name ).
    ENDIF.

    LOOP AT name ASSIGNING FIELD-SYMBOL(<name_component>).
      IF result IS NOT INITIAL.
        result = |{ result }{ separator } |.
      ENDIF.
      result = |{ result }{ <name_component>-key }={ _escape( <name_component>-name ) }|.
    ENDLOOP.

  ENDMETHOD.


  METHOD parse.

    " Replace special characters with %xx so we can easily split the name
    DO strlen( c_special ) TIMES.
      DATA(pos) = sy-index - 1.
      name = replace(
        val  = name
        sub  = '\' && c_special+pos(1)
        with = _special_to_hex( c_special+pos(1) )
        occ  = 0 ).
    ENDDO.

    SPLIT name AT separator INTO TABLE DATA(parts).

    LOOP AT parts ASSIGNING FIELD-SYMBOL(<part>).
      DATA(name_component) = VALUE ty_name_component( ).
      SPLIT <part> AT '=' INTO name_component-key name_component-name.
      CONDENSE name_component-key NO-GAPS.

      " Revert %xx replacements
      DO strlen( c_special ) TIMES.
        pos = sy-index - 1.
        name = replace(
          val  = name
          sub  = _special_to_hex( c_special+pos(1) )
          with = '\' && c_special+pos(1)
          occ  = 0 ).
      ENDDO.

      name_component-name = _unescape( name_component-name ).
      INSERT name_component INTO TABLE result.
    ENDLOOP.

    IF common_order = abap_true.
      result = _sort( result ).
    ENDIF.

  ENDMETHOD.


  METHOD _escape.

    result = value.

    result = replace(
      val  = result
      sub  = '\\'
      with = '\'
      occ  = 0 ).

    DO strlen( c_special ) TIMES.
      DATA(pos) = sy-index - 1.
      result = replace(
        val  = result
        sub  = c_special+pos(1)
        with = '\' && c_special+pos(1)
        occ  = 0 ).
    ENDDO.

    " Multiple spaces also need to be quoted
    IF result <> value OR value CS `  `.
      result = |"{ result }"|.
    ENDIF.

  ENDMETHOD.


  METHOD _sort.

    " Process common components in order
    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE c_keywords TO FIELD-SYMBOL(<keyword>).
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      IF NOT line_exists( name[ key = <keyword> ] ).
        CONTINUE.
      ENDIF.

      INSERT name[ key = <keyword> ] INTO TABLE result.
      DELETE name WHERE key = <keyword>.
    ENDDO.

    " Add remaining components
    LOOP AT name ASSIGNING FIELD-SYMBOL(<name_component>).
      INSERT <name_component> INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD _special_to_hex.

    CASE value.
      WHEN '"'.
        result = '%22'.
      WHEN '#'.
        result = '%23'.
      WHEN '+'.
        result = '%2B'.
      WHEN ','.
        result = '%2C'.
      WHEN ';'.
        result = '%3B'.
      WHEN '<'.
        result = '%3C'.
      WHEN '='.
        result = '%3D'.
      WHEN '>'.
        result = '%3E'.
      WHEN OTHERS.
        ASSERT 1 = 2.
    ENDCASE.

  ENDMETHOD.


  METHOD _unescape.

    result = value.

    DATA(pos) = strlen( result ) - 1.
    IF result+pos(1) = '"'.
      result = result(pos).
    ENDIF.
    IF result(1) = '"'.
      result = result+1.
    ENDIF.

    DO strlen( c_special ) TIMES.
      pos = sy-index - 1.
      result = replace(
        val  = result
        sub  = '\' && c_special+pos(1)
        with = c_special+pos(1)
        occ  = 0 ).
    ENDDO.

    result = replace(
      val  = result
      sub  = '\\'
      with = '\'
      occ  = 0 ).

  ENDMETHOD.
ENDCLASS.
