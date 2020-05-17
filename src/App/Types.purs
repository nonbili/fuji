module App.Types where

import Fuji.Prelude

import Component.LinkPane as LinkPane
import Halogen as H
import Model.Link (Link, LinkId)
import Web.Event.Event (Event)

type Message = Void

type Query = Const Void

data Action
  = Init
  | OnSubmit Event
  | OnValueChange String
  | OnSelectLink Link
  | OnClickOpenDialog
  | OnSubmitInitModal
  | HandleLinkPane LinkPane.Message

type Slot =
  ( linkPane :: H.Slot LinkPane.Query LinkPane.Message Unit
  )

_linkPane = SProxy :: SProxy "linkPane"

type HTML = H.ComponentHTML Action Slot Aff

type DSL = H.HalogenM State Action Slot Message Aff

type State =
  { url :: String
  , links :: Array Link
  , selectedLinkIds :: Array LinkId
  , isInitModalOpen :: Boolean
  , dataDir :: String
  }

initialState :: State
initialState =
  { url: ""
  , links: []
  , selectedLinkIds: []
  , isInitModalOpen: false
  , dataDir: ""
  }
