module Framework.Internal.RenderTest exposing (suite)

import Expect
import Fixtures.App as Fixture
import Fixtures.Pid as Fixture
import Framework.Internal.Render as Render
import Html
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Render"
        [ test_element
        , test_application
        , test_renderPid
        ]


test_element : Test
test_element =
    test "element" <|
        \_ ->
            Render.element
                Fixture.args.apply
                Fixture.modelWithActors
                |> Expect.equal
                    [ "0"
                    , "Lorem ipsum dolor sit amet"
                    ]


test_application : Test
test_application =
    test "application" <|
        \_ ->
            Render.application
                Fixture.args.apply
                (List.map Html.text)
                Fixture.modelWithActors
                |> Expect.equal
                    { title = "ModelWithActors"
                    , body =
                        [ Html.text "0"
                        , Html.text "Lorem ipsum dolor sit amet"
                        ]
                    }


test_renderPid : Test
test_renderPid =
    describe "renderPid"
        [ test "renderPid Counter" <|
            \_ ->
                let
                    appliedActorView =
                        .view << Fixture.args.apply
                in
                Render.renderPid
                    appliedActorView
                    Fixture.modelWithActors
                    Fixture.pid_1_2
                    |> Expect.equal (Just "0")
        , test "renderPid LoremIspum" <|
            \_ ->
                let
                    appliedActorView =
                        .view << Fixture.args.apply
                in
                Render.renderPid
                    appliedActorView
                    Fixture.modelWithActors
                    Fixture.pid_1_3
                    |> Expect.equal (Just "Lorem ipsum dolor sit amet")
        ]
