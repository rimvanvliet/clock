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
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( Model Time.utc ( Time.millisToPosix 0 )
   , Task.perform UpdateTimeZone Time.here
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
      update GetTime { model | zone = newZone }

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
    1000 *  (60 - (toFloat (Time.toSecond model.zone model.time))) - (toFloat (Time.toMillis model.zone model.time))



-- VIEW


baseColor : Array String
baseColor = Array.fromList ["white","yellow","red","blue"]

clockNames = Array.fromList ["twelve","one","two","three","four","five","six","seven","eight","nine","ten","eleven",
              "twelve","thir-\nteen","four-\nteen","a quarter","six-\nteen","seven-\nteen","eight-\nteen","nine-\nteen",
              "twenty", "twenty-\none", "twenty-\ntwo", "twenty-\nthree", "twenty-\nfoour", "twenty-\nfive",
              "twenty-\nsix", "twenty-\nseven", "twenty-\neight", "twenty-\nnine", "half"]

getClockName : Int -> String
getClockName index = withDefault "unknown" (get index clockNames)

toRadixBase2 : Int -> List Int
toRadixBase2 num = RadixInt.toList (RadixInt.fromInt (Base 2) num )

view : Model -> Html Msg
view model =
    let
       hour = Time.toHour model.zone model.time
       minute = Time.toMinute model.zone model.time

       hourRadix2 =  List.append ( toRadixBase2 hour ) ( List.repeat 5 0  )
       minuteRadix2 =  List.append ( toRadixBase2 minute ) ( List.repeat 5 0  )

       clockColorIndex = List.map2 (\h m -> 2 * h + m ) hourRadix2 minuteRadix2
       clockColor = Array.fromList (List.map (\num -> withDefault "white" ( get num baseColor ) ) clockColorIndex)
       setBackgroundColor index = style "background-color" ( withDefault "white" ( get index clockColor ) )

       minuteName = if (minute == 0) then ""
         else if (minute <= 30) then ( getClockName minute ++ "\npast\n" )
         else ( getClockName (60 - minute) ++ "\nto\n" )
       hourName = if (minute == 0) then getClockName (modBy 12 hour) ++ "\no'clock"
         else if (minute <= 30) then getClockName (modBy 12 hour)
         else getClockName ((modBy 12 hour) + 1)
       timeText = List.intersperse (br [] [])
               (List.map text
                   (String.lines ("it's\n" ++ minuteName ++ hourName ))
               )
    in
    div [ class "box" ] [
        div [ class "container left-half box brdr" ] [
            div [ class "upper-half box" ] [
                div [ class "left-half box" ] [
                    div [ setBackgroundColor 3, class "upper-half box brdr" ] [],
                    div [ class "lower-half box" ] [
                        div [ setBackgroundColor 2, class "left-half brdr" ] [],
                        div [ class "right-half box brdr" ] [
                            div [ class "upper-half box" ] [
                                div [ class "left-half brdrr" ] [],
                                div [ setBackgroundColor 0, class "right-half" ] []
                            ],
                            div [ setBackgroundColor 1, class "lower-half brdrt" ] []
                        ]
                    ]
                ],
                div [ setBackgroundColor 4, class "right-half brdr" ] []
            ],
            div [ setBackgroundColor 5, class "lower-half box brdr" ] []
        ],
        div [ class "right-half" ] [
            div [ class "info" ] [
                div [ class "tooltip" ] [
                    div [ class "tooltiptext" ] [
                        h2 [] [ text "The binary Mondrian clock" ],
                        p [] [ text "The clock is divided into an imaginary grid of 8 x 8, so with an area of 64." ],
                        p [] [ text "In that grid, the clock is divided into 7 squares with areas of 1, 2, 4, 8, 16 or 32." ],
                        p [] [ text "The dark gray box in the middle does not count." ],
                        p [] [ text "The hours are determined by the area of the red + blue boxes." ],
                        p [] [ text "The minutes are determined by the area of the yellow + blue boxes." ],
                        p [] [ text "Because the color clock is not easy to read, I have put the time in text next to it. The text clock is a 12 hour clock, the color clock is a 24 hour clock." ],
                        p [] [ text "The clock was made in 2021 by Ruud van Vliet." ]
                    ],
                    img [ src "info.png", alt"info" ] []
                ]
            ],
            p [ id "timeText" ] timeText
        ]
    ]
