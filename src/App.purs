module App
  ( app
  ) where

import Fuji.Prelude

import Api (Meta)
import Api as Api
import App.Eval as Eval
import App.Types (Action(..), DSL, HTML, Message, Query, State, initialState, metaToLink)
import Data.Array as Array
import Effect.Exception (throw)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Web.Event.Event as Event

renderMeta :: Meta -> HTML
renderMeta meta =
  HH.img
  [ HP.src $ fromMaybe "" meta.image
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
  , HH.div_ $ map renderMeta state.metas
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
    H.liftAff Api.readMetas >>= case _ of
      Left err -> H.liftEffect $ throw err
      Right metas -> do
        H.modify_ $ _ { metas = metas }

  OnSubmit event -> do
    H.liftEffect $ Event.preventDefault event
    state <- H.get
    H.liftAff (Api.getMeta state.url) >>= traverse_ \meta -> do
      link <- H.liftEffect $ metaToLink meta
      H.modify_ \s -> s { links = Array.snoc s.links link }
      Eval.persist

  OnValueChange url -> do
    H.modify_ $ _ { url = url }
