module DigitalClock exposing (..)

import Browser
import Html exposing (..)
import Process
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
    hour   = String.fromInt (Time.toHour   model.zone model.time)
    minute = String.fromInt (Time.toMinute model.zone model.time) |> String.padLeft 2 '0'
    second = String.fromInt (Time.toSecond model.zone model.time) |> String.padLeft 2 '0'
    year = String.fromInt (Time.toYear model.zone model.time) |> String.padLeft 2 '0'
    monthName = toDutchMonth (Time.toMonth model.zone model.time) |> String.padLeft 2 '0'
    monthNumber = String.fromInt (toMonthNumber (Time.toMonth model.zone model.time)) |> String.padLeft 2 '0'
    day = String.fromInt (Time.toDay model.zone model.time) |> String.padLeft 2 '0'
  in
  div []
     [ h1 [] [ text (hour ++ ":" ++ minute ++ ":" ++ second) ]
     , h1 [] [ text (day ++ " " ++ monthName ++ " " ++ year) ]
     , h1 [] [ text (year ++ "-" ++ monthNumber ++ "-" ++ day) ]
     , p  [] [ text ("Length of the delayPeriod: " ++ (String.fromFloat (timeFraction model)))]
    ]

toDutchMonth : Month -> String
toDutchMonth month =
  case month of
    Jan -> "januari"
    Feb -> "februari"
    Mar -> "maart"
    Apr -> "april"
    May -> "mei"
    Jun -> "juni"
    Jul -> "juli"
    Aug -> "augustus"
    Sep -> "september"
    Oct -> "oktober"
    Nov -> "november"
    Dec -> "december"

toMonthNumber : Month -> Int
toMonthNumber month =
  case month of
    Jan -> 1
    Feb -> 2
    Mar -> 3
    Apr -> 4
    May -> 5
    Jun -> 6
    Jul -> 7
    Aug -> 8
    Sep -> 9
    Oct -> 10
    Nov -> 11
    Dec -> 12
