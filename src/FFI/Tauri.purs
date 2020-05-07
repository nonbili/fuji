module FFI.Tauri
  ( readFiles
  , writeFile
  ) where

import Prelude

import Control.Promise (Promise)
import Control.Promise as Promise
import Data.DateTime.Instant (Instant)
import Effect (Effect)
import Effect.Aff (Aff)

foreign import readFiles_ :: Effect (Promise (Array String))
readFiles :: Aff (Array String)
readFiles = Promise.toAffE readFiles_

foreign import writeFile_ :: String -> String -> Effect Unit
writeFile :: String -> String -> Effect Unit
writeFile = writeFile_
