module App
  ( app
  ) where

import Fuji.Prelude

import Api as Api
import App.Eval as Eval
import App.Types (Action(..), DSL, HTML, Message, Query, State, initialState, metaToLink)
import Data.Array as Array
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Model.Link (Link)
import Web.Event.Event as Event

renderLink :: Link -> HTML
renderLink link =
  HH.img
  [ class_ "w-15 h-20 object-fit"
  , HP.src $ fromMaybe "" link.image
  ]

render :: State -> HTML
render state =
  HH.div_
  [ HH.form
    [ class_ "bg-blue-200 py-2 px-4"
    , HE.onSubmit $ Just <<< OnSubmit
    ]
    [ HH.input
      [ HP.required true
      , HE.onValueChange $ Just <<< OnValueChange
      ]
    , HH.button
      [ HP.type_ HP.ButtonSubmit]
      [ HH.text "Add"]
    ]
  , HH.div_ $ map renderLink state.links
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
      Eval.persist

  OnValueChange url -> do
    H.modify_ $ _ { url = url }
