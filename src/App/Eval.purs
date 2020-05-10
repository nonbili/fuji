module App.Eval where

import Fuji.Prelude

import App.Types (DSL)
import Effect.Exception (throw)
import FFI.Tauri as Tauri
import Halogen as H
import Model.Store as Store

init :: DSL Unit
init = do
  liftEffect Tauri.getDataDir >>= case _ of
    Nothing -> H.modify_ $ _ { isInitModalOpen = true }
    Just _ -> load

load :: DSL Unit
load = do
  liftAff Store.load >>= case _ of
    Left err -> liftEffect $ throw err
    Right store -> do
      H.modify_ $ _ { links = store.links }

save :: DSL Unit
save = do
  state <- H.get
  liftAff $ Store.save state.links
