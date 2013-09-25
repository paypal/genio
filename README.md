
Genio is an easy to use code generation tool that can generate API client libraries in multiple programming languages. Genio comes with in-built support for multiple API specification formats - WSDLs, WADLs and the [JSON schema](http://json-schema.org/) format but also allows you to plug in parsers for additional specification formats. It uses a simple templating system that allows easy customization of the generated code.


## Requirements

   * Ruby 1.9.3

## Installation

```sh
gem install genio
```

## Usage

Once you have genio installed on your local machine, run

```sh
genio <java|php|dotnet> --schema=path/to/specification [--output-path=output/directory]
```


With the --schema argument option, Genio will attempt to guess the specification type based on the file extension of the argument. If you follow a non-standard naming convention, please use the --wsdl / --wadl / --json-schema argument options instead.

## Supported languages

Genio comes with templates for the following programming languages. Support for other languages to follow soon.

   * java
   * dotnet
   * php

## Supported formats

   * JSON schema (`--json-schema=path/to/schema.json`)
   * WADL (`--wadl=path/to/schema.wadl`)
   * WSDL (`--wsdl=path/to/schema.wsdl`)

## Documentation

   * [Genio internals](https://github.com/paypal/genio/wiki/Genio-internals)

## Getting help

If you have a feature ask or an issue to report, please file an [issue](https://github.com/paypal/genio/issues/new) on github

