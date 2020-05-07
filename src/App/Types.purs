module App.Types where

import Fuji.Prelude

import Api (Meta)
import Effect.Now as Now
import Halogen as H
import Model.Link (Link)
import Model.Link as Link
import Web.Event.Event (Event)

type Message = Void

type Query = Const Void

data Action
  = Init
  | OnSubmit Event
  | OnValueChange String

type HTML = H.ComponentHTML Action () Aff

type DSL = H.HalogenM State Action () Message Aff

type State =
  { url :: String
  , links :: Array Link
  , metas :: Array Meta
  }

initialState :: State
initialState =
  { url: ""
  , links: []
  , metas: []
  }

metaToLink :: Meta -> Effect Link
metaToLink { url, title, image } = do
  id <- Link.LinkId <$> H.liftEffect Now.now
  pure
    { id
    , url
    , title
    , image
    , tags: []
    }
