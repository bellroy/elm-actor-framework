module Framework.Browser exposing
    ( Program
    , element
    , document
    , application
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

---

@docs Program


# Elements

@docs element


# Documents

@docs document


# Application

@docs application

-}

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Framework.Internal.Actor exposing (Process)
import Framework.Internal.Message exposing (FrameworkMessage)
import Framework.Internal.Model as Model exposing (FrameworkModel)
import Framework.Internal.Pid exposing (Pid)
import Framework.Internal.Render as Render
import Framework.Internal.Update exposing (update)
import Html exposing (Html)
import Url exposing (Url)


{-| All of the functions in this module will return a Program.
A Program describes an Elm program! How does it react to input? Does it show anything on screen? Etc.
-}
type alias Program elmFlags appFlags appAddresses appActorNames appModel appMsg =
    Platform.Program
        --
        elmFlags
        --
        (FrameworkModel appAddresses appModel)
        --
        (FrameworkMessage appFlags appAddresses appActorNames appModel appMsg)


{-| Create an HTML element managed by Elm. The resulting elements are easy to embed in larger JavaScript projects, and lots of companies that use Elm started with this approach! Try it out on something small. If it works, great, do more! If not, revert, no big deal.
-}
element :
    { factory :
        appActorNames
        -> ( Pid, appFlags )
        -> ( appModel, FrameworkMessage appFlags appAddresses appActorNames appModel appMsg )
    , apply :
        appModel
        -> Process appModel output (FrameworkMessage appFlags appAddresses appActorNames appModel appMsg)
    , init :
        elmFlags
        -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
    , view :
        List output
        -> Html (FrameworkMessage appFlags appAddresses appActorNames appModel appMsg)
    }
    -> Program elmFlags appFlags appAddresses appActorNames appModel appMsg
element { init, factory, apply, view } =
    let
        updateArgs =
            { factory = factory
            , apply = apply
            }
    in
    Browser.element
        { init = init >> (\msg -> update updateArgs Nothing msg Model.empty)
        , update = update updateArgs Nothing
        , subscriptions = always Sub.none
        , view = view << Render.element apply
        }


{-| Create an HTML document managed by Elm.
This expands upon what element can do in that view now gives you control over the <title> and <body>.
-}
document :
    { factory :
        appActorNames
        -> ( Pid, appFlags )
        -> ( appModel, FrameworkMessage appFlags appAddresses appActorNames appModel appMsg )
    , apply :
        appModel
        -> Process appModel output (FrameworkMessage appFlags appAddresses appActorNames appModel appMsg)
    , init :
        elmFlags
        -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
    , view :
        List output
        -> List (Html (FrameworkMessage appFlags appAddresses appActorNames appModel appMsg))
    }
    -> Program elmFlags appFlags appAddresses appActorNames appModel appMsg
document args =
    let
        updateArgs =
            { factory = args.factory
            , apply = args.apply
            }
    in
    Browser.document
        { init = args.init >> (\msg -> update updateArgs Nothing msg Model.empty)
        , update = update updateArgs Nothing
        , subscriptions = always Sub.none
        , view = Render.application args.apply args.view
        }


{-| Create an application that manages Url changes.
-}
application :
    { factory :
        appActorNames
        -> ( Pid, appFlags )
        -> ( appModel, FrameworkMessage appFlags appAddresses appActorNames appModel appMsg )
    , apply :
        appModel
        -> Process appModel output (FrameworkMessage appFlags appAddresses appActorNames appModel appMsg)
    , init :
        elmFlags
        -> Url
        -> Key
        -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
    , view :
        List output
        -> List (Html (FrameworkMessage appFlags appAddresses appActorNames appModel appMsg))
    , onUrlRequest :
        UrlRequest
        -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
    , onUrlChange :
        Url
        -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
    }
    -> Program elmFlags appFlags appAddresses appActorNames appModel appMsg
application args =
    let
        updateArgs =
            { factory = args.factory
            , apply = args.apply
            }
    in
    Browser.application
        { init =
            \elmFlags url key ->
                args.init elmFlags url key
                    |> (\msg -> update updateArgs Nothing msg Model.empty)
        , update = update updateArgs Nothing
        , subscriptions = always Sub.none
        , view = Render.application args.apply args.view
        , onUrlRequest = args.onUrlRequest
        , onUrlChange = args.onUrlChange
        }
