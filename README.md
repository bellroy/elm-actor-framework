# Elm Actor Framework

![Build Status](https://github.com/bellroy/elm-actor-framework/workflows/Continuous%20Integration/badge.svg) [![Elm package](https://img.shields.io/elm-package/v/bellroy/elm-actor-framework.svg)](https://package.elm-lang.org/packages/bellroy/elm-actor-framework/latest/)

This library allows you to more easily re-use components between Elm applications
by moving state, views and other logic into components themselves. Helping to
avoid the top heavy application that the traditional Elm architecture can lead
to and that becomes hard to maintain.

![Component > Actor > Process](https://raw.githubusercontent.com/bellroy/elm-actor-framework/assets/component_actor_process.png)

## Documentation

Start with the (tutorial)(#Tutorial) in this Readme file.

The API documentation is hosted on the [Elm package website](https://package.elm-lang.org/packages/bellroy/elm-actor-framework/latest).

## Example Applications

There are three examples in the example folder.

The output can be [seen online](https://bellroy.github.io/elm-actor-framework)
and it's easy to run them locally;

- Clone this repository.
- Navigate to the example folder; `cd example`.
- On the root of the example folder run `yarn install`
- Run one of the live examples;
  - **Counter** example `yarn run start:counter`
  - Multiple **Counters** example `yarn run start:counters`
  - A Simple **SPA** (Single Page Application) example `yarn run start:spa`
- Visit `http://localhost:8000` in your desired browser.

## Templates

Actors make up ideal components that can be used on a template.

- [Elm Actor Framework - Templates](https://github.com/bellroy/elm-actor-framework-template)
- [Elm Actor Framework - Templates - Html](https://github.com/bellroy/elm-actor-framework-template-html)
- [Elm Actor Framework - Templates - Markdown](https://github.com/bellroy/elm-actor-framework-template-markdown)

---

## Tutorial

It's easiest, or maybe just easiest for me, to start at the "inside" when
describing how the Elm Actor Framework works, or better; how to use it.

### Component

The concept of a `Component` within this little framework is as followed;

A component describes what what its state looks like _(Model)_, its initial
state and action _(init)_ , how it can _update_ its state based on messages
_(MsgIn)_ and what it outputs _(view)_.

Hopefully this sounds very familiar. It follows the same pattern as any other
Elm framework. Without too much work a simple Elm application could be ported to
become a `Component`.

A neat thing about `Component`s is that they could be interchangeable between
different application.

Let's start with setting up a simple **Counter** `Component`.
The `Component` is a record which signature can be imported from the
`Framework.Actor` module. It looks almost the same as Elm.Browser's embed
function so this is going to be easy!

---

`File: Component/Counter.elm`

```elm
module Component.Counter exposing (Model, MsgIn, component)
```

We are going to use the Component record type from this package

```elm
import Framework.Actor exposing (Component)
```

This Component will output `Html`, but you decide what your Component will output;
You could just output Strings for example or perhaps you prefer using elm-ui!

```elm
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
```

Our Counters `Model` will be an alias for an Integer.

```elm
type alias Model =
    Int
```

Our Counter can `Increment` or `Decrement` its state using these `msg`'s.
I've called them `MsgIn` because a component can also have `msgOut`'s but we are
not going to use those for our first go.

```elm
type MsgIn
    = Increment
    | Decrement
```

Our Component doesn't use `appFlags` so we can tell it to never expect
anything by giving it the `()` type. We also opt-out of using `msgOut` using
the same technique

```elm
component : Component () Model MsgIn () (Html msg) msg
component =
    { init = init
    , update = update
    , subscriptions = always Sub.none
    , view = view
    }
```

The initial state of our Counter is 0. We aren't returning any msgOuts or
cmd's just yet.

```elm
init : a -> ( Model, List (), Cmd msg )
init _ =
    ( 0, [], Cmd.none )
```

Given a `msgIn` and our current state (Model) we can return a new updated state

```elm
update : MsgIn -> Model -> ( Model, List (), Cmd MsgIn )
update msgIn model =
    case msgIn of
        Increment ->
            ( model + 1, [], Cmd.none )

        Decrement ->
            ( model - 1, [], Cmd.none )
```

Our view function renders our counter's current value and two buttons that can
decrement or increment the counters value.
The view function gets a function provided that knows how to turn internal
`MsgIn`'s into higher level `msg`'s. We need to use Html.map is this case to
comply with the expected return type.

```elm
view : (MsgIn -> msg) -> Model -> a -> Html msg
view toSelf model _ =
    div []
        [ Html.button [ HtmlE.onClick Decrement ] [ Html.text "-" ]
        , Html.span [] [ String.fromInt model |> Html.text ]
        , Html.button [ HtmlE.onClick Increment ] [ Html.text "+" ]
        ]
        |> Html.map toSelf
```

In the module above we have described a simple **Counter** `Component` that
starts with an integer value of 0 and decrements or increments its value by 1
when a user clicks one of the buttons.

### Program

Now that we have created our first Component we can start setting up the rest
of our Program.

<img
  src="https://i.imgur.com/SBErZBD.jpg"
  alt="First create some Components and then write the rest of your Program"
  width="300"
/>

---

`File: Main.elm`

```elm
module Main exposing (main)

import Html exposing (div)
```

Elm's `main` function expects a `Program` to be returned. The
`Framework.Browser` module offers multiple ways of creating such a Program, and
mirrors the behaviour described on [Elm's - Browser package](https://package.elm-lang.org/packages/elm/browser/latest/Browser).

```elm
import Framework.Browser exposing (Program, element)
```

We will also require the `Framework.Message` and `Framework.Actor` modules later on.

```elm
import Framework.Actor exposing (Actor, Pid, Process, fromComponent)
import Framework.Message exposing (FrameworkMessage, addToView, batch, noOperation, spawn)
```

Import the Counter we just created, not that the Counter module itself doesn't
depend on any types we will define here. The counter we just created could come
from a different application and we can reuse our Counter on a different
application as well.

```elm
import Component.Counter as Counter
```

We are going to use the element function here that on its turn uses the Elm's -
Browser package to create our Elm application.
https://package.elm-lang.org/packages/elm/browser/latest/Browser#element

For now we skip the elmFlags appFlags and appAddresses definitions by
supplying `()`.

```elm
main : Program () () () AppActors AppModel AppMsg
main =
    Browser.element
        { factory = factory
        , apply = apply
        , init = init
        , view = view
        }
```

Our Program signature tells us we need to supply it a type representing our
`appActors`. This is a type we use that represents our Actors within our
application.

```elm
type AppActors
    = Counter
```

Our components hold define and deal their own state (Model) but it's our
application that eventually needs to store this. `appModel` is a type that
can wrap our components Models.

```elm
type AppModel
    = CounterModel Counter.Model
```

Just like the `appModel` our application has to deal with all of our components
`msgIn`'s. In a similar fashion of how our AppModel wraps our Counter.Model;
AppMsg wraps our Counter.MsgIn.

```elm
type AppMsg
    = CounterMsg Counter.MsgIn
```

Now that we've dealt with our required types, we can start looking at
implementing the functions we promised to our Browser.element function
starting with the factory function.

This is were things become a little bit more tricky. I've tried writing this in
a more "discovering" order then perhaps logical or chronological.

The first next "clue" we have is our missing `factory` implementation.
A factory's signature looks like;

> ```elm
> appActors
>  -> ( Pid, appFlags )
>  -> ( appModel, FrameworkMessage appFlags appAddresses appActors appModel appMsg )
> ```

We've already handled the type variables we see here when we defined our `Program`.
And by creating a `Msg` type alias we don't have to repeat the `FrameworkMessage`
type every time.

Our component doesn't care about it's Pid so we can simplify our implementation
a little but by ignoring that Tuple all together.

> ```elm
> type alias Msg =
>     FrameworkMessage () () AppActors AppModel AppMsg
>
>
> factory : AppActors -> a -> ( AppModel, Msg )
> ```

Now the signature is a bit easier to talk about;
Factory takes an `AppActors` and should give us back a function `a -> (AppModel, Msg)`.

Now if we search for that signature on our Api documentation we'll find that
the `Actor` record on the `Framework.Actor` module provides an `init` function
with that exact signature.

So now we need to think about how we can get an `Actor` to use on our `factory`
function. On the same `Actor` module we can find the `fromComponent` function.

The `fromComponent` function takes a record of functions that allow a
`Component` to progress in to an `Actor`.

The record requires the following functions;

- `toAppModel: componentModel -> appModel`
  Given an componentModel return an appModel... Hey we've already got this
  covered! Our `AppModel`'s `CounterModel` takes `Counter.Model` as a value.
- `toAppMsg: componentMsgIn -> appMsg`
  Very similar to `toAppModel`; We can use `AppMsg`'s `CounterMsg` here.
- `fromAppMsg: appMsg -> Maybe componentMsgIn`
  This is almost the opposite of `toAppMsg`, given an `AppMsg` we might be able
  to return a `componentMsgIn` (a `Counter.Msg`).
- `onMsgOut: { self: Pid, msgOut: componentMsgOut } -> FrameworkMessage ppFlags appAddresses appActors appModel appMsg`
  Our component doesn't have any `msgOut`'s so we can just return a NoOp from
  the `Framework.Message` module here to comply with the requested return type.

The signature of an Actor combines a few type variables that we can get from our
`Component` and a few that we have defined here on our actual App.

> ```elm
> Actor appFlags componentModel appModel output frameworkMs
> ```

Knowing all this we can define our actor based on our _Counter_ `Component`.

I am going to call our actor `counter`.

```elm
counter : Actor () Counter.Model AppModel (Html Msg) Msg
counter =
    fromComponent
        { toAppModel = CounterModel
        , toAppMsg = CounterMsg
        , fromAppMsg = \(CounterMsg msgIn) -> Just msgIn
        , onMsgOut = \_ -> noOperation
        }
        Counter.component
```

Now we have turned our `Component` in to an `Actor` by providing functions that
let our `Component` understand how to "deal" with our Application level types.

This let's us continue with the `factory` implementation; we were searching for
a function that provides us with the required signature and by creating our
`counter` `Actor` we have done just that.

```elm
type alias Msg =
    FrameworkMessage () () AppActors AppModel AppMsg


factory : AppActors -> ( Pid, () ) -> ( AppModel, Msg )
factory actor =
    case actor of
        Counter ->
            counter.init
```

Now we can obviously just return `counter.init` straight away, we don't need
to case match here. But imagine having more then one `Actor` then this is the
way to handle multiple of them.

Cool, so one down. Next is the `apply` function. The (simplified) signature
looks like;

> ```elm
> apply : appModel -> Process appModel output Msg
> ```

So in our case; given an `AppModel` return a `Process AppModel (Html Msg) Msg`

Well first, what is an Process within the scope of this package?

An Process means an Actor + State. So in other words a "running" Actor.

![Component > Actor > Process](https://raw.githubusercontent.com/bellroy/elm-actor-framework/assets/component_actor_process.png)

We can get a `Process` from our freshly created `Actor` by using its `apply`
function and providing its `componentModel`.

```elm
apply : AppModel -> Process AppModel (Html Msg) Msg
apply appModel =
    case appModel of
        CounterModel counterModel ->
            counter.apply counterModel
```

That's it, to easy!

Next up; `init`

Just like the `init` function on our `Component` or on a typical Elm application
`init` allows us to set an initial state of our Application.

Unlike the other mentioned `init` functions our `init` should return a
`FrameworkMessage` though instead of a `Model`. But fear not because by calling
these messages we update an predetermined framework model.

Without using init we haven't actually "started" our **Counter** `Actor` yet.
And Let's straight away utilise our set up here and spin up two **Counter**'s
at start up that each hold their own state.

We can start our `Actors` by `spawn`-ing them.

`spawn` on the `Framework.Message` module takes 3 arguments.

- `elm appFlags`
  Just like a typical Elm app your actors could receive some flags at start up.
  We already set our app doesn't use though so we'll leave it to `()` for now.
- `appActors`
  The actor you want to spawn
- `(Pid -> Msg)`
  A callback function that will provide the newly created `Pid`.
  The `Pid` is the unique identifier of a process that can be used to send
  message to.

When we do `spawn` our **Counter**'s we should also let the application know
what to do with the output. For now we will add the output of our **Counter**'s
straight on our application view using `addToView`. In other cases you might
want a different Actor spawn different Actors.

We can use `batch` to batch multiple `FrameworkMessage`'s in to a single one.
The batch will be performed in order.

```elm
init : flags -> Msg
init _ =
    batch
        [ spawn () Counter addToView
        , spawn () Counter addToView
        ]
```

We're nearly there. All is left is to provide our main function with a `view`
This should be very straight forward.

```elm
view : List (Html Msg) -> Html Msg
view =
    div []
```

An near identical demonstration of this Counter example can be found inside the
`example` folder. There are also two more examples listed there that
progressively utilise more of the frameworks capabilities.
