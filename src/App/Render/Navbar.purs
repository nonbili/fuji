module App.Render.Navbar
  ( render
  ) where

import Fuji.Prelude

import App.Route (AppRoute(..))
import App.Route as Route
import App.Types (HTML, State)
import Data.Array as Array
import Data.Set as Set
import Data.String as String
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Nonbili.Halogen as NbH

render :: State -> HTML
render state@{ settings } =
  HH.nav
  [ class_ "bg-green-400 flex flex-col justify-between"]
  [ HH.div
    []
    [ HH.a
      [ class_ $ if String.null state.tag then activeCls else itemCls
      , HP.href $ Route.showRoute RouteHome
      ]
      [ HH.text "🏠"]
    , HH.div
      [ class_ "py-2 border-t-2 border-green-500 -m-px"
      ] $ Array.fromFoldable settings.starredTags <#> \tag ->
        HH.a
        [ class_ $ if state.tag == tag then activeCls else itemCls
        , HP.href $ Route.showRoute $ RouteTag tag
        , HP.title tag
        ]
        [ HH.text "🔖"]
    ]
  , NbH.when showPlaceholder \\
      HH.a
      [ class_ activeCls]
      [ HH.text "🔖"]
  ]
  where
  itemCls = "flex items-center justify-center w-10 h-10 no-underline"
  activeCls = itemCls <> " bg-green-500"
  showPlaceholder =
    String.null state.tag ||
    not (Set.member state.tag settings.starredTags)
