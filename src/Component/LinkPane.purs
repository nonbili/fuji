module Component.LinkPane
  ( Message(..)
  , Query
  , Action
  , component
  ) where

import Fuji.Prelude

import Data.Array as Array
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Model.Link (Link)
import Nonbili.Halogen as NbH

type Props = Array Link

type Message = Void

type Query = Const Void

data Action
  = Init
  | Receive Props

type HTML = H.ComponentHTML Action () Aff

type DSL = H.HalogenM State Action () Message Aff

type State =
  { props :: Props
  }

initialState :: Props -> State
initialState props =
  { props
  }

renderLink :: State -> Link -> HTML
renderLink state link =
  HH.div_
  [ HH.h3
    []
    [ HH.text link.title ]
  , HH.div_
    [ HH.a
      [ class_ "block truncate"
      , HP.href link.url
      , HP.target "_blank"
      ]
      [ HH.text link.url]
    ]
  ]

render :: State -> HTML
render state =
  HH.div
  [ class_ "p-4"]
  [ NbH.fromMaybe (Array.head state.props) (renderLink state)
  ]

component :: H.Component HH.HTML Query Props Message Aff
component = H.mkComponent
  { initialState
  , render
  , eval: H.mkEval $ H.defaultEval
      { handleAction = handleAction
      , receive = Just <<< Receive
      }
  }

handleAction :: Action -> DSL Unit
handleAction = case _ of
  Init -> pure unit

  Receive props ->
    H.modify_ $ _ { props = props }
