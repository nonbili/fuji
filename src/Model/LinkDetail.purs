module Model.LinkDetail
  ( LinkDetail
  , Note
  , NoteId
  , NoteContent(..)
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
import Data.DateTime.Instant as Instant
import Data.Generic.Rep (class Generic)
import Data.String as String
import Data.Time.Duration (Milliseconds(..))
import Effect.Now as Now
import FFI.Tauri (FileName(..))
import FFI.Tauri as Tauri
import Model.Link (LinkId)

currentVersion :: Int
currentVersion = 0

type LinkDetail =
  { version :: Int
  , id :: LinkId
  , notes :: Array Note
  }

newtype NoteId = NoteId Milliseconds

instance encodeJsonNoteId :: EncodeJson NoteId where
  encodeJson (NoteId instant) = encodeJson $ unwrap instant

instance decodeJsonNoteId :: DecodeJson NoteId where
  decodeJson json = note "Invalid note id" $
    (pure <<< NoteId <<< Milliseconds) =<< A.toNumber json

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
newNoteId = do
  now <- Now.now
  pure $ NoteId $ Instant.unInstant now

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
