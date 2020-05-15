module App.Eval where

import Fuji.Prelude

import App.Types (DSL)
import Effect.Aff as Aff
import FFI.Tauri as Tauri
import Halogen as H
import Model.Store as Store

init :: DSL Unit
init = do
  liftAff (Aff.attempt Tauri.getDataDir) >>= case _ of
    Left _ -> H.modify_ $ _ { isInitModalOpen = true }
    Right _ -> load

load :: DSL Unit
load = do
  liftAff Store.load >>= traverse_ \store ->
    H.modify_ $ _ { links = store.links }

save :: DSL Unit
save = do
  state <- H.get
  liftAff $ Store.save state.links
