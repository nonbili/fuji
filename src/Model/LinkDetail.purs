module Model.LinkDetail
  ( LinkDetail
  , Note
  , NoteId
  , formatNoteId
  , newNote
  , load
  , save
  , delete
  ) where

import Fuji.Prelude

import Data.Argonaut.Decode (class DecodeJson, decodeJson)
import Data.Argonaut.Decode.Generic.Rep (genericDecodeJson)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.Argonaut.Encode.Generic.Rep (genericEncodeJson)
import Data.Argonaut.Parser (jsonParser)
import Data.Generic.Rep (class Generic)
import Effect.Aff as Aff
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

derive newtype instance eqNoteId :: Eq NoteId
derive newtype instance ordNoteId :: Ord NoteId
derive newtype instance encodeJsonNoteId :: EncodeJson NoteId
derive newtype instance decodeJsonNoteId :: DecodeJson NoteId

type Note =
  { id :: NoteId
  , content :: String
  }

newNoteId :: Effect NoteId
newNoteId = NoteId <$> Timestamp.newTimestamp

formatNoteId :: NoteId -> String
formatNoteId (NoteId ts) = Timestamp.formatTimestamp ts

newNote :: String -> Effect Note
newNote content = do
  id <- newNoteId
  pure
    { id
    , content
    }

getFileName :: LinkId -> FileName
getFileName linkId = FileName $ "notes/" <> show linkId <> ".json"

load :: LinkId -> Aff (Either String LinkDetail)
load id = do
  Aff.attempt (Tauri.readFile $ getFileName id) >>= case _ of
    Left _ -> pure $ Right initialDetail
    Right contents -> do
      pure $ decodeJson =<< jsonParser contents
  where
  initialDetail =
    { version: currentVersion
    , id
    , notes: []
    }

save :: LinkDetail -> Aff Unit
save detail = do
  liftEffect $ Tauri.writeJson (getFileName detail.id) $ encodeJson
    { version: currentVersion
    , id: detail.id
    , notes: detail.notes
    }

delete :: LinkId -> Aff Unit
delete id = do
  liftEffect $ Tauri.removeFile $ getFileName id
