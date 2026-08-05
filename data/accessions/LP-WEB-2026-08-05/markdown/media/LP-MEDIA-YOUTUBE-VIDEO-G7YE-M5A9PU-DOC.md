---
document_id: "LP-MEDIA-YOUTUBE-VIDEO-G7YE-M5A9PU-DOC"
source_id: "LP-MEDIA-YOUTUBE-VIDEO-G7YE-M5A9PU"
title: "S2_02_DEADPROGRAM@LA PIPA"
language: "en"
document_type: "youtube_video"
origin_uri: "https://www.youtube.com/watch?v=G7YE-m5a9pU"
verification_status: "provider_metadata_captured"
access_scope: "public"
content_sha256: "beee755d6163c2450480751f283ec4682cd1c4f48a5d9975d9f4888a15ba21f1"
---

# S2_02_DEADPROGRAM@LA PIPA

Archive source LP-MEDIA-YOUTUBE-VIDEO-G7YE-M5A9PU. S2_02_DEADPROGRAM@LA PIPA.

YOUTUBE video accession record.

Canonical provider URL: https://www.youtube.com/watch?v=G7YE-m5a9pU

Provider identifier: G7YE-m5a9pU

Creator/channel: LA PIPA IS LA PIPA

Ron Evans , Alex LAwton, Bedrock

Provider metadata captured successfully.

Transcript (en-orig; automatic_captions):

