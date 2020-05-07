module Model.Store where

import Fuji.Prelude

import Data.Argonaut.Core as A
import Data.Argonaut.Encode (encodeJson)
import FFI.Tauri as Tauri
import Model.Link (Link)

fileName :: String
fileName = "store.json"

currentVersion :: Int
currentVersion = 0

type Store =
  { version :: Int
  , links :: Array Link
  }

save :: Array Link -> Aff Unit
save links = do
  liftEffect $ Tauri.writeFile fileName $ A.stringify $ encodeJson
    { version: currentVersion
    , links
    }
