module Model.Link
  ( Link
  , LinkId
  , newLinkId
  , formatLinkId
  , metaToLink
  , loadAll
  , save
  , delete
  ) where

import Fuji.Prelude

import Api (Meta)
import Data.Argonaut.Decode (class DecodeJson, decodeJson)
import Data.Argonaut.Encode (class EncodeJson)
import Data.Argonaut.Parser (jsonParser)
import Effect.Aff as Aff
import FFI.Tauri (FileName(..))
import FFI.Tauri as Tauri
import Model.Timestamp (Timestamp)
import Model.Timestamp as Timestamp
import Nonbili.Logger (logError)

newtype LinkId = LinkId Timestamp

derive newtype instance eqLinkId :: Eq LinkId
derive newtype instance ordLinkId :: Ord LinkId
derive newtype instance showLinkId :: Show LinkId
derive newtype instance encodeJsonLinkId :: EncodeJson LinkId
derive newtype instance decodeJsonLinkId :: DecodeJson LinkId

newLinkId :: Effect LinkId
newLinkId = LinkId <$> Timestamp.newTimestamp

formatLinkId :: LinkId -> String
formatLinkId (LinkId ts) = Timestamp.formatTimestamp ts

currentVersion :: Int
currentVersion = 0

type Link =
  { version :: Int
  , id :: LinkId
  , url :: String
  , title :: String
  , image :: Maybe String
  , tags :: Array String
  }

metaToLink :: Meta -> Effect Link
metaToLink { url, title, image } = do
  id <- newLinkId
  pure
    { version: currentVersion
    , id
    , url
    , title: fromMaybe "" title
    , image
    , tags: []
    }

dir :: FileName
dir = FileName "links"

getFileName :: LinkId -> FileName
getFileName linkId = FileName $ "links/" <> show linkId <> ".json"

loadAll :: Aff (Either String (Array Link))
loadAll = do
  Aff.attempt (Tauri.readLinks dir) >>= case _ of
    Left err -> do
      logError $ Aff.message err
      pure $ Right []
    Right contents -> do
      pure $ sequence $ map (\x -> decodeJson =<< jsonParser x) contents

save :: Link -> Aff Unit
save link = do
  liftEffect $ Tauri.writeJson (getFileName link.id) link

delete :: LinkId -> Aff Unit
delete id = do
  liftEffect $ Tauri.removeFile $ getFileName id
