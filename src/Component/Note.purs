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
import Nonbili.Halogen as NbH

type Props = Note

data Message
  = MsgUpdate String
  | MsgDelete

type Query = Const Void

data Action
  = Init
  | Receive Props
  | OnClickEdit String
  | OnClickSave
  | OnClickCancel
  | OnTextChange String

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

inputRef = H.RefLabel "textarea" :: H.RefLabel

render :: State -> HTML
render state@{ note } = case note.content of
  LinkDetail.NoteText text ->
    HH.div_
    [ HH.text $ LinkDetail.formatNoteId note.id
    , if state.editing
      then
        HH.div_
        [ HH.textarea
          [ HP.value state.text
          , HP.ref inputRef
          , HE.onValueChange $ Just <<< OnTextChange
          ]
        , HH.div_
          [ HH.button
            [ class_ "Btn-primary"
            , HE.onClick $ Just <<< const OnClickSave
            ]
            [ HH.text "Save"]
          , HH.button
            [ class_ "Btn-white"
            , HE.onClick $ Just <<< const OnClickCancel
            ]
            [ HH.text "Cancel"]
          ]
        ]
      else
        HH.div_
        [ HH.text text
        , HH.button
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
      , receive = Just <<< Receive
      }
  }

handleAction :: Action -> DSL Unit
handleAction = case _ of
  Init -> pure unit

  Receive note -> do
    H.modify_ $ _ { note = note }

  OnTextChange text -> do
    H.modify_ $ _ { text = text }

  OnClickEdit text -> do
    H.modify_ $ _
      { editing = true
      , text = text
      }
    NbH.focus inputRef

  OnClickSave -> do
    state <- H.get
    H.modify_ $ _
      { editing = false }
    H.raise $ MsgUpdate state.text

  OnClickCancel -> do
    H.modify_ $ _ { editing = false }
