{ name = "my-project"
, dependencies = [ "console", "effect", "psci-support", "halogen" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
