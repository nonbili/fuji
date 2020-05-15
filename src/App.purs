module App
  ( app
  ) where

import Fuji.Prelude

import Api as Api
import App.Eval as Eval
import App.Render.InitModal as InitModal
import App.Types (Action(..), DSL, HTML, Message, Query, State, _linkPane, initialState, metaToLink)
import Component.LinkPane as LinkPane
import Data.Array as Array
import Data.Monoid as Monoid
import Effect.Exception as E
import FFI.Tauri as Tauri
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Model.Link (Link)
import Model.LinkDetail as LinkDetail
import Nonbili.Halogen as NbH
import Web.Event.Event as Event

renderLink :: State -> Link -> HTML
renderLink state link =
  HH.img
  [ class_ $ "object-contain hover:bg-gray-200 cursor-pointer m-2" <>
      Monoid.guard selected " border-green-500 border-2 py-2"
  , style "width: 12rem; height: 16rem;"
  , HP.src $ fromMaybe "" link.image
  , HE.onClick $ Just <<< const (OnSelectLink link)
  ]
  where
  selected = Array.elem link.id state.selectedLinkIds

render :: State -> HTML
render state =
  HH.div
  [ class_ "flex flex-col h-screen"
  ]
  [ HH.form
    [ class_ "bg-blue-200 py-2 px-4"
    , HE.onSubmit $ Just <<< OnSubmit
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
      [ class_ "flex-1 p-4 flex flex-wrap content-start min-w-0 overflow-y-auto"
      ] $ map (renderLink state) state.links
    , HH.div
      [ class_ "border-l h-full min-h-0 overflow-y-auto"
      , style "width: 24rem"
      ]
      [ HH.slot _linkPane unit LinkPane.component selectedLinks $
          Just <<< HandleLinkPane
      ]
    ]
  , NbH.when state.isInitModalOpen \\ InitModal.render state
  ]
  where
  selectedLinks = state.links # Array.filter \link ->
    Array.elem link.id state.selectedLinkIds

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

  OnSubmit event -> do
    H.liftEffect $ Event.preventDefault event
    state <- H.get
    H.liftAff (Api.getMeta state.url) >>= traverse_ \meta -> do
      link <- H.liftEffect $ metaToLink meta
      H.modify_ \s -> s
        { links = Array.cons link s.links
        , url = ""
        }
      Eval.save

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

  HandleLinkPane msg -> do
    state <- H.get
    case msg of
      LinkPane.MsgUpdate link -> do
        for_ (Array.findIndex (\x -> x.id == link.id) state.links) \index -> do
          let
            newLinks = fromMaybe state.links $
              Array.updateAt index link state.links
          H.modify_ $ _ { links = newLinks }
          Eval.save

      LinkPane.MsgDelete link -> do
        H.modify_ $ _
          { links = Array.delete link state.links
          , selectedLinkIds = []
          }
        Eval.save
        liftAff $ LinkDetail.delete link.id
