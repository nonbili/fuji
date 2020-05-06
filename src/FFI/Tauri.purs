module FFI.Tauri
  ( readFiles
  , writeFile
  ) where

import Prelude

import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Argonaut.Core (Json)
import Data.DateTime.Instant (Instant)
import Effect (Effect)
import Effect.Aff (Aff)

foreign import readFiles_ :: Effect (Promise (Array String))
readFiles :: Aff (Array String)
readFiles = Promise.toAffE readFiles_

foreign import writeFile_ :: Instant -> String -> Effect Unit
writeFile :: Instant -> String -> Effect Unit
writeFile = writeFile_
