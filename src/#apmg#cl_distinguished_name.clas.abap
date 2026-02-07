CLASS /apmg/cl_distinguished_name DEFINITION
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
      "! Schema sapcryptolib
      "! https://me.sap.com/notes/2338952
      BEGIN OF c_schema,
        common_name         TYPE string VALUE 'CN',
        surname             TYPE string VALUE 'S',
        title               TYPE string VALUE 'T',
        description         TYPE string VALUE 'D',
        serial_number       TYPE string VALUE 'SN',
        business_category   TYPE string VALUE 'BC',
        organizational_unit TYPE string VALUE 'OU',
        organization        TYPE string VALUE 'O',
        locality            TYPE string VALUE 'L',
        street_address      TYPE string VALUE 'ST',
        state_or_province   TYPE string VALUE 'SP',
        country             TYPE string VALUE 'C',
      END OF c_schema,
      BEGIN OF c_schema_rfc2256 ##NEEDED,
        common_name         TYPE string VALUE 'CN',
        surname             TYPE string VALUE 'S',
        title               TYPE string VALUE 'T',
        description         TYPE string VALUE 'DESCRIPTION',
        serial_number       TYPE string VALUE 'SERIALNUMBER',
        business_category   TYPE string VALUE 'BUSINESSCATEGORY',
        organizational_unit TYPE string VALUE 'OU',
        organization        TYPE string VALUE 'O',
        locality            TYPE string VALUE 'L',
        street_address      TYPE string VALUE 'STREET',
        state_or_province   TYPE string VALUE 'ST',
        country             TYPE string VALUE 'C',
      END OF c_schema_rfc2256,
      BEGIN OF c_separators,
        comma     TYPE c VALUE ',',
        semicolon TYPE c VALUE ';',
      END OF c_separators.

    CLASS-METHODS parse
      IMPORTING
        !name         TYPE csequence
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
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS c_special TYPE c LENGTH 8 VALUE '",=+<>#;'.

    CLASS-METHODS _sort
      IMPORTING
        VALUE(name)   TYPE ty_distinguished_name
      RETURNING
        VALUE(result) TYPE ty_distinguished_name.

    CLASS-METHODS _escape
      IMPORTING
        !value        TYPE string
        !separator    TYPE c
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS _unescape
      IMPORTING
        !value        TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS _unquote
      IMPORTING
        !value        TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS _add_part
      IMPORTING
        !value TYPE string
      CHANGING
        !parts TYPE string_table.

    CLASS-METHODS _add_name_component
      IMPORTING
        !parts TYPE string_table
      CHANGING
        !name  TYPE ty_distinguished_name.

    CLASS-METHODS _trim
      IMPORTING
        !value        TYPE string
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.



