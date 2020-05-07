module App.Eval where

import Fuji.Prelude

import App.Types (DSL)
import Halogen as H
import Model.Store as Store

persist :: DSL Unit
persist = do
  state <- H.get
  liftAff $ Store.save state.links
