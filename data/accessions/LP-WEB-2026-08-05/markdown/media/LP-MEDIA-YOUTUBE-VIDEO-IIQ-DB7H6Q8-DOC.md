---
document_id: "LP-MEDIA-YOUTUBE-VIDEO-IIQ-DB7H6Q8-DOC"
source_id: "LP-MEDIA-YOUTUBE-VIDEO-IIQ-DB7H6Q8"
title: "S2_05_DEADPROGRAM@LA PIPA"
language: "en"
document_type: "youtube_video"
origin_uri: "https://www.youtube.com/watch?v=Iiq_db7h6q8"
verification_status: "provider_metadata_captured"
access_scope: "public"
content_sha256: "7706b739a17bdb0784999c6d12af40500c6d8e9f036df008b21206e482485573"
---

# S2_05_DEADPROGRAM@LA PIPA

Archive source LP-MEDIA-YOUTUBE-VIDEO-IIQ-DB7H6Q8. S2_05_DEADPROGRAM@LA PIPA.

YOUTUBE video accession record.

Canonical provider URL: https://www.youtube.com/watch?v=Iiq_db7h6q8

Provider identifier: Iiq_db7h6q8

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
hello beautiful humans of the internet
humans robots extraterrestrials and
fellow cyborgs this is high dead program
back again with the live stream from
beautiful la pipa in mysterious espana i
am here of course with gopherbot and the
two of us are wearing our masks because
although we have been fully vaccinated
it is better when in interior
environments to maintain your protective
shields up
stay safe out there my friends
very very important
luckily there's no other humans here
just some clones and cyborgs so we
should be fine
so um
yes lots of exciting things happening in
the world of technology
let's start out with a little bit of
news
jumping to the linux desktop so last
week i was
making some fun joke comments about the
problems on the international space
station
yes when the russian module docked the
thrusters actually three hours later
after the docking when they were out of
contact
with the russian space control center
the thrusters went off on their own
so
apparently the situation was much much
more dangerous than previously reported
everybody thought that the international
space station was only out of alignment
about 45 degrees 50 degrees it turned
out it was
540 degrees
so uh yeah luckily for the astronauts uh
the people on the ground kept their cool
and got things back under control but
that could have been a very serious
situation
wow
software it is very important and it
must be tested
in somewhat better space news
the uh ingenuity the awesome marge
helicopter has made its 11th flight
recently this this little copter this
little drone
is just it doesn't stop giving it's so
amazing what it can do
they they thought it would maybe survive
one flight 11 flights so i have here um
really cool visualization that shows the
horizontal flight trajectory of this
recent flight and if i look in here let
me see if i can find this
there's actually a
well i lost the image but there was a
really cool image that showed
all of the different flights combined
together
so ingenuity is a long way from the
rover now and is actually scouting out
new territory so that's pretty
incredible
robot space exploration
that is the way
crude space flight
kind of dangerous maybe kind of
expensive not convinced
uh speaking of awesome robots on the red
planet
jurong
the fantastic chinese rover with the
awesome smile this is a really cool
visualization that is showing
all of the different steps in the
journey from the landing site down here
see if we can increase the size yeah the
landing site all the way to where the
rover is now
so uh covering some ground on another
world
robots that's the way
so here on earth on the other hand uh
copernicus which is the satellites run
by the european space administration and
they're used for monitoring weather
here in europe it's the second house
july on record not here in the series of
very cold but everywhere else it's
really really hot look at these surface
air temperature anomalies
so uh it's getting kind of serious if
you haven't thought about your carbon
expenditures you should
all right
and slightly happier news
here's some really cool stuff that i've
seen this week in the world of tiny go
so senior enterprise geek aka
keeg org
um i don't actually know this person in
real life i don't think
but um
but they have been doing some really
cool things with tiny go and web
assembly specifically
they've been developing apparently
during their paid time off
time off
um
assembly this is really really cool
there's a lot of amazing work going on
in the world
[Music]
all right
so
speaking of uh
and so this
um basically it's getting emergency
right now because we really need this so
let's do it
here we go
all right
delete the branch so that should be
deployed in just a couple minutes let's
see um
we'll go back we'll take a look we'll
see the new site search activated here
on the kind of website hopefully that's
still working um
okay
so last week
we managed to get merged in a really
great pull request
from soy pack
has been doing some really interesting
stuff with the
raspberry pi rp 2040.
it's a more formal name chip circuit i
always heard chip
so it's basically a protocol
for having chips communicate directly
with each other when they're on the same
circuit board
and it uses four wires
one for the power one for the ground
one for sending the data back and forth
and one for the clock
right
so
let's go and check to see if this pull
request that's been added
actually adds support and we'll do that
by testing this ssd
1306 oled display
let's go and take a look here
and see about this polar request now
he's already submitted a few pull
requests i think
in this case what we care about is the
pico
so the pico
is if we look at the panel here it's
using the
for data and clock it's using gp4 and
five
so gp four and five we can see here is
kind of on the
if the
jack that we plug into is on the bottom
of the board
then four and five would be on the
bottom right
so let's
or we could just look at it the same way
as the illustration
that's too easy but we'll do it that way
so four and five is on the top left
and so it's pins
this actually is quite literally pins
four and five from the top hard to beat
that so let's take and plug in
this cable that i brought
and
of course these colors don't match any
colors that we might i'm not sure if
this cable actually works
so i have some other cables here
somewhere
oh actually i have an even easier way
for us to test this
if i go and i
rummage around in my bags of tricks
somewhere here
i can find it i know i have one
oh yes here we go
i actually have a separate display with
the cables already attached that'll make
it a lot easier right so let's go back
to
so let's pull out this little board
we'll use that later
let's uh
we could probably just leave in the spy
cables
and so this is our ssd
1306 board and we've got the cables
plugged in already
ground is black
so that would be on our pin out
that would be the third from the top
so
that one there
then
we have
the
pens four which is for the clock
pin four for the clock
so that's the one right before the right
below the ground
so if we go and we look at which one of
these is the clock pin
and the
clock is the white one
so let's plug that right below the
ground
then
naturally
the data pin must be the one right below
that
let's just verify that
so
yes
actually we want to use
let's go back to that data to that code
for a minute
because that doesn't quite look the same
as what i expected
should be gp4
and uh five
and one should be two and three
and if we go back and look at this we
see
four and five gp four and five
oh i see that's not actually pins four
and five
that's gp four and five which is
actually
on pins six and seven
right that's what that code showed us
let's go back and look real quick just
to make
sure because that will never work so
here we are
so for i score c bus 0 the data should
be gp4 and the clock gp5
so gp4 is on pin six
so the data is on six and the clock on
seven
okay
that's
so that's a little different
the ground is still okay
but now we wanna put
the data
which is
this kind of brownish cable
on number six
which it just so happens i have the
board
going in the correct direction so it's
actually labeled
six
very nice and then seven which would be
i believe the white
for the clock
yes that's right okay so we're good
now we just need the power
let's take a look at the power
power we can pull that from
pin
um 36 which is
the
fifth pin down on the other side of the
board
so if we go take a look at that
oh actually we already took previously
we took the power out
from that and we put it into our rail
so i can just plug this in
in fact i can do the same thing with the
ground
on the other side i can just plug the
the ground in
on our rail here
which should be powering all of the
little devices that we have plugged in
okay so in theory
this is plugged in and it should work
right
let's go find out so we take a look we
see
we've got our display we've plugged it
in
so now we just need to go and pull down
the actual code for this implementation
which the way that we do that is
um
so this actually cannot be rebased but
we can merge it
squashing it
so we'll just
get check out
dash b
is this that's in the main time you go
repo here we go
so if we
get checkout dash b
whoops
we hope if you saw that
get check out dash b for branch the soy
pat branch of the i square c r p 24 d
and so we're going to
create that branch name from the dev
branch
and then we're going to get pull
from soypath's fork
of course rebasing it
so now we've got that code
so now we should be able to
um
if we make this so that we build it and
we've got all of the latest
tiny go goodness just in case i didn't
do that already
with some of the other changes that
might be in there
so let's go over to the drivers repo
here
so in the drivers repo i have
an example
that lets me use the
ssd
1306 here we go watch is the same board
and this one is a
um
what's the size of it it's 128 by 64.
so if we go look at our main program
here
so we're just using
the same i square c bus
and we're using the normal pins default
pins whatever those are
so this should just work
we'll find out
let's see if the tiny go rebuild is done
yes that's done so we just need to copy
that
from our build directory into the right
place for our
1 6
1 16 3
and so now if we go tiny go version
we see that it is the
15 ed4 c2
which is should be our last commit
and that is in fact what it is so yes we
got the right code very good so far so
good
so now if i
build and flash this by saying tiny go
flash
target
pico
and then we're going to use the
example
oh
wait
we want to be over in the drivers to
actually flashes because that's where
the example is
let's make sure we have the right tiny
go version there
yup same one 15 ed for c2 development
version very good
all right so now if we tiny go flash
and our target
will be the pico which is the name for
the
small raspberry pi board that i got from
raspberry pi thank you very much
and we use the examples
for the ssd 1306
and we use the example that's for the i
score c interface
with the
128 by 64.
so
that should work let's find out what
happens try to flash it
failed flash
okay
oh forgot to plug in the raspberry pi
that would help
there we go
now it's plugged in
we know it's plugged in because we can
actually see the
previous program so when we flash it
that program will stop running so the
lights will freeze
eventually
nope still can't do it hmm
let's see
oh with the raspberry pi you have to
hold down the button when you flash it
when you plug it in so let's unplug it
hold down the button
plug it in
release the button
and now it's ready to be flashed
this time we'll flash it and
yes
we can see that the i square c display
is in fact working and it's drawing
these little
delta v lines
you know get it
space it's everywhere
so yeah all right
wow
great job soy pack it totally works
so let's merge the squash and merge this
because uh
they've been working on this for a while
so tested
with my ssd 1306 display
and worked perfectly
thanks soy pat
now merging
well actually now squash emerging
something kind of went wrong with this
pull request
and
i don't know what happened
they have some conflicts
because of
the some conflicting changes that they
were not able to successfully resolve
but if we use squash merge
it will turn it into a single commit
that has what we need
and we can just
leave it
for the
simple instructions of adding i square c
support
wow that's so awesome
thank you soy pat
that is so cool
all right
great job
we need those outside contributors
inside contributors any side offside
any contributor
on any planet
from
any kind of entity
we will be grateful
for your pull request
thank you
all right
let's take a quick look and see if
there's anything else we can easily get
in there ah
so they are working on also a pulse
width modulation
example
which looks like they now need to
something's not working too well with
this so
i guess we'll get back to that in the
future time
cool
that is really awesome
let's take a look and see i have a
couple of other pull requests that i
wanted to take a quick look at
before we start working on some other
stuff that i wanted to work on today
with all of you my dear friends
so
recently in the tiny go drivers
repository
long-term contributor and awesome human
being saga 35
has been
as usual cranking out incredible numbers
of awesome contributions
this time
they're all about
the weo terminal
so the wii terminal
is a very cool little
um
it's powered by an atsam d51
which is an awesome
arm cortex m4 microcontroller from
microchip
and seed studio is the manufacturer of
this awesome little device and it has a
built-in
oled display
it has a built-in
esp32 compatible wi-fi chip
actually no it's not an esp32 compatible
wi-fi chip that is incorrect
it is in fact the rtl
8720 dn
rtl
dn
which is of course
a wi-fi and bluetooth module but of a
completely different kind
similar and yet
completely different
than the board which is
typically included on these
microcontrollers so over the last couple
of months
we've been seeing just an amazing number
of contributions from sago 35 specific
to adding support for this cool board
that is got on it another cool board
for wi-fi so most recently
the most recent pull request was in fact
i think we could just run this so you
can see it
it actually added support for
the
tiny go drivers repository's own version
of the net http library this is needed
because we have different connection
requirements and the standard http
library that's part of the standard net
package it doesn't work that well
when you're trying to use it with these
external adapters like we are bare metal
so
let's take a quick look and see
this last week's pull request let me see
if i can get that focused in
so this is actually communicating with
the wi-fi
it connected
it's kind of hard to see
see if i can get that a little sharper
that's pretty good so it connected to
the wi-fi and it used the http
extensions that were added by saga 35 to
be able to actually go out and try to
fetch the
tinygo.org website and since the request
is being made without using https
it is redirecting
we can kind of see that
can we see let's make it a little bit
bigger
we could see that it's
301 moved permanently
because
netlify will not let us access the
insecure version of the site
the way that it's configured so it's
just automatically redirecting and it's
showing all of this on the built-in
display
wow that is so cool
so
this week i thought we would take a look
at this most recent pull request
that is
intended to add some examples
that
are also compatible
with the
atsam d21
and other chips that use the wi-fi
neenah which is the esp32
so
in theory
did i bring it with me oh i forgot the
board
well
i forgot the board i wanted to try this
on to
try using this exact same example but on
the
pi portal
so i guess we're going to have to take a
look at this pull request
maybe next week
when i have the right board with me
either that or i'll just do it between
now and then because this is too good
to not try out and maybe get merged
because what does this actually mean
this means that all of our same examples
that are using the wi-fi capabilities
that are built into the tiny go
drivers repository will work regardless
of which one of these wi-fi chips is
currently in use
so it will support both the esp32 which
is so commonly used it's in almost
everything as well as this new kit on
the block the rtl chip that's built into
the seed studio device
so uh
oh i wanted to try that out but i forgot
the board i pulled it out but i didn't
bring it
darn oh well well
we'll do that next time but uh but this
is looking pretty good and it's actually
a very small change
it's just switching over from using the
this tls package
to using the http package
and then instead of
doing all this work to create a request
manually by composing together the
format that's used for an http request
and
you can see that right here this is an
actual http request in the form of text
oh
help if we saw that an http request in
the form of just plain text
instead of doing that
it replaces that code just by calling
the tiny go http package get
so it just works the way that you would
normally write your basic rest apis in
go except it's running in tiny go i
really want to try this to see i know
this works on the rtl but i want to see
if this change makes it work with the
wi-fi neenah we'll do that next week
because this is actually quite important
for extending our wireless communication
range
even further
okay
so speaking of wireless well actually
before we do that let's go see if this
change to the tiny go website actually
worked
yes site search
so let's look for
the we out terminal that we were just
looking at here it is
i click on that
and here is the documentation page
so wow that's really cool
site search thanks to algolia
very nice thank you very much it's
actually working
all right so we can close that
so um
last week
i was hanging out with friend lorenzo
and speaking of wireless communication
and we were working a little bit on
trying to create a better version
of the
tiny go
tiny flight controller
so if you've seen any of the talks that
i've done recently you may have seen
that we have added support
for bluetooth in the tiny go bluetooth
package
and there's a separate package called
tinygo minidrone which is a wrapper
around the parrot
mambo and all the other parrot mini
drones and so this little flight
controller which i can show you my
version of it
it's here somewhere
there we go
so i brought this
cool little
get out of here we are terminal we don't
need you we don't need you anymore
so this is my homebrew version
of a very small flight controller
and the only problem is it's not very
stable with all these breadboard cables
some of them want to pop out at any
given point in time
so
talking with trum lorenzo we thought hey
let's build a slightly better controller
so i think he's here and he may have
brought some of his gear
we'll put on our masks just so we can
set good examples even though everyone
here has been vaccinated twice
at least
hey what's happening how you doing
i'm
it would be much better to have
you know a slightly larger controller
and um so i thought that this larger
board that you had brought would be good
and then
i realized after that actually
we're going to need to make more than
one of these okay here's why
because
what i want to do is i want to be able
to
add
not right now
but it adds soon i want to add an esp32
along with the
bluetooth that way we can also use this
to fly
different kinds of drones
ones that have built-in wi-fi
so i thought before we go too far with
the chip itself
maybe we should just look at the what
we're going to do about the controller
part for the joysticks
so i brought
some of these connectors we were talking
about last time
ones that were not bent
well that's better thank you a little
bit better light
and so i know it's five pins over
so if i unfortunately it's going to
destroy the other pins
yeah i'm going to sacrifice for them
for the gray they're good no this thing
is like this is a good chopper
this this was well worth when i paid for
this tool it's really
it's quite good
i've been chopping at things all day
it's great
okay so
here's the other one
and
eventually we'll sand off the edge maybe
but
for now it's certainly good enough
oh no wait
maybe it's still okay can survive it's
barely but it's just okay
all right
so what i was practicing before was
bending over these pins in a better way
and i figured out that if i do it like
this i actually can bend them
pretty nicely
so that we can
that's a little better
that way
what you were saying last time i recall
was
if we put these through we can wire wrap
from the other side
so it's five pens so let's see
let's see five let's see it's the second
tenth
and this way
you were saying that would be pretty
good because there'd be lots to wire
wrapper too so if we just did a little
spot solder job yeah one can be
it makes it easier for us to
to wire wrap them to whatever we want to
attach them to do you still think that's
a good idea i think it can we can try i
mean while wrapping well we should but
we should solder it in that way it
doesn't come loose just one well we can
solder them all in because this way it
holds steady okay when we plug in
make sure it still works
the
joysticks and that way there'll be a
joystick on either side
so i brought my little
programmable soldering iron
i can't just use the normal soldering
iron that would be too boring
so instead i have this uh pine cell i
don't know did you see this yes it looks
amazing so this is really cool it's from
pine 64. very cool open source com open
source hardware company
and so i just received this
just a couple of weeks back
and uh in order to actually we have to
un loosen these screws i have a
screwdriver
you have to loosen these screws to
actually put into the tip
because it holds it actually holds in
pretty well
so let's
unscrew
and then put in this
and tighten it back down
it's so small
you can run it off battery
but that's not i haven't really tried
that yet how long does it last i think
not very long i mean it's got a lot of
amps
how long can they possibly last
and then let's see where's my here we go
but so instead i brought this 12 volt
power supply because that definitely is
going to give it juice
we just need to plug that in
to something
and of course i have a nice slim
cable i think that it will fit
i think it will fit into this
power strip we have right here in the
front
okay
i don't know if we have enough amps but
i think it will fit there we go
so then plug into my
german-made power supply at least that's
what it's claims it's a german company
name i don't know if it's actually
german probably chinese
plug it in and you see
it actually on its little oled display
it's telling us that we are plugged in
and so uh we might need to bring up the
wiki page to remember how to use this um
which is really funny let me unplug it
because i also have to look for my uh
i'm not sure if i brought the apparatus
to put it onto
we don't want to start any fires
let's see if i brought the
i have a cool little stand
may not have brought the stand so you
might have to use
something else
look at the size here of the
holder for my big normal soldering iron
but i don't know if that's going to even
work
it'll be good enough
i don't think this is going to heat up
that much
so let's bring up the wiki page because
i actually
can barely remember how to operate this
device
so the pine sill
wiki
has instructions on how to
control the soldering iron it's the
first other iron i ever needed to
actually
read the documentation for
i know it's kind of embarrassing but uh
but what can you do
so it says to um
let's see
here's the tips
where's the control
uh
let's see oh here we go
all right so clicking the plus button
starts to heating
the display then shows power draw
current temperature supply voltage and
estimated time
to reach your desired temperature wow
that is like really fancy
if you put it down
the accelerometer that's built in
detects that
and will reduce the heat
wow okay
this is more professional of a soldering
iron than i am at soldering
clearly since uh
right now i can't even figure out where
the end of the saw there is let's see
here oh here we go no that's the other
end
the beginning the end you know what's
the difference
has to be here so oh here we go
it's very skinny
which is okay because we don't need that
much so let's see
plug in the soldering iron
it boots up
it's heating up you can see
there's the temperature
feeding up a lot very quickly
i don't know what it's set to is the
target 315 you think that's hot enough
uh out for this one i guess so i usually
350 okay 350.
okay 350 it is it's heating up
let's see what happens
when the smoke starts coming out
you'll know the reason why
so we should be able to just
oh yeah i definitely smell it now
maybe oh yeah look at that for smd maybe
it's too much but for the connectors
it'll be fine it looks like it's hotter
it says it's 370.
i think we better turn it down a little
let's turn it down to let's say 3
25.
okay
see if it's still hot
oh yeah looks pretty hot
seems hot to me
so the main thing is i want to get it
pretty snug so that you have as much
room to do the wire wrap as possible
so let's see here
don't do this at home kids
okay i've got to say this is a good
southern iron
it's really nice
what
maybe a little too much out there on
that one
let me
take some of that off
okay so let's see if it actually turns
the temperature down
when you put it down
put it down and stand by
it takes a while maybe i don't think
it's working
maybe i don't have that mode turned on
um i was looking for the solder sucker
here
because i put a little too much
got a little too enthusiastic with the
solder i was so excited about the
ability to do the soldering with this
little guy
or thing it's not a it has no gender
it's simply a tool
yeah i got a little too much it's not
that hot though
i thought i can tell if you
you want me to well it's better to
soldering is not is like surgery one
person should hold the knife and the
other stand back
obviously i've never performed a surgery
i think someone holds dead
okay well it's heating up again
i think it was better with the hother
temperature
it seemed like it was a lot better
let's just put it to three fourths
i will hold it for you
well i think it's better if we put it
down okay
that way i don't like accidentally burn
you and then you're like oh that really
hurts
and then i feel really bad
yeah
that is yeah that's definitely better
though i can tell with the
all right
yeah we can put a lot less out of there
i didn't realize there was so much
solder on the tip when i started
oh that's a lot better i can actually
see now
that explains everything
this tip is not the sharpest tip
and yeah i think it'd be a lot better if
it was hotter
let's put it back to 360 now
you can't see that one on that side
because of the glare oh there we go
pull a little more off there
all right that's a little better
now we can actually see
all right
there's a little bridge between these
though just because i got a little too
messy probably needed
a rag or something let's clean the deep
yeah let's clean the tip
and we we can prove here
from looking at this
it does not lower the temperature when
you put it down
it for sure is not in in my things i
would not touch it
it takes a while
no i just think it's not doing it
luckily i have
get a
the wettest i'll go wait don't worry
yeah but we could probably just wipe it
off at night
it's not the best but it'll do okay
that's better
it seems like it's not hot enough
probably you can see from the solder is
not too it lost the flux so it's better
probably if we remove everything and
then just clean that i'm sure you're
right so let's do that
because it may not even be in there that
well actually it is
here let's do this let's get the tool
hold on a second what are you doing i'm
not cutting it i'm just want to hold it
with something
okay i don't have anything to hold it
with
while i let it
peel off
i mean these pens are not that good
they're very cheap
and now they're stuck but can you have a
gold it means of course
now we need a magnifying glass yeah
neither one of us can actually see can
we
oh my god
a much brighter light
do you have a multimeter probably we can
see if
well now that it's all mangled
see how it's kind of bent i think the
best thing to do i'm going to put this
down okay
that way we don't
burn ourselves
and now that i've destroyed it i think
we can just
cut them out
we could just get another board
we'll clean this board later
we use the other side of here
no yeah we'll we'll do that later but
they want to have one that at least
looks good
so here's a five
i have some more balls
i'm not sure if it's the same but
dude what is the other
i think it's
or maybe it's a little smaller yeah i
think it's
a little small do you want to go with
that or you prefer it
well i wanted to use this bigger one for
the
um for when we attach the
wi-fi chip
so we can use
unless you just you think you can just
pull them out but i don't have another
crimper
or tool
let's see one by one
i need i have some helping hand
somewhere with clips but i didn't bring
them
okay
oh yeah we need that we need that water
so we can actually clean the uh the
soldering device
two
come on
okay the sponge is now damp
three
doctor
i'm not even a good nurse here
okay and this one
and four okay so now we will
i think we can reuse this one yes now we
can actually use this other shocker the
way it's meant to be used to clean the
board
oops
but he's not hitting
it's not yes i know that's what i was
saying i'm wondering if we need to turn
it up more
because i mean it does claim that it's
at 360 degrees but this is quite a lot
yeah it should be plenty yeah i think
that now we i don't know now we're
destroying the board there's one it's
not a very good board i mean that's just
how a lot of these boards are
okay
well i think
we can see through so i guess we can try
the next
oh that's plenty good enough
we could try again
all right should we
because we wanted to do it on the other
side
so this is should we try to stick it in
and then bend it or yeah
okay probably need to clean a little bit
more off i know but if you have this one
this one is better for bending it if it
fits
clean a bit more
just it doesn't quite
slip through
yep probably a couple of them are partly
closed
oh i got it perfect
just a little extra
emphasis
because
we do want to but we need to bend it
before we solder it yes much better you
have this one which fits so
yeah
oh yeah that's actually way better
of course we need to do it the other
direction
so it sticks out
so we can plug it in
okay there we go
this is more like circuit bending than
it is you know
mind design
mind bending yeah exactly it's mind
bending
okay
yeah this looks better
you see it went to sleep mode
it's just about time oh it did do it
it's just wait a while oh i see that way
if you put it down for a minute it does
not switch it doesn't switch off until
you think that you're done there's
probably a setting in there somewhere to
control that
are these clean enough for you or should
they
we should measure it if we have a
other multimeter
or just to make sure that there's no
shorts i i it looks clean to me but
my vision is it looks clean
i'm sure it'll be fun
what could go wrong drone crash
all right
so do you want to solder this one since
i mangled the other one so badly okay i
can have a go
i want to let it heat up a bit first
uh yeah
which it should do automatically
oh whoa that was quick
it's pretty cool
i can remove some of the items we're not
using so we don't burn those up
did it work
it looks like but
the problem is i'm
blind
i usually use the magnifying do you have
the
magnifying glass
no
i do not have that with me
that would have been a good thing to
bring
i should have done that
i'll cut the other
connector oh too far
geez
i'm mangling these connectors faster
than they can make them right now which
is amazing considering how fast they
make them
because these are the ones with the long
pins and those are a little bit
i only
i only got those with the
boards
this time i have to do it right because
we're running all the materials
i mean yeah
what do you think i mean i didn't put
enough but we connect with the wire wrap
so just to hold it
at the end we don't mind about the
connectivity if yes that's true and
really it's just to make sure it doesn't
fall out when
when i'm trying to you know
massage massage when i'm trying to
mangle the drone controller
so this time
six let's just get a little bit closer
so i can cut off this other pin okay now
i got five
i don't wanna
have too much hanging on there but okay
that looks pretty good so now we'll put
it on the other side same as what we
just did
which was five down from the top
which is e
yes confirmed e
and then bent over
by
holding the pins this way and just sort
of bending them
and then
trying to bend them back a little bit so
that they're not quite so
out of alignment
yeah what do you think
looks good look it went to sleep it's
got a little z message on there oh that
is so cool
see we're gonna have to program that
with something before we're done not
today i'm saying but before we before we
do
before we're done with this device we're
going to have to put some custom
you know display message on there
on the wiki it's got instructions on how
to do that
well not a custom message but how to
recompile it
okay
are you really doctor
okay
the patient
is not alive
luckily the patient did not start out
alive so uh so nothing's changed as far
as that's concerned
clean the tip between each solder joint
very nice like a true professional
heating up the
copper and then
let's see if
that works
i mean i know it's a little gimmicky to
use the pine sill as opposed to the
other
soldering iron but
but it's so cool this time i'm using it
and it's so it's like using having a pen
in your hands and
exactly the cable is the worst part i
need a slightly better cable nature i
think it's okay
yeah since we're you know exactly since
we're going to do the wrap and we can
experiment right now just by plugging in
the joysticks
and see how it feels
this one's a little off alignment
ouch
not much just a little
but i mean you could just the way you
plug it in it's still fine
hey that feels pretty good what do you
think
and if you add more weight to that it
looks like uh good fun yeah well
i mean probably
um
so now that i look at this i realize in
the future edition we should probably
mount these a little further over so
that we can put some
yeah
something to sustain the weight even
though with some hot glue in here and it
will become a lot more
exactly so the next addition luckily we
can reuse the same parts
but anyway we wanted to maximize the
space so
okay so this is so far so good
so
now we should look at the buttons
did you bring those buttons with the
leds
i forgot it well well okay let's look at
this i knew let's look at the display
i knew there was something
so i brought um
i do have a
[Music]
four connector that i did cut correctly
before
which are you going to do
within
the board or for with the we have to
flip or flip the screen
i don't know if the draw even allows to
the driver does allow us to flip 180
degrees
so that was what you were suggesting
last time you thought we saved space
maybe on the board
yes we do that is true
and also it gives it a little different
angle of inclination you were suggesting
oops
basically to make it a little easier for
us to see
just by having a slightly different
angle
which is just the same exact thing just
bending it a little differently since i
mean this has to be disassembled for
transport but that's easy to do right
now yeah i have anything so
okay that seems
like a good plan so far
so let's see
so this is 36
pins minus 32
on each side
so 16 on this side and 16 on this side
it looks a little off only because
there's an extra edge on here
and let's just put it on to make sure
that that's true
yeah that looks right
okay
so
so we said
we were going to bend it back the other
way
a little bit not too much
wait i did it the wrong way why but you
can turn it
luckily yes
because we wanted to have it
i know you were right you were right
absolutely right okay
yeah it should go and we
and and it will
yeah that way it's angled
towards us slightly
you know that's going to be hard to
solve that then
probably at that angle
the other one it's flat
that's not it's a little flat anyway if
you leave it like that then we have let
me have a look yeah okay see if it goes
we like that then we have this kind of
inclination the 45 degrees angle which
makes it ergonomic as long as it's even
across this way otherwise it's tilted a
little more but we can bend it later
maybe a little bit there is some room
for it i guess it's needed yeah okay
let's that sounds good i i will probably
that sounds good so i think by his way
we can
yes exactly we could take off the pieces
too and
use the sponge as our
guide as well
let's see how it goes
oops
increasing temperature
it heats up pretty quick
let's see if it's not too but i think we
have some
room for
change as needed
looks oh that looks pretty solid
and that's like
very pro
customized controllers
this one we may have to bend it over a
little more just because it's
you can see it's got a little yeah it
goes but we can you could probably just
bend it like i don't know if you can let
me have a look
this one is more tight than this one
for example i can maybe if you push it
in
instead of pulling it but i don't want
to
let's just not mess with it we learned
something about getting it aligned
anyway
so this is pretty good so we can
actually test this right now
the way we can test it is i have the
cables would you like ah yeah you are
right we can but we can also um
let's see if i have
if i have a nail on one end would you
like to try with wire wrap or oh well i
just wanted to see if the display was
still working we can have
if we killed it yet
i could just use these jumpers
let's see okay i know what you mean yes
i have um if i have like a i think it's
uh
what's the output where's the pens of
the display
i guess i just need
um we can even use the raspberry pi we
just used
actually if we wanted to right
because we can just we need um you need
maybe i don't even need to flash
anything i just need the right i have
quite some cables oh you've got plenty
of dupont cables yes yes yes you do it's
uh male and female exactly so let's just
use i don't know these four okay they
seem likely
and so if we plug in the same
i guess we'll make the power
bro
the red one
rather than brown
unplug those
and then let's make the
data
i forgot which one is which
actually i usually you know the sda
like you know the orange one it's the s
is
i know this is spi or
and yeah they don't remember which order
they're in but i can look at this and
see that the brown one here is
it's right
the brown one is data so it's data and
then clock
hold on well you were saying that brown
was the negative
not on this right here okay sorry sorry
so data is this brown
so it's data and clock so if we make
let's say the data yellow
it's is slipping in there
doesn't want to go in there a pen oh
there we go okay
so
tower we have the leftmost is ground
leftmost is ground on
the most well probably you want to
power
rightmost is power
plus
then we say data
and then the clock will be this one i
guess
okay
so now if we just plug it in we should
see something on the
display let's find out
beautiful oh
oh so good
we're missing out on the
yes
no you cannot
and say sorry
kind of hard to see
yeah i know
but at least it is working okay we
didn't destroy anything yet this is
excellent this is excellent we're off to
a fine start
okay let's see what else can we do we
tested that
well i
so i don't know um
how we want to connect them yet but
that's another that's the next thing we
could look at
is what do we want to do about the chip
because for that we said we were going
to use some uh let me find it here
we said we would use some sockets
so we have to solder both the pins
onto this board
and then the
heathers
onto this
if we want to be able to
plug it in like we said
on the bottom like this
that way
we actually still have room for the
wi-fi chip if we want and we still have
room for the buttons
but you were saying originally you
thought you thought we should put it up
here
or down just to access the usb
thing maybe i mean we don't have
anything over here
and this way we still have room for
because we're going to need room for the
esp32 chip if we end up putting it on
this board later
do you have one here
because i have one but it's you know
they're all in one we display a server
we don't want that i have one
is this one we will use no no
i have an
esp8266 but that's not the same exact
pin out
something
but the main thing is just to leave
enough room
not to put it on now
and if we think that this is going to
leave enough space we will solder just
one here i mean on the on the
on this one on the breadboard
because what i thought we were going to
do
maybe not but
is that whoops
ripped the bags
uh
other shell but not the bag itself
does that mean it's a really good bag or
really bad i don't know
whichever
bad bag
let's see
i don't think i have the
i might have the exact size
already broken off in here
no they're a little short
but
but that's okay
um
maybe with this one you can get two i
know they are
same
whoops
one extra well
so
what um we were saying we would do
was that we would put heathers on
so that we could take it on and off but
then you said that made it a lot harder
for us to be able to use the wire wrap
in that case we cannot use the wire wrap
but then it's just a point of soldering
so it depends how you would like to do
it let's see you're saying it won't be
hard to remove if we really want to
in this case if we just solder one pin
it will be very easy like on each side
yeah i mean the top pins we have to
solder but the bottom pin yeah the
bottom just one okay i'm willing to try
it
because
trying things is what this is all about
right
having fun yes
waiting for new parts as we hopefully
don't destroy the existing parts
okay
so the main thing is to make sure we put
it going the right direction
all right
so now we should be able to solder this
i would put it on the breadboard maybe
or if you have a breadboard which will
be the real place i do
that is a good place
you're absolutely right
i have one
maybe
i heard a minute ago here we go
i just want to take off this other chip
mpu604d
i just have like a lot of these around
because it doesn't have to be in there
very it doesn't have to like be set in
there it just needs to be sitting there
right
basically i don't know this format if
it's because i saw that they were going
like that converging
too much that's true in my taste
yeah with the grape maybe that's not the
right
holes yeah i have
there we go yeah it looks good yes yes
yeah i just didn't have it in there
quite correctly
i think that's going to be the easiest
thought we would like to see it let's
push it all the way out
right where's the solder
wake up
wake up little soldering iron
work to do
yeah that's actually pretty nice
we need a fan to remove the magic smoke
no it's not good to breathe this
i swear i didn't inhale
you know after living in big cities
for so many years if this is the worst
thing i inhale
i'm probably okay
i probably should have looked to my cats
it's aligned it's like up too late it
better be aligned if not well we've
already soldered it all in yeah
so let's get the other side
this is a really cool little signing
iron
i'm totally amazed at how cool this is
okay almost there
just a couple more
this saw there doesn't have lead in it
that's why it's not that good
lead solder
that's the best on there i mean it's the
worst saw there but it's also the best
on there
i had
the last bit of my supply of
vintage 80s radio shack
and i'm pretty sure
that
it's all gone now
all right
so
take a look see what you think
oh
yeah but i think
we can even look at the
micro view
we can focus it you can see if it looks
good to you out there in our studio
audience
looking pretty shiny
okay
cool all right so now
let's go back to what you were just
saying which is if we just tuck it into
one place
just one
and we should go how far over from
do we want to be
uh maybe one more one more this way yes
close to the
like so
although it's not strictly necessary if
you think there is a lot more mess
within the board we can but probably
it's better
to leave some room
you know i'm i think that's a good plan
let's take off the display
we usually
solder only the ground pin yes that's a
very good idea
which is the second
so it's pin b 27
hit
b27
oh whoops oh i see it doesn't quite fit
if we do it like this though we'll be
fine
okay you want to do the honors or show
off well
no no which one is b27 b27
i i see it i see it
i think i can get it yeah yeah
if i could get all of the
whatever it is all of the alien
infection
i guess we're the alien infection in
this case
so b
second row 27 that would be this pin
so i'm going to talk it's hot enough
go in there
okay i think that's it
if i lift it up and it doesn't fall off
it worked
hey
okay
all right
we have now succeeded apparently
in attaching the one pin so
i guess if we want to prove that this at
least is mostly working right now
we could wire wrap the
i square c pins only
flash this with something and then see
the display work and we've proven that
part of it right good idea
okay do we actually need the
soldering iron
or should we turn it off i think we
don't need it right now for the next
few bits so let's
actually unplug it
it's still going to be really hot so we
have to wait a bit for it to cool off
so i'm going to
this is this is okay
i'm going to put it over here to cool
off a bit cooling off period for the
soldering iron
so shall we go with the i will prepare
some cable four cables here
okay yes let's say i remove this one
because i think they are a bit broken
we can move this out of the way because
we're not going to use this anymore
we're actually going right for the real
display oh this is so cool
hopefully we're not going to need this
i can put the other way
and then keep moving a few of these
extra cables out of here
because you don't need any extra less
it's kind of like you know when you're a
chef and you clean up as you go
yeah right
you've never seen me cook there's stuff
everywhere in the kitchen
no no i'm not that bad
nor am i that good
so um
what is the display this is one right
yes
so let's say grow
so it's going to be um
sorry this is positive right the second
one from the left that is correct okay
so it's seven well seven i go
by heart i don't mind
let's see what comes up
too much but it's look
oh cool looks beautiful yeah i know oh
that's very solid
also i usually cut like uh
that long
maybe that one was too much
you have to insert it in
my it's kind of like a needle and thread
yeah exactly
but yourself to stick it through the eye
of the needle more or less yeah it's
difficult because my hands are shaking
well that's why we don't perform real
surgery on real like anything exactly
on poor robots
i know they don't complain much
they're saving it for the right time
let's see
would you like to try one and so
same deal that we said that the ground
is the furthest okay yes that looks good
so without
making a lot of pressure we just live
with the weight of the tool
and it should
just neatly come up curl around oh
that's really cool neat that's very neat
like literally neat both in the sense of
very cool and also very clean
uh
then we use the what was the oranges for
the data no
um well it doesn't matter it doesn't
really matter now but let's just say
yeah to stay consistent
it would be easier
yes okay that seems like a good plan
[Music]
okay
also it goes all the way through on the
outside so yeah it's very much like a
needle it's it is it is
and that was the data
it was the outmost on the right the
right it's yes that is the furthest one
like that
and that's and now the yellow one
the yellow will be the clock
okay
and
you just turn it until it uses up all of
the amount that you put through
basically yeah it doesn't really matter
but i mean you see it's kind of
consistent and it's a good connection
now we have to be careful not to
uh i i i usually then
measure properly but this time i we did
it like you know so i guess the question
now though is what do we do about the
ground because on this board we only
have
the one ground pan one thing i do is i
do one binary uh
i i will short circuit one
for example one rail one there's a coin
yeah in this one for example i was
soldering
i remove these
also use a piece of wire and you just
and solder it at each little tops and do
something like that so that the ground
it's
you don't have to mess anything instead
of just laying the bead of solder
that's probably smarter because that way
well so it's the second pin here which
is
the one we soldered before remember
so if we just put a little run over here
you can use this one for example and you
can make a rain
or i could use one of these broken pins
from before because well these one is
actually this is better it's cleaner in
my opinion okay
that seems good i like it
because it's the one that's what we're
saying is we're going to basically
short a fuel home in this direction
right
whoops yeah you can use that same rain
like this
not that far but like maybe maybe
another four pins
that should be probably enough yeah
or maybe even all the way to 22.
do we have another ground
not on that
that's the reason why uh we're doing
this because if they have a second
ground pin we would just use that
but since it doesn't
it just seems like that's going to be
the which was the piece that oh this was
the piece
this is just as an example
yeah we can that's because if you look
we can
here
[Music]
as well if you
see in the past what i've usually done
is just lay solid beads across
but it's fine i mean but the thing is
this seems like it might be better
because it's less likely and you just
soldered one end the other end and then
all the rest comes
easy
because you don't even need but how do
you wrap to that then no you don't wrap
it in here but you can but how do you
well the question is how do you attach
the ground
this wire to that well depend okay this
one we can go straight on to it we can
wire wrap some other stuff
on top of this one for example depends
how many grounds
i i told you i was mixing
uh
wire wrapping with uh
some soldering as well just because what
it makes me think
just from
is
what we could do
since because we want to be able to wire
wrap on this side of the board
so what we could do is we could just
put in this is too far we need one
that's only like four
let's see if i have another one there we
go this is perfect
what we could do
is since we want these to be able to
wire wrap to
and we want to connect to this we could
now we have the
pins to connect to
but you have to go from
here to here
all right so do not
no i think this will complicate things a
little bit if we just go a small rail
solder it and then you forget about i
mean more than this for example like
this okay
even that would do because this is the
ground but you're not going to touch
that normally and if you knee the ground
on the top of the board for some reason
that would be that would be nice and
this way we can just
but they're not connected to each other
so we still have to do the bead of
solder all the way along but this way
it's easier because it's got any pins to
attach to the idea of the buy of the
rail with the ground is just because you
know
everything is going there
well we have about everything one two
three
and then
the ones for the buttons so we have at
least four
yeah right and we have here
those four pins plus the original one
so we could it seems like that but maybe
better to have five
since we're doing this
i mean is this a bad idea or is this a
good idea no i think you send it in here
just because we're not we're not going
to fabricate anything specific this is
just we're only going to work with
you know
all right we did it
how do we do this
on this side are these seeks of
where do we go on the other side
we did it on this side
there is one more hole
if we think that
because you always need another ground
right now we have six pins we have the
original pin i remember the one and then
these five we can pick one here by wrap
it onto the same
so it's just this way you have a good
ground on both sides
so and we just have to
lay across
one thing we can do
is
i don't know but
maybe this one can go like that
this one wire up to here
and you're done
we can
i mean if you can put this one
let's do one thing let's
wire up
this the ground to this one and then we
do the this binary you will instead of
turning it here to it somewhere else
that's less yeah we did in the way in
line with the ground
what do you think
it's hard to complain about that because
it makes it more out of the way
[Music]
oh
[Music]
