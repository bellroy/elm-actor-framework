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
        updateArgs =
            { factory = factory
            , apply = apply
            }
    in
    Browser.element
        { init = init >> (\msg -> update updateArgs Nothing msg Model.empty)
        , update = update updateArgs Nothing
        , subscriptions = getSubscriptions apply
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
        , subscriptions = getSubscriptions args.apply
        , view = Render.application args.apply args.view
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
        , subscriptions = getSubscriptions args.apply
        , view = Render.application args.apply args.view
        , onUrlRequest = args.onUrlRequest
        , onUrlChange = args.onUrlChange
        }


getSubscriptions :
    (appModel
     -> Process appModel output (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
    )
    -> FrameworkModel appAddresses appModel
    -> Sub (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
getSubscriptions apply =
    Model.foldlInstances
        (\pid appModel listOfSubs ->
            let
                process =
                    apply appModel

                processSubscriptions =
                    process.subscriptions pid
            in
            if processSubscriptions == Sub.none then
                listOfSubs

            else
                processSubscriptions :: listOfSubs
        )
        []
        >> Sub.batch
