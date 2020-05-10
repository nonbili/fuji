module FFI.Tauri
  ( FileName(..)
  , getDataDir
  , readFile
  , writeFile
  ) where

import Fuji.Prelude

import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Nullable (Nullable)
import Data.Nullable as Nullable

newtype FileName = FileName String

foreign import getDataDir_ :: Effect (Nullable String)
getDataDir ::Effect (Maybe String)
getDataDir = Nullable.toMaybe <$> getDataDir_

foreign import readFile_ :: String -> Effect (Promise String)
readFile :: FileName -> Aff String
readFile (FileName fn)= Promise.toAffE $ readFile_ fn

foreign import writeFile_ :: String -> String -> Effect Unit
writeFile :: FileName -> String -> Effect Unit
writeFile (FileName fn) = writeFile_ fn
