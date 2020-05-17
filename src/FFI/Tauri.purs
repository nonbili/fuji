module FFI.Tauri
  ( FileName(..)
  , getDataDir
  , setDataDir
  , readFile
  , writeJson
  , removeFile
  , openDialog
  ) where

import Fuji.Prelude

import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Argonaut.Core (Json)

newtype FileName = FileName String

foreign import getDataDir_ :: Effect (Promise String)
getDataDir ::Aff String
getDataDir = Promise.toAffE getDataDir_

foreign import setDataDir :: String -> Effect Unit

foreign import readFile_ :: String -> Effect (Promise String)
readFile :: FileName -> Aff String
readFile (FileName fn)= Promise.toAffE $ readFile_ fn

foreign import writeJson_ :: String -> Json -> Effect Unit
writeJson :: FileName -> Json -> Effect Unit
writeJson (FileName fn) = writeJson_ fn

foreign import removeFile_ :: String -> Effect Unit
removeFile :: FileName -> Effect Unit
removeFile (FileName fn) = removeFile_ fn

foreign import openDialog_ :: Effect (Promise String)
openDialog :: Aff String
openDialog = Promise.toAffE openDialog_
