module Framework.Actor exposing
    ( Component
    , Actor, fromComponent
    , ProcessMethods, Process
    , Pid, spawnedBy
    , altInit, altUpdate, altSubscriptions, altView
    , pidSystem, pidCompare, pidEquals, pidToInt, pidToString
    )

{-|

---

**Component**

  - [Component](#Component)

**Actor**

  - [Actor](#Actor)
  - [fromComponent](#fromComponent)
  - [ProcessMethods](#ProcessMethods)

**Process**

  - [Process](#Process)
  - [Pid](#Pid)
  - [spawnedBy](#spawnedBy)

**Component Utility**

  - [altInit](#altInit)
  - [altUpdate](#altUpdate)
  - [altSubscriptions](#altSubscriptions)
  - [altView](#altView)

**Process Utility**

  - [pidSystem](#pidSystem)
  - [pidCompare](#pidCompare)
  - [pidEquals](#pidEquals)
  - [pidToInt](#pidToInt)
  - [pidToString](#pidToString)

---


# Component

@docs Component


# Actor

@docs Actor, fromComponent


# Process

@docs ProcessMethods, Process

An Actor that has been spawned inside the framework always receives an unique identifier ([PID](https://en.wikipedia.org/wiki/Process_identifier)).

The PID also holds information about who spawned (started) the process.


# Process Identifier

@docs Pid, spawnedBy


# Component Utility

@docs altInit, altUpdate, altSubscriptions, altView


# Process Utility

@docs pidSystem, pidCompare, pidEquals, pidToInt, pidToString

-}

import Framework.Internal.Actor as Internal
import Framework.Internal.Message exposing (FrameworkMessage)
import Framework.Internal.Pid as Internal exposing (Pid)


{-| -}
type alias Component appFlags componentModel componentMsgIn componentMsgOut output frameworkMsg =
    { init :
        ( Pid, appFlags )
        -> ( componentModel, List componentMsgOut, Cmd componentMsgIn )
    , update :
        componentMsgIn
        -> componentModel
        -> ( componentModel, List componentMsgOut, Cmd componentMsgIn )
    , subscriptions :
        componentModel
        -> Sub componentMsgIn
    , view :
        (componentMsgIn -> frameworkMsg)
        -> componentModel
        -> (Pid -> Maybe output)
        -> output
    }


{-| Transform your components init function
-}
altInit :
    ((( Pid, a ) -> ( componentModel, List componentMsgOut, Cmd componentMsgIn ))
     -> ( Pid, appFlags )
     -> ( componentModel, List componentMsgOut, Cmd componentMsgIn )
    )
    -> Component a componentModel componentMsgIn componentMsgOut output frameworkMsg
    -> Component appFlags componentModel componentMsgIn componentMsgOut output frameworkMsg
altInit =
    Internal.altInit


{-| Transform your components update function
-}
altUpdate :
    ((componentMsgIn -> componentModel -> ( componentModel, List componentMsgOut, Cmd componentMsgIn ))
     -> componentMsgIn
     -> componentModel
     -> ( componentModel, List componentMsgOut, Cmd componentMsgIn )
    )
    -> Component appFlags componentModel componentMsgIn componentMsgOut output frameworkMsg
    -> Component appFlags componentModel componentMsgIn componentMsgOut output frameworkMsg
altUpdate =
    Internal.altUpdate


{-| Transform your components subscriptions function
-}
altSubscriptions :
    ((componentModel -> Sub componentMsgIn)
     -> componentModel
     -> Sub componentMsgIn
    )
    -> Component appFlags componentModel componentMsgIn componentMsgOut output frameworkMsg
    -> Component appFlags componentModel componentMsgIn componentMsgOut output frameworkMsg
altSubscriptions =
    Internal.altSubscriptions


{-| Transform your components view function
-}
altView :
    (((componentMsgIn -> frameworkMsg) -> componentModel -> (Pid -> Maybe outputA) -> outputA)
     -> ((componentMsgIn -> frameworkMsg) -> componentModel -> (Pid -> Maybe outputB) -> outputB)
    )
    -> Component appFlags componentModel componentMsgIn componentMsgOut outputA frameworkMsg
    -> Component appFlags componentModel componentMsgIn componentMsgOut outputB frameworkMsg
altView =
    Internal.altView


{-| -}
type alias Actor appFlags componentModel appModel output frameworkMsg =
    { processMethods : ProcessMethods componentModel appModel output frameworkMsg
    , init : ( Pid, appFlags ) -> ( appModel, frameworkMsg )
    , apply : componentModel -> Process appModel output frameworkMsg
    }


{-| -}
type alias ProcessMethods componentModel appModel output frameworkMsg =
    Internal.ProcessMethods componentModel appModel output frameworkMsg


{-| -}
type alias Process appModel output frameworkMsg =
    Internal.Process appModel output frameworkMsg


{-| Progress a `Component` into an `Actor` by supplying it functions of how to
handle application types.
-}
fromComponent :
    { toAppModel : componentModel -> appModel
    , toAppMsg : componentMsgIn -> appMsg
    , fromAppMsg : appMsg -> Maybe componentMsgIn
    , onMsgOut :
        { self : Pid
        , msgOut : componentMsgOut
        }
        -> FrameworkMessage appFlags appAddresses appActors appModel appMsg
    }
    -> Component appFlags componentModel componentMsgIn componentMsgOut output (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
    -> Actor appFlags componentModel appModel output (FrameworkMessage appFlags appAddresses appActors appModel appMsg)
fromComponent =
    Internal.fromComponent


{-| The type of a Pid
-}
type alias Pid =
    Internal.Pid


{-| The System's Pid
-}
pidSystem : Pid
pidSystem =
    Internal.system


{-| Retrieve the Pid responsible for spawning the given Pid
-}
spawnedBy : Pid -> Pid
spawnedBy =
    Internal.toSpawnedBy


{-| Compare two Pid's
-}
pidCompare : Pid -> Pid -> Order
pidCompare =
    Internal.compare


{-| Check if two Pid's are in fact the same
-}
pidEquals : Pid -> Pid -> Bool
pidEquals =
    Internal.equals


{-| Returns an Integer representation of a Pid.
-}
pidToInt : Pid -> Int
pidToInt =
    Internal.toInt


{-| Returns a String representation of a Pid.
-}
pidToString : Pid -> String
pidToString =
    Internal.toString
