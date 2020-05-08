module Component.LinkPane
  ( Message(..)
  , Query
  , Action
  , component
  ) where

import Fuji.Prelude

import Data.Array as Array
import Effect.Exception (throw)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Model.Link (Link)
import Model.Link as Link
import Model.LinkDetail (LinkDetail)
import Model.LinkDetail as LinkDetail
import Nonbili.Halogen as NbH

type Props = Array Link

type Message = Void

type Query = Const Void

data Action
  = Init
  | Receive Props
  | OnTextNoteChange String
  | OnAddTextNote

type HTML = H.ComponentHTML Action () Aff

type DSL = H.HalogenM State Action () Message Aff

type State =
  { props :: Props
  , detail :: Maybe LinkDetail
  , textNote :: String
  }

initialState :: Props -> State
initialState props =
  { props
  , detail: Nothing
  , textNote: ""
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
  , HH.div
    []
    [ HH.text $ Link.formatLinkId link.id
    ]
  ]

renderNote :: LinkDetail.Note -> HTML
renderNote note = case note.content of
  LinkDetail.NoteText text ->
    HH.div_
    [ HH.text text
    , HH.span
      [ class_ "ml-3"]
      [ HH.text $ LinkDetail.formatNoteId note.id
      ]
    ]

renderDetail :: LinkDetail -> HTML
renderDetail detail =
  HH.div
  [] $ map renderNote detail.notes

renderTextNoteForm :: State -> HTML
renderTextNoteForm state =
  HH.div
  []
  [ HH.textarea
    [ class_ "block border w-full"
    , HP.value state.textNote
    , HE.onValueChange $ Just <<< OnTextNoteChange
    ]
  , HH.button
    [ HE.onClick $ Just <<< const OnAddTextNote
    ]
    [ HH.text "+ Add Note"]
  ]

render :: State -> HTML
render state =
  HH.div
  [ class_ "p-4"]
  [ NbH.fromMaybe (Array.head state.props) \link ->
     HH.div_
     [ renderLink state link
     , NbH.fromMaybe state.detail renderDetail
     , renderTextNoteForm state
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

  Receive props -> do
    state <- H.get
    when (props /= state.props) \\do
      H.modify_ $ _
        { props = props
        , detail = Nothing
        , textNote = ""
        }
      for_ (Array.head props) \link -> do
        liftAff (LinkDetail.load link.id) >>= case _ of
          Left err -> liftEffect $ throw err
          Right detail -> do
            H.modify_ $ _ { detail = Just detail }

  OnTextNoteChange textNote -> do
    H.modify_ $ _ { textNote = textNote }

  OnAddTextNote -> do
    state <- H.get
    for_ state.detail \detail -> do
      note <- liftEffect $ LinkDetail.newTextNote state.textNote
      let
        newDetail = detail
          { notes = Array.snoc detail.notes note
          }
      H.modify_ $ _
        { detail = Just newDetail
        , textNote = ""
        }
      liftAff $ LinkDetail.save newDetail
