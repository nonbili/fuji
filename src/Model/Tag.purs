module Model.Tag
  ( Tag(..)
  , null
  , empty
  , toString
  ) where

import Fuji.Prelude

import Data.Argonaut.Decode (class DecodeJson)
import Data.Argonaut.Encode (class EncodeJson)
import Data.String as String

newtype Tag = Tag String

derive newtype instance eqTag :: Eq Tag
derive newtype instance ordTag :: Ord Tag
derive newtype instance encodeJsonTag :: EncodeJson Tag
derive newtype instance decodeJsonTag :: DecodeJson Tag

null :: Tag -> Boolean
null (Tag x) = String.null x

empty :: Tag
empty = Tag ""

toString :: Tag -> String
toString (Tag x) = x
