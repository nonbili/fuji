module Component.LinkPane
  ( Message(..)
  , Query
  , Action
  , component
  ) where

import Fuji.Prelude

import App.Route (AppRoute(..))
import App.Route as Route
import Component.Note as Note
import Data.Array as Array
import Data.Monoid as Monoid
import Data.Set as Set
import Data.String as String
import Data.String.Regex as Regex
import Data.String.Regex.Flags as RF
import Data.String.Regex.Unsafe (unsafeRegex)
import Effect.Aff as Aff
import FFI.DOM as DOM
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Model.Link (Link)
import Model.Link as Link
import Model.LinkDetail (LinkDetail)
import Model.LinkDetail as LinkDetail
import Model.Tag (Tag(..))
import Model.Tag as Tag
import NSelect as Select
import Nonbili.DOM as NbDom
import Nonbili.Halogen as NbH
import Nonbili.String as NString
import Web.Event.Event as Event
import Web.UIEvent.KeyboardEvent (KeyboardEvent)

type Props =
  { selected :: Array Link
  , tags :: Set.Set Tag
  }

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
  | OnKeyUpLinkTags KeyboardEvent
  | OnTextNoteInput String
  | OnAddTextNote
  | HandleNote Int Note.Message
  | HandleTagSelect (Select.Message Action)

type Slot =
  ( note :: H.Slot Note.Query Note.Message LinkDetail.NoteId
  , tagSelect :: Select.Slot Action Unit
  )

_note = SProxy :: SProxy "note"
_tagSelect = SProxy :: SProxy "tagSelect"

type HTML = H.ComponentHTML Action Slot Aff

type DSL = H.HalogenM State Action Slot Message Aff

type State =
  { props :: Props
  , detail :: Maybe LinkDetail
  , textNote :: String
  , editingLink :: Boolean
  , linkTitle :: String
  , linkUrl :: String
  , linkImage :: String
  , linkTags :: String
  , tagOptions :: Array Tag
  }

initialState :: Props -> State
initialState props =
  { props
  , detail: Nothing
  , textNote: ""
  , editingLink: false
  , linkTitle: ""
  , linkUrl: ""
  , linkImage: ""
  , linkTags: ""
  , tagOptions: []
  }

renderTagSelect :: State -> Select.State -> Select.HTML Action () Aff
renderTagSelect state st =
  HH.div
  ( Select.setRootProps [ class_ "relative"]
  ) $ join
  [ pure $ HH.input
    ( Select.setInputProps'
      { onKeyDown: \e -> OnKeyUpLinkTags e }
      [ class_ "Input"
      , HP.value state.linkTags
      ]
    )
  , guard (st.isOpen && Array.length state.tagOptions > 0) $> HH.div
    [ class_ "absolute bg-white text-base overflow-y-auto border shadow-xl w-full z-dropdown"
    , style "max-height: 40vh"
    ]
    [ HH.ul
      ( Select.setMenuProps
        []
      ) $ state.tagOptions # Array.mapWithIndex \ix (Tag s) ->
        HH.li
        ( Select.setItemProps ix
          [ class_ $ "py-1 px-3 hover:bg-gray-200"
              <> Monoid.guard (ix == st.highlightedIndex) " bg-gray-200"
          ]
        )
        [ HH.text s ]
    ]
  ]

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
          , HP.value state.linkTitle
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
          , HP.value state.linkUrl
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
          , HP.value state.linkImage
          , NbH.attr "onfocus" "setTimeout(() => this.select())"
          , HE.onValueChange $ Just <<< OnChangeLinkImage
          ]
        ]
      , HH.label
        [ class_ controlCls]
        [ HH.div
          [ class_ labelCls]
          [ HH.text "Tags"]
        , HH.slot _tagSelect unit Select.component
            { render: renderTagSelect state
            , itemCount: Array.length state.tagOptions
            } $ Just <<< HandleTagSelect
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
      , HH.div
        [ class_ "flex flex-wrap mt-3"
        ] $ (Array.fromFoldable link.tags) <#> \tag ->
          HH.a
          [ class_ "mr-2 mb-2 bg-blue-100 text-blue-500 text-sm px-2 no-underline"
          , HP.href $ Route.showRoute $ RouteTag tag
          , style "line-height: 1.25rem"
          ]
          [ HH.text $ Tag.toString tag]
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
  [ NbH.fromMaybe (Array.head state.props.selected) \link ->
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
    for_ (Array.head props.selected) \link -> do
      liftAff (LinkDetail.load link.id) >>= traverse_ \detail ->
        H.modify_ $ _
          { detail = Just detail
          }

  OnClickEditLink -> do
    state <- H.get
    for_ (Array.head state.props.selected) \link -> do
      H.modify_ $ _
        { editingLink = true
        , linkTitle = link.title
        , linkUrl = link.url
        , linkImage = fromMaybe "" link.image
        , linkTags =
            String.joinWith " " $ Tag.toString <$> Array.fromFoldable link.tags
        }

  OnSubmitEditLink event -> do
    liftEffect $ Event.preventDefault event
    state <- H.get
    let
      re = unsafeRegex "\\s" RF.noFlags
    for_ (Array.head state.props.selected) \link -> do
      let
        linkTags = String.trim state.linkTags
      H.raise $ MsgUpdate link
        { title = state.linkTitle
        , url = state.linkUrl
        , image = Just state.linkImage
        , tags =
            if String.null linkTags
            then Set.empty
            else Set.fromFoldable $ map Tag $
                 Regex.split re state.linkTags
        }
    H.modify_ $ _ { editingLink = false }

  OnClickCancelEditLink -> do
    H.modify_ $ _ { editingLink = false }

  OnClickDeleteLink -> do
    state <- H.get
    for_ (Array.head state.props.selected) \link -> do
      H.raise $ MsgDelete link

  OnChangeLinkTitle title -> do
    H.modify_ $ _ { linkTitle = title }

  OnChangeLinkUrl url -> do
    H.modify_ $ _ { linkUrl = url }

  OnChangeLinkImage image -> do
    H.modify_ $ _ { linkImage = image }

  OnKeyUpLinkTags event -> do
    -- TODO: support complete with TAB key.

    liftAff $ Aff.delay $ Aff.Milliseconds 0.0
    H.query _tagSelect unit (H.request Select.GetInputElement) >>= traverse_ \el -> do
      liftEffect (DOM.getWordBeforeCursor $ unsafeCoerce el) >>= case _ of
        Nothing -> H.modify_ $ _ { tagOptions = [] }
        Just word -> do
          state <- H.get
          let
            pattern = String.Pattern word
            options = Array.fromFoldable $ state.props.tags # Set.filter \(Tag s) ->
              NString.startsWith pattern s
          -- TODO: should filter out existing tags in the input.
          H.modify_ $ _
            { tagOptions =
                if options == [Tag word] then [] else options }

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

  HandleTagSelect msg -> do
    case msg of
      Select.Emit a -> handleAction a

      Select.Selected index -> do
        state <- H.get
        for_ (Array.index state.tagOptions index) \(Tag s) -> do
          H.query _tagSelect unit (H.request Select.GetInputElement) >>= traverse_ \el -> do
            value <- liftEffect (DOM.replaceWordBeforeCursor s $ unsafeCoerce el)
            H.modify_ $ _
              { linkTags = value
              , tagOptions = []
              }

      Select.InputValueChanged value -> do
        H.modify_ $ _ { linkTags = value }

      _ -> pure unit
