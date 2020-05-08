module Component.Note
  ( Message(..)
  , Query
  , Action
  , component
  ) where

import Fuji.Prelude

import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Model.LinkDetail (Note)
import Model.LinkDetail as LinkDetail

type Props = Note

data Message
  = MsgUpdate String
  | MsgDelete

type Query = Const Void

data Action
  = Init
  | Receive Props
  | OnBlur
  | OnClickEdit String

type HTML = H.ComponentHTML Action () Aff

type DSL = H.HalogenM State Action () Message Aff

type State =
  { note :: Note
  , text :: String
  , editing :: Boolean
  }

initialState :: Props -> State
initialState note =
  { note
  , text: ""
  , editing: false
  }

render :: State -> HTML
render state@{ note } = case note.content of
  LinkDetail.NoteText text ->
    HH.div_
    [ HH.text $ LinkDetail.formatNoteId note.id
    , if state.editing
      then
        HH.textarea
        [ HP.value state.text
        , HE.onBlur $ Just <<< const OnBlur
        ]
      else
        HH.div_
        [ HH.text text
        , HH.span
          [ class_ "ml-3"
          , HE.onClick $ Just <<< const (OnClickEdit text)
          ]
          [ HH.text "Edit"]
        ]
    ]

component :: H.Component HH.HTML Query Props Message Aff
component = H.mkComponent
  { initialState
  , render
  , eval: H.mkEval $ H.defaultEval
      { handleAction = handleAction
      }
  }

handleAction :: Action -> DSL Unit
handleAction = case _ of
  Init -> pure unit

  Receive note -> do
    H.modify_ $ _ { note = note }

  OnBlur -> do
    H.modify_ $ _ { editing = false }

  OnClickEdit text -> do
    H.modify_ $ _
      { editing = true
      , text = text
      }
