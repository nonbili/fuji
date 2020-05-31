module Model.Settings
  ( Settings
  , initialSettings
  , load
  , save
  ) where

import Fuji.Prelude

import Data.Set (Set)
import Data.Set as Set
import FFI.Tauri (FileName(..))
import FFI.Tauri as Tauri

currentVersion :: Int
currentVersion = 0

type Settings =
  { version :: Int
  , starredTags :: Set String
  }

initialSettings :: Settings
initialSettings =
  { version: currentVersion
  , starredTags: Set.empty
  }

fileName :: FileName
fileName = FileName "settings.json"

load :: Aff (Either String Settings)
load = do
  ex <- Tauri.readJson fileName
  pure $ either (const (Right initialSettings)) Right ex

save :: Settings -> Aff Unit
save settings = do
  liftEffect $ Tauri.writeJson fileName settings
