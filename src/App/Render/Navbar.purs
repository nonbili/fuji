module App.Render.Navbar
  ( render
  ) where

import Fuji.Prelude

import App.Route (AppRoute(..))
import App.Route as Route
import App.Types (HTML, State)
import Data.String as String
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Nonbili.Halogen as NbH

render :: State -> HTML
render state =
  HH.nav
  [ class_ "bg-green-400 flex flex-col justify-between"]
  [ HH.a
    [ class_ $ if String.null state.tag then activeCls else itemCls
    , HP.href $ Route.showRoute RouteHome
    ]
    [ HH.text "🏠"]
  , NbH.unless (String.null state.tag) \\
      HH.a
      [ class_ activeCls]
      [ HH.text "🔖"]
  ]
  where
  itemCls = "flex items-center justify-center w-10 h-10"
  activeCls = itemCls <> " bg-green-500"
