module Framework.Internal.Subscriptions exposing (getSubscriptions)

import Framework.Internal.Actor exposing (Process)
import Framework.Internal.Message exposing (FrameworkMessage)
import Framework.Internal.Model as Model exposing (FrameworkModel)


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
