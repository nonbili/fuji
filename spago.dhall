{ name = "my-project"
, dependencies =
  [ "aff-promise"
  , "argonaut-generic"
  , "effect"
  , "halogen"
  , "nonbili"
  , "nonbili-halogen"
  , "now"
  , "template-literals"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
