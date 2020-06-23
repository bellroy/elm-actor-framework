module Framework.Internal.Update exposing (Args, update)

import Framework.Internal.Actor exposing (Process)
import Framework.Internal.Helper.List as List
import Framework.Internal.Message as Message exposing (FrameworkMessage(..), FrameworkOperation(..))
import Framework.Internal.Model as Model exposing (FrameworkModel)
import Framework.Internal.Pid as Pid exposing (Pid)


type alias Args appFlags appAddresses appActorNames appModel output appMsg =
    { factory :
        appActorNames
        -> ( Pid, appFlags )
        -> ( appModel, FrameworkMessage appFlags appAddresses appActorNames appModel appMsg )
    , apply :
        appModel
        -> Process appModel output (FrameworkMessage appFlags appAddresses appActorNames appModel appMsg)
    }


update :
    Args appFlags appAddresses appActorNames appModel output appMsg
    -> Maybe Pid
    -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
    -> FrameworkModel appAddresses appModel
    -> ( FrameworkModel appAddresses appModel, Cmd (FrameworkMessage appFlags appAddresses appActorNames appModel appMsg) )
update ({ factory, apply } as args) maybePid msg model =
    case msg of
        AppMsg _ ->
            ( model, Cmd.none )

        InContextOfPid pid contextMsg ->
            update args (Just pid) contextMsg model

        Operate (Batch []) ->
            ( model, Cmd.none )

        Operate (Batch (first :: rest)) ->
            update args maybePid first model
                |> andThen args maybePid (Operate (Batch rest))

        Operate (Command cmd) ->
            ( model, cmd )

        Operate (ForAddress address msgForPid) ->
            Model.getInhabitants address model
                |> List.map (\pid_ -> Operate <| ForPid pid_ msgForPid)
                |> (Operate << Batch)
                |> (\msg_ -> update args maybePid msg_ model)

        Operate (ForPid pid msgForPid) ->
            case Model.getInstance pid model of
                Just state ->
                    let
                        ( updatedModel, newMsgs ) =
                            Message.filterAppMsgs msgForPid
                                |> List.foldl
                                    (\appMsg ( model_, msgs_ ) ->
                                        let
                                            instanceUpdate =
                                                apply model_ |> .update
                                        in
                                        instanceUpdate appMsg pid
                                            |> Tuple.mapSecond (List.postpend msgs_)
                                    )
                                    ( state, [] )
                                |> Tuple.mapFirst (Model.updateInstance model pid)
                                |> Tuple.mapSecond Message.filterNoOp
                    in
                    if List.isEmpty newMsgs then
                        ( updatedModel, Cmd.none )

                    else
                        update args maybePid (Message.batch newMsgs) updatedModel

                Nothing ->
                    ( model, Cmd.none )

        Operate (Spawn flags actorName callback) ->
            let
                spawnedBy =
                    Maybe.withDefault Pid.system maybePid

                ( updatedModel, newMsg ) =
                    Model.spawnInstance factory spawnedBy actorName flags model

                newMsgs =
                    Message.filterNoOp [ newMsg, callback updatedModel.lastPid ]
            in
            if List.isEmpty newMsgs then
                ( updatedModel, Cmd.none )

            else
                update args maybePid (Message.batch newMsgs) updatedModel

        Operate (StopProcess pid) ->
            ( Model.removePid pid model, Cmd.none )

        Operate (AddToView pid) ->
            ( Model.addToView pid model, Cmd.none )

        Operate (RemoveFromView pid) ->
            ( Model.removeFromView pid model, Cmd.none )

        Operate (PopulateAddress address pid) ->
            ( Model.populateAddress address pid model, Cmd.none )

        Operate (RemoveFromAddress address pid) ->
            ( Model.removeFromAddress address pid model, Cmd.none )

        Operate (UpdateDocumentTitle title) ->
            ( Model.updateDocumentTitle title model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


andThen :
    Args appFlags appAddresses appActorNames appModel output appMsg
    -> Maybe Pid
    -> FrameworkMessage appFlags appAddresses appActorNames appModel appMsg
    -> ( FrameworkModel appAddresses appModel, Cmd (FrameworkMessage appFlags appAddresses appActorNames appModel appMsg) )
    -> ( FrameworkModel appAddresses appModel, Cmd (FrameworkMessage appFlags appAddresses appActorNames appModel appMsg) )
andThen args maybePid msg ( model, cmd ) =
    update args maybePid msg model
        |> Tuple.mapSecond (List.singleton >> (++) [ cmd ] >> Cmd.batch)
