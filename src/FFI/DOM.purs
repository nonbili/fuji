module FFI.DOM
  ( getWordBeforeCursor
  , replaceWordBeforeCursor
  ) where

import Fuji.Prelude

import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Web.HTML (HTMLInputElement)

foreign import getWordBeforeCursor_ :: HTMLInputElement -> Effect (Nullable String)

getWordBeforeCursor :: HTMLInputElement -> Effect (Maybe String)
getWordBeforeCursor el = Nullable.toMaybe <$> getWordBeforeCursor_ el

foreign import replaceWordBeforeCursor :: String -> HTMLInputElement -> Effect Unit
