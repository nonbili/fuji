module Model.Settings
  ( Settings
  , initialSettings
  , getTagSymbol
  , setTagSymbol
  , load
  , save
  ) where

import Fuji.Prelude

import Data.Map (Map)
import Data.Map as Map
import Data.Set (Set)
import Data.Set as Set
import FFI.Tauri (FileName(..))
import FFI.Tauri as Tauri
import Model.Tag (Tag)

currentVersion :: Int
currentVersion = 0

type Settings =
  { version :: Int
  , starredTags :: Set Tag
  , tagSymbolMap :: Map Tag String
  }

initialSettings :: Settings
initialSettings =
  { version: currentVersion
  , starredTags: Set.empty
  , tagSymbolMap: Map.empty
  }

fileName :: FileName
fileName = FileName "settings.json"

getTagSymbol :: Tag -> Settings -> String
getTagSymbol tag settings =
  fromMaybe "🔖" $ Map.lookup tag settings.tagSymbolMap

setTagSymbol :: Tag -> String -> Settings -> Settings
setTagSymbol tag symbol settings = settings
  { tagSymbolMap = Map.insert tag symbol settings.tagSymbolMap
  }

load :: Aff (Either String Settings)
load = do
  ex <- Tauri.readJson fileName
  pure $ either (const (Right initialSettings)) Right ex

save :: Settings -> Aff Unit
save settings = do
  liftEffect $ Tauri.writeJson fileName settings
