# ♾ Inflist

Inflist is a infinitely nestable todo list written in [PureScript](https://www.purescript.org/). It's an **excercise** and an **experiment** to better understand the interoperability between **PureScript** and [React](https://reactjs.org/).

## Architecture

This application uses [purescript-react-basic](https://github.com/lumihq/purescript-react-basic) and [purescript-react-basic-hook](https://github.com/megamaddu/purescript-react-basic-hooks) to operate using React as the user interface library. Even though _purescript-react-basic_ is almost not maintained anymore, _purescript-react-basic-hook_ is quite a formidable porting with a really flexible API and easy to use.

The global state is managed through the use of the [`useContextSelector` hook](https://github.com/dai-shi/use-context-selector) and [`useReducer` hook](https://reactjs.org/docs/hooks-reference.html#usereducer). Using just the Context API would result in a drop of performance due to the fact that the context in React should not be used for highly dynamic values since it will cause the whole application to re-render everytime. The `useContextSelector` hook behave a bit more like the `useSelector` from Redux, subscribing to only the piece of context we really want to observe.

The **Storage Layer** uses the [Local Storage](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage) to save the application's current state. Even though it's possible to implement different [storage strategies](https://github.com/dgopsq/inflist/blob/master/src/App/Api/Storage/Storage.purs), the persistence is **not** optimized and the consistency is not really assured. The logic that Inflist uses to store and retrieve the persisted state is a bit scattered across the application (mostly in the [`ConnectedTodo`](https://github.com/dgopsq/inflist/blob/master/src/App/Components/ConnectedTodo.purs) and [`TodosListPage`](https://github.com/dgopsq/inflist/blob/master/src/App/Pages/TodosListPage.purs) components) and too much coupled with the React lifecycle events.
