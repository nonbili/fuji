module App.Route where

import Fuji.Prelude

import Data.Foldable (oneOf)
import Routing.Match (Match, end, lit, root, str)

data AppRoute
  = RouteHome
  | RouteTag String

derive instance eqAppRoute :: Eq AppRoute
derive instance ordAppRoute :: Ord AppRoute

appRoute :: Match AppRoute
appRoute =
  root *> oneOf
    [ RouteHome <$ end
    , RouteTag  <$> (lit "tags" *> str)
    ]

showRoute :: AppRoute -> String
showRoute x = "#" <> case x of
  RouteHome -> "/"
  RouteTag tag -> "/tags/" <> tag
