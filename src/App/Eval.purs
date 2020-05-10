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
    Nothing -> traceM "config workspace"
    Just _ -> do
      liftAff Store.load >>= case _ of
        Left err -> liftEffect $ throw err
        Right store -> do
          H.modify_ $ _ { links = store.links }

persist :: DSL Unit
persist = do
  state <- H.get
  liftAff $ Store.save state.links
