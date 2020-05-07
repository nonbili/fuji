module Model.Link where

import Fuji.Prelude

import Data.Argonaut.Core as A
import Data.Argonaut.Decode (class DecodeJson)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.DateTime.Instant as Instant
import Data.Time.Duration (Milliseconds(..))
import Effect.Now as Now

newtype LinkId = LinkId Milliseconds

instance encodeJsonLinkId :: EncodeJson LinkId where
  encodeJson (LinkId instant) = encodeJson $ unwrap instant

instance decodeJsonLinkId :: DecodeJson LinkId where
  decodeJson json = note "Invalid link id" $
    (pure <<< LinkId <<< Milliseconds) =<< A.toNumber json

mkLinkId :: Effect LinkId
mkLinkId = do
  now <- Now.now
  pure $ LinkId $ Instant.unInstant now

type Link =
  { id :: LinkId
  , url :: String
  , title :: Maybe String
  , image :: Maybe String
  , tags :: Array String
  }
