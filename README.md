# clock

The 'standard' [elm-clock](https://elm-lang.org/examples/clock) and [elm-time](https://elm-lang.org/examples/time) uses a subscription 
to `Time.every` to process every 1000 millis a message, to update the clock.

This results in an inaccurate time representation: 
- the `Tick` does not arrive at the start of the second, so the time flips up to 999 millis too late; 
- the time between 2 `Tick`s is slightly more than 1000 millis, over time resulting that seconds can even be skipped;
- it starts with a `0:0:0` time (in GMT time zone) i.s.o. the real time.

To prevent this from happening I decided to use `Process.sleep` in `(Digital)Clock` and calculate the remainder 
of the second to wake up the at exactly (haha) the start of the second. It requires a few more steps:
- `UpdateTime` to update the model
- `Delay` to calculate and set the delay period
- `GetTime` to get the new time

In the `DigitalClock` I publish the delay. It is mostly just under 1000 milli seconds.

The Binary Mondriaan  clock is divided into an imaginary grid of 8 x 8, so with an area of 64. In that grid, the clock is divided into 7 sections with areas of 1, 2, 4, 8, 16 or 32. The dark gray box in the middle doesn't count. Note that the areas are powers of 2, hence "binary" in the name. Any number between 0 and 63 can be written in 1 unique way as the sum of 0, 1, 2, 3, 4, 5 or 6 of these numbers. For the clock, the numbers 0 to 23 are used for the hours, and 0 to 59 for the minutes, as follows:

- The hours are determined by the area of the red + blue boxes.
- The minutes are determined by the area of the yellow + blue boxes.
- The white squares (and the dark gray box in the middle) are NOT included in the count.

To compile the Binary Mondriaan clock (`Main.elm`), run `elm-app build` followed by `serve build` (where `serve` can be replaced by any webserver.

To run the Binary Mondriaan clock, run `elm start`.

A javascript version of the clock can be found on https://github.com/rimvanvliet/mondriaan-klok and runs on http://vliet.io. As the color clock is not easy to read, I have put the time in (Dutch) text next to it. The text clock is a 12 hour clock, the color clock is a 24 hour clock.


