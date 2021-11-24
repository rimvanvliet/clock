module Clock exposing (Model, Msg(..), init, main, update, view, viewHand)

import Browser
import Html exposing (Html)
import Process
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Task
import Time
import List exposing (..)



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
    , subscriptions = always Sub.none
        }



-- MODEL


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    }


init : () -> (Model, Cmd Msg)
init _ =
  ( Model Time.utc ( Time.millisToPosix 0 )
  , Cmd.batch
            [ Task.perform UpdateTimeZone Time.here
            , Task.perform UpdateTime Time.now
            ]
  )


-- UPDATE

type Msg
  = UpdateTimeZone Time.Zone
  | UpdateTime Time.Posix
  | Delay
  | GetTime

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UpdateTimeZone newZone ->
      update GetTime( { model | zone = newZone } )

    GetTime ->
      ( model, Task.perform UpdateTime Time.now )

    UpdateTime newTime ->
      update Delay ( { model | time = newTime } )

    Delay ->
      ( model, delay (timeFraction model) )

delay : Float -> Cmd Msg
delay delayPeriod
  = Process.sleep delayPeriod
  |> Task.perform (\_ -> GetTime)

timeFraction : Model -> Float
timeFraction model =
    1000 - toFloat (Time.toMillis model.zone model.time)


-- VIEW

view : Model -> Html Msg
view model =
    let
        hour = toFloat (Time.toHour model.zone model.time)
        minute = toFloat (Time.toMinute model.zone model.time)
        second = toFloat (Time.toSecond model.zone model.time)
    in
    svg
        [ viewBox "0 0 400 400"
        , width "400"
        , height "400"
        ]
        ( circle [ cx "200", cy "200", r "120", fill "#1293D8" ] []
        :: strokes ++
        [ circle [ cx "200", cy "200", r "100", fill "#1293D8" ] []
        , viewHand 8 60 ((hour / 12)  + (minute / 720)) "white"
        , viewHand 6 90 ((minute / 60) + (second / 3600)) "darkgrey"
        , viewHand 1 98 (second / 60) "black"
        ])

strokes : List (Svg msg)
strokes = List.map ( \num -> viewHand 1 110 ( num/12 ) "white" ) [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]

viewHand : Int -> Float -> Float -> String -> Svg msg
viewHand width length turns color =
    let
        t = 2 * pi * (turns - 0.25)
        x = 200 + length * cos t
        y = 200 + length * sin t
    in
    line
        [ x1 "200"
        , y1 "200"
        , x2 (String.fromFloat x)
        , y2 (String.fromFloat y)
        , stroke color
        , strokeWidth (String.fromInt width)
        , strokeLinecap "round"
        ]
        []
