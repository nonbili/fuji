module FFI.Tauri
  ( FileName(..)
  , readLinks
  , getDataDir
  , setDataDir
  , readFile
  , readJson
  , writeJson
  , removeFile
  , openDialog
  ) where

import Fuji.Prelude

import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (class DecodeJson, decodeJson)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.Argonaut.Parser (jsonParser)
import Effect.Aff as Aff

newtype FileName = FileName String

foreign import getDataDir_ :: Effect (Promise String)
getDataDir ::Aff String
getDataDir = Promise.toAffE getDataDir_

foreign import setDataDir :: String -> Effect Unit

foreign import readLinks_ :: String -> Effect (Promise (Array String))
readLinks :: FileName -> Aff (Array String)
readLinks (FileName name)= Promise.toAffE $ readLinks_ name

foreign import readFile_ :: String -> Effect (Promise String)
readFile :: FileName -> Aff String
readFile (FileName name)= Promise.toAffE $ readFile_ name

readJson :: forall a. DecodeJson a => FileName -> Aff (Either String a)
readJson name = Aff.attempt (readFile name) >>= case _ of
  Left e -> pure $ Left $ Aff.message e
  Right x -> pure $ decodeJson =<< jsonParser x

foreign import writeJson_ :: String -> Json -> Effect Unit
writeJson :: forall a. EncodeJson a => FileName -> a -> Effect Unit
writeJson (FileName name) x = writeJson_ name (encodeJson x)

foreign import removeFile_ :: String -> Effect Unit
removeFile :: FileName -> Effect Unit
removeFile (FileName name) = removeFile_ name

foreign import openDialog_ :: Effect (Promise String)
openDialog :: Aff String
openDialog = Promise.toAffE openDialog_
