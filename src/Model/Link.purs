module Model.Link
  ( Link
  , LinkId
  , newLinkId
  ) where

import Fuji.Prelude

import Data.Argonaut.Core as A
import Data.Argonaut.Decode (class DecodeJson)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.DateTime.Instant as Instant
import Data.String as String
import Data.Time.Duration (Milliseconds(..))
import Effect.Now as Now

newtype LinkId = LinkId Milliseconds

derive instance eqLinkId :: Eq LinkId

instance showLinkId :: Show LinkId where
  show (LinkId ts) =
    String.takeWhile (_ /= String.codePointFromChar '.') $ show $ unwrap ts

instance encodeJsonLinkId :: EncodeJson LinkId where
  encodeJson (LinkId ts) = encodeJson $ unwrap ts

instance decodeJsonLinkId :: DecodeJson LinkId where
  decodeJson json = note "Invalid link id" $
    (pure <<< LinkId <<< Milliseconds) =<< A.toNumber json

newLinkId :: Effect LinkId
newLinkId = do
  now <- Now.now
  pure $ LinkId $ Instant.unInstant now

type Link =
  { id :: LinkId
  , url :: String
  , title :: String
  , image :: Maybe String
  , tags :: Array String
  }
