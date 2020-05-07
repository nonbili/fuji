module Model.Store
  ( Store
  , load
  , save
  ) where

import Fuji.Prelude

import Data.Argonaut.Core as A
import Data.Argonaut.Decode (decodeJson)
import Data.Argonaut.Encode (encodeJson)
import Data.Argonaut.Parser (jsonParser)
import Data.String as String
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

load :: Aff (Either String Store)
load = do
  contents <- Tauri.readFile fileName
  if String.null contents
    then
      pure $ Right
        { version: currentVersion
        , links: []
        }
    else
      pure $ decodeJson =<< jsonParser contents

save :: Array Link -> Aff Unit
save links = do
  liftEffect $ Tauri.writeFile fileName $ A.stringify $ encodeJson
    { version: currentVersion
    , links
    }
