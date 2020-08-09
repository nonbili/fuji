module App
  ( app
  ) where

import Fuji.Prelude

import Api as Api
import App.Eval as Eval
import App.Render.CurrentTag as CurrentTag
import App.Render.InitModal as InitModal
import App.Render.Navbar as Navbar
import App.Route (AppRoute(..), appRoute)
import App.Types (Action(..), DSL, HTML, Message, Query, State, _emojiSelect, _linkPane, initialState)
import Component.LinkPane as LinkPane
import Data.Array as Array
import Data.Monoid as Monoid
import Data.Set as Set
import Effect.Exception as E
import FFI.Tauri as Tauri
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Query.EventSource as ES
import Model.Link (Link)
import Model.Link as Link
import Model.Settings as Settings
import Model.Tag as Tag
import NSelect as Select
import Nonbili.Halogen as NbH
import Routing.Hash as R
import Web.Event.Event as Event
import Web.HTML.HTMLElement as HTMLElement
import Web.HTML.HTMLInputElement as HTMLInputElement

renderLink :: State -> Link -> HTML
renderLink state link =
  HH.div
  [ class_ "relative GridItem"
  ]
  [ HH.div
    [ class_ "relative"
    , style "padding-top: 133.33%"
    ]
    [ HH.img $
      [ class_ $ "absolute inset-0 p-4 w-full h-full object-contain hover:bg-gray-200 cursor-pointer" <> Monoid.guard selected " border-green-500 border-2 py-2"
      , HE.onClick $ Just <<< const (OnSelectLink link)
      ] <> Monoid.guard (isJust link.image)
      [ HP.src $ fromMaybe "" link.image
      ]
    ]
  ]
  where
  selected = Array.elem link.id state.selectedLinkIds

render :: State -> HTML
render state =
  HH.div
  [ class_ "flex h-screen"
  ]
  [ Navbar.render state
  , HH.div
    [ class_ "flex flex-col flex-1"
    ]
    [ HH.form
      [ class_ "bg-blue-200 py-2 px-4"
      , HE.onSubmit $ Just <<< OnSubmitLink
      ]
      [ HH.input
        [ class_ "py-1 px-2 rounded w-1/3 border-none"
        , HP.value state.url
        , HP.required true
        , HP.placeholder "Save a link https://any.url"
        , NbH.attr "onfocus" "setTimeout(() => this.select())"
        , HE.onValueChange $ Just <<< OnValueChange
        ]
      , HH.button
        [ class_ "hidden"
        , HP.type_ HP.ButtonSubmit
        ]
        [ HH.text "Add"]
      ]
    , HH.div
      [ class_ "flex-1 flex min-h-0"
      ]
      [ HH.div
        [ class_ "flex-1 p-4 min-w-0 overflow-y-auto"
        ]
        [ CurrentTag.render state
        , HH.div
          [ class_ "flex flex-wrap content-start"
          ] $ map (renderLink state) showingLinks
        ]
      , HH.div
        [ class_ "border-l h-full min-h-0 overflow-y-auto"
        , style "width: 24rem"
        ]
        [ HH.slot _linkPane unit LinkPane.component
            { selected: selectedLinks
            , tags: getAllTags state
            } $ Just <<< HandleLinkPane
        ]
      ]
    ]
  , NbH.when state.isInitModalOpen \\ InitModal.render state
  ]
  where
  showingLinks =
    if Tag.null state.tag
    then state.links
    else
      state.links # Array.filter \link ->
        Array.elem link.id state.showingLinkIds
  selectedLinks = state.links # Array.filter \link ->
    Array.elem link.id state.selectedLinkIds

getAllTags :: State -> Set.Set Tag.Tag
getAllTags state = Set.unions $ Set.fromFoldable $ _.tags <$> state.links

app :: H.Component HH.HTML Query Unit Message Aff
app = H.mkComponent
  { initialState: const initialState
  , render
  , eval: H.mkEval $ H.defaultEval
      { handleAction = handleAction
      , initialize = Just Init
      }
  }

handleAction :: Action -> DSL Unit
handleAction = case _ of
  Init -> do
    Eval.init
    void $ H.subscribe $ ES.effectEventSource \emitter -> do
      void $ R.matches appRoute \_ next -> do
        ES.emit emitter (OnRouteChange next)
      pure mempty

  OnRouteChange route -> case route of
    RouteHome ->
      H.modify_ $ _
        { tag = Tag.empty
        , showingLinkIds = []
        }
    RouteTag tag -> do
      H.modify_ $ _ { tag = tag }
      Eval.updateShowingLinkIds

  OnSubmitLink event -> do
    H.liftEffect $ Event.preventDefault event
    state <- H.get
    H.liftAff (Api.getMeta state.url) >>= traverse_ \meta -> do
      link <- H.liftEffect $ Link.metaToLink state.tag meta
      H.modify_ \s -> s
        { links = Array.cons link s.links
        , url = ""
        }
      Eval.updateShowingLinkIds
      Eval.saveLink link

  OnValueChange url -> do
    H.modify_ $ _ { url = url }

  OnSelectLink link -> do
    H.modify_ $ _ { selectedLinkIds = [link.id] }

  OnClickOpenDialog -> do
    dir <- liftAff Tauri.openDialog
    H.modify_ $ _ { dataDir = dir }

  OnSubmitInitModal -> do
    state <- H.get
    void $ liftEffect $ E.try $ Tauri.setDataDir state.dataDir
    Eval.load
    H.modify_ $ _ { isInitModalOpen = false }

  OnToggleStarTag star -> do
    { settings, tag } <- H.get
    let
      action = if star then Set.insert else Set.delete
      newSettings = settings
        { starredTags = action tag settings.starredTags
        }
    H.modify_ $ _
      { settings = newSettings
      }
    liftAff $ Settings.save newSettings

  OnChangeEmojiSelectSearch value -> do
    H.modify_ $ _ { emojiSelectSearch = value }

  OnSelectEmoji event -> do
    for_ (Event.target event >>= HTMLElement.fromEventTarget) \el -> do
      value <- liftEffect $ HTMLInputElement.value $ unsafeCoerce el
      state <- H.get
      let
        newSettings = Settings.setTagSymbol state.tag value state.settings
      H.modify_ $ _
        { settings = newSettings
        , emojiSelectSearch = ""
        }
      liftAff $ Settings.save newSettings
      H.query _emojiSelect unit $ H.tell Select.Close

  HandleEmojiSelect msg -> do
    case msg of
      Select.Emit a -> handleAction a
      _ -> pure unit

  HandleLinkPane msg -> do
    state <- H.get
    case msg of
      LinkPane.MsgUpdate link -> do
        for_ (Array.findIndex (\x -> x.id == link.id) state.links) \index -> do
          let
            newLinks = fromMaybe state.links $
              Array.updateAt index link state.links
          H.modify_ $ _ { links = newLinks }
          Eval.saveLink link

      LinkPane.MsgDelete link -> do
        Eval.deleteLink link
