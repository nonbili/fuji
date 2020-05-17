module App.Eval where

import Fuji.Prelude

import App.Types (DSL)
import Data.Array as Array
import Data.Ordering as Ord
import Effect.Aff as Aff
import FFI.Tauri as Tauri
import Halogen as H
import Model.Link (Link)
import Model.Link as Link
import Model.LinkDetail as LinkDetail

init :: DSL Unit
init = do
  liftAff (Aff.attempt Tauri.getDataDir) >>= case _ of
    Left _ -> H.modify_ $ _ { isInitModalOpen = true }
    Right _ -> load

load :: DSL Unit
load = do
  liftAff Link.loadAll >>= traverse_ \links ->
    H.modify_ $ _
      { links = links # Array.sortBy \x1 x2 ->
          Ord.invert $ compare x1.id x2.id
      }

saveLink :: Link -> DSL Unit
saveLink link = do
  liftAff $ Link.save link

deleteLink :: Link -> DSL Unit
deleteLink link = do
  H.modify_ \s -> s
    { links = Array.delete link s.links
    , selectedLinkIds = []
    }
  liftAff do
    Link.delete link.id
    LinkDetail.delete link.id
