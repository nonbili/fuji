module Api where

import Nonbili.Prelude

import Data.Argonaut.Decode (decodeJson)
import Data.Argonaut.Parser (jsonParser)
import Effect.Aff (Aff)
import FFI.Http as Http
import FFI.Tauri as Tauri

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

readMetas :: Aff (Result (Array Meta))
readMetas = do
  contents <- Tauri.readFiles
  pure $ sequence $ map (\x -> decodeJson =<< jsonParser x) contents
