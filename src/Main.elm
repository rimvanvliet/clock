module Main exposing (..)

import Array exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Maybe exposing (withDefault)
import Process
import RadixInt exposing (..)
import Task
import Time exposing (..)



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
  , fraction : Float
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( Model Time.utc ( Time.millisToPosix 0 ) 0
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
      ( { model | zone = newZone }, Cmd.none )

    UpdateTime newTime ->
      update Delay ( { model | time = newTime } )

    Delay ->
      ( { model | fraction = (timeFraction model ) }, delay (timeFraction model) )

    GetTime ->
      ( model, Task.perform UpdateTime Time.now )

delay : Float -> Cmd Msg
delay delayPeriod
  = Process.sleep delayPeriod
  |> Task.perform (\_ -> GetTime)

timeFraction : Model -> Float
timeFraction model =
    1000 *  (60 - (toFloat (Time.toSecond model.zone model.time))) - (toFloat (Time.toMillis model.zone model.time))



-- VIEW


baseColor : Array String
baseColor = Array.fromList ["white","yellow","red","blue"]

toRadixBase2 : Int -> List Int
toRadixBase2 num = RadixInt.toList (RadixInt.fromInt (Base 2) num )

setBackgroundColor : Int -> Array String -> Attribute msg
setBackgroundColor index array = style "background-color" ( withDefault "white" ( get index array ) )

view : Model -> Html Msg
view model =
    let
       hourRadix2 =  List.append ( toRadixBase2 ( Time.toHour model.zone model.time ) ) ( List.repeat 6 0  )
       minuteRadix2 =  List.append ( toRadixBase2 ( Time.toMinute model.zone model.time ) ) ( List.repeat 6 0  )
       clockColorIndex = List.map2 (\h m -> 2 * h + m ) hourRadix2 minuteRadix2
       clockColor = Array.fromList (List.map (\num -> withDefault "white" ( get num baseColor ) ) clockColorIndex)
    in
    div [ class "box" ] [
        div [ class "container left-half box brdr" ] [
            div [ class "upper-half box" ] [
                div [ class "left-half box" ] [
                    div [ setBackgroundColor 3 clockColor, class "upper-half box brdr" ] [],
                    div [ class "lower-half box" ] [
                        div [ setBackgroundColor 2 clockColor, class "left-half brdr" ] [],
                        div [ class "right-half box brdr" ] [
                            div [ class "upper-half box" ] [
                                div [ class "left-half brdrr" ] [],
                                div [ setBackgroundColor 0 clockColor, class "right-half" ] []
                            ],
                            div [ setBackgroundColor 1 clockColor, class "lower-half brdrt" ] []
                        ]
                    ]
                ],
                div [ setBackgroundColor 4 clockColor, class "right-half brdr" ] []
            ],
            div [ setBackgroundColor 5 clockColor, class "lower-half box brdr" ] []
        ]
    ]
