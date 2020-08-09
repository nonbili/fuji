let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.13.6-20200502/packages.dhall sha256:1e1ecbf222c709b76cc7e24cf63af3c2089ffd22bbb1e3379dfd3c07a1787694

let nonbili =
      https://github.com/nonbili/package-sets/releases/download/v0.5/packages.dhall sha256:b6e243c12beb4c2b122f9ec23a5a1bd6910d92e382e0ff9ccea2af99560ce499

let overrides = {=}

let additions = {=}

in  upstream // nonbili // overrides // additions
