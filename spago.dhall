{ name = "fuji"
, dependencies =
  [ "aff-promise"
  , "argonaut-generic"
  , "effect"
  , "halogen"
  , "nonbili"
  , "nonbili-dom"
  , "nonbili-halogen"
  , "now"
  , "routing"
  , "template-literals"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
