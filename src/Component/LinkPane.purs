module Component.LinkPane
  ( Message(..)
  , Query
  , Action
  , component
  ) where

import Fuji.Prelude

import Halogen as H
import Halogen.HTML as HH

type Message = Void

type Query = Const Void

data Action
  = Init

type HTML = H.ComponentHTML Action () Aff

type DSL = H.HalogenM State Action () Message Aff

type State =
  { value :: String
  }

initialState :: State
initialState =
  { value: ""
  }

render :: State -> HTML
render state =
  HH.div_
  [ HH.text "LinkPane" ]

component :: H.Component HH.HTML Query Unit Message Aff
component = H.mkComponent
  { initialState: const initialState
  , render
  , eval: H.mkEval $ H.defaultEval
      { handleAction = handleAction
      }
  }

handleAction :: Action -> DSL Unit
handleAction = case _ of
  _ -> pure unit
