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
import FFI.Tauri as Tauri
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Model.Link (Link)
import Nonbili.Halogen as NbH
import Web.Event.Event as Event

renderLink :: Link -> HTML
renderLink link =
  HH.img
  [ class_ "object-contain hover:bg-gray-200 cursor-pointer"
  , style "width: 12rem; height: 16rem;"
  , HP.src $ fromMaybe "" link.image
  , HE.onClick $ Just <<< const (OnSelectLink link)
  ]

render :: State -> HTML
render state =
  HH.div
  [ class_ "grid h-screen"
  , style "grid-template-rows: auto 1fr"
  ]
  [ HH.form
    [ class_ "bg-blue-200 py-2 px-4"
    , HE.onSubmit $ Just <<< OnSubmit
    ]
    [ HH.input
      [ class_ "py-1 px-2 rounded w-1/3 border-none"
      , HP.required true
      , HP.placeholder "Save a link https://any.url"
      , HE.onValueChange $ Just <<< OnValueChange
      ]
    , HH.button
      [ class_ "hidden"
      , HP.type_ HP.ButtonSubmit
      ]
      [ HH.text "Add"]
    ]
  , HH.div
    [ class_ "grid min-h-0"
    , style "grid-template-columns: 1fr auto;"
    ]
    [ HH.div
      [ class_ "p-4 grid grid-flow-col gap-4"
      , style "grid-auto-columns: min-content"
      ] $ map renderLink state.links
    , HH.div
      [ class_ "border-l h-full min-h-0 pb-8 overflow-y-auto"
      , style "width: 24rem"
      ]
      [ HH.slot _linkPane unit LinkPane.component state.selectedLinks $
          const Nothing
      ]
    ]
  , NbH.when state.isInitModalOpen \\ InitModal.render state
  ]

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
      H.modify_ \s -> s { links = Array.snoc s.links link }
      Eval.save

  OnValueChange url -> do
    H.modify_ $ _ { url = url }

  OnSelectLink link -> do
    H.modify_ $ _ { selectedLinks = [link] }

  OnClickOpenDialog -> do
    dir <- liftAff Tauri.openDialog
    H.modify_ $ _ { dataDir = dir }

  OnSubmitInitModal -> do
    state <- H.get
    liftEffect $ Tauri.setDataDir state.dataDir
    Eval.load
    H.modify_ $ _ { isInitModalOpen = false }
