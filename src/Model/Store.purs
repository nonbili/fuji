module Model.Store
  ( Store
  , load
  , save
  ) where

import Fuji.Prelude

import Data.Argonaut.Decode (decodeJson)
import Data.Argonaut.Encode (encodeJson)
import Data.Argonaut.Parser (jsonParser)
import Effect.Aff as Aff
import FFI.Tauri (FileName(..))
import FFI.Tauri as Tauri
import Model.Link (Link)

fileName :: FileName
fileName = FileName "store.json"

currentVersion :: Int
currentVersion = 0

type Store =
  { version :: Int
  , links :: Array Link
  }

initialStore :: Store
initialStore =
  { version: currentVersion
  , links: []
  }

load :: Aff (Either String Store)
load = do
  Aff.attempt (Tauri.readFile fileName) >>= case _ of
    Left _ -> pure $ Right initialStore
    Right contents -> pure $ decodeJson =<< jsonParser contents

save :: Array Link -> Aff Unit
save links = do
  liftEffect $ Tauri.writeJson fileName $ encodeJson
    { version: currentVersion
    , links
    }
