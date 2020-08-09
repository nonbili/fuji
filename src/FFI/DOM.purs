module FFI.DOM
  ( getWordBeforeCursor
  ) where

import Fuji.Prelude

import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Web.UIEvent.KeyboardEvent (KeyboardEvent)

foreign import getWordBeforeCursor_ :: KeyboardEvent -> Effect (Nullable String)

getWordBeforeCursor :: KeyboardEvent -> Effect (Maybe String)
getWordBeforeCursor e = Nullable.toMaybe <$> getWordBeforeCursor_ e
