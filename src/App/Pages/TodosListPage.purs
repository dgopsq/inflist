module App.Pages.TodosListPage where

import Prelude
import App.Components.AddTodoInput (mkAddTodoInput)
import App.Components.Layout (mkLayout)
import App.Components.TodosList (mkTodosList)
import App.Components.TodosListNav (mkTodosListNav)
import AppComponent (AppComponent, appComponent)
import Control.Monad.Reader (ask)
import Data.List (fromFoldable, length)
import Data.Map (lookup)
import Data.Maybe (Maybe(..), fromMaybe, isJust)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import React.Basic.DOM as DOM
import React.Basic.Hooks (useContext, (/\))
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useAff)
import State.Helpers (useSelector)
import State.Selectors (todosMapSelector)
import State.Todo (TodoId, genUniqTodo)
import State.TodosMapReducer (addTodo, loadTodo, updateTodo)

type Props
  = { parentId :: TodoId }

mkTodosListPage :: AppComponent Props
mkTodosListPage = do
  { store, todosStorage } <- ask
  todosList <- mkTodosList
  addTodoInput <- mkAddTodoInput
  layout <- mkLayout
  todosListNav <- mkTodosListNav
  appComponent "TodosListPage" \{ parentId } -> React.do
    todosMapState <- useSelector store.stateContext todosMapSelector
    dispatch <- useContext store.dispatchContext
    let
      maybeParent = lookup parentId todosMapState

      handleTodoChangeStatus :: TodoId -> Boolean -> Effect Unit
      handleTodoChangeStatus id status = case maybeTodo of
        Just todo -> dispatch $ updateTodo id (todo { checked = status })
        _ -> pure unit
        where
        maybeTodo = lookup id todosMapState

      handleAdd :: String -> Effect Unit
      handleAdd text = do
        newTodo <- genUniqTodo parentId text false
        dispatch $ addTodo newTodo

      maybePrevious = case maybeParent of
        Just parent -> lookup parent.parent todosMapState
        _ -> Nothing

      showedTodos = fromMaybe (fromFoldable []) $ map _.children maybeParent

      computedTodosListNav = case (Tuple maybeParent maybePrevious) of
        (Tuple (Just parent) (Just previous)) ->
          [ todosListNav
              { parentTodo: parent
              , previousTodo: previous
              }
          ]
        _ -> []
    -- This is used to retrieve the parent
    -- from the storage.
    parentRetrieved <-
      map isJust
        $ useAff parentId do
            maybeRetrievedParentTodo <- todosStorage.retrieve parentId
            case maybeRetrievedParentTodo of
              Just retrievedParentTodo -> liftEffect <<< dispatch $ loadTodo retrievedParentTodo
              _ -> pure unit
    -- This is used to synchronize the
    -- root todo with the storage.
    -- FIXME: There is an incorrect call
    -- in the very first render.
    _ <-
      useAff (parentRetrieved /\ maybeParent) do
        case (Tuple parentRetrieved maybeParent) of
          (Tuple true (Just parent)) -> todosStorage.store parent.id parent
          _ -> pure unit
    pure
      $ layout
          [ DOM.div
              { className: "pt-40"
              , children:
                  [ DOM.div_ computedTodosListNav
                  , DOM.div
                      { className: "mt-4"
                      , children:
                          [ addTodoInput { onAdd: handleAdd }
                          ]
                      }
                  , DOM.div
                      { className: if length showedTodos > 0 then "mt-4" else ""
                      , children:
                          [ todosList
                              { todos: showedTodos
                              , onTodoChangeStatus: handleTodoChangeStatus
                              }
                          ]
                      }
                  ]
              }
          ]
