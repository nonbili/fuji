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
import Model.Settings as Settings

init :: DSL Unit
init = do
  liftAff (Aff.attempt Tauri.getDataDir) >>= case _ of
    Left _ -> H.modify_ $ _ { isInitModalOpen = true }
    Right _ -> load

load :: DSL Unit
load = do
  liftAff Link.loadAll >>= traverse_ \links -> do
    liftAff Settings.load >>= traverse_ \settings -> do
      H.modify_ $ _
        { links = links # Array.sortBy \x1 x2 ->
            Ord.invert $ compare x1.id x2.id
        , selectedLinkIds = _.id <$> Array.take 1 links
        , settings = settings
        }

updateShowingLinkIds :: DSL Unit
updateShowingLinkIds = do
  H.modify_ $ \s -> s
    { showingLinkIds = _.id <$>
        (s.links # Array.filter \link ->
          Array.elem s.tag link.tags)
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
