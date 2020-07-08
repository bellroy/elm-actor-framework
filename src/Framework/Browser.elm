module Framework.Browser exposing
    ( Program
    , element
    , document
    , application
    , FrameworkModel, toProgramRecord
    )

{-|

---

**Program**

  - [Program](#Program)

**Elements**

  - [element](#element)

**Documents**

  - [document](#document)

**Application**

  - [application](#application)

**Utility**

  - [FrameworkModel](#FrameworkModel)
  - [toProgramRecord](#toProgramRecord)

---

@docs Program


# Elements

@docs element


# Documents

@docs document


# Application

@docs application


# Utility

@docs FrameworkModel, toProgramRecord

-}

import Browser exposing (Document, UrlRequest)
import Browser.Navigation exposing (Key)
import Framework.Internal.Actor exposing (Process)
import Framework.Internal.Message exposing (FrameworkMessage)
import Framework.Internal.Model as Model
import Framework.Internal.Pid exposing (Pid)
import Framework.Internal.Render as Render
import Framework.Internal.Subscriptions as Subscriptions
import Framework.Internal.Update as Update
import Html exposing (Html)
import Url exposing (Url)


{-| All of the functions in this module will return a Program.
A Program describes an Elm program! How does it react to input? Does it show anything on screen? Etc.
-}
type alias Program elmFlags appFlags appAddresses appActors appModel appMsg =
    Platform.Program
        --
        elmFlags
        --
        (FrameworkModel appAddresses appModel)
        --
        (FrameworkMessage appFlags appAddresses appActors appModel appMsg)


{-| Create an HTML element managed by Elm. The resulting elements are easy to embed in larger JavaScript projects, and lots of companies that use Elm started with this approach! Try it out on something small. If it works, great, do more! If not, revert, no big deal.
-}
element :
    { factory :
        appActors
        -> ( Pid, appFlags )
        -> ( appModel, FrameworkMessage appFlags appAddresses appActors appModel appMsg )
    , apply :
        appModel
        -> Process appModel output (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
    , init :
        elmFlags
        -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
    , view :
        List output
        -> Html (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
    }
    -> Program elmFlags appFlags appAddresses appActors appModel appMsg
element { init, factory, apply, view } =
    let
        record =
            toProgramRecord { factory = factory, apply = apply }
    in
    Browser.element
        { init = init >> record.init
        , update = record.update
        , subscriptions = record.subscriptions
        , view = view << Render.element apply
        }


{-| Create an HTML document managed by Elm.
This expands upon what element can do in that view now gives you control over the <title> and <body>.
-}
document :
    { factory :
        appActors
        -> ( Pid, appFlags )
        -> ( appModel, FrameworkMessage appFlags appAddresses appActors appModel appMsg )
    , apply :
        appModel
        -> Process appModel output (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
    , init :
        elmFlags
        -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
    , view :
        List output
        -> List (Html (FrameworkMessage appFlags appAddresses appActors appModel appMsg))
    }
    -> Program elmFlags appFlags appAddresses appActors appModel appMsg
document { factory, apply, init, view } =
    let
        record =
            toProgramRecord { factory = factory, apply = apply }
    in
    Browser.document
        { init = init >> record.init
        , update = record.update
        , subscriptions = record.subscriptions
        , view = record.view view
        }


{-| Create an application that manages Url changes.
-}
application :
    { factory :
        appActors
        -> ( Pid, appFlags )
        -> ( appModel, FrameworkMessage appFlags appAddresses appActors appModel appMsg )
    , apply :
        appModel
        -> Process appModel output (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
    , init :
        elmFlags
        -> Url
        -> Key
        -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
    , view :
        List output
        -> List (Html (FrameworkMessage appFlags appAddresses appActors appModel appMsg))
    , onUrlRequest :
        UrlRequest
        -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
    , onUrlChange :
        Url
        -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
    }
    -> Program elmFlags appFlags appAddresses appActors appModel appMsg
application { factory, apply, init, view, onUrlRequest, onUrlChange } =
    let
        record =
            toProgramRecord { factory = factory, apply = apply }
    in
    Browser.application
        { init = \elmFlags url key -> init elmFlags url key |> record.init
        , update = record.update
        , subscriptions = record.subscriptions
        , view = record.view view
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }



---


{-| An alias for the Internal Framework Model
-}
type alias FrameworkModel appAddresses appModel =
    Model.FrameworkModel appAddresses appModel


{-| Returns a record that is ready to be used on one of the elm/browsers creation functions.

This can be used to roll your own Program

-}
toProgramRecord :
    { factory : appActors -> ( Pid, appFlags ) -> ( appModel, FrameworkMessage appFlags appAddresses appActors appModel appMsg )
    , apply : appModel -> Process appModel output (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
    }
    ->
        { init :
            FrameworkMessage appFlags appAddresses appActors appModel appMsg
            -> ( FrameworkModel appAddresses appModel, Cmd (FrameworkMessage appFlags appAddresses appActors appModel appMsg) )
        , update :
            FrameworkMessage appFlags appAddresses appActors appModel appMsg
            -> FrameworkModel appAddresses appModel
            -> ( FrameworkModel appAddresses appModel, Cmd (FrameworkMessage appFlags appAddresses appActors appModel appMsg) )
        , subscriptions : FrameworkModel appAddresses appModel -> Sub (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
        , view : (List output -> List (Html msg)) -> FrameworkModel appAddresses appModel -> Document msg
        }
toProgramRecord args =
    let
        init msg =
            update msg Model.empty

        update =
            Update.update args Nothing

        subscriptions =
            Subscriptions.getSubscriptions args.apply

        view =
            Render.application args.apply
    in
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }
