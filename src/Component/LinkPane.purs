module Component.LinkPane
  ( Message(..)
  , Query
  , Action
  , component
  ) where

import Fuji.Prelude

import Component.Note as Note
import Data.Array as Array
import Data.String as String
import Data.String.Regex as Regex
import Data.String.Regex.Flags as RF
import Data.String.Regex.Unsafe (unsafeRegex)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Model.Link (Link)
import Model.Link as Link
import Model.LinkDetail (LinkDetail)
import Model.LinkDetail as LinkDetail
import Nonbili.DOM as NbDom
import Nonbili.Halogen as NbH
import Web.Event.Event as Event

type Props = Array Link

data Message
  = MsgUpdate Link
  | MsgDelete Link

type Query = Const Void

data Action
  = Init
  | Receive Props
  | OnClickEditLink
  | OnSubmitEditLink Event.Event
  | OnClickCancelEditLink
  | OnClickDeleteLink
  | OnChangeLinkTitle String
  | OnChangeLinkUrl String
  | OnChangeLinkImage String
  | OnChangeLinkTags String
  | OnTextNoteInput String
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
  , editingLinkImage :: String
  , editingLinkTags :: String
  }

initialState :: Props -> State
initialState props =
  { props
  , detail: Nothing
  , textNote: ""
  , editingLink: false
  , editingLinkTitle: ""
  , editingLinkUrl: ""
  , editingLinkImage: ""
  , editingLinkTags: ""
  }

renderLink :: State -> Link -> HTML
renderLink state link =
  HH.div
  [ class_ "px-3 py-8 border-b relative group" ]
  [ if state.editingLink
    then
      HH.form
      [ HE.onSubmit $ Just <<< OnSubmitEditLink ]
      [ HH.label
        [ class_ controlCls]
        [ HH.div
          [ class_ labelCls]
          [ HH.text "Title"]
        , HH.input
          [ class_ "Input"
          , HP.value state.editingLinkTitle
          , HP.required true
          , HE.onValueChange $ Just <<< OnChangeLinkTitle
          ]
        ]
      , HH.label
        [ class_ controlCls]
        [ HH.div
          [ class_ labelCls]
          [ HH.text "URL"]
        , HH.input
          [ class_ "Input"
          , HP.value state.editingLinkUrl
          , HP.required true
          , NbH.attr "onfocus" "setTimeout(() => this.select())"
          , HE.onValueChange $ Just <<< OnChangeLinkUrl
          ]
        ]
      , HH.label
        [ class_ controlCls]
        [ HH.div
          [ class_ labelCls]
          [ HH.text "Image"]
        , HH.input
          [ class_ "Input"
          , HP.value state.editingLinkImage
          , NbH.attr "onfocus" "setTimeout(() => this.select())"
          , HE.onValueChange $ Just <<< OnChangeLinkImage
          ]
        ]
      , HH.label
        [ class_ controlCls]
        [ HH.div
          [ class_ labelCls]
          [ HH.text "Tags"]
        , HH.input
          [ class_ "Input"
          , HP.value state.editingLinkTags
          , HE.onValueChange $ Just <<< OnChangeLinkTags
          ]
        ]
      , HH.div
        [ class_ "flex justify-between"]
        [ HH.div_
          [ HH.button
            [ class_ "Btn-primary"
            , HP.type_ HP.ButtonSubmit
            ]
            [ HH.text "Save"]
          , HH.button
            [ class_ "Btn-normal ml-2"
            , HE.onClick $ Just <<< const OnClickCancelEditLink
            ]
            [ HH.text "Cancel"]
          ]
        , HH.button
          [ class_ "Btn-danger"
          , HE.onClick $ Just <<< const OnClickDeleteLink
          ]
          [ HH.text "Delete"]
        ]
      ]
    else
      HH.div_
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
      , HH.ul
        [ class_ "flex flex-wrap mt-3"
        ] $ link.tags <#> \tag ->
          HH.li
          [ class_ "mr-2 bg-blue-100 text-blue-500 text-sm px-2"
          , style "line-height: 1.25rem"
          ]
          [ HH.text tag]
      ]

  , NbH.unless state.editingLink \\
      HH.button
      [ class_ "absolute top-0 right-0 mt-1 mr-1 hidden group-hover:block Btn-secondary"
      , HE.onClick $ Just <<< const OnClickEditLink
      ]
      [ HH.text "Edit"]
  , HH.div
    [ class_ "text-right mt-4 text-xs text-gray-600"]
    [ HH.span
      [ class_ "mr-1"]
      [ HH.text "Added on"]
    , HH.text $ Link.formatLinkId link.id
    ]
  ]
  where
  controlCls = "block mb-3"
  labelCls = "font-medium text-gray-600"

