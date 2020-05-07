module App.Types where

import Fuji.Prelude

import Api (Meta)
import Component.LinkPane as LinkPane
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

type Slot =
  ( linkPane :: H.Slot LinkPane.Query LinkPane.Message Unit
  )

_linkPane = SProxy :: SProxy "linkPane"

type HTML = H.ComponentHTML Action Slot Aff

type DSL = H.HalogenM State Action Slot Message Aff

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
