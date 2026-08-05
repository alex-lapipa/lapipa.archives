---
document_id: "LP-MEDIA-YOUTUBE-VIDEO-NKKZY3ZHSOU-DOC"
source_id: "LP-MEDIA-YOUTUBE-VIDEO-NKKZY3ZHSOU"
title: "S2_06_DEADPROGRAM@LA PIPA"
language: "en"
document_type: "youtube_video"
origin_uri: "https://www.youtube.com/watch?v=nkkzy3zhsOU"
verification_status: "provider_metadata_captured"
access_scope: "public"
content_sha256: "405a7432cb7ff4104fd90a2fe21b43e319f15bc8a19eb37c999c4c757999fa7b"
---

# S2_06_DEADPROGRAM@LA PIPA

Archive source LP-MEDIA-YOUTUBE-VIDEO-NKKZY3ZHSOU. S2_06_DEADPROGRAM@LA PIPA.

YOUTUBE video accession record.

Canonical provider URL: https://www.youtube.com/watch?v=nkkzy3zhsOU

Provider identifier: nkkzy3zhsOU

Creator/channel: LA PIPA IS LA PIPA

Provider metadata captured successfully.

Transcript (en-orig; automatic_captions):

Kind: captions
Language: en
[Music]
is
[Music]
oh
[Music]
hello humans of the internet it is i did
program along with gopherbot here in our
season finale episode
at la pipa live in mysterious espana
i've now been fully vaccinated as has
gopherbot so we're actually go for about
you could take off your mask too if you
really want like yeah let's do that okay
gopherbot takes the mask off this is
this is incredible this is the first
time gopherbots had
the mask off in months
wow i mean it's not over yet but at
least we're not too bad off here
so my dear friends we have some really
cool stuff for you today um
basically last time it was a cliffhanger
as we completely failed to get the
revamp of our
new tiny drone flight controller working
uh so
with that you know terrible
crisis
of confidence on our hands we go back at
it again today but first
a bit of news from the world so um if
you've been following along with the
brilliance of the mars helicopter so
there's the next one is going to be even
more brilliant and of course it's all
going to be completely open source
so this was um
going to be open source all the way
along the line right but they're
basically
planning right now to build it all from
open source hardware and software from
scratch so that's pretty exciting uh
we'll give you more updates on that as
they occur
here on earth this last week um not
necessarily my favorite of companies for
various reasons but facebook always can
be counted upon to do some really
interesting things engineering-wise so
this week
they have an open source time appliance
so this is actually open source hardware
and software that's designed to
communicate with the same type of
latency calculations that the gps
satellites use
and utilizing those drift calculations
come up with a time server
which is or a time appliance rather that
instead of using the
ntp time protocol with its maybe you
know
millisecond accuracy instead we're
talking about as they're claiming uh
nanosecond accuracy where is the stat on
that um let's see here
i tell you right up in the beginning
ah from 10 milliseconds to 100
microseconds okay not nanosecond sorry
microseconds
well that's a pretty incredible
difference as far as our ability to
synchronize different devices across
geographic time zones other sides of the
planet
so very cool stuff going on there
awesome work
um
so
in the world of tiny go
there's been a couple of really awesome
projects that have been worked on by
amazing members of the community
um aurelie vash
has done a whole series of posts about
learning go by example
and this week their post is
creating a game boy advance game so this
is actually a really awesome post that
goes really deep as far as how to use of
course tiny go since that's the only
goal you can run on the game boy advance
naturally
and it goes through the entire
set of steps that you need to do in
order to actually create something that
runs on if i scroll down
the real live actual hardware where's
this video ah yes
so um i'm going to bring in my game boy
advanced next season and some special
hardware that i have and we'll actually
do a little bit of hacking with this
ourselves because it's just it's too
cool i need to play with it right
so
also
different member of our amazing
community um who i've talked about
before
uh keeg
so keegan has been writing a whole
series of posts about using tiny go with
web assembly and they have done all of
their programming on the tablet because
in theory they're on paid time off
so yeah paid time off and they're
hacking on this awesome project that's
just so cool talk about labor of love
really um so they they just released
part eight of this whole series about
um
getting tiny go to run in web assembly
and create a whole browser-based
application using nothing but tinygo
and i guess go for the server but anyway
amazing stuff i want to play with that a
bit more to go through all the steps of
their tutorial but
extremely cool stuff
really excited to play with that
all right
so
in speaking of tiny go
so we've had a lot of activity
as far as cool new capabilities which
have gotten merged in over the last week
and one of the ones that i find
especially interesting
is
the ability to use tiny go test
so tiny go test is as you might guess
similar to go test except it uses tiny
go to execute the tests and so
this is a pull request created by ike
the creator of the tiny go project
and this adds the
dash v flag for verbose that way when
you run tiny go test you can get all of
the outputs individually from the test
whether they pass or fail so that's
really cool
and
this actually also can be run on bare
metal so i'm going to try to take
advantage of this to modify the tiny hci
which if you have not seen that tiny
hdis are hardware integration
server hardware continuous integration
that's what we use when we're developing
tiny go as we are actually
running our tests against real hardware
located at my secret headquarters and so
that's how we test tinygo against real
hardware every time that we are making
changes to it so uh yeah we take testing
seriously and now we can test the tests
that's so awesome
all right
so um there's another pull request
that's been sitting out there for a
little while and i thought maybe we
would try to take a quick look at it
so soy pat who has been
really really amazingly prolific
contributor adding capabilities for the
raspberry pi
rp 2040 microcontroller
so this is a really cool microcontroller
from raspberry pi we can take it let me
turn on the light here so we can
actually see it
yeah wait no light uh oh
oh oh it's kind of dim
i think the battery is dead well we can
still see it
these
and one of them is it's got pulse width
modulation implementation in the
microcontroller if you ever did any
raspberry pi programming
you probably discovered that like most
uh single board linux computers it does
not have pulse width modulation built in
you can simulate it by using things like
pi blaster which is a very very cool um
piece of software i've made a few
contributions to myself
but
but yeah you need pi blaster in order to
do that on the raspberry pi linux
computer but we don't have a problem to
doing this on a actual microcontroller
so let's go take a look at this pull
request
because
i know that there was a few
differences between this and the other
uh pulse width modulation implementation
so let's just take a look here and see
so um we have the
um normal pwm definition which is the
ports that are actually on the raspberry
pi itself
and then
this is creating defining which
peripheral matches to which pin
and if i look at the pull request i
think they say they tested it on
the built-in led
let's take a look and see
how did they actually test this
i know that they did
oh yeah tested with the onboard led so
that's really cool that means we don't
have to plug in anything to try this out
all right let's go back to the code so
we can take a look and see if it
so this is
the changes to the machine package
which
for the raspberry pi 2040 pulse width
modulation implementation
and these are the different registers
apparently that you need for that
we saw a bit of that when we've been
hacking on the raspberry pi before
so let's see here set period now we're
into the interface that's defined
that's needed for the
uh supporting the pulse width modulation
interface that's the same as all the
other devices
get set hmm
okay
let's see keep going quite a bit to it
and there's a lot of registers that you
have to set on most platforms
on this platform it's um
got plenty in there let's see oh yeah
cluck divider
that we need obviously in order to
support
different
speeds
we have to set the clock within the
range of what the pulse width modulation
block on the microcontroller can support
well okay that that's it
not too much
so let's go and actually try to pull
this in
um
because of a squash
or a merge commit we're going to have to
do a merge and squash but let's first
try to pull in this group of changes
from this branch
so i'm going to
again
being very lazy
i'm gonna just copy and paste
from the
um
instructions on the github web page for
how to do a command line merge
so first we're going to check out
let's go over to the correct place here
we go
so first we're going to get checkout
dash b
for creating a branch
the
soy patch pico pwm
is going to be the name of the branch
and it's going to be based on the
current dev branch
so we switch to that branch we're good
so now we need to pull it down
the only difference between this and the
syntax that's just provided here by
github
is
that we're going to want to
add a rebase
so we want to get poll
dash dash rebase
and then we're going to pull that down
from the soy pat
fork of tiny go
from the patch pico pwm branch
and okay we got it
all right so
we should i believe
if we go and we um
let's take a look here at the
code for the
tiny go
whoops no i do not want to get the new
go language server
or
the new vs code update i'm good on both
of those thanks all right let's see pwm
here we go
so the pwm example
has
is set up for a few different
boards and none of them are in fact
the raspberry pi rp 2040
so we're going to have to go and
basically tell
the
example
which is the correct pins to use
in order to implement
you know the same interface or whatever
right so let's go and make a new so
that's one thing that is probably needed
at least to make it easy to run that
example right we don't have to have that
but it definitely would make it easier
so i'm just going to
copy
and then i'm going to create a new file
and we'll call it um
let's see rp 2040
go
and
here we want to have a build tag for the
rp2040
and
let's figure out which are the actual
pins
that are supported for this
which um didn't actually make it into
this pull request it would appear
so let's see
let's go take a look at the
files that were changed
these are the actual peripherals that
are available
uh pw m0 through seven
and
i think we're looking for configure
oh yes here we go
so we want to use
um
hmm
how does this integrate let's see
um
well let's take a look at the configure
method
um
down here oh there we go all right
so
to configure we have to take oh we use a
particular group
so
that would mean that
for our pwm
here
for the rp2040 i guess we would say
machine for example
pwm pwm0
i think that's what we do
and then which pins let's see
how does this work each profile has two
pins
some pins may not be available on some
boards well yes of course
but we want to try to find the built-in
so if i look for the rp
2040 pin out
that i was looking at the other day
and let's see if we can
consent to everything yes i don't care
right now
there we go
so the built-in oh
hmm
let's see does this tell us anything
about the built-in
not really
which one is the built-in led we can
tell that if we just look at the
board file
for the pico
and if we look at board pico we could
see that the built-in led
is
we could just say dot led or gpio 25
okay
so i guess pin a would be
we could just say led
maybe
what does pin be used for
is this example
pulse on two different pins how does
this work
let's see it sets the
oh it has two channels so it's gonna do
it on
i guess we could just set a different
pin
it really doesn't matter which one as
long as it's not one that we're already
using for something else
so let's look for
you know some other
random pin like
you know for example the
pin for the analog to digital converter
0 or 1
gp27 let's just say
so if we go back here
we say b will be gp27
i believe that should work
okay
so
i think we should be able to try
building this if we just say tiny go
flash
and we say target
equals pico
and then we want to set use the
um
examples pwm
ah no okay
so we can't just use the pwm group
as a substitute for
um
the timer
the way that the other
code worked
so it's not exactly
plug and play
so let's
look a little bit more closely to see
what the example is doing
so it is calling pwm channel
it's got a configure
i think our problem here
is perhaps
that
instead of
passing the
address we just want to pass the pwm 0
directly okay
i think that is what we needed to do
yeah we were trying to pass a pointer to
a pointer
and naturally that wasn't going to work
all right
so the code compiled
now we can i guess find out if it
actually works
so we're off to a good start off to a
good start here
we're just going to plug into
an available port
and let's
it looks like it worked
so let's go ahead and try to flash this
code
something happened
it's hard to tell if it's working
let's take again another look at the
code
and see if we can
speculate on which
pins may work with which pwm
let's see here
rpe 2040
built
in led pwm
so
let's see if we can take a guess
arduino is usually pretty well
documenting of things but this is not
quite what i'm looking for
um
ah the data sheets yes of course
so let's look for the pwm page here
which is going to be deeply buried on
here we go pwm
so this tells us
all pins can be used but not for all
channels so if we want to use the pin
which is the pen for the built-in led
again
it is the
gotta go to the board file
for the picot
and open that
and it's gpio25
so gpio25
is
pwm
channel what is that 4b
okay so what does that mean
4b
um
let's see
i guess that's pwm
ah here we go
that's it it's pwm4
and then it's the b channel okay
so that means this should be four
then
i guess we could put anything here
and this one the b channel
the led
okay
so let's find out
if in fact
that works a little better
so one more
to our
bootloader mode
now we'll flash it again
and let's see what happened
i don't see anything different
so far
hmm
no
thing
this pull request is not quite ready yet
let's but let's not quite give up
let's give it
just one more attempt
so again the built-in led is gpio25
and so if we're looking at 25 that would
be
4b
channel 4
b
right
so
going back to the
example for the pwm
which i lost in here but it's in here
somewhere
uh here we go
so it's going to configure it and then
it's going to set the two channels for
the outputs and try to run them through
the different duty cycles
okay
and
i thought i had it set correctly
let's see
pin a
is whatever gp27
and the pin b would be the built-in led
which would be 25.
yeah really none of those um
i don't think
let's see
let's go back and take a look at the
pull request again one more time
just to see if maybe
just maybe
we can decipher this
so it's got the seven
it's got the group
each peripheral has two pins
we are configuring it
and we're setting
maybe the channels reversed
that's always a possibility right so
let's try
the original
led here and gp27
for pin b
just to see if you know maybe
so we'll go back one last time
and
[Music]
i see
nothing
yeah
nothing at all
just
no
nada unfortunately
you can
get a little more insight
but it was close i will make one comment
which was uh
just to say so far not able
oh wait hold on hold on
here's an example
um
hmm
this is a little different
than the
uh
the other example
the one that we're using for all the
other code
so that's kind of
i'm not too sure
hm
well
i'm just going to mention
not able
yet
was not able
to get working with the
pwm
example
in the main
tiny go
examples
or it was not able sorry
i was not able to get working with the
pbo and the main tiny go examples
some mappings
are perhaps
some apple mappings are mip are missing
and i might not
have them
correct
for the pico board
just that way if soy pat does get the
chance to look at this
they could tell
you know where we ended up
okay
so
let's switch gears now
back over to the
fun that we were trying to work on last
time
just because i haven't given up yet
and we've got i think enough time to do
this
once again my main man loveenzo is here
and we're gonna make a serious attempt
to build a custom controller
hello what's happening man how are you
doing
i don't know i'm confused no no
i i we're both fully vaccinated so we're
in the same social group now
all right so it's too late
um
or maybe i should put on my mask
one of us should the other one who knows
oh yeah it's okay all right
so last time we were making a real
attempt to build this
let me show for anybody who wasn't
around if they hadn't seen it
so i have a
special controller
that i had built for
flying drones the other bluetooth drones
that was really dumb
on my part i should not have brought
that board
um
oh we lost the audio
uh hmm
it looks like it's going out
okay we're good false alarm
um
they tried to cut my microphone but oh
wait maybe i mean i i'm too loud
that's what the problem is i'm a little
too loud no no
okay
we're good all right
so
anyway let's move gopherbot out of the
way because
actually wow gopherbot makes a really
good light to solder by
fantastic
i'm gonna put that back in
yeah that actually that's that's one of
the better lights that we have
let's go back to that you know
okay go for about you got a job now
all right so um
wait what happened here i don't see
anything on the uh
hmm
see that's good hello yes and let's go
back here
you know
uh we lost the camera on the table maybe
trying um plug
it was a view not long ago
okay
um okay
that's good
yeah of course we lost the table
so while we wait
is it this one
because i'm afraid our
oh not quite almost there
almost there
stay on target
stay on target oh yeah i mean
we should have known that it wasn't
working before because look at that
amazing light
okay
so um
maybe that's too much of a good thing
well we still have a little scanline
probably i bet you're right
probably i would guess we're better off
without this
yeah okay
and then we'll get the gopher bots butt
light
okay there we go
uh-oh something happened
how many engineers does it take to
change a light bulb
i'm sorry we don't give estimates
[Laughter]
see
that's okay we're we're we're good now
it appears we're good all right
so i get like i guess the first thing
we're gonna have to do
is um
this was the new board you brought
that way we can make another attempt
to uh
to salvage our our honor
um
oh yeah that's a way to do it but you're
going to need your hands in the moment
okay so that's not going to work too
well
and how long can the phone last
i guess we'll find out
right but we have to see yeah see
i know they could the internet can see
this i know but the internet doesn't
have to connect these wires to each
other see
exactly they just have to make few
comments like you know hey do you guys
know how to solder and we're like yeah
we swear we do
we're i'm i'm i'm
i'm a radio shack certified soldering
artist
yes i made that up
okay
oh
so we're going to need a couple of other
items we need a little sponge
and
see where i have that
because we need to do some de-soldering
here
real quick
oh yeah last time we made up our own
little
last time we used the
heatsink from
a
real soldering iron whatever that means
and then we used that just so we had a
thing to stick it into
so that we didn't accidentally burn
anything like ourselves
all right so we're off to a good start
here
can we do it yes we can
yes we can
i'm still optimistic
perhaps
fatally so but i'm still optimistic all
right
so the first thing we're gonna have to
do i guess is remove
the uh
actually if you do it right here that's
pretty good
like you can actually see reasonably
well
at least i think you can
so i guess the first thing we need to do
is is remove
the one pin that we soldered
so that we can get the microcontroller
back out you know yeah we remove
everything and start from scratch i
think it's the idea we move i mean
there's only one pin that we soldered
i believe
the other ones are wrapped
yeah and the one we soldered was the
ground
that's this one here so if we desolder
that
i guess we can
i mean look at that tip
really sharp right
can you see how deadly that tip is
i know i'm frightened myself all right
let's plug it in
and
i guess it's gonna boot up
it says it's plugged in
so then we start heating up
it's upside down so
sorry about that
i don't want to turn it the other way
because then i'll probably burn the cell
phone but it's heating up quite quickly
to our our maximum temperature
another maximum but our setting
and the one pin that we have to desolder
is this one
so hopefully
hopefully this is going to work
it's heating up pretty quick
it's already at
320 degrees celsius
so that's kind of exciting i would put
it down okay
because i don't want to be responsible
you can just put you can just leave it i
don't want to be responsible for burning
you
any more than i have to
need to go i wanted to help you to slide
it out while you are dissolving if i can
get enough of the software to remove
those connections oh yeah that's a good
idea so that eight wheel comes out
quite smoothly yeah very good idea and
one two three and now if you dissolve
there this one i i trust you okay i got
burned many times i'll be gentle i will
survive okay here we go
so while you are yeah almost we almost
got it here it's just a little piece
left
it's probably on the other side of the
board now
yeah that's the problem heat up a little
more
okay
okay we got it
all right we did it great
we have extracted the part
isn't this kind of like a really stupid
commercial that tim cook did
for apple where was the m1 chip
i haven't
seen that one okay i swear i didn't
either
i only heard about it on the internet i
swear all right
so if we go back to the original design
was solid
i think if we do the same thing
but this time the right way
there is no way on this so it's
completely
each
hole it's independent and not join there
is
no soldering
and this is what we were trying to do
before
is to put it in
with the usb connector up i think right
yes exactly there's still a little bit
of solder on these pins so it won't
quite slip in
okay if we can
just
we can just pick it up off there
i think i got enough
because we just need to get an output
so it slips into the holes right
it's so close
why isn't it going in
because there's just a little bit of
solder on that one
you can kind of see it actually you can
probably see it through this camera a
little bit
pretty annoying
now another way to do this
is the reverse of what we were just
doing a minute ago which is basically
just
heat up the pin
and it maybe will slide in
we just heat the solder up on there
just a little bit more
oh yeah but if we if we clean the tip
now you see you clean the tip every time
you saw there yes and the joint you're
really like very disciplined about that
i'm really lazy i'm just like okay slap
it in there you know
which it didn't work this time
okay perfect so yeah cleaning the tip
excellent idea
i'm glad i thought of it
okay so so we got this is where we want
to put this
and then we said we were going to have
a couple of different
adapters
one on each side we were going to use
for the two joysticks
which i guess in this case would be
we have
let's see i have some more i have a few
of these
a few extras i even have one that was
bent already but
we're better off using fresh ones if we
can just because they
probably come out better
and we only need we need four
for the top
that we're going to use for the display
right
and i think i have
one that's a length of four that i
already
if you can cut it
well i did anyway
maybe it
took off on its own
just because it's the perfect size
already we don't have to cut anything
you know
that's always good
oh here's the display
this we're going to need in a minute
that's just interference from the phone
yeah i was wondering if i can switch off
the monitor
um okay it's not there
maybe it's in this box
this is where my other parts were
i had one that we cut
that was the perfect size
well we'll cut another one
that's okay
we have plenty
we don't have plenty but we have enough
like we have just enough barely enough
we have almost enough um
actually we have quite a few
we have more than i thought
oh and this was the one wasn't this the
one we made to be uh
double length
we were going to use that for something
all right so
going back to the display
so we need
on both sides we're going to need
five pins
for the
joysticks
and each one of these has eight
so if we trim them the right length
hopefully
if i don't destroy them
and we'll get this one
okay
i'm not quite
i hate when i cut them off and then
you're like oh too short
too bad it's gone
oh you brought like some better colors
no i don't know if it's better but
this is a pretty good length so we need
another one of those of length five
so let's cut that off
same way
all right five pins
that leaves three
and if we can
chop it off at just the right length
let's get a little extra but that's okay
better than that then
too much cut off i mean we don't have an
endless number of those right
okay
so
i guess we could put these in no right
and what did we say what we were going
to do we said we were going to put them
in
like uh
where did we put them in we put them in
a little bit further down so it'd be
easier to reach
that's what we did so this one has 26
pins
well if this is five
then maybe
if we move five pins down
so if we do that starting at pin 20
like that
that seems pretty good
and then we just have to bend it over
appropriately
so it's the right length
and the way i was doing that was how did
i do that
um oh yes
i bent it over
hmm
well when i did this i did not have the
other chip in the way so let's just take
that out
and this way we can bend it in
using this little crimper part
on the pins themselves
right because what we're trying to do is
we're trying to bend it
out so that we can bend it over
like so
that way we can
bring this out
a little ways right
i'm not sure that was the best way to do
it
let me bend them back
that was not the best way to do it
i think what i meant to do
was
have a little bit higher
that way
i can
yeah there we go
and then
if i bend it over a little bit more
so
okay
i think this time i've got it
like that
because that's what we did last time
because we were going to
do the breadboarding on the other side
or the sorry the wire wrapping
was i think that's what we said we were
going to do right
because we didn't it would have been
cleaner to do it this way
but then
we thought it was less stable
as i recall that was our
that was our thinking at the time or
maybe one inside
you were saying
that
move it from
oh that's right move it over a little
bit that way it's got more to sit on
exactly we can also add some glue later
and it will become quite
because if we do it this way maybe just
in line with the edge of the board yes
that's a better plan because i don't
know if it
that looks pretty good let's see how the
yeah
that looks
that actually works really well because
you can plug it in it's kind of snug
yeah that's really good so if we just
move that down a bit
oh how many pins was it over 2
and then five down
like oh wait
three
like this
that looks pretty good
and then let's just plug it in again
yeah
i think that's happening all right
so we just need the same thing on the
other side
which was three over this one is longer
right it has more pins
no it's the same number okay i flipped
it over so that the
little bit of extra
leftover edge
was just on the same side
that was the theory let's see if that
actually worked
i think it did
yep okay
here we go
that totally worked
this one actually worked better
and then same deal
we can plug it in
so now if we have them both plugged in
it will be like this
yeah oh yeah it looks clean looks very
clean yes with all the wire wrapping i
guess on the other side
all right
so then
[Music]
um
now we said we were going to
solder in all these pins because that
way it was more solid
is that what we said we were going to do
yes
and then
only the ground pin
for
which how many pins do you need in
between
to have enough space at least two or
three i would say so is that enough
yeah
let's try with the display in the middle
and see how it goes i asked the display
that is very important
the display could change everything
because this one is
a narrow board so
yes
so we need
i'm going to try to cut them right in
the middle let's see hopefully i don't
screw them both up
okay
well
one of them is now a triple and the
other one though is luckily a four so
okay great so that's good do you have
those other colors
that's that way i can maybe trim off a
little bit of this
thank you not sure if it's
yes don't overdo it story of my life my
friend story of my life
all right that looks pretty good
and we're gonna bend it in a little ways
and it's um let's see 26
plus five
is that really correct
so a through z
and then five more
okay
well then
that means it should be here
can we this is the middle
and we can plug in the little board
yeah just to try it out and we said
we're going to tilt it inward a little
bit and reverse the display
that way it's kind of leaning up
but let's just plug it in so we can see
how it looks
and that looks pretty good maybe
you think maybe not i don't know
i mean if it goes a little bit
outside it's not that bad but maybe
having a go at how it looks like
if it leaned
inside
it could be
let's have a look
because in that case you can also solder
it
and we'll solder it glue it
what do you think
i mean we don't have to reverse
i feel like it's one pin over but
maybe we shift
the
controller
on the left
so this is pretty cool because it makes
it more compact yes
and um
that's always good
right
and also it means there's less things to
there's less things sticking out
i mean we're not committed only
if we go
we can change the orientation of it
if we decided to exactly
but
now that
you had me change it the other way
it looks a lot better
this looks more like what you would
expect compact yes more compact
if you want to put it in a box for
example
and you don't want to remove the display
i would remove the display for travel
anyway yeah but maybe if this fits into
uh you know uh
yeah books you
can just pop it out mm-hmm
just do a small
hole a squares hole and it just
fits
and with no angle that's much more
likely to be possible
yeah let's leave it like that
of course we still have the thing with
the battery
like if we have a separate battery we
have to plug it in
somewhere else which is you know very
doable
right
well
i feel like you talked us into just
putting it in in the original way just
flat
just because that really feels like
the most stable the other one it's going
to get knocked into or
this is the least likely to break if i
drop it
one thing in that way uh i don't know if
this is the right position for the
controller
maybe it needs to go on the bottom on
the bottom on one side i was thinking
what else do we need to well the buttons
yes where do you want to have them the
buttons need to be down here on the
right side for they can be all on it's
much easier to have them that way
okay you should have one
um on the left and one on the right the
button so they can be all in the same
i am trained my friend
on the creme de la creme
of controllers by which i mean the dual
dualshock 3 controller okay
like the dualshock 3 the button
placement
is really good like you take your finger
off off the right button
you know you're strafting while firing
okay now it's
that's a it's a great way to go
so that means the buttons have to be
down here okay so
if we do this though it means we could
for example
[Music]
put this in like so
there's other ways these can be
and this leaves us a little bit of the
space
if we wanted to contemplate
the feature
which was
let's see if i can find it
i have a
esp32 board somewhere here
now it's an actual board board it's not
a
it's not just a separate
microcontroller
which is probably good because it's a
lot easier to work with
i know i have it here
i had it here a minute ago
because i wanted to see if it was going
to fit
now those are the buttons
let's see maybe i have it here in my bag
of tricks
it's very possible
i i have one that's an esp32
mini
and oh thank you that's a lot easier
i don't see it in here
once i put it in here
no
it's not there either i know i have one
because i specifically grabbed it
well we're not going to put it in right
now anyway
but
i don't have it i have it but not here
maybe somewhere
probably fell on the floor somewhere
but it's very close to the same size
as
this
board which is in esp8266
this is really similar size
and so
it would be a similar sort of deal where
we want to
you know be able to solder it on as a
separate board
and connect to the
serial peripheral interface pins
so
again that's a future change that we
could do if we do it this
way it's not like the most perfect to
fit but it would work
if we do it the other way
the original plan
which was
two pins one more pin
if we do it like the original plan
then
we have a lot more room for this board
somewhere
like here for example
for a future addition just because we
need to have
some power well that's going to have to
draw from the same power if you want you
can
this is more if we need to flash it
with some firmware
or something anyway this is not to be
done right now this is more just like uh
if we're going to do this in the future
this is this would be a way
but we might again we're not worrying
about that right now so we don't have to
care so i guess we're just trying to
decide are we going to put this
like this
or are we going to
put it on the other side
down
here
you know the nice thing about this is it
leaves us more room for future expansion
like it's very compact right now
yes i think so i think we should do we
can even
shift if you prefer this one one bit
because it's not strictly necessary
i can still reach in and hit the buttons
if i have to re-flash it
and you have more room here to connect
things
i think this is the way to go all righty
for now
again this is just our v1
so
what do we want to saw there first we i
guess we want to solve all the pins on
both of these
and then
and all the pins on this
and then just the ground on this one
let's have a go with one pin for each
thing so it will have a more stable have
a look and then finalized and soldered
everything
yes i think that's the beauty of wire
wrapping is that that you can actually
do that
all right so
that being the case i guess it's a lot
easier we just tack in one
for each of these
whoops i guess
we have to hold them in somehow
do you want to solder them or do you
want to do the wrapping and i'll do this
on whatever you oh it's fine for me
i i follow you
he's like i just want to get
i just want to see something happen
all right well i guess we'll just start
with
so it's got to heat up again
i'm going to follow your sagely advice
and clean the tap
and so
would you like me to help you with i
just want to see that there
i trust i think if i hold it in i'll do
it for you don't i have another idea
because that here's a better way to do
this
okay
you need to just put something
underneath that's the right size which
one of these happens to be exactly the
right size
ah come on i'll i'll hold it for you um
this is easier
all right
let me we just have to put one we just
have to put it on both sides
i see what you're talking about no
because then if you solder it it will
come out a little bit so i will i will
here for you okay trust
okay
okay one two okay here we can go
i'll just solder on the top hole yeah
just exactly just one
can you
yes i just get very close to it without
my glasses and it works perfectly
oh yeah this tip is so much better yeah
okay
then just any one of them really right
well no let's do this
yes yes sorry
well let's do this one first
okay and then the chip
okay you ready yes
fantastic uh
ground which one i cannot see
i think it's the second from it's on the
this side second from the right second
from the right okay hold on
here okay
so it's this one here
uh it's a pleasure with this board sorry
but i see that this and with this
with this tip yes so much different like
it actually now we have it quite of
stable and we can also
put it on the top here yeah
which was i believe here
and if we don't like it we can change it
okay
this one is longer so it stays in okay
more easily
i won't risk my hands this time okay
and now we're pushing it
i'll clean the tip
no don't don't do them i know i know
it's true it's true you're right
i know i'm like all excited like
but that's what the whole point of this
wire wrapping is
wow okay that looks really good
i think we can
probably okay now the ground
that's what we needed we needed multiple
pins for the ground that's what we were
doing yeah we can
use one of those rails
and decide which one will be the ground
for example
this is the reason why we
um
if you like i don't
i don't know other way we can choose
another approach no
well
we made it a lot closer now
if
it was any of this one goes to ground
which is quite large we can derive the
other unfortunately the ground is on
this side right here it's the one pin i
saw there yeah but we can do up to two
wraps
on one of those small oh so make it just
choose some area to make the ground yeah
and this is where we were going to use
one
we can
derive two grounds one here one here and
then
sorry
okay one here
one here and and the other one from this
one which is longer
because on this board we chose to do
that
yeah we did that i guess on both sides
is what we said and we pushed down the
pins
i think that was still a good idea
but
that was based on a slightly different
layout
of where
this board was going to be
because we had more width
yes
so we can't do that now
anymore
so you're just saying just pick uh just
pick a rail down here to make
essentially i wouldn't do the rail in
this case no let me let me tell you
about it yeah what do you think
um how many grounds are we going to
connect
we need
one for each of the joysticks yes
we need one for the display yes and then
we need one for all of the buttons yeah
we we have plenty because we look on one
of those
which are the same length we can do
three
wraps on this one we can do
like i would say two wraps
so this one
so we have we can but we still need but
we still need
to have more than two wraps for the
ground i mean we need to have some place
that we make a rail of some sort
yeah
and that's what you're suggesting to use
down in here from here we can move to
this rail for example
and do this one the ground rail and this
one we will do it the
is that better is that actually okay to
be touching the ground
ah
well with these voltages and
i
i haven't got
much problems
i just think it's maybe better to not
have it all the whole edge be the ground
that way if some something shorts it
we don't fry the thing out
all right
well
hmm
just because i like the way we did it
before
i mean that was actually really clean
and if we put like a ground down here
essentially
you can see uh
it's not right in line remember how we
did it we
pushed
sorry one second so we push all those
though out and then we will stick it
from the bottom and solder it from the
top so it will goes
but can i yeah absolutely
it's
like this
and we have more room for
that
oh yeah that's right i do remember that
now
and we have like
here's a four
this is a three
but we said we wanted five because we
needed five
things to plug into
actually we needed six
is this a six seven i think oh well
that's plenty
because then we we did the just the
reverse
exactly and that way we just said okay i
mean
and we can move it over a bit more if we
want to like
make it so it's not quite so tight
for example
i mean
i don't we don't have to make it right
in line with the ground
but if we did
the problem is it's two it's too close
right yes
so if we but if we did that same idea
and we just move it down
that's perfect i mean it's one step but
it's not it's a few steps
but i mean it doesn't actually match up
to anything
specific
we could put it in pin 13 which that
since it's you rarely use that since
it's the led
like that maybe okay so we'll hold it
for you and you solder one i saw there
and this is what we did before where we
had the one
jumper across them as i recall so yeah
if you hold it yeah
hold up so you are soldering this one
right
okay
you can
hear the hissing that's how you know
it's real these special effects are
they're just all too real
everything's all good until you get
burned you know then it's like not funny
anymore just one
yeah as usual yeah because we have to uh
it's not hot yet no that's the way i'm
doing it
it's heating
340.
yeah i really like the display it's so
cool all right these plays are always
fantastic
okay
perfect
so we have this one
okay so now
we just need to find another
piece of wire to jump across them all
like we did the previous time
another i used i used a resistor he
had like a spare
just a extra resistor cable
because it was not too actually this
might work yeah you were seeing these
from
oh
yeah this would work
it's a little
the problem is it's not quite it has
this extra part on the end
maybe it's not long enough if you got it
exactly
but i have a resistor wire here
somewhere
i had an extra resistor i was willing to
sacrifice
for the greater good of this controller
you proved the resistor wire was the
best
well it was the best we had
i'm sure there's yeah you know
there's a probably a more proper way to
do this but if you don't have one we can
just have another go right there no i
have one i have one
i have like a bag of resistors here
somewhere if i can find it
now that's the bag of leds
i mean i i can always break down and
actually take like a nice resistor out
of the box
or the resistor kit
it's just
like pick one that i don't use much of
let's see here
1k resistors oh no not those
where they are in abundance in nature
it's true
i know i'm like which one of these like
like come on pick it pick a resistor
okay
sorry resistor was
some
it was someone's turn this time it was
yours
the fact that we're not using it for
resistance but that we're using it
actually for mo instead of ohm
you know mohs are conductive
units of conductance instead of
resistance
yeah yes
so i'm not used to listen to that but
yeah
i'm not sure if i've ever said that word
out loud
i know it exists though no it reminds me
more
like curly and larry yeah
three stooges yeah that's that's
probably the level of technology that
we're at here is definitely three
stooges
okay
so now
this was the uh
i'll hold it for you well i looks like
it's easier to just well actually maybe
because we just want to put
whoops the main thing is to
once you get one of them on there
then they can all just plop on
the trick is to not
well first we have to wait for it to
heat up
yes
okay yeah you got the right idea
not at full power yet
actually i've never taken this thing to
full
power i think that's more heat than i
need
i mean for this kind of work okay 360.
we're good
let's go in
all right so the first one
yeah
fantastic
second one just not the first time we
should probably go to the other side
yeah
yeah that's almost for sure true
okay
well it's really slim this bit it's so
tiny that barely
gets any on there
well you're not supposed to inhale this
don't do this at home kids
i mean breathing that is
that's what i used to do it is i would
just build up a bridge of solider
between them
which is you know probably good
all right
seems like there's plenty on there yeah
so let's
okay let's take a closer look
that so if we wrap the um
hmm so we're going to need another one
of these for the power
we've got the ground but we need the
power
yeah because we need the power rail it's
should we do the same thing we just did
to make a power rail in the middle here
or it's a good idea
but i don't know about the
layout where to position it but
it looks like that's the way to go
do we have one of those rails from the
other day that we pushed not to
sacrifice one of the existing no we
already had soldered the man
okay
so
but that's okay because we need
let's see how many do we need
we should just make it the same size
yeah
we can always
find uh
if we need more we can get more yeah so
oh shall we break it
well you do because it's
isn't this the right size here
you can
how did you do this you just
i think we can do it
with that one
okay let me try sure if it
that looked works looks clean
and
it also seemed like a pretty solid
connection
and we can use the other side of the
resistor lead
okay
it looks like it works
it seems legit
and should we put it like far on the
other side or kind of next to it or
where do we want it no we don't want to
sacrifice this area so maybe not more
than
i think this is fine well a little lower
that's that's
what do you think
too much space maybe
well i don't want to
have it too close
and this is where the
um
clock and the sda are so if we move it
up a little bit
i think we'd be better off
right below the display maybe
just
oh good idea let's see we can hide it
well
it can go down a couple more
okay
well let's bring it back up one more
yeah maybe
it was just a little too close
okay
so then we just tack one
again yes i hold it for you thank you
surgery
put the chip heat up
back to 360.
uh we need yes
and then we'll need to clip off another
lead
yeah
okay that looks good
take off my glasses
we're up to
360.
so let's
get
this one here
okay
all right nice hot tip
clean
sharp tip
it's so easy compared to
some of the tools i've used are really
bad where's that easiest uh
uh
here it is
so
about so long
same so
it's too short no it's just
right
like it's a little short no no it's fine
i think with one um look i can hold well
if you i don't know
i think it's perfect
it's perfect with a little blob or
something
as long as i do it very gently yeah
hopefully
we'll see
because this will give us the power
so
it's still hot
the sleep doesn't hit
right away it takes it like a little
minute actually
i think i'm going to try this
[Music]
it fell off now it's still on
it's just it
moved
in a way that was undesirable
hmm hold on i will
take the sponge
it's a little bent
maybe we should
let's just cut a new one oh shit
yeah starting to cut a new one okay so
let's put down this other one
yeah
well you know to make a few circuits
you're gonna have to clip a few
resistors yeah sacrificing that's what
my drill sergeant told me
and uh for somebody maybe it was my auto
shop teacher i don't
know of those people who tells you how
you're supposed to do things i mean they
came out i got it
but it's kind of bad
let me see if we can
i know i don't seems like i don't want
to waste materials exactly
because it was always kind of short
it's a little bit better if it's long
okay okay
if it's a little bit longer it's a
little bit better because it's a little
bit easier
not too much longer but
like that but we can calculate
afterwards anyway
well a little bit that protrudes is not
too much of a problem
but
as you saw if it's a little too short
so you have the tweezers you can adjust
it more easily
well but
from that way yeah
actually do we need to cut a little
piece off it looks like it's a little
too long let's just trim the little tiny
chunk off but i
think
we'll be happier if we do
no no no okay i thought you work
oh no
no i definitely wasn't gonna do that
okay i think it's a good one
up still a little long
otherwise like the power pin sticking
out a little bit further
definitely something can go wrong with
that
still 360.
this one we have to give them all
in one shot
nope
not good
there we go
that's not exactly what i had in mind
but
that'll work
hold on a second i will change the
probably if i rotate it that way you
will
work better
right now
okay yeah now we got it
i can just tack the other ones down
there we go
oh glob
glob flu
oh there's another one
well we weren't going to use that hole
anyway
that's why we didn't make these too
close
there we go
just a little bit more
that one's cold
oh
these are a little cold
and now
okay
great
make it shiny except the last one
okay yeah that is perfect
all right i think we have it i think we
have it
so
if it's true
we shouldn't that's a little bit much
but that's okay
you can use that one to connect to the
actual power okay
just like that one you this end you're
going to want to connect to the actual
ground right right
so now we're ready to wire wrap
and i guess the first thing is
the ground
the power
and then
the
sda
and the clock
and we should be able to
see something appear on the display
that was where we got to last time
when
things all of a sudden went bad
actually it wasn't all of a sudden they
were bad the whole time it was just
suddenly we noticed it
right
i can put the resistors away we're not
going to need those
anymore i hope
now that little this little pack of
resistors i think it's from
sparkfun maybe
yeah colors looks like this fun red
yeah that's a handy little kit
i have a couple adafruit ones as well
and they're pretty great
i mean i've used them so many times
oh wow no just to so organized yeah
because otherwise
yeah we'll try to reuse them
we shouldn't need the
solder sucker
aka the desoldering tool hopefully
um
now if we are going to plug this one
that way
we will do the signals and then we do
the power
okay
so
data
data or sba
which is
the
um
third up from
this side
okay
third i'm sorry third here
okay hey okay third from the bottom is
the
data
let's see
threading a needle
yes exactly
certainly there is so much reflection
i'm sorry about this
only all works
i should be holding the board while you
do it no no no no no
just stop
i'll hold my own board thanks
just like this i'm gonna unplug the
soldering iron
because we shouldn't need it now
hopefully
[Applause]
we'll need it for the buttons but we
don't need it for this part of the test
all right
oh yeah that looks nice
so third from the bottom
then
one
two
three
four well whatever
i think it came out quite clean
yeah look at that
so
we will go
to the
er we say data sda so the extreme
left
this length more or less
my side and my hands the little
stripping tool is so cool yes all in
one i remember doing this with a uh
a friend's z80 based computer kit
fantastic oh man
good times oh yes
i don't remember if we had the actual
chip
i think we had everything for the kit
except for the micro controller
microprocessor hi
i will give a little push okay
and that's it
i will use everything
i think i'm doing more than required but
anyway we don't yeah but this is for you
know avionics
you know
i mean we're flying things with it you
know over engineering of course
of course you know this okay now we do
the clock there's many experimental
aircraft
that people sit in and fly off the
ground which are not as well put
together as this which is really scary
there's quite a few that are though
actually
of course
there is no limit to
well the only limit is time and budget
my friend time and budget that's the
only limit
imagination we have aplenty
um on the cheap on the chip it is
clock which is the
pin directly up in this direction from
the data
so it's the fourth pin from the bottom
okay just next to it exactly
as usual adafruit their
board layouts are very nice
they've really thought through the
typical use cases that
most
you know i guess hobbyist
prototypers
would need
same thing to the other side
and i think it's the next one yes or
clock yeah exactly next one over
now you can try you will do
now
you have seen it twice okay you will
remember it how
it's
i will first you strap about the length
of the
and
there we go from here
without pushing too much
just with the weight of the tool
and then
gently
and then holding it with your left hand
so it doesn't move is
at least not too much
oops
it's not the same length but it doesn't
close enough yeah close enough and we
have two okay
so now we need
the power i will cut it for you
would you like to see it probably yeah
it gets a little closer
okay and
and so the power we need to actually do
two of these start with the ground we
need to go from the power from the chip
to
the power rail
so we need two of them so the power on
the chip is the second
from the top here
so we need to go from here
to
this power rail
so i guess going this way
i guess we'll go from
the second from
[Music]
the top here is three volt yeah
and so we want to go from here
to
this rail which is what we're going to
make power
right because then this will be ground
right
so
so we need to go from here
to here yeah so we start with the power
then i i will now a separate one will
jump from here
to the power on the
display
right yeah i mean that's the proper way
to do this right i mean if you want to
yeah the idea is to
start i mean just connect the power to
the rail and then everything else will
be powered from here so we do it once
and we forget about it okay
all right i will start the length of
these problems the length how much do we
need to have for stripping so it's like
this yes
two of those approximate so like two of
those this no no it's just one well no
because we're going to put strip it on
the other side
so we need this yeah but i think let me
just see if i have this right well then
we have this
plus another one of the same size
and then the length of the run
approximately
so like something kind of like
this but i will cut the second end after
oh yeah i see yes of course yeah
right it's not that hard i'm making it
much harder
so actually what we just need is to go
with uh now this is too long in my
opinion that a bit more than that it and
it's fine that exactly that exactly that
so then we just it's not the side we put
it in yeah yeah the right slip it in
there
and then just
how do we call it oh yeah slide it down
no
more it has to do some sort of click
when you
when you just slide it down the
cutter
like so yeah
nice feeling
oh yeah that's really nice okay
so then we thread the needle
see where's the hole
ah this is the difficulty it has two
holes oh no one in the middle
but it's not this the big one is for the
pin
there is a very small on top where there
is rail is where you have to actually
insert the
the wire
so it's very tricky that's the most
uh
yeah that's perfect you nailed it
and the first attempt
and then we have to just hold it over no
no no no okay yeah you did the right
thing but not fold it just
just kind of bend a little bit no let me
so it's
just the plastic here the wire you bend
it a little bit and then
by holding
this
you insert into the pin
okay okay
exactly
keep it
all right so we've got to get the right
power which is the three volt here
and then very gently without pressure
i'm just gently turning
keeping the one side not moving
oh yeah i feel like something happened
and until you hear the click which means
it's done
well i think it's done
you didn't have a clock
but it doesn't matter oh yeah looks good
okay looks good perfect so then the same
thing on the other side exactly
now
you
want to make sure the length is about
enough for the
exactly so about like that ish that's
too far
right
because we want to be like
this plus this length
it's like here
okay thank you
thank you doctor
okay
so we'll use this for the other side
[Music]
we strip it
oh the length
about like so
you can take with your nails as well
usually it comes out yes
that's the kind of thing i inevitably
screw up okay perfect
i at least in my experience i do the
wrong thing and next thing you know i've
destroyed it
okay
it could be on the end
like so
i probably would have put it below the
other ones if i could do it again
you can hear the click
yep
i did
all right i think it's not the best wire
wrap job it doesn't let me pull it but i
i cannot see that when it's ah
i know because of the solder no it looks
good it's just
um a bit
rising
because of this of the blob it could be
better globe it could definitely be
better but it could also be worse
all right so now we need to do the same
thing
from
the power
on this which is
this pin
over to really any one of these right
but since we're going to want some for
the
joysticks maybe we want to like pick one
in the middle or i don't know what do
you how do you do i don't think that is
really
let's start from nah doesn't really
matter
yeah because okay this is actually
really we usually tend to do this kind
of movement so running around and leave
plenty of space anyway
oh
yeah this is really fun
i i think so
i really like wire wrapping now i'm
totally hooked it's addictive i totally
see why this is like
and it's more like jewelry than
for certain things it's um i think it's
the ideal and the hybrid stuff you know
it always works
mixing best of both worlds
you know i could definitely see that
because
we use less
uh
lead
yes well i've been inhaling lead fumes
for too long that surely is not good for
you
well but it has some really practical
advantage in some cases well over the
breadboard for sure because of the
stability of the well i'm already over
breadboarding for a lot of things i've
been using breadboards for things that
you shouldn't use breadboards for
and
like the cables keep coming out
and it's very frustrating absolutely
and it's not um
necessary
like i was thinking how many i want to
build some boards to use for the tiny go
tiny hci
because i have all these breadboards and
they're a little flimsy sometimes
not just sometimes
and
the problem is
the cables come out at exactly the wrong
time
yeah i mean it's always like that yeah
that's just a given
okay i see what i was doing wrong
i should point the camera a bit because
it's a pda
now the same thing here
we just
because there's a little extra
glob of solder it's not as tight
but
it's still good enough
yeah
i'm sorry no no no worries just trying
to okay i have the power
i have the power
yeah now wait now is this the way to the
ground
yeah all right here's the ground oh man
i'm on fire i can't stop now i'm like
totally hooked
it's like this is like those labeling
machines you know like you start using
the labeler and you're like i can't stop
labeling everything
i want to wire wrap everything i i
made the mistake of giving the labeler
to my daughter
like everything's labeled but with
labels that maybe you didn't want
labeled
like her name for things yeah
this is really cool
okay so the ground
same deal we uh second from the
yeah this one here
okay i'm getting slightly better at this
i'm not saying i'm good at it i'll just
say i'm slightly less bad mastering it
already i'm slightly less bad okay i'm
going to try to go for a tight
connection from the ground to the
i'm going for it
i know it's probably a mistake but i'm
doing it anyway
i'll give a little extra just because
that way
i know
because i saw someone in the video do
this once and i'm like okay
i should be able to do that
that kind of tight clean
wire wrapping
i learned it from a youtuber called um
andreas spice
he has a very beautiful
channel for makers
i don't think i've seen my channel and i
should
absolutely
okay
do they pass the audition
wonderful
okay we just need one more cable and we
should find out whether this actually
works wrapping highways
oh man this is so okay but i dropped the
black cable
doesn't matter well i will have a look
but uh if maybe i used it maybe i used
it a lot because it
i didn't use very much of it
i hear these
yeah i didn't use much
i used so little that there's no way i
could have used it all
okay so same deal
strip and end
it doesn't have to be perfect but when
you see these people's wire wraps so
they're so perfect and you just think
like wow
i mean it's really
it's kind of like jewelry absolutely
like beating
you know like something like a mosaic or
a chocolate machine how do you build the
texture of the
i'm gonna go this way
yeah like a mandala or
one of these geometric mosaics that they
have fabrics the
fabrics the teaks yeah
i'll just suddenly now i wanted to go
the other way but because these cables
are all going this way i have to do that
see that's a trap
now we've got to go like this and then
one
little bit extra
about here
i'm sorry
no worries i'm just now i'm addicted now
i can't stop
i know that for you like
my entire vacation all i'm going to do
is basically wire wrap now
like that's all i want is a wire wrap
kit i'm going to have to order one
like if your kit is missing and then
he's um your kit is missing you're like
what happened to my kid
i think that program stole it there is a
pistol i mean that rather than you
turning the tool you just
oh i'm not i'm not like i'm sorry i'm
not that good yet
that's too much i don't think i need
that yet
you know that's for people who actually
know what they're doing
i'm still just a
you know enthusiast
but maybe i'll get one of those because
come to think of it i really do have a
lot of
wraps that will have to be done
i'm just looking to see to make sure
that there's no
yeah because if you do it right then
the insulation like this one i didn't do
it quite perfectly
i'm not sure if that's fixable
basically
like if you do it so the insulation is
actually very close well if the if it's
not insulated they may touch the other
one and that's not good right and that's
what i did that's what happened here
for example which of course is the
ground so that's unacceptable
happened with those tweezers here we go
so like this is not actually good
i mean it looked neat it seemed like it
was tight but in fact
maybe
if i just pull it a little bit
but
like it's okay now
but
now that i've learned a little bit more
about the wire wrapping i realized that
like the ones you did are better of
course because
you have the right little space between
the insulation and the wrap
in any case though we should be able to
test this now
so if it doesn't explode
if we plug in the battery
like any battery actually or just a
cable
let's see here
so i think we just need um
to go to the tiny go drivers
and if i flash
tinygo flash
target
itsy bitsy
nrf 52840
and we flash the examples ssd 1306
which one is it the
i score c 128 by 64.
yup that should do it
okay it's flashing
and
observe
on the fact that we had completely used
the wrong board
and this time
like we're really close to having a
flyable thing
because the
not really close but
much closer
we have to connect
10 more wires for the joysticks
and then we have to connect
we have four buttons
each of which has a pin and a ground
so eight
so we have
wire wraps
and i guess
eight solder joints
and if we do that
we have
the ability to actually turn this into a
flying thing
wow okay
well i guess i have my my homework
uh i have to get a wire wrap kit now
because this is just too fun
i mean look at this thing
wow well awesome man fantastic thank you
so much i really appreciate that oh man
that is so awesome
okay that's it now i'm hooked on wire
wrapping
all right so let's see what today we
redeemed ourselves we actually got the
wire wrapping prototype done
uh before that i got to take a look at a
couple of pull requests the pulse width
modulation pull request that is on the
raspberry pi
not quite ready for prime time
but it's getting close so hopefully by
the end of the summer we're going to
have full raspberry pi support for all
the peripherals and some other stuff
and some other fun new pull requests
that i see coming in for other hardware
as well so
on that everybody you have a great
summer what's left of it
thank you so much gracias
thank you to all my colleagues for
what's been a really great run we'll be
back after summer vacation with a new
format new awesome things
new toys and
maybe a new look i'll maybe i'll even
cut my hair anyway
goodbye my friends and see you in the
fall
[Music]
oh
[Music]
foreign
