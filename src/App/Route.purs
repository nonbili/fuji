module App.Route where

import Fuji.Prelude

import Data.Foldable (oneOf)
import Model.Tag (Tag(..))
import Model.Tag as Tag
import Routing.Match (Match, end, lit, root, str)

data AppRoute
  = RouteHome
  | RouteTag Tag

derive instance eqAppRoute :: Eq AppRoute
derive instance ordAppRoute :: Ord AppRoute

appRoute :: Match AppRoute
appRoute =
  root *> oneOf
    [ RouteHome <$ end
    , (RouteTag <<< Tag) <$> (lit "tags" *> str)
    ]

showRoute :: AppRoute -> String
showRoute x = "#" <> case x of
  RouteHome -> "/"
  RouteTag tag -> "/tags/" <> Tag.toString tag
