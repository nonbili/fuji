module FFI.Tauri
  ( writeFile
  ) where

import Prelude

import Data.DateTime.Instant (Instant)
import Effect (Effect)

foreign import writeFile_ :: Instant -> String -> Effect Unit

writeFile :: Instant -> String -> Effect Unit
writeFile = writeFile_
