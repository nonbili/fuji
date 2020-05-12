module FFI.Tauri
  ( FileName(..)
  , getDataDir
  , setDataDir
  , readFile
  , writeFile
  , removeFile
  , openDialog
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

foreign import setDataDir :: String -> Effect Unit

foreign import readFile_ :: String -> Effect (Promise String)
readFile :: FileName -> Aff String
readFile (FileName fn)= Promise.toAffE $ readFile_ fn

foreign import writeFile_ :: String -> String -> Effect Unit
writeFile :: FileName -> String -> Effect Unit
writeFile (FileName fn) = writeFile_ fn

foreign import removeFile_ :: String -> Effect Unit
removeFile :: FileName -> Effect Unit
removeFile (FileName fn) = removeFile_ fn

foreign import openDialog_ :: Effect (Promise String)
openDialog :: Aff String
openDialog = Promise.toAffE openDialog_
