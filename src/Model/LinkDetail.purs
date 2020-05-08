module Model.LinkDetail
  ( LinkDetail
  , Note
  , NoteId
  , NoteContent(..)
  , formatNoteId
  , newTextNote
  , load
  , save
  ) where

import Fuji.Prelude

import Data.Argonaut.Core as A
import Data.Argonaut.Decode (class DecodeJson, decodeJson)
import Data.Argonaut.Decode.Generic.Rep (genericDecodeJson)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.Argonaut.Encode.Generic.Rep (genericEncodeJson)
import Data.Argonaut.Parser (jsonParser)
import Data.Generic.Rep (class Generic)
import Data.String as String
import FFI.Tauri (FileName(..))
import FFI.Tauri as Tauri
import Model.Link (LinkId)
import Model.Timestamp (Timestamp)
import Model.Timestamp as Timestamp

currentVersion :: Int
currentVersion = 0

type LinkDetail =
  { version :: Int
  , id :: LinkId
  , notes :: Array Note
  }

newtype NoteId = NoteId Timestamp

derive newtype instance encodeJsonNoteId :: EncodeJson NoteId
derive newtype instance decodeJsonNoteId :: DecodeJson NoteId

type Note =
  { id :: NoteId
  , content :: NoteContent
  }

data NoteContent
  = NoteText String

derive instance genericNoteContent :: Generic NoteContent _

instance encodeJsonNoteContent :: EncodeJson NoteContent where
  encodeJson = genericEncodeJson

instance decodeJsonNoteContent :: DecodeJson NoteContent where
  decodeJson = genericDecodeJson

newNoteId :: Effect NoteId
newNoteId = NoteId <$> Timestamp.newTimestamp

formatNoteId :: NoteId -> String
formatNoteId (NoteId ts) = Timestamp.formatTimestamp ts

newTextNote :: String -> Effect Note
newTextNote text = do
  id <- newNoteId
  pure
    { id
    , content: NoteText text
    }

getFileName :: LinkId -> FileName
getFileName linkId = FileName $ "notes/" <> show linkId <> ".json"

load :: LinkId -> Aff (Either String LinkDetail)
load id = do
  contents <- Tauri.readFile $ getFileName id
  if String.null contents
    then
      pure $ Right
        { version: currentVersion
        , id
        , notes: []
        }
    else
      pure $ decodeJson =<< jsonParser contents

save :: LinkDetail -> Aff Unit
save detail = do
  liftEffect $ Tauri.writeFile (getFileName detail.id) $ A.stringify $ encodeJson
    { version: currentVersion
    , id: detail.id
    , notes: detail.notes
    }
