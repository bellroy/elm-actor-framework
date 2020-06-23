module Framework.Internal.Render exposing
    ( application
    , element
    , renderPid
    )

import Browser exposing (Document)
import Framework.Internal.Actor exposing (Process)
import Framework.Internal.Model as Model exposing (FrameworkModel)
import Framework.Internal.Pid exposing (Pid)
import Html exposing (Html)


element :
    (appModel -> Process appModel output frameworkMsg)
    -> FrameworkModel appAddresses appModel
    -> List output
element apply frameworkModel =
    Model.getViews frameworkModel
        |> List.filterMap (renderPid (.view << apply) frameworkModel)


application :
    (appModel -> Process appModel output frameworkMsg)
    -> (List output -> List (Html msg))
    -> FrameworkModel appAddresses appModel
    -> Document msg
application apply view frameworkModel =
    element apply frameworkModel
        |> view
        |> (\body ->
                { title = Model.getDocumentTitle frameworkModel
                , body = body
                }
           )


renderPid :
    (appModel -> Pid -> (Pid -> Maybe output) -> output)
    -> FrameworkModel appAddresses appModel
    -> Pid
    -> Maybe output
renderPid appliedActorView frameworkModel pid =
    Model.getInstance pid frameworkModel
        |> Maybe.map
            (\appModel ->
                appliedActorView appModel
                    pid
                    (renderPid appliedActorView frameworkModel)
            )
