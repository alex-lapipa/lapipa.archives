---
document_id: "LP-MEDIA-YOUTUBE-VIDEO-E7SXJ5P1GLM-DOC"
source_id: "LP-MEDIA-YOUTUBE-VIDEO-E7SXJ5P1GLM"
title: "S2_01_DEADPROGRAM@LA PIPA"
language: "en"
document_type: "youtube_video"
origin_uri: "https://www.youtube.com/watch?v=E7sXJ5p1GlM"
verification_status: "provider_metadata_captured"
access_scope: "public"
content_sha256: "5e4b9e5d0a1e52e2fd09c99872b574d06c6c0e1ec82b26d479b37982ecf2d5e0"
---

# S2_01_DEADPROGRAM@LA PIPA

Archive source LP-MEDIA-YOUTUBE-VIDEO-E7SXJ5P1GLM. S2_01_DEADPROGRAM@LA PIPA.

YOUTUBE video accession record.

Canonical provider URL: https://www.youtube.com/watch?v=E7sXJ5p1GlM

Provider identifier: E7sXJ5p1GlM

Creator/channel: LA PIPA IS LA PIPA

GO, TinyGo, GoCV, GoBot, Bedrock, LA PIPA, Ron Evans, Alex Lawton

Provider metadata captured successfully.

Transcript (en-orig; automatic_captions):

