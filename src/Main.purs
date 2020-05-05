module Main where

import Prelude

import App (app)
import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver as Driver

main :: Effect Unit
main = do
  HA.runHalogenAff do
    body <- HA.awaitBody
    Driver.runUI app unit body
