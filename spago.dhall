{ name = "my-project"
, dependencies =
  [ "aff-promise", "effect", "halogen", "nonbili", "nonbili-halogen", "now" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
