# tree-lib

[![build](https://img.shields.io/travis/com/geops/tree-lib.svg)](https://travis-ci.com/geops/tree-lib)
[![npm](https://img.shields.io/npm/v/@geops/tree-lib.svg)](https://www.npmjs.com/package/@geops/tree-lib)

This library provides tree recommendations for different climate change scenarios.

Documentation coming soon.

## Getting Started

Install the [@geops/tree-lib](https://www.npmjs.com/package/@geops/tree-lib) package:

```bash
yarn add @geops/tree-lib
```

Details coming soon.

## Data

Data for tree type projections is provided as a [CSV file](./data/projections.csv) and needs to be converted into JSON to be usable by the library.

1. Install Yarn and Docker Compose.
2. Run transformation: `yarn run data:transform`

### NaiS

NaiS data is provided as CSV files and imported into the PostgreSQL database for furhter processing. New data needs to be converted to UTF-8 encoding with the following command: `iconv -f ISO-8859-1 -t UTF-8 [target].csv > [source].csv`

## Bugs

Please use the [GitHub issue tracker](https://github.com/geops/tree-lib/issues) for all bugs and feature requests. Before creating a new issue, do a quick search to see if the problem has been reported already.
