module App.Render.CurrentTag
  ( render
  ) where

import Fuji.Prelude

import App.Types (Action(..), HTML, State)
import Data.Set as Set
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Model.Tag as Tag
import Nonbili.Halogen as NbH

render :: State -> HTML
render state = NbH.unless (Tag.null state.tag) \\
  HH.div
  [ class_ "flex items-baseline mb-4"]
  [ HH.h1
    [ class_ "mr-5"]
    [ HH.text "🔖"
    , HH.text $ Tag.toString state.tag
    ]
  , HH.button
    [ class_ $ "Btn cursor-pointer " <>
        if starred
        then "bg-yellow-500 text-white"
        else "bg-transparent border border-yellow-600 text-yellow-600"
    , HE.onClick $ Just <<< const (OnToggleStarTag $ not starred)
    ]
    [ HH.text $ if starred then "Starring" else "+ Star"
    ]
  ]
  where
  starred =
    if Tag.null state.tag
      then false
      else Set.member state.tag state.settings.starredTags
