module App.Types where

import Fuji.Prelude

import Api (Meta)
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
  }

initialState :: State
initialState =
  { url: ""
  , links: []
  }

metaToLink :: Meta -> Effect Link
metaToLink { url, title, image } = do
  id <- Link.mkLinkId
  pure
    { id
    , url
    , title
    , image
    , tags: []
    }
