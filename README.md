![Version](https://img.shields.io/endpoint?url=https://shield.abappm.com/github/abapPM/ABAP-Distinguished-Name/src/zcl_distinguished_name.clas.abap/c_version&label=Version&color=blue)

[![License](https://img.shields.io/github/license/abapPM/ABAP-Distinguished-Name?label=License&color=success)](https://github.com/abapPM/ABAP-Distinguished-Name/blob/main/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg?color=success)](https://github.com/abapPM/.github/blob/main/CODE_OF_CONDUCT.md)
[![REUSE Status](https://api.reuse.software/badge/github.com/abapPM/ABAP-Distinguished-Name)](https://api.reuse.software/info/github.com/abapPM/ABAP-Distinguished-Name)

# Distinguished Name

Parser and Formatter for Distinguished Names (RFC 1779)

NO WARRANTIES, [MIT License](https://github.com/abapPM/ABAP-Distinguished-Name/blob/main/LICENSE)

## Usage

Parse a distinguished name string:

```abap
DATA(input) = 'CN=Sectigo ECC Domain Validation Secure Server CA, O=Sectigo Limited, L=Salford, SP=Greater Manchester, C=GB'.

DATA(output) = zcl_distinguished_name=>parse( input ).

" Result
output = VALUE zcl_distinguished_name=>ty_distinguished_name(
  ( key = 'CN' name = 'Sectigo ECC Domain Validation Secure Server CA' )
  ( key = 'O'  name = 'Sectigo Limited' )
  ( key = 'L'  name = 'Salford' )
  ( key = 'SP' name = 'Greater Manchester' )
  ( key = 'C'  name = 'GB' ) ).
```

Format a distinguished name as a string:

```abap
DATA(input) = VALUE zcl_distinguished_name=>ty_distinguished_name(
  ( key = 'CN' name = 'Sectigo ECC Domain Validation Secure Server CA' )
  ( key = 'O'  name = 'Sectigo Limited' )
  ( key = 'L'  name = 'Salford' )
  ( key = 'SP' name = 'Greater Manchester' )
  ( key = 'C'  name = 'GB' ) ).

DATA(output) = zcl_distinguished_name=>format( input ).

" Result
output = 'CN=Sectigo ECC Domain Validation Secure Server CA, O=Sectigo Limited, L=Salford, SP=Greater Manchester, C=GB'.
```

Options:

- `separator`: Change from `,` (default) to `;` as a separator between name components
- `common_order`: Change from `abap_true` (default) to `abap_false` for keeping the name components in the input order

## Prerequisites

SAP Basis 7.50 or higher

## Installation

Install `distinguished-name` as a global module in your system using [apm](https://abappm.com).

or

Specify the `distinguished-name` module as a dependency in your project and import it to your namespace using [apm](https://abappm.com).

## Contributions

All contributions are welcome! Read our [Contribution Guidelines](https://github.com/abapPM/ABAP-Distinguished-Name/blob/main/CONTRIBUTING.md), fork this repo, and create a pull request.

You can install the developer version of ABAP Distinguished Name using [abapGit](https://github.com/abapGit/abapGit) by creating a new online repository for `https://github.com/abapPM/ABAP-Distinguished-Name`.

Recommended SAP package: `$DISTINGUISHED-NAME`

## About

Made with ❤ in Canada

Copyright 2025 apm.to Inc. <https://apm.to>

Follow [@marcf.be](https://bsky.app/profile/marcf.be) on Blueksy and [@marcfbe](https://linkedin.com/in/marcfbe) or LinkedIn