Kind: captions
Language: en
[Music]
is
[Music]
oh
[Music]
hello
beautiful humans of the internet
it is i
did program
your favorite
i don't know cyborg sure
hello fellow cyborgs hello robots and
especially hello
extraterrestrials
send us a sign
we just want you to blow our minds he
has the david bowie lyric goes so here i
am at the beautiful la pipa
in asturias spain
with my trusty colleague gopherbot what
was that cover about
yes go government says that now that we
have been vaccinated with the moderna
vaccine since we are very modern
creatures hopefully it will not be too
much longer before we don't have to be
messed up all the time just most of the
time
so
it's been quite a week with lots of fun
action
and let's talk about a little bit of
news
naturally last week's news was the
all-important interview with yours truly
and go laying weekly
thank you very much
but uh interestingly there was a part of
this that actually resonated with a few
people
what has been the most surprising
interesting use of tiny go
well people running tiny on older less
powerful hardware here's the clip
the recent chip shortages and supply
chain issues mean
that we have to do more
with the hardware we've already got
well it just so happens that even tech
republican others have been covering
this painful global chip shortage that
we've been going through
and
interestingly they say that it's going
to affect more than just your laptop and
your automobile and your toys of course
so um interestingly
one of the statistics was that the
automotive industry has been
substantially impacted
but additionally other areas of
technology such as computer networking
so yes we must do more with what we've
already got which is a key part of the
whole value proposition of things like
tiny go
languages that are very small very
compact and very powerful
anyway
on the opposite side doing some really
interesting things this week oxide
computer company run by a few friends of
mine who are deeply involved in the rust
programming language they finally put
their website live and we have a little
bit of an idea of what they're up to
kind of the opposite of the global chip
shortage philosophy
their idea is to build very high-end
server hardware powered from bottom to
top all using rust so that's pretty
interesting
i'm really looking forward to seeing
what they come up with the website looks
cool the concept is great and uh who
knows maybe we'll do something kind of
like that with tinygo
um
closer to earth
interesting company that i have heard
about because they just raised a round
of funding is heirloom carbon
so they are involved in technologies for
carbon sequester and obviously these are
topics near and dear to all of our
hearts who like doing things on planet
earth like for example
living
so yes check out our heirloom carbon be
interesting to see what they actually
have once it's a little more public
so
this week the
first tiny go book is now officially out
tobias teal contributor and cool human
being their book creative diy micro
controller projects with tiny go and web
assembly is now finally out unpacked so
please go check it out get a copy it's
the first book and that the present only
book about tiny go who knows how long
that will last but it looks really cool
there's also a whole series of youtube
videos here with all the different
things i don't think all but a bunch of
the things that are in the book so it
looks really interesting looking forward
to checking that out
and then a bit of interesting news from
the red planet
so
mars ingenuity which is one of the most
interesting
multicopters
the first multicopter operated on
another world
another world world world world yes so
uh they i think was their sixth flight
yes the sixth flight uh things did not
exactly go as planned in fact this uh
this gif is really cool of the last 29
seconds
so you can see that
the rotors are turning all of a sudden
whoa the ground came up
really quick
so this was the part that i thought was
especially interesting
jpl traced the cause of this glitch to
the loss of a single image
in the pipeline that ingenuity uses to
estimate its speed and position so one
image lost
in the computer vision pipeline
and near disaster on the red planet
whoa
so it just goes to show you that
computer vision is not so easy is it
on that i'm i should bring my friend
manuel who has been working on the first
i must find my mask
it's probably on the ground hmm
yes i have a spare not to worry
i have mask will travel
that's my model so my mother's been
working on the cow tracker
and i think some progress was made i
don't know let's uh let's find out
manuel how's it going man how's it going
wrong thank you for having me yeah so i
you've been doing some work on the
computer vision system for cow
identification
yes um if you recall and the last day i
showed you how
the tensorflow model already takes some
other objects but it doesn't really
detect cause or anything else that rate
so i try to
use those weights to retrain the model
just so to save training time
and try and
with a small data set of cow images
try to retrain it using tensorflow just
so we can run it on ocd so a small
data set of of large cow images yes
images of large cows and images i guess
all cows are large well yes i had a
small and bigger cows and i also had
small cows with photos taken from drones
as well just so it can have some variety
nice so how did it go well i was able to
follow the whole tensorflow api for
object detection and i got to the part
where i got and the model the protobuf
model which is one of the two files that
you need for ocb to run
but if you recall you also need a
configuration file which basically tells
the program yes you have these weights
and this model but that model is built
this way
so one is the actual model itself and
the other is like a definition of what's
in the model yes more or less and the
problem is that once you change for
example the number of classes you can't
use that
file that configuration file that you
have for example on the read half that
we were using on the whole
program if you recall so you have to
generate a new one because you've
changed
excuse me
so you've changed the uh definition of
what's in the model so you need to
change the config file as to match yes
for example i change the number of
epochs and all of that just so it's
raining less time just to see if it work
and for example the number of classes
because if you recall the previous model
had 90 classes and we just need one of
them we just needed to detect cows yeah
because it detected all these other
objects that you discovered that could
detect but none of them were cows of
course yes and a water was a knife so
for example
and so the problem that i came with was
that um
these
all of this is built on the tensorflow
api
and the tensorflow api was updated and
now it's i think tensorflow 2.5 which is
the latest version but opencv
really works with all those tutorials
that you can find online until
tensorflow 1.15 so most of the functions
are either deprecated or they just are
removed
so some for example and these there are
some files
in the source
repo
where you can
input your protobuf file and then it can
generate that config file automatically
for example if it's an ssd model then
you have a tf text graph ssd for example
so it reverse engineers the definition
from the actual model well you don't
just pass the model you pass the model
and then you pass the pipeline config
which is this other configuration file
but
the issue is that that model doesn't
work because maybe
90 percent of of it is made up of
functions that don't exist
so it's been deprecated yes
and it seems like a real issue so i try
to migrate to cafe models but i haven't
really done much on that yet
so we may end up with a bespoke cow
identification model after all yes
totally customized hl in australia made
mysterious yes and i think it's really
interesting that we can do that and use
these models that are pre-trained just
to save some time in the training if we
were to just do the model from scratch
then it would probably take a lot of
hours
unless we had a really nice gpu
which i don't so yes nobody has gpus
these days
well we'll try to see if we can do
something about that
well very cool so what what's the next
step
work on the training and then try to or
check a different approach yes my idea
was just train it with a small model and
then test if it worked and then once the
pipeline already worked then i could
just
input some more images and try another
model which was trained in more time
check the laws see that it predicted
correctly and just follow that whole
process
got it well very interesting well uh so
maybe you'll have a demonstration of the
pipeline next week if nothing else you
could show us yes if nothing else comes
around then probably i'll have something
to show or maybe even a fully trained
model well maybe it depends on the time
maybe maybe we'll see
well cool well thanks for stopping by
and uh keep going it sounds like some
progress is being made keep moving
moving
thank you all right all right thanks for
coming ciao
cool yeah no it's it's a lot of work
the uh the black art of training models
it's not the black art it's just science
there's a lot of math
and of course a lot of input data
and of course human beings saying yes
it's a cow and no it's not so don't
worry humans there will be work for us
in the future
cool
so um also my friend lorenzo
uh is down here and i know he's been
working uh with us every week on the
learning to tiny go
and uh we made some progress last week
we got both a button
and an led and who knows what's coming
next hello lorenzo what's happening man
how you doing i'm i'm i'm fine thank you
cool so you got your computer you have a
cool mechanical keyboard yes but show us
show us the keyboard here like this is
let's see if it works
i like the colors yes well you can
change them as well well yeah of course
it's all about leds everywhere now right
all leds all the time yeah i love them
especially when working at night
with dim lights and things like that i
love it
so um last time we ran into a problem
with the um gopherbot you got to move
over here
um
ran into a problem with
programming the
arduino using the basa boost loader on
windows
and i don't think we've ever actually
reported the bug to the
people on the tiny go team to fix
no it was done on the wrong
repository on bossac but it was a tiny
goal probably issue i i think we should
do the same on
on tiny gold
i'm sure that's where the problem
actually is
i don't i don't think um
i don't think
oh uh-oh
we're just seeing a screen or maybe you
have to
because i was seeing something before
yeah there we go sorry yeah no worries i
fell asleep
let's see all right
so um
so i guess maybe the first thing we
should do is um
try to tell people about or try to
report that bug
don't you think because that way we can
maybe try to get it fixed as you wish
um well i don't have the screen for
the capture let me do something we don't
have to you don't have to capture i
think if we were just to uh
run you mean
i think if we just go to the website for
the repo and we just enter an issue with
the error message we got
that would probably be enough right okay
let's
uh tiny go
yeah if we go to the repo
okay so it's a link on the repo i guess
here so
and ooh dark mode
he's a hipster yes
so yeah i think we should enter the
issue probably but that way we um
have a chance and i would probably say
windows
and then
unable to flash arduino nano 33
okay
oops
something like that
the thing is that i wanted to
paste know the
message
well we should go back to and try the uh
try to flash it and see the message and
that way we can copy and paste it right
let me see if i can find the
well we could just run the program and
it will fail in the same way i assume
okay now i have to find the
project
wait what is that that looks really neat
yes it's my organizer
it's the you know the brain maps
and i have a markdown page where i can
take notes this is the free version the
so has some limitation but at least for
example you can attach some document or
and also use it to take notes
and it's quite nice that's very cool
mind mapping is really an interesting
technique yes it's very
natural let's say it it doesn't get
clogged sometimes but if you
do a proper organization it will
help a lot
and as long as you have a mind then you
can have a map
that's what stopped me generally
the prerequisite for it of course
so flashing was tiny go build target
no tinygo flash
exactly
well you tell me the
yeah so we can go
we can just go to the um
terminal okay
okay
so time you go
flash
space dash target yes
space arduino
and then um
the name of the program which would be i
guess
um
no you know what was it called step
really it could be any step yeah okay
let's do steps to zero
do we need the extension or it's enough
well we have to tell the directory of
where to find it right because this is
the okay
so
the um so being we so go back because we
have to give it to them at the output so
space will the output is if you want it
to build but not flash this is to say
this is the program we want to flash
okay
so it would be i guess under
um
i guess it would be
dot
backslash
is it backslash or full yeah backslash
and then step
whatever it is zero that's fine and i
think if you just hit no return it
should it's like
it should try to flash everything in the
step zero directory
and then we actually plugged into yeah
we have to plug in yeah yes first
sorry
no one else forget those things every
time i have to read it i don't have a
good memory in that stand
so it's still compiling
and then
it should give us the error message
whatever that was
maybe
we did it without flashing without
connecting it so
well it would say i'm not unable to find
any device
if it can't find any so it's just
probably taking a while to compile okay
it's a lot slower to compile than it is
to execute
our priority is to is speed of execution
rather than yeah
i mean it's
okay yeah boss extra arguments found
exactly so if you copy yeah with a
screenshot or text i think text is fine
if you can successfully copy and paste
the text in
windows
okay this is
because you're in markdown
so if you hit the three uh yes
and then return yeah exactly and then on
the bottom of the whole thing
uh yeah when you are previewing it right
now it doesn't show up but i guess it
should pick it once we submit
and well you can see preview on the
channel yeah you're right yes that's it
and but you might want to also
um format the output
so if you click on right
okay so everything will put everything
in here yeah that's a good way
okay
looks
clean enough
do you think that's enough or they want
me to i think that's enough okay let's
do just a message next
submit you wish
so
this way at least there's some record
of the fact that this problem exists and
then maybe somebody
uh could take a look at that
cool so i think we're on step four yes
so what was step four
uh it was the i think a touch sensor and
a buzzer if i'm not wrong
okay
well let's go and look at the um
at the actual content
for the
website
which was on the gophercon 2019
the last time we got to do this live
and uh yeah i think if we go down and we
can see that step
one was the blue led
step two
was a blue led
and the button
step three was the blue led
the button
and
i guess the green led
oh it looks like you plugged in some
more stuff yeah well yes this does the
capacity and well the touch sensor and
and
but they i haven't connected just to
to do it here got it
so i guess step four now was the blue
led
the button
the green led the buzzer and the touch
sensor whoa we had two
now i'm trying to
see
if
okay let me see okay let's see if it
works the with the previous
okay so we can just
so yeah step three which was the blue
led and the green led yeah we can see is
working when you click on the button
it turns on blue and when you release it
turns on green
exactly so that's good that's working
so now we're on to step four okay so
step four was we have two
well let me
pick those two
new devices the growth
so this is a buzzer it should beep
and this is a capacitive
well like a touch sensor i guess it's
yeah but exactly one this is the buzzer
which is your basic
piezo electric
you know makes a
nasty noise to let you know you've done
something you shouldn't do
or
and then yeah the other one
exactly you're quite you are correct it
is a capacitive touch sensor
that just detects
you know the
change in the current from you being
connected to the ground so it just takes
a little tiny change to touch it and it
acts like a button basically okay
so should we keep everything else
connected as before yes all of the
steps
in this are additive you just add more
things until we get to the end
cumulative okay cumulative yes exactly i
will power them first if you are okay
that sounds good okay so i will
put the negative into the negative rail
positive to the positive one
and this one is showing it's active i
guess with there is a
yeah there's a little led that comes on
that's getting powered exactly so now we
go for
powering the
buzzer
positive and negative
some says i'm positive
no
okay
and um
okay we i think we need to choose the
output so now in the input pin i guess
exactly
so i guess now the um
the
yellow pin from the touch sensor
should go into pin d9 d9 i think 10 was
the last one we
we used so
if i'm not wrong the picture so yeah the
picture so it's the one on the
on the right
of the last one we connected and you
were talking about the
sense exactly that's sensor so yellow
the signal goes here next to
number 10. i guess it's this one i
cannot see properly so i'm sorry i hope
i'm right and this is one now we connect
the buzzer i guess onto
pin eight
so the buzzer
yellow should go to pin eight exactly
okay
so here we have it
pin
eight
so um i guess everything is connected
now
so it's just hopefully so
all right so let's go take a look at the
code
i guess um
let's see this is step four
so step four
let's see what we got going here
so we got package main
same as before
as the previous step
we're importing the
machine
package the time package and now we're
importing another package
the buzzer package
from the tiny go drivers repository
so we have a separate repository
that contains
drivers for different sensors
displays
also different devices peripheral type
devices that you would want to connect
to a project
and so the buzzer is one of those that
lets us
you know make different bleeps and
blocks can we have a look or it's too
complicated to dive into
well let's let's look at this program
first and make it work and then we'll go
take a look at the buzzer i i would like
to yes
so
our main program
so we define our blue
is on pin d12
and it's an output pin
our red led is on pin d10
and it's an output pin
our buttons on d11
and it's an input
our touch sensor is on pin d9
it is also an input
and then our buzzer is on pin d8
and it is also an output so it's just an
on off button there is no
level of
input from the capacitive sensor right
that's right okay so it's just a just on
and off
and then here we're going to say that
our buzzer
colon equals so we're both going to
define it and assign it
is equal to the buzzer which refers to
our buzzer package
dot new
and then we're passing it the pin
so this is saying create the new buzzer
driver
and use this pin
in order to control it
then our for loop
is very similar to how it was before it
says forever
that if the button is off we turn on
blue
i'm sorry off blue and on red
and if the button is being pushed we
turn on blue
and off-red
and then the touch
sensor
if you touch it then the buzzer will go
on
which should make a noise
or else it should turn off okay
and then
sleep for 10 milliseconds to give a
chance for whatever else in the system
so let's go and see
if we can successfully flash this
program
so we have to do two things yeah exactly
nothing wrong with taking notes okay so
well the
path is set
and
the only thing is do we have to move
over on the directory we are in and i
guess we need to
run the
boss shock
well we have to build the the hex file
first so or been functioning
yeah ben we have to build the binary
file
with time to go build to compile it
and then we use bossack to do the
flashing
okay so bosak is the flashing so there
is a mistake here
you know let me correct it so i will
have it
for future reference
yes
good that's the thing about mind mapping
they they tell us all the things we used
to know when we were so much smarter
exactly and they let us get back to that
same place so now that i have this one
well i'm not trusting so i don't want
this to start without
because sometimes it adds the carriage
return which is
yeah then suddenly the
you didn't want to execute you wanted to
edit it first
okay so it's step four
and then the output you should make step
four name also as well right just that
way we
step four
and okay then you go build target
arduino the platform
output is the binary
object and step four it's the directory
exactly so that should work okay let's
find out
go get it done
yes so
now we need it actually tells you what
you have to do
ah so in go
there's a command
go get beautiful which goes and gets
that package
and adds it
to the packages that are installed for
this particular
program to be able to get to it so it's
a package management okay go get it tiny
go boom
so that should go and download it from
our drivers repo
which it appears to be
we have connection
package machine that's okay that's
because the machine package is not
actually a normal package it's part of
the tiny go compiler
when we compile a tiny go program the
machine package is the
hardware abstraction layer
that lets us have an api to communicate
with the actual hardware but it's not
just a normal go package because the
tiny go compiler has to actually take
that and translate it
to the registers
and the values in the hardware itself
so the go package manager
can't install a package named machine
because there is no package name machine
to install it's part of tinygo okay but
that's okay it's already installed the
driver so now you should be able to up
arrow and try it again
target
i think it's correct and again
something go downloading well here
version
um well type dir
so
you have a go mod file
hey what's up so it should have um
so when we said go get it should have
added it to the go mod file
edit
or add
so that file if you were to output the
gomod file if you were to just echo or
cat i think it's um or type yeah that's
i'm not sure
i don't i have such a
yes yes it's the one so you'll see that
it doesn't know about any actual
dependencies right so what we needed to
do actually is if you go
if you hit up arrow to the go get
command
and now if we just instead of just
saying go get if we say go get
dash d
space dash u
that will say d for download it and the
dependencies and then u for updating it
it should add it to our go mod file
but it didn't actually add it it would
appear then you go
but if but it's true that if we cut the
or type the go.mod file
it didn't actually add it changed
i'm not sure why
it didn't do that
because normally it would add its
because we have we're in a directory
that has a mod file
and that modules file go.modules file
um
but here's the thing we could do if we
edit that modules file
just and i don't think it edits but we
can
remember here
i think you can say go
i think you can say go space mod
space edit
i like this yes
oh help
or
maybe it doesn't know about the editor
let's open this directory which we are
in here so
i don't remember those commands anymore
because also they changed a few things
since
i was
so let's see if we are lucky we'll open
it from here
um hold on no
no no not this one sorry i
do use vs code no i have it installed
but i'm not using it let me do something
else
okay let me do this instead
you can even use notepad yeah again ah
yeah you're right i forgot it see
um
what's interesting what's that file it's
what have we opened sorry some other
phone
yeah
holy shit
whoops i'm not biggie
okay
again
i think if you just go to your command
line
and you say notepad space ah yeah you're
right and then no
[Music]
yeah no i'm i'm the master of the cheap
editor
if it's a fancy evidence
it
i don't know how to use it if you
remember once it was added something and
it will open uh
wait is that a killi
we have a friend in the studio
hello
hello everyone
and what is your cat's name
cece
oh my god so cute
cats and robots
okay
we have to stop things for a cat my
friends i mean
they're so cute oh my god i love cats
okay sorry what were we doing oh yeah we
were coding
um okay so if we look at the go module
file
we see the first thing it says is the
name of the package it says module and
then this is the gophercon then below
that
it says go and then that's the minimum
version of go that this package would
need to support right so then when we go
and we add those files it should add
them automatically to the go mod file
right if we were to take a look at the
go mod file
and uh
another a different example
right when if we go over to let's this
is how it was working for me on linux
and if we
go into the
sensor directory
arduino
and if we say go
get
and then tinygo.org
x
drivers
it should have added it to our go mod
file
and we see it actually modified the go
mod file
and added it as a requirement okay so i
don't know why that didn't work the way
you expected the two on windows
but it's probably relatively easy for us
to just type that in so you have to put
it in below the line of go okay so
behind the line will go and require yeah
so require
uh you've heard that one before from
python require space tinygo.org
forward slash x
forward slash drivers
and then
you can put in the version or the tag or
whatever or i think you could just leave
it blank then we leave it blunt i
believe you can just leave it blind okay
so i guess we uh
so if we exit this yeah i need but just
in case and then if we try now to go mod
tidy
tidy like to tidy up
exactly
wait let's go to your computer there we
go
so go mod tidy should
update all the files necessary
go errors parsing go mod
another dependency all right so we
didn't add to that quite correctly so
let's go back to the notepad
so you need to maybe some extra lines
first of all
also it looks like it didn't need the
version
ah okay so if we go back to the end of
that line and we type v
0 dot 16.0
and we new line and we save that make
sure you save it yeah
and try again ah tidy right
it's doing something okay so this should
be fetching down the module
and now it actually is
it's pulling down all of our
dependencies
and
um
there is a
[Music]
um there was an error in one of the
samples but it won't affect us right now
so we should be able to if you say uh if
you type
the go.mod file now typespace
go.mod
so if we now type go.some
go dot
type the word type
sorry go the word type
so like these
forget go no
just the word type space
and then go dot sum which should be the
checksum
of all the files that we just installed
go ahead
and it didn't actually generate the file
but it looks like it did install
our dependencies so it might have worked
so let's go and try to compile again
because we'll deal with these other
dependencies are for a future step
so if we go to back to the tiny go build
exactly so that hopefully we'll know no
i'm missing go.some entry
okay so let's go fix the problem
with um if we go over to my computer
here and we see there's some older code
here that's causing this to occur
so if i go and i look to see which one
of the examples it's probably step like
six five six or seven
it's not five
yeah here we go
so this uh kanoheon ninja
danial esteban who's one of our team
members
he was the original creator of tiny draw
and tiny font which is what we use for
the displays
but since that time
those projects became part of the tiny
go organization
so we need to put these
in
as tinygo.org
forward slash x tiny font or else it
can't resolve our dependencies
and so i will fix this and then you
should be able to just
pull down an updated version
from um
the repository and it should work
so let me go and update my
again
so if i go in here and i say go um
go mod tidy
it should update
the various dependencies up downloading
kaneko ninja tiny fonts it must still be
in there somewhere
so we don't want tiny fonts we only want
we want tiny font and tiny draw from
the correct repositories
which is the tiny go
organization
they got moved after the time that this
workshop took place
and i think if we just um
that sure that worked
let's see
still somewhere in there
which program was it
i wonder
oh i know why
because we actually have the fonts in
here
this needed to be updated
as well
this is an actual rendering of the font
as it's displayed
um then you go tinygo
dot org
okay
go
dot org
x tiny font okay that's where that keeps
pulling that from
that's why i can't find the right uh
it keeps thinking that it's in there
well there's still another one
does not contain package
oh yes because this step 7 also got
changed
only now are we getting to the point
where some of this stuff are we catching
up here
this would be drivers net mqtt
yes
we moved a few things around
okay
so now it should be fixed up
now if i just add everything
and i say git commit
and we'll say mod
update references
to match
latest
tiny go
and friends
and if we push this
i could have just done it from the root
directory git push
origin master
still on the master as opposed to a main
branch
okay
so now if we go over to
and if you go up two directories
so just cd
cd
dot dot
xl dot dot
so now you're in the main directory for
tiny go and so git status
uh it doesn't connect to my
okay ah yeah it's
so you've made a few changes
right
so
but we don't care about those changes so
now if you say git
reset
space
dash dash hard
okay that will do a hard reset and wipe
out the changes that you made
okay okay so now if you say get
pull
we
space
dash dash rebase
because we don't want a merge command
space origin
space
i mean pulling it from the main repo and
then master
this will pull down the latest master
branch from the from the remote repo
from the origin and it will rebase it on
top of our current
branch so that should do it
that's one of my favorite commands
okay
so now we have the write go mod and go
sum file because i checked those in
so if you change directories back
and what was the name to uh sensor
sensor arduino
that's it yeah and now up arrow
to wherever that last command that
failed was
that's it okay
i go
much better okay so now all we have to
do is flash it with the boss at command
good news
exactly go to the mind map
so it's possible offset we have to
change one step
before
we sorry exactly
and step four not being
right that looks like it yeah we
probably have to tap the button to put
it in bootloader mode for this though
i don't i don't remember let's find out
let's try it i go and we'll see no
device found so yeah um
like how was it where was it on com we
changed it to com10 actually
we do have to double tap
one two three
let's see
maybe it is eleven
this one goes to eleven
let's try again now that we we said
no um
how was it
the
other day we did something
we went into the device manager
and it appeared
under porch i believe
it's 13 now oh now it's 13.
let's try it
that's more like it
looks good
okay so now it should be running
so what happens when you push the button
let's see um the push the button no the
normal one it should still
oh
yeah i mean this is the same behavior
now we should
have this extra no yeah
scary
it works
morse code
exactly
yeah
it's a beauty london calling
i enjoy this the clash still the only
band that mattered until rage against
the machine
yes um very cool fantastic all right we
made some progress so let's see what do
we do
we
did a bug report
with
the issues with tiny go flash on windows
and bossack
we you wired up
the step
we
updated the repository so that it's got
the correct set of dependencies so you
were able to actually install it
and it even works
fantastic
one thing i want to ask next time maybe
if you have time we look at the driver
or things like that if you don't mind
okay would be well if it's not too
complex stuff but just to see since this
is a simple device maybe well we should
let's take a look right now
just because i actually wanted to do
something on another driver
so let's take a quick look here
at how drivers work
so the tiny go drivers repository
is a separate repository
that let's bring it up in github
in the web interface
so the tiny go drivers repository
has um how many
different devices currently supported
temperature sensors accelerometers light
sensors
displays
more displays
servos
all sorts of things
and so the way it's organized is we have
the drivers themselves
and then we also have examples that show
how they're used
right like if we look under buzzer
we'll see
a very small version
of an example using the buzzer
where it's very similar to what your
program was doing
it was configuring a pin to use
an output pin
telling the buzzer to use that
and then calling some functions of the
buzzer in this case buzzer.tone
which knows how to play a little song
okay although it doesn't sound that
great because i mean it's only a buzzer
so if we go and we look at the actual
repositories buzzer directory
we'll see that
in there we have two files we have
buzzer.gov
which is what contains the definition of
the buzzer itself
and then notes dot go which is
the definition for each of those notes
which
what's the hurts yeah that corresponds
to that right
so if we look at buzzer here
so we'll see that
instead of the package main it's using
package buzzer
since ingo the package name tells us
what is the what's the name of the
package to be used
and this is a package that's meant to be
used from another package okay
right so it's called package buzzer that
way in your program's package main
it could load
the buzzer package exactly
so it also has imports
the machine import that we talked about
the machine package which is the
hardware abstraction layer
and then the time package which is the
standing standard
tiny go time package
or go time package
so then we have a type
yeah so in go
types
can be
simple types like integers or floats
and they can also be
like see a struct like c structure
and a struct has different members which
are or fields
so in this case we have
three fields
one is called pin and it's a type
machine dot pin
so that's how we keep track of which pin
is being
connected to
then we have a boolean value high
which i gather is whether it's high or
low
and then bpm which i think is beats per
minute yeah that way if you're trying to
make it play back i don't know how well
that really works so the the fast
the higher let's say the frequency i
guess
i guess it would be more like the faster
than it plays back it's got some kind of
playback mode okay
so our new function
because it's not an object-oriented
language
right it's a package level function so
it's buzzer dot new
and it returns a device
so in this case it's returning a struct
type
of struct device or structure type
device i mean yes and it's filling in
the fields for us pen is equal to the
pen we pass as the parameter okay
and then the other ones are being
initialized to default values
now if we wanted to change these values
in go
any field that's capitalized is public
okay and any field which is
lowercase is private okay
so
we have no way to change pin
from the outside without some type of
you know accessor function
but high and bpm you could change at any
time okay
right so
just an
important thing to know that is also
true with with uh functions
so this function on
is exported so that i could say
buzzer.on
but if it was lowercase then that would
not be exported and so i wouldn't be
able to call that from another function
so that's how we can define our
interface that we want other packages to
consume
and our implementation which is how we
do our own work but we don't necessarily
want other packages to worry about
so
the uh function that we were turning we
used uh was it on yeah so on just turns
on
the pin
just by turning it on
and then off does the same
but if we want to produce an actual tone
that's where we can pass it the hertz
and the duration
and it will do a calculation
based on your typical speed
of what the tone is and then it will
turn on and off
quickly to generate
you know kind of a
simple pulse width modulation style tone
okay
so it's not the most sophisticated but
but it does get the job done to you know
make bleeps and bloops fantastic
so that's how the the buzzer driver
works now it turns out there's actually
a much better
driver
for creating sound it's called the tone
driver
and the tone driver is one that was
created recently by ike
who is the actual founder of the tiny go
project and it uses pulse width
modulation
and it can use direct memory access so
it can produce much better sounding
tones and it doesn't require
the microcontroller to be busy while
it's doing it do you need on the same
kind of device like this one or maybe on
a speaker on a small speaker probably it
could work on this but you'd have to
have a pin that supports pulse width
modulation
okay so that's a little beyond
what we're doing right this second but
we can do that um in a future
iteration very interesting fantastic
i know it's a whole world of tiny girl
yes yes
okay cool so your homework um
for next time
is uh the same as the last time because
it seems like we're making some progress
here yes uh i agree
cool thanks for coming man my pleasure i
really appreciate it this is awesome
thank you very much great fun great fun
also thanks thanks so much for helping
find these things that need to be
updated
in the workshop
usually we do this and like right before
we actually do the workshop we like oh
we got to fix these things and we update
them real fast and
then people come in and
we've done this step so this is the
preparation thank you great great i'll
bring my stuff on yeah because i'm going
to need uh to get them some space here
for some of the next let's see next some
of the next one fantastic
well all right cool all right thank you
see you next time ciao
cool
yeah
we're making some real progress here on
uh improving
or fix updating i should say the
workshop content
so many changes in tiny go since the
last time we actually got to do a live
show
man it's crazy
all right
so um
i thought it would be good to take a
look
um
at a couple of the outstanding pull
requests actually there's been a lot of
activity
over the last week or so
and
so last week i was trying to get a
couple of tasks completed
one of them was this new pull request
for
the sd card support
which um
sago 35 has been working on diligently
and we've actually gone through a whole
series of rounds of testing but
unfortunately it's not yet working we're
getting really close though hopefully
next week
but in the meantime
um
yuri soldak who is one of our new very
prolific contributors
i guess basically went crazy went went
all out
and started in on doing some refactoring
of the wi-fi nina
driver
which if you may recall that's the
driver that we use for
connecting to the esp32 wi-fi chip for
doing
internet of things style things
and
so
they were working on um
if you recall a couple of weeks ago
the wi-fi nina driver was desperately in
need of some tender loving care
and a couple of different people had you
know done part of the work to get it
there but it needed you know a really
big push
and so they went in and got it all
basically to a functional state
so
this week
um was that yesterday yeah 19 hours ago
um
they took a look and they said wow you
know
can we make this smaller like can we
shrink this down
it's it turns out that if you use the
format package the font package
which is part of the
standard go packages
that the front package needs to use
reflection
so reflection is a capability
where a program is able to look at
itself
information about its own operation
you know metadata about the program
and then using that
make some decisions about how it's going
to execute that run time
so
in go this is commonly used as a way
for parsing json since we may be
receiving an arbitrary json document
with different fields and different data
so
the front package
which is part of the go standard library
happens to use reflection
and using reflection
in tiny go
requires increasing substantially the
amount of memory that we need because we
have to include a bunch of code that if
we don't require reflection we can get
around and we can actually optimize out
so it's not part of the final binary
so
why sold act took a look at this and
said hmm
i bet we don't need the front package
so
these were their results
so the original example
with the original driver
55k
okay not too bad
new example
with the old driver
because the old driver still requires
the front package
55k
okay so it still dragged in that
dependency and it still required it
but the new example
with the new driver only 30k
oh yeah i like it
that is a substantial weight loss
program
apparently highly effective
so
let's take a look and see if this
actually works
because uh if so i'm merging this right
away this is totally awesome
so
first thing we're going to do is we'll
check out
so let's go over to our drivers repo
directory in our command line
and let's make sure that we
get pull rebase origin dev to make sure
we have the latest oh i have some
changes one of those changes
uh hmm
let's stash those changes
okay so we'll pull
all right good
good
let's see what our commits are that we
pulled in yeah here's the
uh
oh yes okay so these are all the latest
changes
um
that are in this dev branch
so now if i
get check out dash b
for creating a new branch
so it's going to create a new branch
with this name y sold act wi-fi nina
avoid front
and it's going to create the new branch
based on the current dev branch
okay so far so good
and then now we're going to
get pull
except we're going to also say git pull
rebase so we don't add the merge commit
so we're going to say git poll
dash rebase
the name of the repository which
they have called tiny go dash drivers
and then it's going to pull down this
branch
wi-fi neenah avoid front
and it's going to rebase it on top of
our current dev branch
okay
so far so good
and then if we
um
let's go and let's take a look and see
what we got
so
in the drivers repo
under the connect
we will see that there is
this is actually now is using stir com
string conversion instead of font
so if i get rid of this access point
info here because that is actually um i
put it into a separate file
so now i should be able to test this
just by building that right but of
course i'm going to need to get my
[Music]
chip
pulling out my
get a little focus going
so this is my arduino nano 33 iot
there's the wi-fi chip in question
so if we plug this in
so we can flash it
and
let's plug it in here to the
computer's usb port
okay very good
and then
so now
what i want to do is i want to say
tiny go
flash
and now i'm going to use size
short
what is that
so that outputs
that's not the size of the program
maybe that's not the best named flag but
we couldn't come up with another name
that is going to output
the short version
of the statistics
for the build which is how we're going
to be able to see
how large the actual file is how much
ram and how much flash it takes up so
tiny go flash size short
target
arduino
nano 33
right and then we should be able to say
examples
wi-fi nina
connect
and that should
and yeah 30k
it's really small
all right so let's go over to my
terminal
somewhere here
and let's see if we can connect
connecting to the hackspace why
trying to see if it can connect to yep
it connected
that is the ssid
there's our relative signal strength
indicator
the mac address
that is on the board
that the the wi-fi nina chip
the esp32
the ip address it was assigned the
subnet and the gateway and that's our
time
and yes it is today
and it is 1600 hours utc
which is 1800 hours central european
time
wow cool this seems like it's actually
working
amazing actually
i mean
seriously that is so cool
if you can chop off 20k of a 50k program
oh
man
i love you that is so awesome
i can't wait to merge this this is just
like
anything that makes tiny go smaller to
me is
miraculous
and useful
so let's uh let's merge this in
this is great
this is
really great
it's not just great
thank you so much
for making
things
smaller
now merging
and it's going into the dev branch so
yeah
looking pretty good
rebase and merge
yes
oh man that is so cool
i love making things smaller and i love
when
my
new internet friends
make things smaller
that is great especially um
30k may not sound like a lot but it's
pretty substantial
you know if you want to use
i know some people would like to use the
wi-fi neenah driver
with an arduino
classic with an avr processor i don't
know if this is going to make it work
but at least it's going to start getting
you down
into the size of binary where it's even
possible
just because when you have
you know such a small amount of ram
knock off 20k
maybe it's maybe we're in the range now
so i guess we'll find out
that is really exciting
cool
all right so there's there's another
thing i wanted to um actually work on
that a bunch of people have been
have been talking about and we talked
about it briefly last week
which is this outstanding pull request
for
well new
outstanding pull requests for adding
support for the raspberry pi pico
rp 2040 microcontroller
so
um
as you probably
if you've been
living on another planet even you
probably still have heard about the new
raspberry pi
which is the first actual
microcontroller it's not a single board
linux computer
it is the next smallest thing
so this is one of the
raspberry pi pico boards from the first
production run
which
i got sent by raspberry pi and it's
lacking a board here which is the new
raspberry pi connect which has just come
out has on it
and u-blox uh esp32
wi-fi chip is right here so you can see
where
adding wi-fi to this makes it even
cooler
right
so um
anyway
this work has been going on for a while
to add support for the
this cool new board
several people
worked on it
and
got it partway along
and
rhythm crazy
is the
lucky recipient
of the gothic to the point of where it
looks like it's actually ready to
uh to be merged in
right
so
if we take a look and we see there's
there's been a lot of work that's gone
on
and several people
even why soldec
has confirmed that it works so yeah
that's that's all looking pretty good
so this pull request actually was a bit
more complex because it had to add
not just your usual support for
new registers and new hardware
compatibility
but it also needed to add support for a
new
svd file
so svd files
let's see if i can find one to show you
an example
so svd files are the
system description files originally
created by arm
and now
you know really sort of turned into a
semi standard
and i believe there's one in here
it's svd not fe not svg svg are graphics
files
svd files are the system
[Music]
value description or system version i
forgot what the v stands for
but it's a uh
no that's not it
um let's see
i want to show you one just because it's
like it's pretty impressive um
let's see
source
maybe
yeah here we go
view raw it's very it's so big it's raw
here we go it's a giant xml file no i
mean it is a giant
xml file that contains the all the
descriptions of every single register in
the entire processor along with actually
kind of a description of what it does
and
so this is what tinygo uses to actually
generate
the
files that are used for the device
package which if we
take a look at the tiny go
documentation
if we look in our
concepts i believe
we could take a look at this mermaid
diagram
that shows us that the
when i was just talking about the device
package is generated from those svd
files and that is what the machine
package which is the hardware
abstraction layer uses to know how to
communicate with this very low level
hardware
right cool
get the idea
so we had to actually add that file to
our repository that we use upstream of
svd files
as well as all the other work that had
to be done
to
add
all of the definitions for the pins for
the board
the initialization
for the different clocks
for the gpio
so let's go and see if this actually
works now with all the latest versions
of the dev branch
so if i go over again
to my command line instructions
oh
it's my son
oh missed the call i was going to bring
him into the stream
darn okay well next time he'll probably
call back
damn i need help with my homework
okay so uh where are we oh yes so let's
first we'll check out
let's go to our
tiny go
and so if we say
git check out
dash b
for creating a new branch
named rhythm crazy dash pico and based
on the dev branch
okay so far so good
and then we'll do a git pull but we'll
also add dash dash rebase because we
don't want the merge commit
all right so git pull
dash dash
rebase
and then the location of rhythm crazies
git repo
and so we're going to pull that repose
pico branch down
and we're going to do a rebase onto the
current branch in my local directory
and it did work
all right
so now if we do make
which should
build our latest binary of tiny go
which we need
actually let's interrupt that because
before we do that
so we need to
make sure we've got the latest versions
of our sub modules
so i want to say
git sub module update inet which will
pull down all the latest versions of our
sub modules
and
actually we already had them so we were
okay
but it's always good to make sure so
we'll do git make
and that will build the binary
of the tiny go compiler itself with all
of our latest goodness in there
and then
after that
which it just takes a little minute
because it's very good
so we need to copy that
and now let's run tiny go version
and you see that the it's the
0.19.0 dev
and 71cb is the last commit and so that
should correspond to
um
hmm
where is the
files i'm expecting from the
well they just pulled down
because i did do the get pull
rebase down from pico
and that sugar pulled down those recent
changes
from
um
i'm not seeing them in there
because the commits that we should be
seeing oh wait there's only one commit i
see
it's just one giant commit now
there were a few commits before
i see so it's 88 e7
so let's go and there's probably some
other commits after it
let's see
i'm not seeing it
that's kind of weird
wait there we go
there's the commit
right here
and we can see it's got all those files
in there
okay
so with this we do have the file so now
if we say make gen device
so make gen device
runs the
go program which actually
uses all of those sd
or sdv files and generates all the
wrappers and you'll see it
did all the
nordic semiconductor and right now it's
doing all of the
atmel at sam boards and they already had
done right before that the espressif
boards
so there's a lot of svd files
for the many many dozens or hundreds of
different kinds of processors
so
we needed to have that update
and
let's see
that was updating the kendrick
risk 5 and there's the nxps
here come the
stm32 boards
there's a lot of boards
we don't have support for every one of
these boards in tiny go but we have
quite a few
um
not even a fraction of the total sum
though there's so many boards
all right and then
i was expecting it to do well we did it
anyway manually make gen device rp
and now that's built the
raspberry pi 2040. okay
so now we should be able to go time you
go
flash
target
i want to say pico
let's go and look and see what's the
name of the target
if we look in the
dot json file
that
corresponds to the target for this board
down here at the end
we'll see that it's actually named
pico yes okay very good
target pico
i guess size
short so we can see how big the file is
and then
let's do examples
blinky1
and now we need to naturally plug in the
board
so
we'll plug it in
to the
usb and then the uf2 bootloader
should be able to take effect
so now if we go back to our
this is our command and
4k program
it failed to flash
unable to locate device
rpi
rp2
okay usually that means that the name
of
the
um
mass storage device is not what we
expected it to be
so if i double tap the board
which should kick it into the bootloader
it's supposed to
hmm
i thought it would but it's not doing it
okay interesting
i thought that was all we had to do
let's see do we have any mass storage
devices that mounted
no
hmm
it's not boot it's not kicking into the
bootloader
not off to a great start
but
let's see
i thought that's all we had to do was
double tap it that's what we normally do
let's go and take a look and see if
anything
well let's just try to run it again
nope
okay
let's see
i thought that's all we had to do was
double tap it
so let's see
raspberry
raspy
pico
bootloader
double tap
i don't know
maybe we have to do it real quick after
plugging it in
uh oh
not after a great start i don't think it
has to do with the pull request though
just like it the board itself is not
responding
hmm
it did solder this board earlier but i
don't think that would affect it
generally no
but
oh you don't double click reset instead
hold down boot select during boot all
right
yep i heard the noise there it is
okay
so it mounted
i don't think the uh
i think the part that's not working yet
is the part
where it kicks it into the bootloader
okay so that time it flashed it
and now we can see
that in fact it is blinking
okay
so it looks like in order to get this to
work
we're going to have to
boot it
with the button turned down
we don't have the 1200 baud port reset
that we use for flashing other boards
yet so it's not
perfectly convenient but it does work
wow
okay
that's actually pretty incredible
so
a lot more work needs to be done
but that is a very substantial bit of
progress
and
i'm not really sure that we should try
to do anything more on this pull request
before we merge it
just because it's been
you know
so long in coming
and there's also a lot more work that
needs to be done
so i think we should merge this as it is
and then we can proceed from there
so let's um
so this was actually the original work
done by
jeff m hastings
um
to end up with this so let's
i mean let's just get it in
so
tested
and appears
to work as promised
thank you
rhythm crazy
for getting
[Music]
it
ready to merge
and thank you
jeff
where is it i think it's jeff m hastings
yes
this is jeff m hastings
[Music]
and thank you
jeff m hastings for getting
so much done
to get it started
now merging
oh my god incredible
i mean there's still a lot of work to be
done
but
that is substantial progress
wow
pretty incredible
so let's get check out dev
and let's get pull
rebase origin dab so we can get that in
there
wow
unbelievable
at last
minimal raspberry pi support
but
minimal is just minimal
right like that's just to start
so what i thought we could try to do
we don't have a lot of time but we have
a little bit of time let's see if we can
um add a bit more support like maybe for
the
digital end not just out
right
so first thing i thought we would do is
um
we could try to
finish soldering up this board
the pins are not actually soldered to
anything they're just sort of hanging
loose we could see that on this camera a
little bit better
um i started doing a little bit of
soldering on this before
but as you could tell i didn't get that
far before my battery operated
soldering iron ran out of the battery
and because my good soldering iron was
down here at lapipa
so let's just do a little quick solder
job on this thing so we can
try to um
plug in
some other devices like maybe a button
right so i got my soldering iron here
and
it's a pretty good one
it gets a lot gets nice and hot
i got my sponge
which i
wet down so that i can
try to clean the soldering tip
and i brought a chair which somebody
took oh no it's over here
they didn't realize i actually needed
this today they thought it was just i
thought i was going to sit down and
start playing some keys
that's also fun but uh
there we go all right
so let's take a quick look here and see
if we can just solder it up so let's
turn on the soldering iron
and got my solder
and we can
see that most of the pins are not
soldered
so we're gonna have to do this real
quick there's a bunch of pins
but i'm generally
not too slow i mean i'm too slow to work
in the factory i would definitely get
fired like my first day
but uh
and we got the temperature here so let's
turn it up to
maybe i don't know five six pretty hot
and we can tell it's starting to work
because a bit of smoke will come out off
the tip
it's making a little hissing
you can't hear it over the fan of the
computer doing the streaming probably
starting to heat up
so we'll use some solder to clean the
tip
i have something better to clean with
but i don't want to look for it right
now
and then we'll wipe that off you want a
nice shiny tip
so that you can have a nice clean solder
joint
otherwise a cold solder joint will not
conduct electricity very well if at all
all right
good
looking good
turn it down a little bit
all right so let's do
let's just
heat up these joints from before
okay looks like it's still straight so
we'll
go for a quick series
i like to do one right after another
there we go once it gets hot then it
works well
if it's not hot enough
generally it won't solder
a little too much on there
get this
it's cleaner a while since i used this
particular soldering iron so there we go
now it's nice and clean
but i think it turned it a little too
turned it down too much
let's get a little hotter again
if you get the right temperature it
works great
if not
well let's just say
[Music]
all right
now it's hot enough
all right so let's do this
it's not really getting quite hot enough
there we go
once it gets hot it works great
and the
solder will just show the flow
and then
try to inhale the smoke
don't inhale man
okay
almost halfway there on the first side
cool
cool we all have to do this once luckily
all right almost there
now you can see why i could never work
in the factory
actually i do work in the factory
sometimes but
not not soldering things let me tell you
well first of all this is not how they
do soldering anymore
they use ovens
and they solder all of these joints all
at once
very very quickly
i don't have a reflow oven
i know some people have used like a
toaster oven to make a reflow oven
and
i would like to do that as well
but
i don't normally do that many soldering
of
of uh
surface mount components
i generally use three hole use through
hole components
so
okay
and then let's heat these up from before
so that they're a little shinier and
nicer
and we're done with side one no
side two
when it flows in there it's really just
pours right in
you need a second light
and when it yeah there we go
now you can see it
let me use the soldering in the dark
you can see it just kind of pours right
in there
once the pin gets hot
the solder pours in to fill the hole
and then you have a good connection
that is really important
with these digital electronics
all right just a couple more
we're almost there
one more or actually two more
and then let's go and fix these
so that they're nice and smooth
and then this one
let's just go get this one here looks
kind of
not so good
oh i can't connect them there we go
all right that's it we're done
clean off the tip
and turn off our soldering iron
and our
everything is nice and
even
so then i just need my breadboard
brought for this exact purpose
and we will
plug it in so that the
usb is coming out the top
and so that there's two pins on each
side
just to plug things into
and make sure it's all lined up
and then push it in and
if we haven't destroyed the board when i
power it up it should start blinking
again right
oh we got to plug it on both sides
and it still blinks
okay so we didn't kill the board that's
good
all right so now let's see
if we can take a quick look
at what we might need to do
in order to add
the gpio in
so
first thing let's do is get
checkout
dash b
and we'll say
rp
gpio
n
whoops
i didn't mean to name it that
gpio
in
there we go
and let's get rid of that extra branch
git
branch
dash d
rp and then what was it this bracket
there we go all right
so
i took a brief look before
at
the
um
data sheet
so
data sheets are very long documents
usually in the form of a pdf file
that are distributed by the
manufacturers of processors and boards
this one is 647 pages
so it's you know decent size not the
largest
by far that i've ever dealt with
it's amazing how quick you can read you
know five or six hundred pages and scan
through so uh it's got a nice red cover
and
the table of contents here
tells us all about the different
capabilities and pro peripherals and
blocks as they're known because they're
literally blocks of circuits that are on
the surface of the wafer of the chip
and so if we take a look for example
at the pin out reference you'll see
this is the pin out of the chip
now you might be wondering what does
that
weird looking square thing
have to do
with this actual board
right
well this is the pin out for the chip
itself
so not wherever the leads are that the
chip connects to on the board for
whatever pins these are the actual
pins directly the gpio ports on the chip
itself
right so if we want to know what's on
the board
then of course we have to
take a look at some picture that shows
the pins on the board
naturally the raspberry pi like a bunch
of these boards the silk screen that
labels the pins is on the bottom side of
the board so we can't actually see it
while we're using the board so that's a
little annoying
but not totally surprising
so if we took a look again back at the
table of contents
we could see that
it's got the power supplies the memory
the power control of the chip the
different oscillators that control the
timing
of the chip and its different
peripherals
and we'll see that it's got the gpio
which is the general purpose input and
output pins on the chip
so let's go take a look at the actual
code that we've written
or that's been written since i haven't
written any myself quite yet
and if we go take a look at the
machine package
and we look at the rp
files that we just merged
wherever those are in here
oh
one thing about
sometimes visual studio code doesn't
like when you
update very large
files so
it can't refresh anymore it actually
tells you that when you first run it
like this workspace is too large for us
to refresh or something of that sort
anyway let's go back to the machine
package and now we can see our rp
and if we look at rp
underscore
gpio.go
you'll see this is listing the different
registers and
that are being used for the
different parts of the
pio chip so it turns out the raspberry
pi
rp 2040
is not just your garden variety type
chip it has a separate chip
called the sio it's not pio sorry the
sio
which is
a special separate io coprocessor
so it actually is able to do very fast
processing because
one chip is doing just these peripheral
ios and the other one is coordinating
all the work
so
this sio chip is a multi-purpose
i o so it can be used to do not just
your general gpio for turning things on
and off
but we can also use it for other
interfaces like the spy interface
which is the
serial peripheral interface that we use
for things like displays
the uart interface that we use to
communicate you know text with your
terminal etc
right so
let's go back now that we know that
again to our definition in the tiny go
board or machine file
so we'll see that this is talking about
the different function selectors of
being able to choose
on that sio
what is the function it's going to
perform right whether it's going to be
as we were just looking at the the spy
function or the uart function the i
square c
or
in the case of what we mostly care about
right now right which is the
um pio
i believe the peripheral io
or the
so let's take a look here so we've got
our pin mode
for output we're going to need to add
one for input
so
pin
[Music]
input
so that gives us a pen mode that we can
switch to
all right so far so good
and then these are some functions that
are used for the set
this is the set itself
and we can see that the way it actually
works is it takes the pin number
and then
it bish bit shifts that position because
the way that these pins often work and
we can see
if we go look at the
data sheet this will actually tell you
that
each one of the pins
has a position a bit that corresponds to
or each one of the banks has a position
that corresponds to that one particular
pin
so pin zero would be in the zeroth
position
pin one would be in the one position and
so on
and so if we go and we take a look we
can see
that's how this set function works is it
says
set bit 1 on to whatever bit corresponds
to the pin we want so if it's pin 0
it'll set the 0 bit positions would be
0 0
zero zero one
and if we wanna turn on pin one it would
be zero zero zero zero
zero zero one zero and so on
and then based on that mask
meaning which bit we want to turn on
it uses the sio register
or sio block i should says gpio out set
register
so this sets the
pin to on
and then this clear does the opposite
it's to turn it off
it uses the
same sio register
but now it use or block i should say but
now it uses the gpio
out clear register and it sets that so
i know it seems odd to set something to
clear it
but
that's actually setting this bit
actually turns off the voltage to the
other pin
and then we have an exclusive or which
is
to leave all the other pins in their
current state and only
turn on the pin so turning on or off the
pin if it's already on it'll turn it off
and if it's ready off it'll turn it on
so flipping it essentially
and then we have our couple of helper
functions which are
this sets the function as we were
looking at the list of functions that
are supported
and so
this turns that function on to whatever
pin function which i would assume
let's go and look and see what that is
set func
and so we're using the sio function in
other words this multi-purpose
ability of the block where we can use it
for gpio or i square c or whatever so
we're telling it
use the
sio function so that we can turn we can
just treat it like a normal gpio
and that's what this init function needs
to do
um
okay so far so good
so then our configure function which is
what we normally call when we're
programming in tiny go
if you remember our blink function that
we had to
declare a pin and we had to set
configure it to be output well this is
where we actually do that work
right so in this case we already have
output so we want to say
case
pin
input
and what should we do
when
our pin is set
to
input well i will guess
that instead of output enable this looks
like gpio output enable set i will guess
that it's input enable
i'm just guessing
let's go take a look and see
if there's a gpio ie set in the
datasheet
so this is um
sending an i o function using a gpio
interrupt which we're not quite ready to
do
um let's go back up to the top here of
the
list of functions
for gpio
um
actually i think we need to be in the
sio function
if we go down here to the
actual
pio overview because we're using the pio
function directly now right
and we look at our
um
no we are sorry we're using the sio
that's right not the pio
so let's see
gpio control
and then we have our gpio
output enable
and then we have our
gpion
i think they're default to input
and they only turn to output
that's what it kind of looks like
because we see that there's
gpo output enable
output enable clear
that's if we don't want to use it as an
output so we probably need to do that
right
like we probably want to
not use it as an output if we're going
to use it as an input just in case it
was already set
so we would want to say gpio output
enable clear believe it is
clr yeah
because i don't see an actual input
enable
so
i will assume that if we turn it off as
an output
then it's no longer an input so that
would be output enable clear
clr
and we don't need to set it as
input
so that should
presumably set it as an input
right
looks like so far so good i don't know
what i'm doing but i'm making it up as i
go along
pretty sure that usually that's all you
have to do
is that
so now the last thing we're going to
need is we're going to need to write a
get function
so get
reads the pen
the pin value
and so
[Music]
it's a gap
and it doesn't take a pen a bool
it returns a bool
and so now here is where we have to
actually retrieve that
and then you know i guess return p dot
get
essentially which we haven't
defined that yet
but we will right now
right that way we have a little wrapper
so gout should look a lot like set
and we'll put it at the end of the
those other functions
and so get returns the pin value
so it's get
so now what are we doing
so we need the same to set a mask right
and there's actually an example of this
in the data sheet
we say
i believe it's up here with these code
examples
clamp mode no that's just something else
let's go to the top because i'm pretty
sure it's listed in our table of
contents
there are some examples
even says examples
let's see
gpio
there we go
and it even shows us
where are they
here we go software examples
all right
so set an io function we already did
that
because we know we need to choose
the um
sio
right
and we don't want to enable an interrupt
because we're not reading an interrupt
let's see if we those are the only
examples
because i saw it in here let's see
gpio
get or maybe just get
i know it's in the
i ran into this before and i
i was just sort of
gazing at the data sheet going
how am i going to find this again
[Music]
let's see
i know it's in here
i thought it was under software examples
no that was what we were just looking at
um
let's see
peripherals no pio no
that's funny because i was just looking
at it's not the same list of examples
ssi
[Music]
i was literally just looking at this
example so there's two sections of
i was just looking at it before
let's go let's just look at the code and
see if we can kind of guess
because it's gpio
in
i believe
and that would be get
because what we want to do actually well
we want to get the value
and then
we only want to
we want to get the value and then return
only
the bit that matches the pin
that we care about
in other words
if we go and we take a look at the
sdk
we can see an example of that
in this um
i think it's rp 40
no
rp2 common
hardware gpio
i believe it's in here
that we can see an example of this very
function here we got gpio get function
and that is the function we're looking
for the definition of
um let's see
is this it
yeah here we go
so we want to look at the the hardware
gpio control
that's not exactly what i was expecting
i know what we need to do is we need to
look at the
register
let's go back to the top here i swear i
saw exactly the code for this but
maybe it was in here anyway go back to
the data sheet because we're almost out
of time but
we can at least take a look at it
we can see that the
gpio
registers that we are looking at
if we scroll down a little bit here not
the interrupts
not the pads
but we can see what we want to do is not
set function
get if there's a get in here somewhere
here's the registers
so we can see that we want to
[Music]
read the gpio
i'm going to say in
[Music]
that's worth a try
p i o
n
yes here we go
so this is an example of what we want
right here
we can copy this function
and we don't quite have time to
implement it but let's just take a look
so this is
taking the
it's shifting over the bit of the pin we
want and it's comparing that to the
value
of the sio gpio in
right so this vowel
we want to take the value
and we want to
[Music]
shift over
val
because that's which bit it is
so
we want to basically test to see is
val's bit or actually we could even just
say it even easier we could say
has
let's say has bits
and then
one
shifted over
p
so this is not exactly correct but it's
almost correct
in that what it's saying is does this
register have a bit set in that bit
position
so i'm not quite done with this but i'll
see if i can finish it up uh this
evening we're we're pretty much out of
the time now we got pretty far along
well so what we actually get to do
we
took a look at our state of the art
where well actually we heard some news
we saw that yes i am a true thought
leader if i could only think and if i
could only lead
maybe i'm a thought follower
what's the opposite of thought i don't
know thought it's its own opposite
so yes
we took a look at some of the cool news
of the world yeah the chip shortages are
still bad but some people like oxide
computer are just going to build
high-end systems anyway
and we
worked a little bit on our
tiny go workshop uh with lorenzo and
reporter the bug upstream to flashing on
windows
then we got a couple of per merge
pull requests merged
in particular the raspberry pi which we
tested and in fact does work
and now i'm hopefully almost done with
adding the gpio in
so
by this time next week
i will expect that i will have it done
so
with that gopher but what's that
are the batteries oh no
well next week more will be revealed to
you dear friends of the internet so
until then i say
farewell
[Music]
oh
[Music]
foreign
