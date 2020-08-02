module Api where

import Nonbili.Prelude

import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (decodeJson)
import Effect.Aff (Aff)

type Result a = Either String a

type Meta =
  { image :: Maybe String
  , title :: Maybe String
  , url :: String
  }

foreign import getMeta_ :: String -> Effect (Promise Json)

getMeta :: String -> Aff (Result Meta)
getMeta url = do
  res <- Promise.toAffE $ getMeta_ url
  pure $ decodeJson res
