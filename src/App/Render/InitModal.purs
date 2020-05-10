module App.Render.InitModal
  ( render
  ) where

import Fuji.Prelude

import App.Types (Action(..), HTML, State)
import Data.String as String
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Nonbili.Halogen as Nbh

render :: State -> HTML
render state =
  HH.div
  [ class_ "fixed inset-0 bg-black bg-opacity-75"
  ]
  [ HH.div
    [ class_ "bg-white p-8"]
    [ HH.text "modal"
    , HH.button
      [ HE.onClick $ Just <<< const OnClickOpenDialog ]
      [ HH.text "Open"]
    , Nbh.unless (String.null state.dataDir) \\
        HH.div_
        [ HH.text state.dataDir
        , HH.div_
          [ HH.button
            [ class_ "Btn-primary"
            , HE.onClick $ Just <<< const OnSubmitInitModal
            ]
            [ HH.text "OK"]
          ]
        ]
    ]
  ]
