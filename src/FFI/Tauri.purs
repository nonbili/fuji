module FFI.Tauri
  ( FileName(..)
  , readFiles
  , readFile
  , writeFile
  ) where

import Fuji.Prelude

import Control.Promise (Promise)
import Control.Promise as Promise

newtype FileName = FileName String

foreign import readFiles_ :: Effect (Promise (Array String))
readFiles :: Aff (Array String)
readFiles = Promise.toAffE readFiles_

foreign import readFile_ :: String -> Effect (Promise String)
readFile :: FileName -> Aff String
readFile (FileName fn)= Promise.toAffE $ readFile_ fn

foreign import writeFile_ :: String -> String -> Effect Unit
writeFile :: FileName -> String -> Effect Unit
writeFile (FileName fn) = writeFile_ fn
