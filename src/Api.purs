module Api where

import Nonbili.Prelude

import Data.Argonaut.Decode (decodeJson)
import Effect.Aff (Aff)
import FFI.Http as Http

type Result a = Either String a

type Meta =
  { description :: Maybe String
  , image :: Maybe String
  , logo :: Maybe String
  , title :: Maybe String
  , url :: String
  }

getMeta :: String -> Aff (Result Meta)
getMeta url = do
  res <- Http.get ("https://meta-proxy.herokuapp.com?q=" <> url)
  pure $ decodeJson res