Kind: captions
Language: en
[Music]
is
[Music]
hello
fellow humans cyborgs robots and
extraterrestrials it is i
your friend dead program
and of course
my wonderful companion gopherbot
coming to you live
from la pipa industrious espana
and we are here today
to talk about all sorts of fun things in
the worlds of technology life the
universe and everything else i believe
that is all inclusive
all right
so
let's go to the news first of all the
biggest news is i have had my first
vaccine dose i may have told you that
last week so just a few more weeks and i
will be ready to go out in a mask still
but it's all right
anyway let's talk about what's going on
in the world of technology this week has
actually been
um pretty awesome
my friends over at google
have been very very busy
and they've created a really cool new
project called open source insights
so open source insights is sort of a
advanced version of a project done by
called libraries.io
which was designed to basically track
the dependencies
excuse me
track all the dependencies of any given
software project that you're using so
you could track things like licensing
issues or security problems so they've
been working on this project for a while
and now the story can be told it lets
you take and it supports several
different package managers so here we
can play with it for a real quick second
open source insights at deps dot dev
so it supports packages from npm if
you're using node go modules if you're
using the awesome language go
a couple of other package cargo if
you're a rust station
so um i was playing with this before
and we could enter in a package for
example we could enter in
go cv
and yes it pops up here on the list
and so it comes up with
information about the go cv package
for example what dependencies it has
which it has very few external
dependencies other than
opencv itself
so we can take a look and it is very
small
shows that we're using go
from pathcal decl and also the m jpeg
package and those are actually used in
the testing and one of the demos
respectively so we clicked on that
package then we could go and take a look
and see its dependencies
and we could also see
who depends on go cv
so it turns out there are a lot of
packages that are using gocv in order to
get their work done so many apparently
that due to the large number of
dependents we only show a sample in the
list below i was looking at some of
these i'm like invisibility cloak
what is that
now this looks interesting
so this person apparently used go cv to
make a
an invisibility cloak and
only dependency was go cv so very
powerful stuff very cool check it out at
depps.dev
so also
from our friends at google on the go
team
this week
they have finally merged into the dev
branch
the new fuzzing capability whoo little
fuzzy
what is that
like why do i mean i'm fuzzy but what
about you
all right
what is fuzzing so fuzzing is actually
when you're testing software and you
start just putting junk trying things
that shouldn't work garbage keyboard
input plugging and unplugging cables
just generally doing things you
shouldn't do with the intention of
course of causing the software to break
and as a result possibly using that to
exploit for
unsavory purposes
you don't want that so turns out that
it's one of the things that we can try
to test for is by doing you know random
crazy variations during tests we can
find problems before they occur and so
this is actually getting merged into go
as part of the normal test routines that
you'll be able to use this
as part of an additional testing
capability the same way as we are able
to do benchmarks and
profiling as part of our tests so very
cool stuff coming from the team
so in the world of
other awesome software
our friends over at jetbrains a very
cool company um been using their tools
for many many years so go land is a not
open source editor it's a product
commercial product but it has a lot of
capabilities to plug into it
so
they got a couple of their interns to
work on and they now have recently
released
a tiny go plug-in for goland so i wanted
to show this to you but i couldn't find
my license key for golan that was kind
of embarrassing
hopefully i'll find it next week
and i can actually show you some of this
but you can install this plug-in
and it gives you one of the main
features that people have been clamoring
for
which is auto completion and auto
imports
for things like the machine package
so it'll just pop right up with a list
of your different pins and leds and
these all these mysterious options that
some of which are kind of hard to
remember so very cool stuff coming from
our friends over at jetbrains
and then
speaking of friends over at other
companies
um next week next thursday to be precise
um at 1 30 p.m
eastern time
and that would be 7 30 p.m central
european time i am going to do an
interview on the hello world program put
out by microsoft
thanks to my friend aaron who is a
developer evangelist over there go
fanatic and generally awesome human
being
i will be doing an interview to talk
about tiny go so
it's going to be really fun i'm looking
forward to it greatly um really cool
program actually i meant to mention this
in a previous show but it turns out they
did a whole show
about go cv
back in april and i didn't even know
that was how awesome is that so
definitely we'll check that out
and then um
so let's take the mask and put that back
on
because i think it's time to bring my
friend lorenzo out
so we were working last week on making a
bunch of changes
to oop we're on camera there we go
hello hey how you doing i'm fine thank
you all right
so
last week we made some progress we found
a few problems
and i saw that you reported
the
issue with flashing
on windows and i saw there was a little
bit of communication hopefully we can
test that out today yes we can have a
look let me bring my stuff here
and we can ah
so what we're doing
if you haven't seen all the previous
episodes is
we are working on going through the
uh gophercon
um
where is it there we go
we're going through the workshop content
that was used at gophercon 2019 which
was one of the last live events
and
using the arduino
nano 33 iot board
which is a cool microcontroller with a
built-in wi-fi chip
there was a series of activities to
learn
how to program in tiny go
so we've been going through each of the
different steps and we got to i think
step five
um we did or step four
i guess which one did we do last time
step four yeah we got on step five okay
great we're on step five
so let's jump over to the table view
here so we can see
this is the board yes let me
clean up this mess a little bit because
i think some cable might have come out
but we have a
look let's see if it works so this is
the microcontroller itself
this on
oh something's working that was the uh
that was the program from last week when
you press the touch sensor exactly and
also the two led switching on and off
alternatively
while pressing the button it's actually
working amazing yeah it still works
that's that's a good sign absolutely
that's a good sign
so um
i know last week you had
we got we were getting sick of the same
problem
which was
it would jump over to your computer yes
the when you were trying to use the tiny
go flash command
that it was giving this kind of nasty
error message about
some extra parameter yes we can
run it again to see what happens
and let's see so
but i did notice that
the
oops
so
the um suggested
solution was to change the
location of your temporary directory
because the
problem apparently has to do with your
name
is a first name and a last name
with a space and apparently that was
something we did not take into account
when we were working on this was that
there could be a space and a directory
name
and actually
um there is a
draft pull request to fix that problem
completely
but as a
temp as a shorter term solution so
you've got i see you created the
tinygo temp directory yes but i think we
need to install something over here i
guess i think what you need to do is you
need to use a set command okay and if we
go to the
um
tiny go repository on github yes i'll
have it here
then
we can maybe take a look at
takasagosan's comment
of how to try to fix this
so
um what he was suggesting in this
was to
use the set command to set the
tmp environmental variable in windows
to this
other directory so that it would
hopefully
um
yeah so that should work hopefully
so i guess we'll be able to find out if
we can just do a flash normally
without having to um
let's
change to first build it
and then separately flash it with the
bossack command let's say step five
directly right well step four was the
last one you had working right yes so
let's just try to reflash step four okay
good idea
i think we need to use oh you need to
change directories to the directory with
the code okay okay you're right
um let me
from here it's
i think it's users
um so the auto completion knows because
it escapes it with quotes yeah but
tarnego was not so clever you had to
include it
um
tiny i think it's time to go
yeah
gopher
and then it would be in the sensors
arduino
subdirectory okay
perfect here we are okay
so yeah if you up arrow
endlessly
and hopefully this will work let's find
out
is building something
it worked yep
yes
fantastic
you had the dash x and that's why i gave
you the verbose version okay so is it
actually running though is the question
yeah still amazing
do we need to reset it
but i think if it flushed it
we are safe no we don't have to do that
anymore okay
so that was the whole process of double
tapping and going to the other bossac
program that was something we had worked
on quite extensively to make it better
for windows users
so when you first ran into that problem
i was very unpleasantly surprised
because we had spent a lot of time and i
actually worked in
workshops where people with windows were
using it
so it didn't occur to me that it would
be something as simple as the directory
naming
i was looking for some complicated
technical reason why it would stop
working
and of course it was much simpler than
that
anyway though um
we have a fix that is going to hopefully
merge for the next release of tiny go
which will basically
automatically escape
directories and paths on windows
so that you don't have to do anything
about this it'll just it should just
work out of the box
i guess when the next release comes out
hopefully in the next week or so
um we don't have an exact date but
hopefully we'll be able to uh so i will
request to close the
well
only when we the way we work is um
what we normally do
is when we have an issue
that we have
entered
if that issue
is not something specific to the current
release only in other words it's like a
problem that's been around for a while
then what we do is
we would take
and we would instead of just closing it
because other people may have the same
problem before the new release comes out
instead we just label it
that it's next release
and that way
when the next release comes out then we
can close it okay that's why if you take
a look at our releases you'll see
whenever we have a release we have a
whole bunch of issues that get closed
because i go and i use that label to
find them all and close them i could
write a script but it's very satisfying
to click on them
okay
so hopefully we'll be able to um to fix
that problem
so
i did know this that there were a few of
the other programs
that also needed to be updated
so if you were to go
and
do a git pull
you may want to change directories uh to
the root i'm not sure if that's if that
matters
i don't know either
so too tiny go right yeah well just the
root of the gophercon 2019 directory so
that's that'll do it
so
you need to get the latest updates that
i pushed to the repository late last
night so if you do a git pull
dash dash rebase
so it doesn't add a merge commit space
origin
space master
one of my almost favorite commands and
then hit enter
it should
pull down all of the latest changes
so now we should be able to compile
steps uh
five
and beyond because i've made some
changes
so if you want to go and bring up the
web page
with the instructions
for the
gophercon-2019 website
on github
probably i will rename this repo when
we're done going through all the rest of
them to something a little more generic
okay because this isn't just about
gophercon 2019 anymore this is about the
whole universe
oops
answers arduino here exactly
no step
so we were on step
five
i cannot see very well with my fog on
the lenses okay
step five here we are
yes you need a truffle so we are going
to add basically a dial a potentiometer
to
the
current installation actually i did it
because it's very similar to all the
other except
so power
positing and negative still the same in
the two power supply binaries in the
in the sockets and the signal this time
goes to an analog pin
which is a0
and it's located
it's on the lower left most
and one two three fourth pin
a0 and it's connected i guess i cannot
see it very well here but i think it's
down there
can you yeah it's the fourth right
is this yellow one
one two three four yes it looks like a
fourth perfect we can
so it happens to be the fourth
yeah oh wait was it the date or the pin
number
just so happens in all of the craziness
i forgot myself push the button see what
happens
okay so do you want to bring up the code
yes
from
the repo directly and then we flash it
okay
step five step
five and main
oops
and here we have it so it's a little
small maybe we can maybe you can uh
i just hit um what is it
shift uh control plus oh well you're
you're way ahead of me man
okay so here we have it all right so
it's it's basically
as you've already noticed like all the
other programs we just take the code we
have usually we just keep adding to it
we might do a little refactoring as we
go but generally it's just keeps adding
capabilities until at the end it's
the full system you know doing all of
its things
so
we start out with a package main
same as before
we're importing
the machine package from tiny go with
the hardware abstraction layer
and then the time package which is just
a normal go standard library time and
then the
tiny go drivers pack buzzer
which is the driver that knows how to
control
you know a really simple speaker to make
it bleep and blop you know not play full
music but we'll get to that in the
future
driver
and then we've got this is new now we've
gotten something new
so
we can declare variables
in go
a couple of different ways
one is if we use a var
section
for short for variable and you could say
var in a you know in a function itself
you could say var and then the name of
it that's what happens when you say
colon equals
okay colon equals declares it
and assigns it
in a single operation
and we don't have to usually specify
what is the type
because go is a compiler
strongly typed compiler and so it uses
type inference to look at the right-hand
side and say
what is this because i don't need to
have a var
and then declare the type if i can guess
what type it is
but in this case
so we have var and then the first one we
say is pwm
which is our pulse width modulation
which just to
for those who don't know what pwm
means pwm
pulse width modulation
is a way of
turning a signal on and off very quickly
in order to make it seem
like
it's an analog signal from a digital one
so
if we want to
only be a light turn a light on but only
a half the strength like a dimmer if we
have it on half the time and off half of
the time
then it will appear to only be at half
of the strength like so we could use
this to control the brightness of leds
or the speed of motors you know
different sorts of things so it's very
useful capability hence
pwm
and so
in this program we're saying that the
pwm
is equal to
machine
dot tcc 0.
so what does that mean so
the machine package
is our hardware abstraction layer so it
says this microcontroller has all these
different capabilities
and so
tcc
0 is one of the timers
so on the microcontroller
you can have a something that happens
automatically at some periodic interval
like if we wanted to
have something happen very quickly like
the oscillation of a speaker to turn it
on and off very quickly
like we would could use this timer to do
that and so
tiny goes pulse width modulation feature
uses timers
in order to turn things on and off very
quickly because that's what they're very
good at
so we have to specify
which timer to use
since
many chips have more than one timer
and we can use them to control many
things all at the same time many
different leds or many different motors
or servos
so first we declare
which
pulse width modulation
timer
fell asleep
i talked too long that's how you know
so then this next line says green
is equal to machine dot t3 or d3 sorry
so that's just the pin
exactly the digital pin number three
number three
that the green led is plugged into
and then last we say channel a
is an unsigned integer
of size eight
so it's just a single byte
so
channels
are what a pulse width modulation
interface can have more than one channel
that means we can use a single timer to
control multiple servos if we want to
interesting and so in this case we're
just going to control a single channel
which is going to be the green led
so let's keep scrolling down
so we can see the rest of the program
so
now we say machine
dot init
adc which is telling tinygo to
initialize all of the analog to digital
converters
and then we have a line that says
in that pwm
but that's now the machine package
that's just a separate function
that's because
instead of
adding all the
whatever eight lines of code to
initialize the pwm right here instead
let's just call a function so that we
can separate that from the rest of the
code okay so if we scroll down
a little bit we can go to any
it's a phone it's a func yeah and here
we have it exactly
oops sorry so let's see what it does
so the first thing it does is it calls
pdo pwm dot configure
and it's passing it
a machine dot pwm config structure but
with nothing in it so it's just the
default structure okay so this is saying
we're going to try to
configure the pwm
and we're going to return an error
and then the next line
we're going to say if that error if
there is an error is not equal to nil
in go
an error is actually a type
and so
if we return
nil type we can check that and say if
it's not if it's not equal to nil that
means there was some error actually
returned
then we're going to print a message that
we failed to configure the pwm and
return okay
okay and if it's all good then we
continue on okay channel a
air again
so this time
pwm channel
and
green
what was green i think we configured
above
yeah so
so now this is using
um of capability of go which is very
similar to python
it's that we can have multiple
assignment yes that
we're going to assign to the two
variables channel a and air
what's returned by the function
pwm.channel because that returns two
values okay and similar to python
the first value returned will be in the
leftmost yes variable and so on so it
keeps them in order
and then
we're going to say pwm.channel
is how we'd say
this pwm we need to obtain a new channel
for this particular pin the green pen so
we're saying this pwm is going to
control this green pin with a new
channel and it returns the channel
number okay which we're putting into
channel a
so if we had multiple
leds that we wanted to control
separately
we would just call pwm.channel
each for each of them and declare a
channel a channel b channel c
for however many things we wanted to
control okay okay yes i forgot the green
was associated to the digital connected
to the
uh
led exactly to the pin so it's like a
one
i should have a diagram of this i'll
make one one
pwm can control multiple pins yeah here
we have it so exactly okay so you can
configure as much as you
wish on that well as many as as can be
supported by the timer on the chip
you're trying to use okay
so that initializes the pwm and now
we're ready to go
so then we have the same code as what we
had in the previous step
we declare the blue
led on pen d12
configure it as an output
okay the button
on pin the 11
as an input
the touch sensor yes
everything was configured
exactly
exactly the same the buzzer same and the
difference it's here i guess where we
are going to
configure the dial
exactly it's machine a0 exactly calling
the adc
analog to digital converter machine
library exactly so so it's the same
pattern you see
that we're configuring the adc pin the
same as the way we're configuring you
know the normal gpio pins we always have
a configure
method and then we pass it some type of
config struct
in this case
it's just the empty struct because it's
the default values whatever they are
default okay
so now enter the loop
exactly entering the loop
and we are getting we are probably
reading the value of the dial exactly so
we get the dot the value of the dial so
dial machine adc get will read the
the value of
what's connected onto the analog pin
exactly pwm set i think here we are
actually configuring the pwm to return
a pwm value from what we what's our
channel a
so this is actually setting
channel a
equal to this value
so if we wanted to turn on the pen at
some particular
duty
which
if we remember our duty cycle is how
much of the time is it on
versus how much it's off
so we want to set the duty cycle
and what duty cycle are we setting
so we have
pwm top
is what's the top speed
in terms of oscillations
you know how many cycles
per second
can this pwm pin support what's the
maximum that depends on the arduino in
our case exactly that will be different
for different pins
or different uh pwms and timers so we
have to have a way to return that so
it's always generic and then we're going
to multiply that times
the dial value which is
how much
it's turned from 0 to
fff
which is the highest value for an analog
to digital converter returned
and we're going to divide that by the
max value
so in other words if it's turned all the
way down
we're going to multiply the top times 0
which will be equal to 0 so it turns it
all the way off and if we turn it all
the way up to max
it's going to return the highest value
which is hex ffff
divided by hex fff ff
well four f's
is one so the top times one is the max
value so if we turn it all the way up
it'll be at the highest possible value
and if we turn it all the way down so
this is just
a way for us in one line to scale that
value
based on the actual top
that this
particular pwm supports okay that way if
we're on a faster chip that could be a
higher value but it'll still do what you
expect which is when you turn it all the
way down it's at zero percent and turn
it all the way up it's a hundred percent
and then from there it's the same code
as before
yeah switch on and off depends on buzzer
brother time sleep okay so i think
that's it so
so let's see what happens
let me see if i can get the i have to
move on to the
sensor exactly
arduino
and
and i guess we can do step five um yeah
that should work
we'll find out
good we have the
out the object
it's
flashing all right something happened
but nothing
let ah because probably we have it at
minimum let's see if it's
no
do we have the other led plugged in yes
it was working before but not now i only
see two leds
did we only use two i thought we had a
third one
no it's it's two if i'm not wrong step
five was just
maybe yeah maybe we're controlling the
green led that's right yeah we're
controlling the green one but
probably we have to push the button
and we try to here here we have the try
with the button push it i don't think
that should matter oh no okay
nothing
probably
as if the connections are still
good
or otherwise we can switch to step four
to see if it's a connectivity problem
with this led
because it was working before
we didn't touch it
yeah everything looks so this time
so do we have it plugged in maybe it's
on the wrong
[Music]
it looks like the pins are the same as
the previous step i guess yeah they
should be
and then
[Music]
it is a rather angle sensor not a ah no
no that's that's good okay no i didn't
um there's not a rotary encoder in there
because yeah that would be very
confusing to people that looks the same
but it operates completely differently
so the thing is because this is like we
have a zero
value
and probably it's not getting the power
so one thing we can do
is
we could put in some logging code to our
serial port and see if anything's coming
out
so we go back to our program okay well
we need to i know okay we need to edit
the we'll have to edit the program and
this time i know the command so it's not
and i have to get into the directories
it is step
five i guess
and no
step
ah no sorry
i think it's um notepad
yeah that's the thing
all right so
if we go down to our part of the code
where we are
setting that value
right after that we could say print line
and before or
like after the pwm
and so that no it's not inside the f so
i'm sorry so right after the pwm value
if we
say print line
print el ln and then we just say dial
value
it's like this now no
ah sorry
let's just print the value we don't need
to okay
the value is dialed sorry you're right
no worries
dial value and then close paren hit an
enter just so we have an extra line to
find this later okay and that's it so
you should be able to save the file
and then we should be able to compile it
again exactly
i guess we'll find out
if you want to get rid of the dash x
that way it's not quite so verbose
because
because now that we know it's actually
working
it'll still give us output but just not
the whole command
okay
so now we have to open up a terminal and
so you can use putty
or you can use the arduino terminal i
don't have an either you have to have
some mechanism for opening
a serial terminal so yeah party is a
good one let's download it then because
i don't have it installed
shame
oh well you're going to need it for this
so let's
let's download it real quick
hey but they don't
sorry
i don't know if that's the uh where's
the legit place to download it ah you're
right i don't know um but i think soft
tonic is
let me see i'm not sure
i think it's this one
if i'm not wrong
i i don't actually know
i'm very suspicious about downloading
things from random sites you are right
um
[Music]
for windows operating system i think i'm
surprised um that windows still doesn't
have a terminal program built in i don't
remember to be honest it's uh while i'm
not using ssh something no
wait there's a new windows terminal
microsoft terminal
ah
is it too serial hold on i mean let me
make sure that it's
serial
port let me just make sure it does what
you think
yep windows terminal
okay
it can't have a worse ui than putty
yep this is it
it's the same as the one we
but from here is like
well no you don't want powershell you're
in powershell not that's not what you
wanted ah okay
and then so it's
there's an application called terminal
windows terminal i mean
if you type windows terminal it's this
one let me see
probably it's redirecting us to
powershell
well i don't know the answer
um let me see how it looks like let's
see it looks like you can say
[Music]
oh from the terminal probably you have
to run
mini
from let's see
no you have to install it first okay
so you can get it on your wsl1 distro
apparently
if you type the following commands
wsl oh okay let me download it then
sorry again i don't know if this is
going to work
but sorry
so it'd be wsl
space
dash d for download i guess
space
kali dash linux
k-a-l-i dash linux
space mini-com
i've never tried this
nope okay so no
all right so much for scott hanselman's
instructions we probably skipped several
blog posts worth of instructions before
that
um okay let me
well back to where the let's see we want
a serial connection to the
yeah we just need to see the serial
output so we can see what values are
coming back from the
analog to see if it's even working
so let's see
so real
party download
um
stack exchange which repeatable site
should i download putty from
the official site is that chiark
greenend.org dot uk
no it's not that first one
not that second one
no no no keep going it's i swear it's
going to be in this one hey chuck that
one no okay like fifth down on the list
is the legit one
don't be scared
uh that's the one i guess i can go for
this one yes exactly 64-bit
x86
oops oops it's okay you got it twice
yeah this is a good program to have
yeah usually i used to
[Music]
but
it's not the best user interface
i mean at least i found it somewhat
confusing
but i think if you use windows
keyboard shortcuts more frequently
that might have a lot to do with it
okay so
i think it was calm
i don't know which column serial com
well we can have a look
i think it's column 13
we changed the last time remember so
we'll have a look now and and ah that's
what i did
and then your speed should be um
eleven no it's one one
five two zero zero okay um five two zero
zero one one five ah one one five sorry
i forgot about those speeds yeah i know
high speed
okay so now you should be able to say
open
oh yeah and yes
and so
some data is coming through let's see
if we turn this one we should see you
know the reading it does
yeah maximum value and
so yeah it's working but okay led well
there must be an error in my code for
setting the pwm so i guess we can
exit party
now that we know that that's working
okay how do you do that i don't know
i have no idea no it's
okay
okay excellent so let's go back to the
code
sorry oh no
horrible because there's might have some
password over there oh well
nobody saw it
okay
so now if you bring up the program again
let's take a look and see if there's so
yes
i must have done something wrong with
the uh
when i was playing around i didn't
actually have a chance to test it
that might have been helpful
i am doing something wrong with cd
sensor
arduino
and ah okay it's a directory it's not a
program is step 5
and no
no
bad
main
goal
here we have it
so actually
one idea would be um
let's output
the
result of the calculation
and instead of
outputting dial value yes let's copy the
whole pwm top the whole
calculation
and then let's display that that way we
can see
you know whatever it is we
think
do we have the right number of parens it
looks like it
okay looks good
this way
we can maybe take a look and see
[Music]
sorry
[Music]
there we go there we go let's see what
happens
this way we can sort of see
i know you're supposed to use real
debuggers
and but uh you know print line is the
debugger of champions
it's the first debugger the pure
debugger
it's the primordial debugger
i think it's uh actually i guess the
primordial debugger is a single led
flashing
so i guess this is the first the first
debugger to walk erect on two feet
perhaps
if we're going for metaphors
oh yeah we flashed it and see how we
have
let's see the maximum value yeah and the
minimum value
it certainly looks like what 1665
so it's ffff no i guess yeah i mean it
jitters around a bit just because analog
uh yeah adc's tend to do that yeah
that's where uh hysterosis is so
important you know averaging the numbers
so you don't yeah um
i found that that's very useful when
flying drones using analog control
sticks and probably grounding pulling up
pulling down etc
exactly and there's also settings you
can use if you want to use a separate
analog reference voltage
instead of the
just the power that's coming over the
usb but
in any case
certainly seems like it should have been
working but it's obviously not
all right so i guess we should and we
saw it working
moments ago
when it was plugged in for the other
program right because we saw it um
we can reassemble the entire circuit if
you like i can do it for the next i
don't think so i don't think so i think
it's
i think we just have some small thing
wrong
i guess we can close putty okay
because we are getting the channel back
yes
and we are trying to set it to what we
should be the correct value which would
be
the top times
oh thank you
so you know the um
we're selling channel a
equal to that value
which would it would so what is channel
a is
we assigned it in our
init pwm
right
if we scroll down a little bit to just
take a look at that
and we assigned
the
um
see channel and we said that it was the
pen
for
yeah that should have been right green
which is which pen
um
[Music]
d3
yeah i think it was this you know it's
usually
we can count
let's take a look at the map yeah
what is it
i have a feeling it's in the wrong pen
the wrong place
it's very easy to have that happen if
you go to the top where the little
diagram is
oh there we go
it's
indeed
oh yeah i think it's on the other side
of the board up
here now that's
what was the number of the green pin
d3
it's very easy to do this when
everything's on the opposite side of the
board
oh yeah go ahead i don't want to take it
i don't want to take the phone away from
you
[Laughter]
let me find out
so it's the third pin
from the upper left so it's not from the
upper right
no because here we are
it should be
yeah but we can change maybe in the code
rather than unplugging i think that's a
great idea no no but without flashing
probably you are right if it's three
then we move it on three sorry
it's
uh but it's difficult to count that's
the only problem well let's make sure we
don't unplug the wrong pin yeah yes
let's
wiggle it
it's this no no this is the green
uh hold it i know but we have the plug
oh i got it the green no i think let's
go back to the code
that may have been my mistake
so we're saying that we want yeah that's
the wrong one i think that that would be
d3 is a really stupid place to put that
because dope
where was the green pin in the previous
example ah we can have a look but i
think it's 10. i think that's where we
should have left it okay let's go i
think that was my error three
and i think
connect on
d10 yes okay so let's go fix the code
yes because that that was an error on my
part i did not mean for that to be
necessary and we'll flash it again yes
flash dance today
exactly
what a feeling
exactly
[Music]
okay yeah at the end it's much easier to
leave it as it is under flash
and um
but okay now we can
yeah it works we forgot to turn up the
volume
let's see if no doesn't affect anything
else right the beep and so only the led
yeah so let's we we should we can look
at it on the uh yeah let's prove it
measure
[Music]
yes you can it's very dim light it's
very dim that's very deep we're using
most of the power
available already
can we even see it i don't know i don't
think you can see it at night but it's
definitely working it's working please
trust us yeah trust us we're
technologists
it's not like we're doctors
all right well
so i got to fix that and the i almost
got it fixed last night but apparently
three tentered into three
missing seven no good
but
but we fixed what did we get done
we've proven that the temporary file
location makes it possible to just use
the normal flash command
hopefully we'll get that pull request
merged so we can actually test the full
updated version in the development build
next week
and we found an error
in the step 5 with the pin
but otherwise it works exactly as
expected
so and we've got now which interfaces
we've got the gpio in
we have gpio
out
we have
um analog in
and we have pulse width modulation out
we have four different
styles of interface from this one chip
so far
and then next we'll add i square c next
week we'll actually get this display the
dc
the i2c
so yeah see i see you made the driver as
well for the font uh
yes that's right
otherwise if you can't see the words you
know yeah you're beautiful it has to say
you know brian benito or something this
would be a nice topic to develop the
nice fonts for the
there's actually um a surprising number
of fonts and um
since we're talking about it
so
the uh font capabilities in tiny go
are
largely the result of
koneco ninja
daniel esteban
my good friend an awesome human being
resident and spanish human being living
with his family down in the south where
it's very hot
i haven't got to see him in real life
for quite some time
but uh he's a tremendous human being and
an amazing collaborator and contributor
so
he started on this tiny font project um
basically
taking a page from the adafruit style
of drawing the fonts as vectors
and
it's not
too slow at all it works surprisingly
well
so subsequent to that other people
jumped in
and so sago 35
our earthwhile japanese contributor
they went and they created a command
called tiny font gen
so tiny font gen will take it so you can
import i believe any true type file is
it yeah you could take any true type
file and you can compile it
to the go code that we used for tiny
font so if you have a custom font
you can import that and you can use that
we just have some specific ones that we
include
but there's a whole bunch of other ones
that you could use
my personal favorite of all the fonts
is the one that was contributed by
jana rackhill
so she currently works at amazon
was formerly a member of the go team at
google amazing person a real genius and
also very creative artist and very nice
singer musician but uh she decided that
we really need a font well actually
she decided we needed a font in the
world that is all gophers
right like gophers in different
positions positions you could do a
dancing gopher and then
when
uh kaneko ninja saw this
he said we need this as a tiny font
because we need this on a badge and i
actually got the great
um pleasure
to give her
a tiny go badge
which is one of the i forgot i didn't
bring it with me today but it's actually
a wearable smart badge
and it had the font on there so boy was
she stoked it was great she was so it
was so nice to make another person who's
done so much for the community
so happy just with like a few bits
moving around it was awesome
but we'll see that next week we'll play
with that okay
cool man thank you well thank you very
much for coming i really appreciate it a
pleasure like a lot of stuff happening
here yes
so exciting
i know we're soon we're going to be
seeing fonts and
soon we're going to be done with all the
steps and you'll be ready to fly free
little bird out into the world and
hopefully hopefully thank you very much
hopefully some of the bugs are reported
will be fixed by that yeah
cool
friend hugo is here as well with us so
he's also an embedded programmer that
i'm trying to pull into the world of
tinygo
right now he's really involved in python
but uh that's a temporary condition no
but i love python i think python's
amazing
actually
you know but i let go too
anyway um i don't know if if
manuel is here
i don't think he made it back um
i was going to try to do a demo
um apparently we were going to try to do
a demo of our
machine learning system for kyle
identification
but uh i don't think he was successful
was trying like i'm gonna get this demo
working right before the stream
um famous last words
i say stuff like that a lot
i'm gonna get it working right before
the stream
all right well
if he shows up cool uh if not let's jump
into some other cool stuff that we've
got
all right
that was really fun i'm really excited
to get this
tutorial stuff
oh
no worries
all right so um
what were we oh yes
so
a lot of really cool stuff has been
happening in the world of tiny go
excuse me
and um one of the things i wanted to
show
i think two weeks ago actually maybe it
was last week time flies was a pull
request
that was created by sago 35
for adding support
for the fat file system and for
sd cards so i've been really excited
about this let me pull out
um it was really hard okay
it was not like you use sd cards
probably
and you don't think much about them you
just use them they just work
you never think about
like how does it work
why does it work what does it take
how many authors of drivers
so
we have this
pi portal which is a very cool board
from
adafruit awesome company from new york
who does a lot of great things with
hardware and software
so
this is one of the boards that they make
that happens to have an sd card reader
and i happen to have this sd card
so if i go over to my
linux machine
and we'll plug in
hitting the buttons
it's thinking
it's thinking a little too hard
so if i um
go over to my linux machine here and
let's go down to
take a look at my terminal
so if i take the sd card and i just plug
it in to my sd card reader that my
awesome
dell xps 13 developer edition happens to
have
then it mounts that volume and we can
see
that actually
here is that drive and it's got two
files on it
it's got a go.mod file
that's got
in it oh it thinks that's a
different file type
i should have said open with
open with other application
and let's open it with
you know nice something nice and simple
you know like any old text editor will
do
actually be easier to just do this with
a terminal
here we go
so i can just say cat
and then i believe it's under
media
ron
and that's probably the name of it
yep go.mod
and you can see here
this is what's on that sd card
which doesn't have a nicer name than
be21-32f1
apparently but that's what's in that one
file
we can
just do an ls for listing just so we can
see everything that's on there
okay two files on there very good so i'm
going to go and eject it
and that way i can take it out without
damaging any of the data that's on there
which is in the
fat file system
which is the original
file allocation table system used by
ms-dos
apparently back in the day
and somehow is still managed to be
around to be used by other people
um it's sort of the most common like
when you go and you stick in an sd card
and it says do you want to format it so
it can be used by any computer
it's fat32 that's being used
so let's go and plug this in
to the
device
and then we'll go back over to linux
here
so
there's a few different components that
are in use
in order to make this all work
okay one is that we have the tiny go
drivers
repository that's where we have all the
different drivers that are
support sensors and displays and
additionally to that
supporting
sd cards
so in order to
communicate with an sd card it's
actually a spy device a spi
serial peripheral interface
and that is because we need to do very
high speed communication
with this device in order to
read and write files
so
all it's doing though is just reading
and writing bytes from a spy interface
it doesn't know anything about
what are those bytes consisting of
is what is what are they just ones and
zeros no it's an actual file system so a
file system is an organization of
specific bytes
into
generally a couple of different sections
right you'll have some type of section
we can even look at let's actually look
at this
fat file system
because we can probably see a diagram
in wikipedia
that will illustrate my point
so
back in the history eventually we'll
no i want a diagram
let's go back to the pictures
that looks pretty good yeah all right
so
um
this is showing that we have some
different sections
of a disk which is formatted using the
fat file system
and it needs to keep track of
where are the directories
and where are the files in them
and then where are the actual data for
all those files stored and so you end up
with usually
a situation where you have different
blocks of data on the
disk or the sd card
and then you have
separately a list of where all the files
their names and then you might have
more than one block of course as part of
a file
and those blocks don't necessarily have
to be in an order right they could be in
some random sequence just if we opened
the file wrote some data to it closed it
and then at some future time
open that file again and added some data
to it it's very likely that we'll be
occupying more than one block so we have
to have a list of all the blocks in
order to retrieve this data
and on the disk
you end up with
your
partition which is a
section of the bytes which corresponds
to what we would think of as a disk when
we insert it
the root of that and then all of the
actual files and directories that are on
that disk
so there's quite a lot to it
so luckily
we have another tiny go project called
tiny fs
and tony fs
is as you might guess from the name it
is an implementation of file systems
that are able to be used within tinygo
and we actually have two different file
systems currently supported
the first one is fat
that we were just discussing
which is like the old school original
and then the other one
is a
file system called little fs
so little fs
is a file system that is actually
meant specifically for use on
microcontrollers and other devices which
are very likely to have power failures
and the other types of things that tend
to impact small devices um more than
they do
desktop computers or so it's very
resilient for power loss
and then also
it's got something called dynamic wear
leveling
so when you're reading and writing to
something which is not a disc
which is actually
a medium like an sd card
or an ssd solid state drive
if you just read and write data on the
same section of the disk over and over
you'll wear it out
they only have so many reads and writes
that are able to be supported by the
actual physical atoms themselves
so little fs is a file system that's
designed to accommodate that
but it's very inconvenient usually to
use from normal desktop operating
systems so we'll just stick to
fat
all right
so
what we need to do
in order to make this work
is if we go over to the tiny go drivers
repository or directory i should say
um we have
uh let's see tinygo well actually let's
look at the program just a part of it
because it's actually a very long
program
excuse me
so
if we look under sd card
demos
it's in there somewhere
we'll see that we have
a demo called
tiny fs
which is
using the f sd card
with tiny fs
and that demo is a console program
that what it does is it actually
launches a
very simple console program that we can
access from our serial port on our
computer and we can
read and write data on the sd card on
the connected microcontroller
okay what does that mean so if we go and
we take a look we can see we have our
microcontroller
and we will go and we will plug it in
we'll go and we'll plug it in
to
our pi portal
and then we'll go and we'll flash
the program
um let's make sure that we have the
right versions
yep it's in there okay
so if we go tiny go
flash
and our target
is the pi portal
and we're going to flash the examples
sd card
tiny fs
then
it will
flash our program
and so now it should be running
if we go over to
a terminal
we launch the terminal and we see that
it says
spy configured reading flash info
okay so if i go
and i say
actually let's go help
no there's no help
i thought there was help
hmm
well i thought let's go and look and see
what commands are are supported i
thought it had help
maybe that was the other example
oh here we go all right so we have a
different list of commands that we can
type in
and so i guess the first one is
um
wait this is the tiny fs directory not
the
drivers
there we go
and the console
there we go all right here's the command
supported
by the
drivers repositories example that
supports tiny fs
and we can see that there's
a few different commands mount unmount
format don't want to do that
xsd which is exporting the data for us
to view
ls
we probably can guess what that does
make directory cat
write remove
all right let's see what let's see what
happens if we type
ls
voila
these are the files
on the sd card
that is on the pi portal
and i believe that it's a read-only file
system but let's see if we can
make their
testing
no
because um it's currently configured
read only
as opposed to read write
so
um
the reason for that
is
you might not want your microcontroller
to be able to
write data
onto your medium
if that medium contains something that
needs to be kept secure
so for example if you have a digital
certificate or something
and you want to be able to
when you're first setting up this device
you want to be able to put files onto it
but then once you deploy it
and once you put it into the
vehicle or the factory equipment or
whatever you don't want
it to be able to write data on there
because it could be used by an attacker
to you know replace the files on that
so
one solution
is to make it so that
only when it's a special condition like
a special boot loader or over the air
update
can we actually write the data
and the rest of the time we can only
read it
so
this is testing that particular
capability so we can't really do that
much more
but we can use a few commands we could
say xxd
0 512 which will display the first
bytes
on the file system itself
and you can see that
these bytes here don't have any real
textual representation because they're
the bytes that are normally used to
indicate the beginning
of a fat file system disk
so
but it's totally working
great job sago 35
so this is actually pretty exciting
because
there's a lot of things that we are
going to want to be able to do
and
we're going to need to be able to write
files somewhere in order to transfer
those files onto our device in order to
execute whatever mysterious program we
might be working on
coming up in a future episode
i forgot to bring my bottle of water all
right
very cool great work so excited by that
amazing contribution
um
i would like to see if it works
with the
flash drive
so in addition to the sd card
a lot of these devices also have
flash memory
which is soldered directly to the board
for example
let's see if we can see it on gopherbot
um
i don't know if you can see it
so there's a
where is it
um i believe it's this chip
this little tiny chip right here
hello
there we go
so this little tiny chip
right there
is a
i think one megabyte
flash drive
that is normally
just empty
um
kept only for updating
the bootloader generally but we can read
and write data from that
once we have support
for reading and writing data from our
usb
using the mass storage device interface
we don't actually have that working yet
but once we do
it'll be we can do it now without tiny
go
we could do it by loading circuit python
onto the board
and then copying the files and then in
fact this is instructions that are on
um
we can
flash it with circuit python
copy the files onto the drive that will
appear as a mass storage device
then flash it with tiny go and read it
but uh be much better if we could just
have support for the mass storage device
so
that is coming
and i expect it will be very soon
that we're able to do that because
that's actually some work that
contributor
andrew ardenu is working on
to
add more usb
cdc or sorry usb
um protocols
higher l higher
protocols like the human interface
device hid or the mass storage device
msd
so um
that work is underway and i'm really
excited about when it can land
so um
also last week let's just shift over
last week i started working on
um
the raspberry pi
rp 2040.
let's see if i can find the window with
no i'll just open it here so last week i
started working on the raspberry pi 2040
microcontroller
which is a really cool little
microcontroller oh gosh yes
i need water
so the raspberry pi
24d
microcontroller
is the latest board from raspberry pi
and everyone's been talking about it
getting very excited about it
the support for this just landed in tiny
go
i think like
maybe a couple of weeks ago
several people have been working on it
and we finally got it there
so last week
i started working on adding the
capability to have general purpose
io input
and it did get merged
no sorry that's a different that was due
to a mistake i made
here we go here's my pull request
which actually was just merged
which added i started working on it and
i almost got it done
so it adds the ability to do a get
not just a set
so we can
blink an led on and off or we can push
the button
and turn it on and off
so we can actually look at that if we
want to if we go over to
we that's now in the tiny go dev branch
that i just built
this is the
pull pull request here with the code the
like changes that i had made
the only thing is we have to change the
pins
because the
um
pin numbering we don't have a standard
pin
that's got a name that's also convenient
like button
or led
just because there's no built in button
so if we go over to our
button example
and
i had cheated a little bit i had changed
the pins already
so that the led will use gp28
and then the button will use gp27
and then similar to many of the other
programs we've ever seen
we configure
the led as an
output we'll configure the button
as an input
and then if the button is pushed we'll
turn on otherwise if it's let go we'll
turn off the led
so we do have to make sure that we are
plugged into the correct
pins
and i accidentally unplugged some pins
so let's go take a look at our pin out
rp 2040
pin out
and we can take a look
and see
um i think i just plugged it into the
pin right next to it
usually that's what i try to do just to
make it a little easier
i have the
we can see this on the
micro i left the button plugged in
so the
led is probably goes in
not one but two pins up
the raspberry pi they do something nice
which is you can see this on the diagram
they decided to make it a little easier
for all of us who
you know are
not able to see all that well
and you can see that the
pins
themselves wait where's that nice color
here we go
you can see that the pins themselves
will skip so gp 28
then it has a ground
then 27
so it's a little easier to not
um accidentally plug into the wrong pin
so the one we wanted was
gp 27
which is the
um let's go look and see
27 is the button so 28 which is the pin
right
is above or below skipping a ground
and then above it so it skips up one
so if we go and we plug in my led
that i brought just for this exact
purpose
so we'll plug in the
red to the power
and the black to the ground
and then we'll plug the yellow pin
which is the control pin
so that it's not
directly above the other one but it
skips one
which should be
pin 28
which matches the
gpio
output pin that we've just designated
all right so now if i
um plug in my cable
we could focus a little
plug in my cable
and then go back to linux so we can
flash this thing
and
if you remember last time
it was very funny watching me struggle
to try to
flash this board
when
i kept trying to double tap the button
and that actually doesn't do anything it
you have to
plug in the board
while the button is
held down in order to kick into the
bootloader mode
so i'll plug it in release the button
and it pops up with the
bootloader drive so i should be able to
now say tinygo flash
target
pico
is that the name of it
um
bored pico yes okay pico pico
target pico
and then it's examples
examples
and then it is called button
okay
so now
it should have flashed it
and if we go over to
so now if i press
the button
the led should come on
yep
pushing it
so okay gpio in
and out
that's a good start
so
yeah we really need that because we need
inputs and outputs
now
i thought
because i
not learned my lesson yet
i thought okay
let's try again to add an entire
new block of capability to the raspberry
pi rp 2040
all in just a few minutes remaining
we could do it
so i'm going to do get check out
dash b for branch
and let's call it rp
adc
see if you can guess which interface i
would like to add today
yes you are correct it is the analog to
digital converter
because i thought like it was a theme
you know we just turned the dial earlier
also i know there's a rotary dial here
somewhere if nothing else i can borrow
lorenzo's so uh so that'll work
i have another one somewhere
i just have to find it
he's already looking for it he's like
yeah yeah i'll find it first um that's
very true but then you'll unplug it and
you won't be able to plug it in again
yeah no no i'm kidding i'm kidding
all right so let's take a look and see
what it is we think we want to do
what actually is necessary
um we can find it
as in here somewhere the data sheet
there we go
all right
so what are we trying to do
is we are looking at the
analog to digital interface
which is one of the blocks
on the rp2040
and so
the analog to digital interface
here's a picture of it
shows you that it's got
several different analog inputs which
all go through this same
adc
analog to digital converter
so kind of like we learned previously
there's a lot of pins on the rp-2040
and so as a result it has a lot of
flexibility
so
when we configure the adc normally what
we have to do
and we can
sort of take a look at this in the pico
sdk example
so normally
what we would need to do is we would
need to initialize
the analog to digital converter
just on the block on the chip itself
and then which we do in tiny go
by using the
init adc function
and so the
board that we were using before the
arduino nano 33 iot
is a board
of the
processor kind the atsam
d21
which is a micro controller made by
microchip
which bought the company atmel which was
originally making this chip
so um
so when we are going to initialize this
adc right first thing we have to do is
implement init adc for the machine in
question so let's
add
init adc
to the machine package
for the rp2040
now
we do not have a separate file called
machine
underscore rp2040
underscore
gpio
the question is do we want to add that
to the gpio
um or do we want to put it into a
separate file
so because the
raspberry pi's machine packages are all
pretty well organized by what type they
are
i have a feeling that adding a new file
will probably be our best bet
so let's add a new file and we're going
to call it
machine
underscore rp 2040
underscore
adc dot go
that way
it matches the format for the other
files and we can find it
and then we need to add an init adc
function to that
of course we also need to add the name
of the package
which should be
machine
but we need to add this build tag so
that it only builds it for the raspberry
pi the rp2040 and not just for any of
the other machines
because that of course would be a
conflict since we already have
init adc functions for some of those
all right
so now what should this init adc
function actually do
is what we were looking at
a moment ago in this
data sheet and also in the pico
sdk
and we can see that the first thing we
want to do is um reset the block
which is just turning
essentially turning on
the overall
capability of the processor
so
i don't know what that does but i guess
we'll find out
and then
we'll turn it back on
by turning on the
adc
registers
cs
or adc block
cs register
to enable it
okay
that sounds interesting let's go and see
if we can find
this
adc cs enable bits
in our files which are generated
by tinygo
when we
run our generator from the svd files
which define
the architecture each one of these chips
it goes and it generates
in our device package
the wrappers that we use for all of the
different processors
and so
in the
rp package we have the rp2040
and this is one of the many files that's
generated by that generator and this one
here we can see that there is an adc
type
and it's got a cs register
and so adc type if we go and we just
look at that we'll see that there's only
a single adc
interface exposed so if we say just
machine dot adc
then we'll be able to access
the registers under it
so let's go over to
our
this is where i guess if i was using
golang
then the author completion would be
pretty handy right
so we'll try that next week if i don't
get it done
so we would say machine
dot adc
dot
cs
right
and then
what are we going to do with that cs
let's go back and look at the
example so we want to set
the adc cs enable bit on
so in time ago we would normally just
use
the set command
because
since the register is a volatile type
it's a special kind
of memory
which is not just free memory for us to
do whatever we want it's memory that
maps directly to the register that
controls these capabilities on the
processor
so we have to treat it a little
differently so when we set it
what are we going to set it to
well we want to set it to the value
for the adc type
and luckily they're all listed for us
as
bit types
underneath are
the generated files so if we look just
for adc underscore
these are the clocks
adc type
this is for training the clock on that
controls the adc
somewhere down here we'll hit the uh
here we go so here are the bit fields
for the adc for controlling it
so now this is generated from that long
xml file
that consisted of all the different
possible
settings and we can see what we want to
do is enable it right
so it's this adc
underscore
cs underscore enabled we just set this
bit on
by going back to our code that we were
adding
and if we just set it to
machine dot that bit
right that should
enable it
let's go take a look at our
c example
so it's c adc cs enable unless we just
adccs enable and we want to set
not just we can we know that because
we're using
just the assignment operator here equals
in other words we don't care about the
other
register
bits
for the cs register we can just ignore
all of them
turn them basically turn them all off
and only turn this one on
okay so that's what we did and then
because it takes a little bit of time
and the data sheet that actually tells
us this right
that
once the adc block is provided with a
clock
and its reset has been removed
writing a one to cs dot en for enable
which is what we do we're just doing
with that little bit of code we'll start
a short internal power up sequence
for the adc's analog hardware you notice
that they have analog spelled
with an e at the end
they're brits you know
um
so after a few clock cycles cs ready
will go high
indicating that the adc is ready for
business now it's ready to start its
first conversion
i guess it would be an american manual
if it said it was ready for business all
right
enough of those jokes let's go back to
the code so that means what we want to
do here
is actually very similar to what we did
in the machine package here
we have some code or the machine package
sorry for the atsam d21
and uh this weight adc sync actually
shows you
a good example so it's a four loop
that's going to loop forever
and we want to
we don't want to say sam actually sorry
this should not be
machine adc cs i think this should be
um
rp 2040 let me let me just look at the
gpio
rp
because we need to say import device rp
that way we're using the correct
reference
so where's my there we go all right
so this should be rp
and this should also be rp
so we're setting the raspberry pi's adc
cs register
to this
bit
and then here we want to say
rp
adc and then what's the name of the
register
it is
also the cs register
and we want to say which bits is it that
we care about
it is the
adc cs ready bits
so if we go and we look
probably very close to where we just
were
we'll see that adc cs ready
so we can check to see if this bit is
set
that's the one we care about
it's actually rp
so we want to wait for it to be set so
we want to say if it's not has bits in
other words if this bit is not yet set
keep looping
and then once it is set it exits this
loop
and we're done
initializing the adc i believe
let's go look
that's all that the adc init does in the
pico sdk
other than
resetting this block
which
let's just ignore that for now
let's assume that when we first power up
that the block is
probably okay
so whoops
so i'm going to say to do
to do
make sure
[Music]
block
is
initialized
just to be sure all right
so that should init the adc
all right so what else do we have to do
to actually read it
well
if we take a look at the
pico
sdk we can see in the
include file that actually actually has
the inline definitions
of these functions so in
in c
we can define functions in our dot c
file but we can also define inline
functions in our dot h file
and it will
basically take those and
output the data directly for those
wherever they're used so it uses up more
space
as far as the program but it's a lot
faster
so let's go take a look and see
so gpionet
is um
if we're going to init
a specific
pin
right just one pin
so yeah we know we're going to need to
do that right and if we that's similar
to what we were doing
in the
configure function
right and if you remember we did the
same thing in
the
configure function that we used
in our
dam uh
example that we were looking at with
lorenzo
so we're going to need to
configure
so let's go back over to our raspberry
pi adc
so we know we're going to need to be
able to configure an adc to be able to
be used
what else is it that we need to do
let's go take a look and see what other
functions well in that we're going to
need
configure we're going to need
oh yeah we need to actually get a value
right
so let's go and
get
so we're going to define get
and
right now let's just say return zero
because
we can't have a function that doesn't
have a return value if it says
that it's going to return something this
way it doesn't work but it does return
something
all right
so
this won't actually do anything
but we can test to see
hopefully
if it even compiles
right
the way we can do that relatively easy
is just by trying to compile the program
that we were trying to use a minute ago
and if there's any syntax errors in that
particular file it won't even compile
all right so it compiled but it couldn't
flash so that's a good sign
we're getting somewhere
so let's go back to our code that we're
adding
all right so to actually configure
whether we need to do
well
we're going to need to set it to a null
function
so the gpio on the raspberry pi
or actually the pins i should say
are very multi-purpose
and we can set the
peripheral i o
to support many different functions
we have a list of those in our
implementation for
gpio
itself right
and if you remember we had a list of
those functions here under the gpio
function selectors
that we can turn on we can make it the
jtag for debugging
spy for
you know once we have the sd card thing
working
so the one that we're supposed to use
in the case
where
the pin is going to be used for analog
so we're going to use null
right because null means don't use any
of the normal gpio functions
in other words only use
the adc block to communicate that way
you don't end up with a conflict where
the analog to digital converter is
trying to do a read at the same time
that the gpio is trying to do a write on
the same pin
you know the that won't function
or that won't work but it will function
like it'll compile and it'll do
something it just won't do what you want
right so let's go back here and we want
to be able to call
the
um
and how did we actually do that
i believe that if we went and looked at
our
configure for the gpio pins
we can see that
it calls this
inet function
and then
it sets the output mode
so we actually want to do pretty much
the same thing right
i mean
even though an adc
is
is it still a pen
yeah it could be a pin
it could be treated like a pin
so if we want to
um
but we don't usually do that right if we
go and we take a look and see what does
adc config do
for the at sam d21
you'll see that
most of the work that it does
is setting all these other magi
special registers until oh wait
it can treat it as a pin it can just say
a dot pen dot configure
so that means we can use this same
technique
right if we want to do a configuration
because the first thing we want to do is
say
a dot pin dot configure
and we want to set the pin config to pin
analog
cool but we have to implement that right
like there is no pen type yet
for analog so let's define one
pin
analog
so we'll add that to our
spelling
so we'll add that to our
list of pin modes so now that's one of
the supported pin modes so now we still
have to do something with that pin mode
right
in other words if our
case
when we're doing configure
is pin
analog
what should we do
well
i don't know let's go take a look
well first of all
if we go and we look at that init
function
where is the net
[Music]
so in that
we'll set that function to
sio function
and now we don't want that here
what we actually want is to set it to
this null function
so init is not doing exactly what we
want
although it does part of what we want
right
maybe the solution here is that we want
to specify
what type of a net we want to do
based on
or another option is just to emit it
twice right to call that
um
to first set it to the
sio function
and then to once again clear it that's a
little messy
that's not exactly how i would prefer to
do it
but we're really calling init here
and if we don't want to duplicate our
code
then
well i mean one option is we can call
this set function first
and we can repeat that for each of them
i think that's going to be the easiest
right now
so if i take that and all of the pins
other than the analog
we're going to set
to the function sio
the analog though
we're going to set the function
null
i think it's null yeah
so this is going to just this removes
that one line
from init
the last line
the one that actually sets it
to which function
so this probably is okay
but there are a couple other things we
need to do besides that right we need to
disable the pull-down resistors
and then make sure
that it's not being used for normal
gpio
um input
we can't read a gpio on or off
and have the analog to digital converter
read an analog voltage at the same time
on the same pin so let's first go and
disable the pills
so we already have a function to do that
it turns out that we are using
where
um
configure
and ah here we go
so we want to
we don't want to pull down or a pull up
so i guess we
want to say
we want to clear the bits
for both so it neither says we don't
have a function yet for that
we have a pull-up function
which turns on the pull up enable
and turns off the pull down enable
so you could turns out you can actually
turn on pull up and pull down at the
same time
which
may or may not have the side effects
that you expect
so
we have pull down which
i guess we should say pull off
and so if we say
pull off
it doesn't sound like it's a guitar
thing
and we want to
clear the bits for both of these
we want to turn
the pull down enable off and the pull up
enable off
so let's go here and so after we set to
a null function
then we want to
call pull off so we're not
we're neither up nor down
and then what was the last thing oh yes
we have to
disable input
so now
um
we do not actually
have
to disable input as much as we do
well actually we kind of do but i think
we do that when we set function
let's set uh set input enable
clear
output disable so that's not good that's
actually not what we want at all
in fact that set function
is going to have an unintended side
effect it looks like
of
turning input enable on
which is not what we want at all
right we want to say
that this
we want to do basically clear bits
that's a typo
of import enable
so let's
take this clear bits line to use as our
starting point
so after we've done the pull off
then we want to clear bits
of
the input enable bit
this will make sense in a minute
i believe
all right so we're setting to the null
function
we're turning off
both the pull-ups and the pull-downs
and we're turning off input enable and
now they're all the three things that
the gpio adc gpio init does
looks like we're really close to being
there
right because this should get everything
ready
so now we have to just do an input
select
and then
get the selected input
okay
so
input select
is a matter of
setting that
cs register that we used before
and turning on the bits that correspond
to which input so if we go and we look
at that cs register
which we should see here in the
datasheet
under cs
and we can see that
um
what's in that register here's the
enable bit we used to turn it on
then we have start once versus start
many conversions
and then
hmm that's not what i expect
that's not quite what i was thinking we
needed to do what i think we need to do
was just this read
actually
just do a single conversion
yeah i think that's all we actually need
to do
because
what that should do is that should turn
on the read once
for that
so you can have your analog to digital
converter read over and over just
continuously reading and then
find out what the latest value is
or you can just say
read right now and tell me the value the
reason why you would do continuous
conversions it takes some time
to start the conversion process and if
you're really time dependent you want to
move really fast you want to read really
really quickly it's better to just be
continuously reading and just get the
latest value whenever you have time to
check it
but in our case we should be able to
just use
the normal adc read
just by saying
read only once
and then once it's ready
get the value
it's not the most efficient if we're
going to read multiple adcs but it
should work for
this initial
um
implementation
all right so let's go back to our adc
so our configure
um we went we added to the pin
configuration for gpio
so that we are doing all of our analog
pin configuration here which is
setting to null turning off
the pull ups and downs and then clearing
the analog the
digital input
and then we should be able to go and
implement our last function which is our
get
and we said to do that first we need to
do
is we want to turn on one of the cs bits
for a single shot
breathing
and that was the one that was called
start once
so we're going to start a single reading
okay
and then we have to wait for it to
actually get the data right that's what
was happening in this
loop
where we're checking to see is it ready
that sounds really familiar that's
almost exactly like
this loop we had right here in fact oh
that is the same exact function
maybe we can make that into
a helper let's call it
funk
and we need to make it off of our
a
adc and let's call it
wait for ready
and all it's going to do is
not return until it's ready
and so we should be able to use that
function here
actually we don't even need to make it
um
well
we don't need to make it a uh
member function of adc we can just wait
for ready because it's always going to
wait for ready regardless
same thing here
so wait for ready
and then the last thing is to try to
actually get the value
which should be in
the result register
so
if we go
aprp.adc
dot it should be result
let's go and look at our definition
for adc
type
and yes there is a result register it's
a 32-bit register
so it turns out that adc values
on the raspberry pi 2040 can be
32 bits not just 16 bits
so
we'll have to deal with that
in a minute
but we should be able to just return
get
the reason we have to say get is
remember it's a volatile we can't just
assign volatile
registers
we need to be able to use our functions
to ensure
the safety of those registers
and so
when we do that we use some vol some
package sorry some functions in a
package that's called volatile that's
part of tiny go
that we use to protect it so now
this won't work quite correctly because
this is a 32-bit value
so
um
one way to address that is just to scale
it down
by half
right in other words
we remove the number of significant
um that's one way to do it
so we could just say
if we scale it over
you know
by
bits
then
we have to cast it to the right type
which would be u n 16
because it's actually a not unit 16.
that sounds interesting
so that should
scale down the value
from the max
to the 16 bits that we actually
allow
and then
i mean that's a lot of bits to lose
i wonder if there's a way to set the
number of bits to be used for the adc
conversion
i think for right now
instead of um
let's just instead of scaling it let's
just chop off the top
now let's scale it that seems better
all right let's see if the code still
compiles
we're almost out of time
again
but
we're really close to having something i
think
okay so it compiles it doesn't actually
work
so it turns out that there's actually an
adc
example but we're gonna have to modify
that a little bit
to
for one of the adc pins
so close let's see if we can actually
maybe get this to work
so
this example
it's plugged into
an led
and
so if we turn up
the like the rotary dial above
the more or less halfway
then it should turn on
otherwise it should be off
and so we need to use one of the
adc ports
so if we go and we look at our pin out
let's see which one of we could use adc0
which is where gp26 is so it's one
right below
the other two pins we have plugged in
so let's see if we can do this
almost there
plug in the
power in the ground
power
red
ground black
and then we plug yellow
into
the pin right below the other pin
which was
gp27
so gp26
which should be adc 0.
so it should be this pin right here
okay
and let's turn it all the way down
and it should work with um the built-in
led
with the way that it's currently
coded
but there is no built-in led so let's
just make it
gp28
that way
i mean there's a built-in led but let's
just
make sure we're using the same led
all right
oh wait it's gp
yup gp 26
all right
let's see what happens
we should be able to compile adc
and it looks like it's going to compile
okay so let's
unplug it
press down the power button
what happened there
unplug the power button
it pops up let's flash it
it flashed
and let's see if it worked
if i turn up the
volume all the way
it seems like nothing happened
wait
no
no i don't think so all right well we
don't quite have it
but we're getting very close
we are in fact out of time
for our little extravaganza today
so i wanted to actually do this to go
for bot but gopherbot said no
don't don't don't use me for your crazy
experiments dead program
like you are one of my crazy experiments
go for bot
so on that i wish you a pleasant weekend
great hacking with you and we will see
you next time for more fun and
excitement here at the people live with
dead program
[Music]
