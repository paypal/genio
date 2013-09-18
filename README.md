
## Installation

```sh
git clone https://github.paypal.com/DevTools/genio.git
cd genio
bundle install
```

## Usage

Genereate java code for Json schema:

```sh
bundle exec bin/genio java --json-schema=path/to/schema.json
```

Generate php code for WSDL:

```sh
bundle exec bin/genio php --wsdl=path/to/schema.wsdl
```

## Supported language

* java
* dotnet
* php

## Supported Format

* Json Schema (`--json-schema=path/to/schema.json`)
* WSDL (`--wsdl=path/to/schema.wsdl`)
* WADL (`--wadl=path/to/schema.wadl`)

