module Model.Timestamp
  ( Timestamp
  , newTimestamp
  , formatTimestamp
  ) where

import Fuji.Prelude

import Data.Argonaut.Core as A
import Data.Argonaut.Decode (class DecodeJson)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.DateTime.Instant (Instant)
import Data.DateTime.Instant as Instant
import Data.JSDate as JSDate
import Data.String as String
import Data.Time.Duration (Milliseconds(..))
import Effect.Now as Now
import Effect.Unsafe (unsafePerformEffect)
import Data.TemplateLiteral.Unsafe (template)

newtype Timestamp = Timestamp Instant

derive newtype instance eqTimestamp :: Eq Timestamp
derive newtype instance ordTimestamp :: Ord Timestamp

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

formatTimestamp :: Timestamp -> String
formatTimestamp (Timestamp instant) =
  template "${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')} ${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}:${second.toString().padStart(2, '0')}"
    { year
    , month: month + 1.0
    , day
    , hour
    , minute
    , second
    }
  where
  date = JSDate.fromInstant instant
  year = unsafePerformEffect $ JSDate.getFullYear date
  month = unsafePerformEffect $ JSDate.getMonth date
  day = unsafePerformEffect $ JSDate.getDate date
  hour = unsafePerformEffect $ JSDate.getHours date
  minute = unsafePerformEffect $ JSDate.getMinutes date
  second = unsafePerformEffect $ JSDate.getSeconds date
