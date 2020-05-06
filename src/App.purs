module App
  ( Message(..)
  , Query
  , Action
  , app
  ) where

import Nonbili.Prelude

import Api (Meta)
import Api as Api
import Data.Argonaut.Core as A
import Data.Argonaut.Encode (encodeJson)
import Effect.Aff (Aff)
import Effect.Exception (throw)
import Effect.Now as Now
import FFI.Tauri as Tauri
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Web.Event.Event (Event)
import Web.Event.Event as Event

type Message = Void

type Query = Const Void

data Action
  = Init
  | OnSubmit Event
  | OnValueChange String

type HTML = H.ComponentHTML Action () Aff

type DSL = H.HalogenM State Action () Message Aff

type State =
  { url :: String
  , metas :: Array Meta
  }

initialState :: State
initialState =
  { url: ""
  , metas: []
  }

renderMeta :: Meta -> HTML
renderMeta meta =
  HH.img
  [ HP.src meta.image
  ]

render :: State -> HTML
render state =
  HH.div_
  [ HH.form
    [ HE.onSubmit $ Just <<< OnSubmit
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
    H.liftAff (Api.getMeta state.url) >>= traverse_ \res -> do
      now <- H.liftEffect Now.now
      H.liftEffect $ Tauri.writeFile now $ A.stringify $ encodeJson res

  OnValueChange url -> do
    H.modify_ $ _ { url = url }
