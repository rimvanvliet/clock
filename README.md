# clock

The standard [elm-clock](https://elm-lang.org/examples/time) uses a subscription 
to `Time.every` to process every 1000 millis a message, to update the clock.

This results in an inaccurate time representation: 
- the `Tick` does not arrive at the start of the second, so the time flips up to 999 millis too late; 
- the time between 2 `Tick`s is slightly more than 1000 millis, over time resulting that seconds can even be skipped;
- it starts with a `1:0:0` time (in CET time zone) i.s.o. the real time.

To prevent this from happening I decided to use `Process.sleep` and calculate the remainder 
of the second to wake up the at exactly (haha) the start of the second. It requires a few more steps:
- `GetTime` to get the new time
- `UpdateTime` to update the model
- `Delay` to calculate and set the delay period

In the `DigitalClock` I publish the delay. It is mostly just under 1000 milli seconds.

And, in the end, I got it working. In hindsight, the solution is quite simple ...
