module App.Types where

import Fuji.Prelude

import Api (Meta)
import Halogen as H
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
  , metas :: Array Meta
  }

initialState :: State
initialState =
  { url: ""
  , metas: []
  }
