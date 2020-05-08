module Model.Link
  ( Link
  , LinkId
  , newLinkId
  ) where

import Fuji.Prelude

import Data.Argonaut.Decode (class DecodeJson)
import Data.Argonaut.Encode (class EncodeJson)
import Model.Timestamp (Timestamp)
import Model.Timestamp as Timestamp

newtype LinkId = LinkId Timestamp

derive instance eqLinkId :: Eq LinkId
derive newtype instance showLinkId :: Show LinkId
derive newtype instance encodeJsonLinkId :: EncodeJson LinkId
derive newtype instance decodeJsonLinkId :: DecodeJson LinkId

newLinkId :: Effect LinkId
newLinkId = LinkId <$> Timestamp.newTimestamp

type Link =
  { id :: LinkId
  , url :: String
  , title :: String
  , image :: Maybe String
  , tags :: Array String
  }
