module Component.LinkPane
  ( Message(..)
  , Query
  , Action
  , component
  ) where

import Fuji.Prelude

import Component.Note as Note
import Data.Array as Array
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

data Message = MsgUpdate Link

type Query = Const Void

data Action
  = Init
  | Receive Props
  | OnClickEditLink
  | OnClickSaveEditLink
  | OnClickCancelEditLink
  | OnChangeLinkTitle String
  | OnChangeLinkUrl String
  | OnTextNoteChange String
  | OnAddTextNote
  | HandleNote Int Note.Message

type Slot =
  ( note :: H.Slot Note.Query Note.Message LinkDetail.NoteId
  )

_note = SProxy :: SProxy "note"

type HTML = H.ComponentHTML Action Slot Aff

type DSL = H.HalogenM State Action Slot Message Aff

type State =
  { props :: Props
  , detail :: Maybe LinkDetail
  , textNote :: String
  , editingLink :: Boolean
  , editingLinkTitle :: String
  , editingLinkUrl :: String
  }

initialState :: Props -> State
initialState props =
  { props
  , detail: Nothing
  , textNote: ""
  , editingLink: false
  , editingLinkTitle: ""
  , editingLinkUrl: ""
  }

renderLink :: State -> Link -> HTML
renderLink state link =
  HH.div
  [ class_ "px-3 py-8 border-b" ]
  [ if state.editingLink
    then
      HH.div_
      [ HH.label
        [ class_ "block mb-3"]
        [ HH.div
          [ class_ "font-medium"]
          [ HH.text "Title"]
        , HH.input
          [ class_ "Input"
          , HP.value state.editingLinkTitle
          , HP.required true
          , HE.onValueChange $ Just <<< OnChangeLinkTitle
          ]
        ]
      , HH.label
        [ class_ "block mb-3"]
        [ HH.div
          [ class_ "font-medium"]
          [ HH.text "URL"]
        , HH.input
          [ class_ "Input"
          , HP.value state.editingLinkUrl
          , HP.required true
          , HE.onValueChange $ Just <<< OnChangeLinkUrl
          ]
        ]
      , HH.div_
        [ HH.button
          [ class_ "Btn-primary"
          , HE.onClick $ Just <<< const OnClickSaveEditLink
          ]
          [ HH.text "Save"]
        , HH.button
          [ class_ "Btn-normal ml-2"
          , HE.onClick $ Just <<< const OnClickCancelEditLink
          ]
          [ HH.text "Cancel"]
        ]
      ]
    else
      HH.div
      [ class_ "relative group"]
      [ HH.h3
        [ class_ "mt-0 mb-1"]
        [ HH.text link.title ]
      , HH.div_
        [ HH.a
          [ class_ "block truncate Link text-sm"
          , HP.href link.url
          , HP.target "_blank"
          ]
          [ HH.text link.url]
        ]
      , HH.button
        [ class_ "absolute top-0 right-0 hidden group-hover:block Btn-secondary"
        , HE.onClick $ Just <<< const OnClickEditLink
        ]
        [ HH.text "Edit"]
      ]
  , HH.div
    [ class_ "text-right mt-1 text-xs text-gray-600"]
    [ HH.span
      [ class_ "mr-1"]
      [ HH.text "Added on"]
    , HH.text $ Link.formatLinkId link.id
    ]
  ]

renderNote :: Int -> LinkDetail.Note -> HTML
renderNote index note =
  HH.slot _note note.id Note.component note $
    Just <<< (HandleNote index)

renderDetail :: LinkDetail -> HTML
renderDetail detail =
  NbH.unless (Array.null detail.notes) \\do
    HH.div_ $ Array.mapWithIndex renderNote detail.notes

renderTextNoteForm :: State -> HTML
renderTextNoteForm state =
  HH.div
  [ class_ "px-3 pt-6"]
  [ HH.textarea
    [ class_ "block w-full Input"
    , HP.value state.textNote
    , HP.rows 4
    , HP.placeholder "This link is ..."
    , HE.onValueChange $ Just <<< OnTextNoteChange
    ]
  , HH.div
    [ class_ "text-right mt-2"]
    [ HH.button
      [ class_ "Btn-primary"
      , HE.onClick $ Just <<< const OnAddTextNote
      ]
      [ HH.text "+ Note"]
    ]
  ]

render :: State -> HTML
render state =
  HH.div_
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
        , editingLink = false
        }
      for_ (Array.head props) \link -> do
        liftAff (LinkDetail.load link.id) >>= traverse_ \detail ->
          H.modify_ $ _
            { detail = Just detail
            , editingLinkTitle = link.title
            , editingLinkUrl = link.url
            }

  OnClickEditLink -> do
    H.modify_ $ _ { editingLink = true }

  OnClickSaveEditLink -> do
    state <- H.get
    traceM state
    for_ (Array.head state.props) \link -> do
      H.raise $ MsgUpdate link
        { title = state.editingLinkTitle
        , url = state.editingLinkUrl
        }
    H.modify_ $ _ { editingLink = false }

  OnClickCancelEditLink -> do
    H.modify_ $ _ { editingLink = false }

  OnChangeLinkTitle title -> do
    H.modify_ $ _ { editingLinkTitle = title }

  OnChangeLinkUrl url -> do
    H.modify_ $ _ { editingLinkUrl = url }

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

  HandleNote index msg -> case msg of
    Note.MsgUpdate text -> do
      state <- H.get
      for_ state.detail \detail -> do
        let
          newDetail = detail
            { notes = fromMaybe detail.notes $
                Array.modifyAt index (\note -> case note.content of
                  LinkDetail.NoteText _ -> note
                    { content = LinkDetail.NoteText text }
                ) detail.notes
            }
        H.modify_ $ _
          { detail = Just newDetail
          }
        liftAff $ LinkDetail.save newDetail

    Note.MsgDelete -> do
      state <- H.get
      for_ state.detail \detail -> do
        let
          newDetail = detail
            { notes = fromMaybe detail.notes $
                Array.deleteAt index detail.notes
            }
        H.modify_ $ _
          { detail = Just newDetail
          }
        liftAff $ LinkDetail.save newDetail
