{ name = "fuji"
, dependencies =
  [ "aff-promise"
  , "argonaut-generic"
  , "effect"
  , "halogen"
  , "halogen-nselect"
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
