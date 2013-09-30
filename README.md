Genio is an easy to use code generation tool that can generate API client libraries in multiple programming languages. Genio comes with in-built support for multiple API specification formats - WSDLs, WADLs and the [Google discovery format](https://developers.google.com/discovery) but also allows you to plug in parsers for additional specification formats. It uses a simple templating system that allows easy customization of the generated code.


## Requirements

* Ruby 1.9.3 or above

## Installation

```sh
gem install genio
```

## Usage

With genio installed on your local machine, run

```sh
genio <java|php|dotnet> --schema=path/to/specification [--output-path=output/directory]
```

With the --schema argument option, Genio will attempt to guess the specification type based on the file extension of the argument. If you follow non-standard naming convention for your files, please use the --wsdl / --wadl / --json-schema arguments instead.

Once you have generated source files with genio, you can use them in your project in conjunction with PayPal's core SDK libraries. You can take a look at the sample [hello world projects](https://github.com/paypal/genio-sample/tree/master/hello-world) and read language specific instructions [here](https://github.com/paypal/genio/wiki/Using-genio).

## Supported languages

Genio comes with templates for the following programming languages. Support for other languages to follow soon.

* java
* dotnet
* php

## Supported formats

* WADL (`--wadl=path/to/schema.wadl`)
* Google discovery format (`--json-schema=path/to/schema.json`)
* WSDL (`--wsdl=path/to/schema.wsdl`)

## Upcoming features

We have plans to add the following soon

* Automatic API reference generation from spec.
* Support for JSON schema Version 4 specification.

## Documentation

* [Genio internals](https://github.com/paypal/genio/wiki/Genio-internals)

## Contributions and issues

We will be happy to accept contributions by way of templates for additional languages and parsers for other API specification formats. Please submit a pull request if you would like to contribute.

If you have a feature ask or an issue to report, please file an [issue](https://github.com/paypal/genio/issues/new) on github.