CLASS /apmg/cl_distinguished_name IMPLEMENTATION.


  METHOD format.

    IF common_order = abap_true.
      name = _sort( name ).
    ENDIF.

    LOOP AT name ASSIGNING FIELD-SYMBOL(<name_component>).
      IF result IS NOT INITIAL.
        result = |{ result }{ separator } |.
      ENDIF.
      result = |{ result }{ <name_component>-key }=|
        && |{ _escape( value = <name_component>-name separator = separator ) }|.
    ENDLOOP.

  ENDMETHOD.


  METHOD parse.

    " Parse the DN string character by character, respecting quotes
    DATA(pos) = 0.
    DATA(char) = 'X'.
    DATA(part) = ``.
    DATA(in_quotes) = abap_false.
    DATA(escape_next) = abap_false.
    DATA(parts) = VALUE string_table( ).

    WHILE pos < strlen( name ).
      char = name+pos(1).

      IF escape_next = abap_true.
        " Escaped character - add as-is
        CONCATENATE part char INTO part RESPECTING BLANKS.
        escape_next = abap_false.
        pos = pos + 1.
        CONTINUE.
      ENDIF.

      IF char = '\'.
        " Escape character
        escape_next = abap_true.
        CONCATENATE part char INTO part RESPECTING BLANKS.
        pos = pos + 1.
        CONTINUE.
      ENDIF.

      IF char = '"'.
        " Toggle quote state
        in_quotes = xsdbool( in_quotes = abap_false ).
        CONCATENATE part char INTO part RESPECTING BLANKS.
        pos = pos + 1.
        CONTINUE.
      ENDIF.

      IF char = separator AND in_quotes = abap_false.
        " Separator outside quotes - split here
        _add_part(
          EXPORTING
            value = part
          CHANGING
            parts = parts ).

        part = ``.
        pos = pos + 1.

        " Skip whitespace after separator
        WHILE pos < strlen( name ) AND name+pos(1) = ` `.
          pos = pos + 1.
        ENDWHILE.
        CONTINUE.
      ENDIF.

      " Regular character
        CONCATENATE part char INTO part RESPECTING BLANKS.
      pos = pos + 1.
    ENDWHILE.

    " Add last part
    _add_part(
      EXPORTING
        value = part
      CHANGING
        parts = parts ).

    _add_name_component(
      EXPORTING
        parts = parts
      CHANGING
        name  = result ).

    IF common_order = abap_true.
      result = _sort( result ).
    ENDIF.

  ENDMETHOD.


  METHOD _add_name_component.

    DATA(equal_pos) = 0.
    DATA(value_start) = 0.
    DATA(name_component) = VALUE ty_name_component( ).

    " Parse each part into key=value pairs
    LOOP AT parts ASSIGNING FIELD-SYMBOL(<part>).
      CLEAR name_component.
      equal_pos   = find( val = <part> sub = '=' ).
      value_start = equal_pos + 1.
      IF equal_pos < 0.
        CONTINUE.
      ENDIF.
      name_component-key  = condense( <part>(equal_pos) ).
      name_component-name = _unescape( _trim( |{ <part>+value_start }| ) ).
      INSERT name_component INTO TABLE name.
    ENDLOOP.

  ENDMETHOD.


  METHOD _add_part.

    " Trim only leading/trailing spaces (preserve internal spaces and quotes)
    DATA(part) = _trim( value ).

    IF part IS NOT INITIAL.
      INSERT part INTO TABLE parts.
    ENDIF.

  ENDMETHOD.


  METHOD _escape.

    result = _unquote( value ).

    " Check if quoting is needed according to RFC 1779
    DATA(needs_quoting) = abap_false.

    " Check for leading/trailing spaces
    IF _trim( result ) <> result.
      needs_quoting = abap_true.
    ENDIF.

    " Check for consecutive spaces
    IF result CS `  `.
      needs_quoting = abap_true.
    ENDIF.

    " Check for special characters that require quoting
    IF result CA c_special OR result CA separator.
      needs_quoting = abap_true.
    ENDIF.

    " Escape quotes inside the quoted string
    IF needs_quoting = abap_true.
      " Escape backslashes first (double them)
      result = replace(
        val  = result
        sub  = '\'
        with = '\\'
        occ  = 0 ).

      " Inside quotes, escape quotes
      result = replace(
        val  = result
        sub  = '"'
        with = '\"'
        occ  = 0 ).
      result = |"{ result }"|.
    ELSE.
      " Not quoting, so escape special characters with backslash
      DO strlen( c_special ) TIMES.
        DATA(pos) = sy-index - 1.
        DATA(special_char) = c_special+pos(1).

        IF special_char <> '"'.
          result = replace(
            val  = result
            sub  = special_char
            with = '\' && special_char
            occ  = 0 ).
        ENDIF.
      ENDDO.
    ENDIF.

  ENDMETHOD.


  METHOD _sort.

    " Process common components in order
    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE c_schema TO FIELD-SYMBOL(<keyword>).
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


  METHOD _trim.
    result = condense( val = value from = `` ).
  ENDMETHOD.


  METHOD _unescape.

    " Process escape sequences
    DATA(pos) = 0.
    DATA(input) = _unquote( value ).
    DATA(escape_next) = abap_false.

    WHILE pos < strlen( input ).
      DATA(char) = input+pos(1).

      IF escape_next = abap_true.
        " Escaped character - add the character itself (backslash removed)
        result = result && char.
        escape_next = abap_false.
      ELSEIF char = '\'.
        escape_next = abap_true.
      ELSE.
        " Regular character
        result = result && char.
      ENDIF.

      pos = pos + 1.
    ENDWHILE.

  ENDMETHOD.


  METHOD _unquote.

    " According to RFC 1779, surrounding quotes are delimiters and should be removed
    " Check if value is quoted (starts and ends with quotes)
    result = value.
    DATA(len) = strlen( result ).

    IF len > 1 AND result(1) = '"'.
      IF substring( val = result off = len - 1 len = 1 ) = '"'.
        " Check if the quotes are delimiters (not escaped)
        " If the second character is a backslash, the first quote might be escaped
        IF substring( val = result off = len - 2 len = 1 ) <> '\'.
          len = len - 2.
          result = substring( val = result off = 1 len = len ).
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
