module FFI.Http where

import Nonbili.Prelude

import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Argonaut.Core (Json)
import Effect.Aff (Aff)

foreign import get_ :: String -> Effect (Promise Json)

get :: String -> Aff Json
get = Promise.toAffE <<< get_
