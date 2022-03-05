module App.Components.Navbar where

import Prelude
import App.Components.Layout (mkLayout)
import App.Components.Link (mkLink)
import App.State.Todo (TodoId)
import AppComponent (AppComponent, appComponent)
import Control.Monad.Trans.Class (lift)
import React.Basic.DOM as DOM

type Props
  = { parentId :: TodoId }

-- | A purely visual component rendering the 
-- | application's top navbar.
mkNavbar :: AppComponent Props
mkNavbar = do
  layout <- lift mkLayout
  link <- mkLink
  appComponent "Navbar" \_ -> React.do
    pure
      $ DOM.div
          { className: "pt-20"
          , children:
              [ layout
                  [ DOM.div
                      { className: "flex flex-row justify"
                      , children:
                          [ DOM.div_
                              [ link
                                  { route: "/"
                                  , children:
                                      [ DOM.span
                                          { className: "text-5xl tracking-wide font-black text-black"
                                          , children: [ DOM.text "♾ inflist" ]
                                          }
                                      ]
                                  }
                              ]
                          ]
                      }
                  ]
              ]
          }
