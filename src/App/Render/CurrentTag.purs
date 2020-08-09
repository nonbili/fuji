module App.Render.CurrentTag
  ( emojiListRef
  , render
  ) where

import Fuji.Prelude

import App.Types (Action(..), HTML, State, _emojiSelect)
import Data.Set as Set
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Model.Settings as Settings
import Model.Tag as Tag
import NSelect as Select
import Nonbili.Halogen as NbH

emojiListRef = H.RefLabel "emoji-list" :: H.RefLabel

renderSelect :: State -> Select.State -> Select.HTML Action () Aff
renderSelect state st =
  HH.div
  ( Select.setRootProps [ class_ "inline-block"]
  ) $ join
  [ pure $ HH.button
    ( Select.setToggleProps
      [ class_ "bg-transparent cursor-pointer"
      , style "font-size: inherit;"
      ]
    )
    [ HH.text $ Settings.getTagSymbol state.tag state.settings ]
  , guard st.isOpen $> HH.div
    [ class_ "absolute p-4 bg-white text-base overflow-y-auto border shadow-xl z-dropdown"
    , style "width: 28.5rem; max-height: 60vh"
    ]
    [ HH.input
      [ class_ "Input mb-4"
      , HP.value state.emojiSelectSearch
      , HP.placeholder "Search"
      , HE.onValueInput $ Just <<< Select.raise <<< OnChangeEmojiSelectSearch
      ]
    , NbH.element "emoji-list"
      [ NbH.attr "filter" state.emojiSelectSearch
      , HP.ref emojiListRef
      , HE.onChange $ Just <<< Select.raise <<< OnSelectEmoji
      ]
      []
    ]
  ]

render :: State -> HTML
render state = NbH.unless (Tag.null state.tag) \\
  HH.div
  [ class_ "flex items-baseline mb-4"]
  [ HH.h1
    [ class_ "mr-5 flex"]
    [ HH.slot _emojiSelect unit Select.component
        { render: renderSelect state
        , itemCount: 0
        } $ Just <<< HandleEmojiSelect
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
