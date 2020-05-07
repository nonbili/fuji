module Model.Link where

import Fuji.Prelude

import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.DateTime.Instant (Instant)
import Data.DateTime.Instant as Instant

newtype LinkId = LinkId Instant

instance encodeJsonLinkId :: EncodeJson LinkId where
  encodeJson (LinkId instant) = encodeJson $ unwrap $ Instant.unInstant instant

type Link =
  { id :: LinkId
  , url :: String
  , title :: Maybe String
  , image :: Maybe String
  , tags :: Array String
  }
