module Model.Timestamp
  ( Timestamp
  , newTimestamp
  ) where

import Fuji.Prelude

import Data.Argonaut.Core as A
import Data.Argonaut.Decode (class DecodeJson)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.DateTime.Instant (Instant)
import Data.DateTime.Instant as Instant
import Data.String as String
import Data.Time.Duration (Milliseconds(..))
import Effect.Now as Now

newtype Timestamp = Timestamp Instant

derive newtype instance eqTimestamp :: Eq Timestamp

instance showTimestamp :: Show Timestamp where
  show (Timestamp instant) =
    String.takeWhile (_ /= String.codePointFromChar '.') $
      show $ unwrap $ Instant.unInstant instant

instance encodeJsonTimestamp :: EncodeJson Timestamp where
  encodeJson (Timestamp instant) =
    encodeJson $ unwrap $ Instant.unInstant instant

instance decodeJsonTimestamp :: DecodeJson Timestamp where
  decodeJson json = note "Invalid timestamp" $
    Timestamp <$> (Instant.instant <<< Milliseconds =<< A.toNumber json)

newTimestamp :: Effect Timestamp
newTimestamp = Timestamp <$> Now.now
