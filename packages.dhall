let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.13.6-20200502/packages.dhall sha256:1e1ecbf222c709b76cc7e24cf63af3c2089ffd22bbb1e3379dfd3c07a1787694

let nonbili =
      https://raw.githubusercontent.com/nonbili/package-sets/d56927bf7d0378647d8302d1bfac30698c208ab9/packages.dhall sha256:4ead482f4ed450dac36166109f54299eeabbac5b30f7e95b9d21d994a84fb5cf

let overrides = {=}

let additions = {=}

in  upstream // nonbili // overrides // additions