renderNote :: Int -> LinkDetail.Note -> HTML
renderNote index note =
  HH.slot _note note.id Note.component note $
    Just <<< (HandleNote index)

renderDetail :: LinkDetail -> HTML
renderDetail detail =
  NbH.unless (Array.null detail.notes) \\do
    HH.div_ $ Array.mapWithIndex renderNote detail.notes

inputRef = H.RefLabel "textarea" :: H.RefLabel

renderTextNoteForm :: State -> HTML
renderTextNoteForm state =
  HH.div
  [ class_ "px-3 pt-6"]
  [ HH.textarea
    [ class_ "block w-full Input resize-none"
    , style "height: 80px"
    , HP.value state.textNote
    , HP.placeholder "This link is ..."
    , HP.ref inputRef
    , HE.onValueInput $ Just <<< OnTextNoteInput
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
  HH.div
  [ class_ "pb-8"]
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

fitTextarea :: DSL Unit
fitTextarea =
  H.getHTMLElementRef inputRef >>= traverse_ \el ->
    liftEffect $ NbDom.fitTextareaHeight el 80.0

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
          }

  OnClickEditLink -> do
    state <- H.get
    for_ (Array.head state.props) \link -> do
      H.modify_ $ _
        { editingLink = true
        , editingLinkTitle = link.title
        , editingLinkUrl = link.url
        , editingLinkImage = fromMaybe "" link.image
        , editingLinkTags = String.joinWith " " link.tags
        }

  OnSubmitEditLink event -> do
    liftEffect $ Event.preventDefault event
    state <- H.get
    let
      re = unsafeRegex "\\s" RF.noFlags
    for_ (Array.head state.props) \link -> do
      H.raise $ MsgUpdate link
        { title = state.editingLinkTitle
        , url = state.editingLinkUrl
        , image = Just state.editingLinkImage
        , tags = Regex.split re state.editingLinkTags
        }
    H.modify_ $ _ { editingLink = false }

  OnClickCancelEditLink -> do
    H.modify_ $ _ { editingLink = false }

  OnClickDeleteLink -> do
    state <- H.get
    for_ (Array.head state.props) \link -> do
      H.raise $ MsgDelete link

  OnChangeLinkTitle title -> do
    H.modify_ $ _ { editingLinkTitle = title }

  OnChangeLinkUrl url -> do
    H.modify_ $ _ { editingLinkUrl = url }

  OnChangeLinkImage image -> do
    H.modify_ $ _ { editingLinkImage = image }

  OnChangeLinkTags tags -> do
    H.modify_ $ _ { editingLinkTags = tags }

  OnTextNoteInput textNote -> do
    H.modify_ $ _ { textNote = textNote }
    fitTextarea

  OnAddTextNote -> do
    state <- H.get
    for_ state.detail \detail -> do
      note <- liftEffect $ LinkDetail.newNote state.textNote
      let
        newDetail = detail
          { notes = Array.snoc detail.notes note
          }
      H.modify_ $ _
        { detail = Just newDetail
        , textNote = ""
        }
      -- Reset textarea height after submitting
      fitTextarea
      liftAff $ LinkDetail.save newDetail

  HandleNote index msg -> case msg of
    Note.MsgUpdate text -> do
      state <- H.get
      for_ state.detail \detail -> do
        let
          newDetail = detail
            { notes = fromMaybe detail.notes $
                Array.modifyAt index (\note -> note
                  { content = text }
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
