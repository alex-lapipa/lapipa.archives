---
document_id: "LP-MEDIA-YOUTUBE-VIDEO-7XW1M9V15YO-DOC"
source_id: "LP-MEDIA-YOUTUBE-VIDEO-7XW1M9V15YO"
title: "S2_04_DEADPROGRAM@LA PIPA"
language: "en"
document_type: "youtube_video"
origin_uri: "https://www.youtube.com/watch?v=7Xw1m9v15Yo"
verification_status: "provider_metadata_captured"
access_scope: "public"
content_sha256: "258c28b4f17b98b027c21863325396a9db42e6bf1991bf5f788a7da6910bcf1b"
---

# S2_04_DEADPROGRAM@LA PIPA

Archive source LP-MEDIA-YOUTUBE-VIDEO-7XW1M9V15YO. S2_04_DEADPROGRAM@LA PIPA.

YOUTUBE video accession record.

Canonical provider URL: https://www.youtube.com/watch?v=7Xw1m9v15Yo

Provider identifier: 7Xw1m9v15Yo

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
we were talking i was talking you were
not hearing but i was ranting about
copilot
the new ai code completion software from
github
that it has analyzed all of the code
that you've ever put on github that was
not private repo and looked at it and
using openai it is going to spit it back
out to anybody who installs this editor
so that's very interesting
um
turns out is it just auto completion
just really fancy auto completion did
they brilliantly re brand autocomplete
in vs code is that what this is about or
is there more to it
well
apparently some people don't like what's
going on one bit
so evie here
has basically said okay
github is taking all this code
regardless of the license and
regurgitating it back out based on its
own license and so as a result
maybe that's no good
so some people have actually looked at
the numbers
i'm not sure who this researcher is or
what their methodology but let's just go
with it
and it's proposing that in fact
the
number of lines of context of the what
you type in determines directly how
close is the matching text in other
words if you type in exactly
something a line that occurs in some
other code base the auto completion is
very likely to be the entirety of that
thing from that other code base right
which sort of makes sense it can't just
mix and match code randomly or that
wouldn't work at all
but
turns out some people have noticed that
in fact
if you type in some of these comments
let's see if i can make this big
uh hmm
no way to enlarge it
anyway this is the uh some code comments
from
some old code for
what software was it
um i'm not sure
some old software like doom or quake or
it's something that's been licensed
under the gpl
however you start typing in one of these
comments and it in fact starts
completing the comment in its entirety
as it was in the original code base
so uh
it's definitely not clear that this is
all good as far as you know what they're
using the code for
and what you thought other you know
people would be using your open source
code and its entirety and it turns out
that it can be sort of dissected and
recombined into entirely new code
wait that also sounds just like open
source development
so
i don't really see a problem myself but
also
i don't have copilot yet and haven't
used it
i know a couple people who do and they
say it's fantastic
but
i guess the jury's still out
um in the meantime
gophercon
they just came out this week with their
early bird tickets which i think they've
already sold out let's take a look and
see
i'm pretty sure that the
yes over there 77
general admission
early gopher tickets
gophercon
it is the greatest collection of gophers
on earth
this year in san diego i am currently
working on plans hopefully to be there
myself so we will see
but
there's only 77 early bird tickets left
and it is going to be of course
fantastic the organizers are brilliant
the participants are lively
everybody there is having a great time
and i hope to be there myself
so gophercon.com
go check it out and support the greatest
collection of gophers on earth
all right
so closer to home
this week we had our new release of tiny
go
version 0.19.0
and uh so that was super exciting
we we uh we wait wait before we talk
about that though very important thing
so this week
well no let's just keep going with this
so um yeah we released this new tiny go
it's got a lot of small changes ha ha a
lot of small changes but it really does
actually um there's been a lot of
activity over the last month and we
wanted to get another tiny go release
out
before
probably i would say in august is when
the next major version of go will come
out and we'll probably target the next
tiny go release right after that just to
make sure that we have compatibility
but
large number of small changes
that are actually
make a big big difference as far as
especially web assembly
we've been working really really hard on
improving our language support for all
of the features that people are trying
to use from webassembly programs
especially
from web assembly programs that don't
necessarily run in the browser
so there's a really cool project called
proxy wasm go sdk
so it's web assembly for proxies
proxies that run inside of the envoy
proxy
so what is envoy if you don't know
because you're not involved on the
server side
it's an open source edge and service
proxy
that's designed for cloud native
applications so you can deploy it on
your gateways or you can deploy it on
your servers and it lets you do
intelligent things as far as routing
you know these types of requests that
you may be getting in a centralized way
and then distributing them out for
example to a bunch of edge devices
so sounds like a very go type thing to
do
and in fact it is
and this group of people here over at
tetrate labs
have been working on a web assembly
for proxy for go that uses tiny go
because tiny go is smaller and more
efficient for their particular purposes
in particular
tiny go lets you build these you know
very bare metal type of applications
that are ideal for supporting the w
the wapi
which is the api that you need
to communicate with the web assembly on
servers
so
really interesting stuff happening here
on the server side with webassembly and
tinygo and a lot of the stuff that we've
been doing on this last release is
specifically to support this sort of
thing so we're pretty excited about it
on the device side though we've also
been doing substantial amount of work
some of it you've seen coming in lots of
amazing contributions
ike the project founder and still most
prolific committer has been making a lot
of changes for compatibility with the
standard library especially improving
support for reflect we've also had some
amazing contributions coming in from
other people adding support more and
more for the net package not complete
yet but getting getting there
also lots of new boards supported in
particular
the new raspberry pi
rp 2040 board that support is now out
and we actually have a few different
flavors of the board supported
the feather rp 2040 from adafruit which
has a built-in esp32 co-processor for
wi-fi
the feather
or sorry the nano rp24d which is an
extremely small version i believe from
seed studio
so
lots of interesting things happening
with that particular processor and we're
going to be having lots more work
happening as we go
so totally cool
all right so another thing that happened
this week is let me switch to my main
i got my copy of the very awesome real
world paper book
yes it is real
tobias teals
creative diy microcontroller projects
with tiny go and web assembly
so the book is real tiny go is real
apparently now there's an actual like
dead tree book which means that it is
real it's like
solid
um no actually i have not had a chance
to read it because it just came in the
post but i'm super excited maybe we can
go through a few of the exercises in
here because just taking a look at the
chapters um it's actually super exciting
the chapter list alone has just got me
let's see if we can switch over to take
a quick look
so yeah we've got
this is yeah this is going to be
gopherbot's new favorite book
um
chapter one
getting started
chapter two building a traffic lights
control system
yes that's a that's a very typical first
exercise yeah you can't really see that
too well from there um
maybe the micro camera
oh turn the light on
no light
it's too dark
well
we'll just read it um
so yeah the uh
very typical sort of exercise that
people do
um
is that traffic light control system in
fact uh one of my sons who's university
student did a program exactly like that
and he had to write in avr assembly
language so i'm sure tiny go would've
been much easier i'm gonna show him this
and he's gonna be like oh that was so
easy
but it goes through um a number of very
cool type of hobbyist projects safety
lock plant watering system
a touchless hand wash timer yes that's
very handy these days that's for sure um
building communication with displays so
using tiny draw and tiny fonts and so
that's very cool weather alerts on the
tiny go wassum dashboard yes so getting
into some
client-side webassembly mqtt
yeah so lots of good stuff in here this
literally looks cool um that's fantastic
and tobias thank you so much for writing
this book it's really awesome and you
know if you want to learn
a lot about tiny go it looks like this
is a great place to get started
along with all the other wonderful
resources online of course
but uh
super exciting
really really into that
all right so
now it's finally jumping back
losing control over my camera views
apparently
all right
so yeah um
also on the new tiny go release
we had
naturally not just a release of the main
tiny go compiler and all of the cool
pieces of software involved with that
but we also had a new release of
tiny go drivers
so
several people were asking you know how
the whole drivers worked
so we added a
page to the tiny go website
if you go to the tinygo.org
click on documentation we have a section
for concepts
that describe
you know the way that
some of the concepts when you're using
tiny go would happen to work and one of
those is this idea of drivers
and trying to show
you know visually
as well as in code at a very
kind of low under the hood complete
level how it is that drivers work
and how when you want to write your own
what you need to be doing so
excuse me
so yeah that's um
so we have a new release of the actual
drivers repository itself
which if we look under reference
we can see our devices
and those are all of the different
devices currently 67 different devices
that are now supported by the tiny go
drivers repo
so
have a new release of that um
0.17.1
so
the reason why it's dot one is i
messed up during the release process yes
i messed up yes even i can mess up
anybody can mess up by the way
an automated process is a good way to go
and we have some automated release
processes for the main tiny go
repository but hadn't added them all for
the driver's repo
so uh i had to do a quick point release
just to actually get the right code in
for the right release
but
very very cool stuff let's take a look
at what we got added because there's
some really interesting new capabilities
controller
maybe we're going to get the stream that
controller
sorry about that but
you know so many buttons
so little time
ah
oh yeah
oh yes
okay oh now it's perfect that's so easy
even my wounded hand can do it
um
so yeah part of the driver's repo we
have a couple of new devices
so
one of them
you may recall the sd card support
so we were
working on that a couple of weeks ago
with saga 35
and
they
helped considerably it took actually
quite a while of a bunch of different
experiments to try to determine like the
one missing bit
that had it not working
so it's always just one bit missing
so um so that sd card support has now
actually landed
in tiny go
which is really really awesome because
you know there's a couple of different
devices
that we have support for where it's
already working
for example
the uh
um is this one though
hmm ah yeah there we go
let's see if i can
focus a little bit here
so we have
the
digikey oh no sorry adafruit pi portal
which is a
very cool device it's got a bunch of
built-in sensors and
built-in display it's got the built-in
wi-fi
it's got
no actual
buttons that are conveniently located
but it does have some ports
and it's got the sd card reader
then another board
that we have support for
just added which also has an sd card
reader
is the very cool little wheel terminal
from seed studio
so this is a very neat little device
it's got
a joystick as well as a small display
and this is the
very well hidden port
for the sd card input
it's got pins so that you can actually
access the external gpio
i square c and other interfaces it also
has some
grove connectors which are the
very typical seed studio connectors that
quite a lot of our
sensors that we used in the gophercon
hardware workshop
used so this is the other board that has
the
sd card support so that's super cool
thank you so much sago 35 for working on
that because that is huge and one of the
things that got added
right before
was not just read but also write ability
so keeping in mind of course that we
don't necessarily want to write
out of control if we're using flash ram
which is the other option
for reading and writing
um
of this data which data
well it's the tiny fs data
let's jump over to that
so in addition to
releasing the new version of the tiny go
drivers
we also have updated the tinygo.org repo
that
no control loss control
um
so the tiny fs repository
which is now part of the tiny go
organization um there's still a fork
so be gould is back
great to have you back thank you for all
of your amazing contributions
and the original repo is going to be
retired it already says that it's been
deprecated and to go to the
tiny go org version of the repo so we'll
see if github can help us
remove the original one and point to
this as the master
or the main one i should say
so we have a new release
that we came out with and it supports
the
little fs as well as fat fs
and also the examples compile
and we now have some
unit tests running on circle ci
just to make sure that in fact yes
the at least the examples all compile
uh similar to what we do in the drivers
repo
we're just doing kind of a smoke test
build
and so in this sample we're building for
the itsy bitsy m0
and the itsy bitsy m4
so the m0
is a sam
at
atmel or um or microchip now sam d21
which is an arm cortex m0 chip
and then the
do i have one do i happen to have one
with me
i always have some like extra boards in
my bag just in case you know i get
hungry
uh
hmm
well i think i took it out
oh well
i'm actually only peaking this just
because it's very common that i have
these boards just
if you ever need a board just hit me up
i got one or two or ten
uh well
anyway so
the
um sam d21 is an arm cortex m0 chip so
it's not as powerful but it does have
the built-in
flash ram and so the support in tiny go
tiny fs
when using the ram disk
and we have an example of that here set
up
right in the tiny fs repository
under simple fat fs
and this example here is using in fact
the memory device
not the sd card
so we're still able to read and write
the fat file system
and we're able to do it on two different
media one being the built-in flash ram
the other one being an sd card
so that's really really cool because it
gives us two different ways to store
data you know directly in the hardware
connected to a microcontroller
and
and it works with both of those
different drivers so we also have
support or the smoke test rather
that we're using
are the
itsy bitsy m4
so that is an arm cortex m4
it is the sam d51
and that in fact is the same chip
that is in both this adafruit pi portal
and is also in the wii o terminal
so that's the arm d51
so
on that both of
the examples are being compiled and
let's see which ones those are
it's using the console
examples
console
little fs
and it's using the q spy which is the
quad
serial peripheral interface so it's much
higher speed
because instead of only having a
single line
for
reading and another one for writing
of data instead it's got four
so it's able to multiplex data
and correspondingly send data very very
quickly
which makes it ideal for you know
storage media whatever that happens to
be
right
so um
if we take a look at the
well there's a little fs we've talked
about that before but it is pretty
interesting
so little fs is a very small file system
that is designed for microcontrollers
around being fail safe
and
so if you just disconnect the power all
of a sudden
the file system will become corrupted if
you do not have a file system that is
able to support that kind of
you know redundancy
and so little fs is very good for those
kind of purposes
where
you know a microcontroller the power
could you know get interrupted at any
time potentially in some use cases right
and if you need to absolutely record
some type of telemetry data or some type
of data readings and you want to be able
to when the device comes back up you
know seamlessly resume operations little
fs is a good option
another is that it's got dynamic wear
leveling so if you're using an sd card
it's really not so much of a problem
but if you are using flash ram if you
just keep reading and writing to the
same
blocks over and over it'll wear out and
since generally it's a chip that's
actually soldered directly
to the board itself
it's like
if i only grabbed an extra one of those
boards with me
let me take a look maybe i have one
just sitting around
i often do
i haven't known to just have boards
boards are
did i plenty
that if you see me you should see if i
have any cool boards to let you have um
well i don't seem to have one with a
flash ram chip that we can easily see
but uh
anyway
so it's it's solid directly to the board
so we can't just
you know replace it like we can an sd
card
so um that's one reason why the dynamic
wear leveling is kind of important so
we've got support for that now and
that's all been released
so if you want to actually use it
you can just go to the tiny go drivers
repository
and then
if you want to use it with our examples
for the sd card you can just go to
examples
and sd card
and you'll see
that we have
what are very similar examples to the
ones that are in the tiny fs repository
the difference here is that they're
running on this on an sd card so we can
actually test these
and
support is
been put in place for all these
different microcontrollers that have
an attached sd card reader
which are the
adafruit feather m4
the adafruit grand central m4
the p1 am which is kind of a more
industrial style controller the pi gamer
the pi portal i showed you that a minute
ago and then the wheel terminal
so that's actually quite a few boards
wait how many is that two
three four five six different boards
that we have support for
right now out of the box
for sd card readers that already built
in
and uh if you have a custom board with
one you know that would you know be very
relatively easy to incorporate as well
so that's really really cool
that's um
that's totally exciting to me just
because like i need that feature
and then
here's the tiny fs support
and this console program again does the
same thing
um we looked at that a couple of weeks
ago
uh
i thought we would make sure that it
actually still worked
today because
you know i never had a chance to
actually do that
um
i assume it does of course but you know
it's always good to check these things
out right so let's go to our
drivers repo and let's
get pull
rebase
origin release since that's the name of
our release branch is release
and it's already up to date
so
if we just um
do a tiny go flash
and our target let's see which one of
these boards has the sd card in it
um
looks like the pi portal so let's use
the pi portal target pi portal
all right and then
we're gonna use the examples sd card
tiny fs
um
yeah i think that's all we need to do is
just run that
and we need to plug it in of course or
else we can't actually flash it
so let's find the cable real quick
um i have it here
i pulled it out before
ah here we go
so we'll just plug in our cable so that
we can
overwrite the current software that's on
there whatever it happens to be
probably the pre-release version of all
of this
so we'll plug in the board
and then
we will
go and hopefully it should flash
i see lights blinking
and
[Music]
it mounted and then unmounted the drive
so we should be able to now go over to
our terminal
and the terminal is ready so it's got
this buy info so
help command
that's working ls
okay those are the files that were on
the sd card
so if we cat
raspy
dot json
that was my pre-release version of the
json file for the raspberry pi rp 2040
board
and so yeah this was actually the
contents of the board in bytes we could
see over here is the bytes and uh
all right oh let's see now let's see if
we can actually create a file
i did not test this
let's see create
test
me dot text
oh
it looks like it worked
yeah i see there's a file on disk now or
on sd card i should say
and
write to file
and let's see what happens here
i have not tested this so write and then
test me that text
and ctrl d the exit it said so
this
is the
test file
and then ctrl d
oh wait whoa what happened there
that was not what i expected
there we go
this is the test file wrote 22 bytes
so let's cat test me
dot text
and
this is the test file yeah it actually
seems like it persisted it
wow that is really cool we have read and
write
fat file system
working with the latest release of tiny
go with the latest tiny ego drivers repo
and also the latest tiny fs
that is so awesome
man i mean
that is really really cool
you need this for so many different
things if you wanted to
you know keep keys or store files with
log data
and this way you could just store your
files on the sd card and then you can
just take the sd card out and put it
into your computer and read the data off
of it so it gives you a good way to
retrieve data if you don't have a
wireless connection or
if you don't want a wireless connection
um
if it's too much data to move over the
speed of wireless connection that you
have
you know if you need to recover that
data because the device that was on has
gone bad but the sd card is still okay
so
wow that is really awesome
cool
so yeah that's been released it's out in
the wild
go get it right now my friends right now
it's there for you
so there was another very cool feature
that was added
um in this last release of the tiny go
drivers repo
also from sago 35
and it is
the
latest wi-fi chip
which is the rtl
8720dn
so now this is
a
completely different wi-fi and bluetooth
low energy coprocessor
it is um
similar conceptually
to the esp32 but it's a different chip
with a different silicon with different
apis and
so one thing that is really really
interesting about this driver
is that
it was actually generated
using a
standard that i did not really know
about
which is known as the
erpc
which is embedded rpc
so what is embedded rpc
you might be wondering that was what i
was wondering i'd never heard of it i
mean i may have heard of it once but i
immediately forgot it
so
it is a technique that has been designed
for having
chip to chip communication that exists
on a slightly higher
protocol level than
i2 sk i square c communication for
example
um
really it's designed probably around two
chips that are connected via a uart or
spy interface
and generally one of them is going to be
something that
has a pretty large api surface like the
wi-fi chip
for example
so this erpc is an open
standard
which um
it's being used by a few companies
mostly
nxp
um a few others
as well though
uh but that i guess is kind of the
primary most common use case and where
they have a bunch the whole
ecosystem of different devices
supporting it
so
sago 35 wrote a generator
so you may have forgotten
we this is not the first
awesome generator that saga 35 has
written
that one was actually tiny font
i was just thinking about that
so tiny font is our font
package it lets you
take true type fonts and then draw them
onto any of the supported tiny go
displays
and if you do not have
support already in tiny font for the
font you need
no problem because there is tiny font
gen
which is a generator which will take as
input a true type font file
and outputs the
generated go package which is that font
so
yes
sago 35 so i guess that was just warm up
for this like much more intense
generator
go
erpc gen
so it would appear
that this
firmware
that is supported by the chip that we
just added the
rtl8720dn which i would love to be able
to show you but i
don't want to open up the case for the
seed studio
um
i haven't figured out exactly how to
open it yet and
uh it looks like it doesn't necessarily
want to be opened
and probably there is a way
but uh
if i just crack it open and it breaks
then i'm gonna be really mad at myself
but anyway um
so i'd like to show you this chip but
anyway
this chip has a very
complete api surface
and there's a lot to it
right i mean there's a lot to it
turns out that the generated file with
the whole rpc surface is
like
um no that's not it 37 lines let's see
um
is that the one
yeah oops um
yeah so
9422 lines of generated code for
essentially the entire api
for the communication between the host
microcontroller
and whatever this device is in this case
this wi-fi device so
luckily we don't have to worry about all
of those generated commands necessarily
and if we take a look at the examples
we can see that there are in fact a
couple of examples that were created
and one of them is
a tiny term based web client so let's
take a look at that
so we should be able to
um
now
one thing i do know
is that if we want to use this chip
that we're going to have to make sure
it's running the latest firmware
so there's firmware you have to download
onto the coprocessor
this is really similar to what we had to
do
for the
esp32 that's on
the
arduino
nano 33 iot board
where we needed to update that to the
latest version of the
neenah firmware
for the wifi nina to work so it's kind
of the same idea here
and
so we have to get the firmware
it's got to be 2.1.2 or above
so i have not um
actually done this yet
so let's go and take a look and
because it's almost for sure
we're going to have to do it so let's
take a look at the procedure here real
quick
so step one is um
let's see
we don't have to do the windows version
we mac linux
so we need to clone the flash tool
okay so let's do that
i meant to do this a couple of times so
no time like the present
so let's create a new tab
and we'll change
to our development repo
and then we'll clone this
amd flash tool
and we probably need to change directory
into it almost for sure yep and now we
need to
connect the wii o terminal
to the computer
ah so now the wheel terminal is a very
modern device
it has usbc
input so we need usbc the usbc
and i only have a very tiny little
shorty cable
or do i
i hope i do
it may not even have that cable let's
take a look
i may have let somebody borrow it
nope hear this okay
it is very small so
we can uh
barely see it
let's plug this in
and then i guess we run this flash
command by way of a python tool
erase the initial firmware
hopefully this will work
what could go wrong
let's do it
wait it's burning
rtl 8720 firmware
that's what it says on the display
um not sure if you can actually see that
generally it is very very bad to unplug
firmware while doing this don't do it
please don't do it
you will regret it
when you do that usually the only way
out is to have some type of jtag
debugger that you connect to some pins
that
almost certainly are not only well
hidden but have no actual pin connectors
so you need to have either pogo pins or
solder something to these little pads
it's a pain at the at the best it's a
pain at worst you may have actually
bricked it because you may not have any
convenient way of getting around it now
luckily for us
no such problem
all is well in the world
it was successful
i mean i can't tell that because the
display didn't change but you know i'm
trustworthy at least i've erased it
so
we now have to actually flash the latest
firmware
well that's why the display hasn't
changed it's been erased but not flashed
all right so let's
go and
hopefully flash
and
okay
looking good
something's
happening and yeah it says it's flashing
same message as before
so
it's burning
this is cool
i meant to do this but i didn't have a
chance so now we get a chance to test it
um
i know a couple of other people on our
team did do some physical testing okay
now it's done
all right i think that's it and uh
okay we're done
we've updated
all right
so now back to the actual task at hand
so we had to actually update that before
we can
you know try testing this
tiny term software so let's go to our
drivers tab
and let's go and take a look at
what is the code
so in our examples directory
under the rtl
not the wi-fi neenah that's the other
one
so yeah one of the tasks that we need to
do is to
look at these different
wi-fi style co-processors and create a
single
interface that's common right now it's
just for the ad hoc
but a single winner interface that's
common that lets you
you know
relatively easily
um
you know actually
switch between them because if you write
some software and it's got a bunch of
functions that are very specific to a
single type of wi-fi adapter
you know that's not very portable that's
not very go like
so
we're going to create some type of
unified api
again this is not net
right that's assumes you've really got
an ethernet connection generally of some
kind via wi-fi or via physical ethernet
you know that's what go itself generally
expects tiny go since we have to run
bare metal we don't have an operating
system we don't have any way to
establish this connection outside of you
know some type of separate chip or block
on the chip
in the case of something like the esp32
which hopefully in the near future we'll
have some support for the wi-fi on that
so um
in any case let's take a look at what
this code does here real quick
so
it um
displays black on the screen turns on
the light
creates a tiny terminal
to
get the information and display it on
the screen
and then it calls this run function
that does all the real work
so that sets up the
wi-fi chip
connects to it
or whatever access point
and then
once it has done that
it goes and it queries some information
about that and then
you know displays that makes an http
request let's see what that does
so that looks like it is
going to go to
which website
what is oh i see whatever server you put
in
in this case the tinygo.org server
so it should go to the web server
make an http request
and then
whatever is returned from that it will
then just display on the terminal
all right that sounds really cool
so let's see if we can actually get this
to work
so we will need to make a few changes
which specifically we're going to have
to
if nothing else we're going to have to
have it connect to the wi-fi access
point
which i believe is
hackspace
and then well actually
one thing we can do is what i have done
in some of the other examples
which was
i have my credentials
over in some external files
and let me just find the examples for
the wi-fi neenah here
because that's how i did it here
was
basically
instead of
no no wonder that didn't work right
so i put these my files into a separate
access point
um into a separate file
and then
let's just see if i can even find those
values here
hmm
i have them here somewhere
um
that's what i did with them but i'm sure
they're here
i guess
that's good
so yeah
ah okay
oh okay that should work
got it
all right so here's what all we have to
do
or all we should have to do to make this
work
is going back to the tiny term
example
so if we
undo the changes i was just making
right so if we create an init function
tiny go just like regular go we'll call
this init function
when the package that it is inside of is
first loaded
so we can copy this
access to file
using my terminal
so if i copy from my desktop
and we'll copy it into
examples
rtl
which one is it web client
tiny term
yeah just into there
and just to make sure it's actually
gotten into the right place
so yeah it's in there now so
when i compile this program
it should use those credentials
in order to
um
connect to the right access point so i
guess we'll find out in a minute
so it's the rtl
and it's the web client tiny term
and our target is no longer the pi
portal right now it's the weo terminal
which is the
awesome little device and it's still
plugged in
through this other cable so i should be
able to just hit it
i guess we'll find out
okay it looks like it flashed it
it's displaying something on its little
display
it's saying it's setting up the rtl
not sure if you can actually see that
hopefully it's working
whenever you know
it seems like it's taking an awfully
long time
makes me think that i don't quite have
something right
go for bob take a look at that
see if you can figure out what's going
on
i'll do the same
so
probably
it has to do with the relatively boring
problem of not having the right
wi-fi info
that is my most common scenario
so let's see
um
i'm almost positive that's what it is
let's see
one second here
because it still didn't actually connect
to anything
and that seems like the most likely
scenario
um let's see
pretty sure
i have this somewhere
i meant to turn that off just because i
mean like who cares um
what the password is on the wi-fi that
you can't even access right
pretty sure let's see here
um
almost positive that this is what
well that's not it
oh excuse me
um
let's see here
i know i have this somewhere
but what did i do with it
famous last words
um
let's see here one other place to check
hmm nope
don't have it there
um
hmm let's see
um
[Music]
bear with me
bear with me my friends bear with me
wait let's try one other thing
let's just try restarting it
i don't think so
let's see i know that i'm connected
because i'm on
that wi-fi right now
but
let's see
here's something else to try just to
simplify
i'm going to go and i'm going to take a
look to see
if just by some chance
i commented out the wrong code in the
wrong place
well that should have been there
here's another thing let's try flashing
it again
sometimes you just gotta flash it twice
and it's flashing
and it's giving the same message
i don't think it's c
this was the exact problem we were
having last time
and
we are having the same difficulty
that's really annoying isn't it
taking a look here to see if i have
another cable
so i can test one other thing
okay
so far
no
this is really annoying isn't it don't
you want to see this work i know i do
hmm
do i have the wrong do i have the right
ssid yes
and i have the right
password
yes
and i set debug on
oh
hmm
that should have worked
i did say debug equals true
which it did display the message of
setting it up but never
ah okay
hmm
that makes me think something else is
wrong
let's see
well here's something we can try
um
oh
yes this way you can
you can watch my struggles and travails
so i'm pretty sure
that we never actually rebuilt
so let's just rebuild tiny go
okay
actually
let's pull the latest
get pull rebase origin dev
pick up all the very latest changes
oh
and it looks like
we're already no
okay
so
let's make that
because yeah it's acting like um
the wrong firmware or something
because it's not even getting past the
point of setting up the firmware so i
don't even think it's the wi-fi access
point actually
come to think of it
let's go back to that
tab 9 which was this
amb flash tool
which is
firmware
2.1.2
okay yeah
should be good
so we should not
first flash
let's see
run with go
hmm
i just want to run with tiny guy that's
what we did before i'm not sure that
worked
web client let's just try the simpler
web client
maybe that's the problem here
so if we go back to uh oh but i was
compiling the new tiny go so let's
finish that
we just got the copy
the executable in there
and tiny go version
yes it is the
0.19.0 latest version very good
so tinygo clean
that way it cleans any extra cache files
so we'll go back to the drivers
and
let's try compile
the just the web client let's go look at
that code actually first real quick
i believe web clients the same deal that
if we just copy over this other file
actually don't want to do that
we just do it in the
terminal so if we just copy
examples
rtl8720dn
web client
tinyterm
access to to
examples rtl
web clients
and if we just go back to the
web client
it should work
the same way so if we flash that
it should flash
and
it is flashing the
the board
and
okay
i think we have to go to the
terminal here to see anything happen
yeah
okay
so that's interesting
it turned the
wi-fi off turned it on
disconnected and then tried to connect
but it doesn't appear that it's actually
connecting
it's as if it doesn't have the right
firmware
which is the problem i thought we would
solve
by updating the firmware
no
there we go here's the flash tool again
i guess we should try the same thing
first we'll try to erase it
again
and it is waiting
flashing
yeah hopefully this will work the second
time
let's go take a look at the actual code
just to see
what's the name of it again
so
still flashing
go back to the wii o terminal getting
started here and just see if there's
does tell us how to update the
we were just here where was it
all right we are terminal network
overview
erase the firmware
we did that with the erase command
and then
flash the latest firmware
which is what we did
uh hmm
it sure worked
we don't need the
arduino core because we are running that
ourselves all right so
so we were able to erase
now we should just be able to go flash
okay
it's flashing
maybe i needed to unplug it and plug it
back in before trying this
i don't know
maybe
i guess we'll find out let's keep going
let's keep going
something's happening here
i'm not sure what but something
uh
still flashing okay success
all right so let's unplug it
plug it back in
switch back to the drivers
flash the web client
okay it's flash let's go back to our
terminal and see what we see
it's doing the same thing as it was
before
which it's trying to call the
entry point of the wi-fi but
it's not it is not succeeding
i guess this would be a good time for us
to take a look at the
code in this repository for the
mbd flash tool
let's go take a look at that and see
what does it do
that's definitely not doing anything
um
well let's see wait maybe
hold on hold on
before we
get too
excited
just maybe
we now
have a program with the right firmware
and we just have to
flash it with the right credentials
let's go back to the drivers
try to flash it again
it's flashed let's go to the
terminal
see what's happening if anything
hmm
well
doesn't seem like it but it looks like
it is sending some commands correctly
but it's not
like timing out or failing or anything
i would have expected
that this api would
at least cleanly fail or something it
seems like it's not being called
correctly but i know we just did in fact
flash it
well we did flash it but what did we
flash it with let's go take a look and
see what's in this
mbd flash tool directory
do i trust the author sure
sure i trust him ish
um
so let's see
it's got a bunch of flash options
using different tools
and
[Music]
let's see what the readme tells us
nothing
amazing
almost nothing
hmm
well it definitely did something
but
not what we expected
i guess we could try again with the uh
we are terminal version
drivers
at least this way we see something on
this if it's going to not do anything
it would be more exciting if it not do
that thing on the display
so here's another thing i'm going to try
because
maybe there is some other problem with
our access point
so let's try
making my own access point
which in fact i do have
turned on now
so let's go and
just as an experiment
let's go and let's try to change
to the info that i usually use when
connecting to my phone
and we'll try to rebuild it again
oh but something else happened
connect to ap
well that's interesting it did get
further
but
it doesn't seem like it's actually doing
anything yet
but let's give it a little time
maybe it's just impatient
but it is it does not have two messages
kind of hard to read
but we now have two messages that we can
see
first one says
that it's connecting to the actual
adapter
and then the second one says connect to
ap
but did not succeed
so
okay
same problem but different error
oh wait
okay
i think that's a different problem
because
when i disconnected from
the serial port
it immediately kicked in and actually
started working
by way of the dead phone
so i think we may have exposed a
slightly different problem
something to do with the way that the
serial output is working
because now if we actually take a look
at the
device itself
it's going and it's querying the
can we zoom in though
we can focus
but not very well
um i don't have enough
cable length to
well actually this might work
let's see
yeah
that'll totally work
so we can
gaze upon its glory
try to focus it a little bit
not focusing too well is it
um
close enough all right so when i
connected via the
serial port
it then proceeds on to display connect
to ap
and then when they disconnect from the
serial port
it seems like it frees up to actually go
and do
[Music]
the things it's supposed to be doing
which is
if we got a little bit closer
and we could actually focus at the same
time
it's actually going and it's making the
http queries to the access point
so i think that the
wi-fi is working correctly on this chip
but in fact there's a different problem
something to do with the serial port
so um or the usb cdc
or maybe it's just some logical problem
in the way the code is implemented
but uh
in any case something's not quite right
but it's not i don't think with
the driver itself because that we can
see is actually communicating
as we expected it
so this would be a good time to go and
change back to the original access point
credentials
to see if maybe
it's now
if that wasn't in fact the problem in
the first place but it was this other
thing
that would be very very possible
based on the behavior that we were just
seeing so let's just go back to the
terminal
and then let's go and take a look
just flashing it again with the same
exact code that we just tried to use
this time with the
information for the
access point here at the hackspace
that way we can just sort of establish
that in fact
it is something to do with the
interaction between the program the way
it's using the serial port and the wi-fi
okay
so then let's go back to the
it's been flashed
so let's try again connecting
still now seeing the same behavior
if we look at the micro
and then when they disconnect from the
serial
let's see if it starts
yep
so that was it
that is the we need to report that
problem
just that way but first let's take a
little look
see if we can diagnose it
just because that is a bit annoying
otherwise it was working great i mean it
is working great i just think i was uh
not looking at the right things
so let's go and take a quick look here
at the code
for the console tool
and see if it's doing something that
seems kind of unusual
so
connect to access point
and then
this is actually where it displays this
message and then it's when it's trying
to set up this that it locks up
so let's go take a look and see what
that function does
okay here it is
so let's see
so it because it's something to do with
the uart
because when the uart gets disconnected
and so
well maybe it is let's let's keep
digging let's keep digging
so what is this actually doing
so it's sending the
chip
power
low and then high i guess that resets
the adapter probably
and then okay wait cereal what does that
do
that looks awfully suspicious aha
wait for user to open serial console
oh okay
so
i guess this is kind of doing what
it's supposed to be
that it doesn't actually proceed until
you open the serial console
it's just that's very very confusing
since that was not what i expected
um maybe we need to add that to the docs
just to explain that
so that's not a that's not a bug per se
right but so it waits for the connection
so let's go back and see
does it do it twice by any chance
just in case it got it calls it twice
just because
it waits for us to connect
and then oh i see
so let's go back to the original logic
of this just to
make sure we understand what we're it's
supposed to be doing or not doing
so
it
tries to connect to the
wi-fi adapter
and it won't proceed until you connect
via serial
so once you connect
it continues in this function
but it doesn't go on until you
disconnect
so that's the part
it does say connect to ap
but it doesn't proceed
i believe that was what was happening
let's let's confirm that just
just so just to be sure
so i'm going to unplug and plug back in
it displays the first message
so then only when we connect via wi-fi
does it display the second message
connect to ap
which
is this message right here
and presumably it actually calls it
but it doesn't return from this call
until we disconnect from it
on the serial port
and only when we disconnect does it then
return says connected and it proceeds on
with all the rest of the calls
so
you know what does this actually do
this
connect to ap because it seems like it's
blocking when it shouldn't be
so i guess let's go take a look at the
implementation
just so we know what's happening here
and that would be
rtl8720dn
and
actually we can just look for
connect to ap
the function
and it's in the
here it is
so let's see
so it's doing the
wi-fi off and on and disconnect and then
trying to connect
and that was where we saw it sitting
before
until
it fails
this logic's a little weird
let's try to parse it though
number of tries
your sum is five so it's going to retry
five times
it's going to try to call this wi-fi
connect and we know that was happening
because we saw it in the log
i wonder what something to do with the
debug
and uh if we turned off debug that maybe
it would work
i have a feeling that is possibly the
case
so let's see here
so going back and just taking a quick
look
because i think that it was debug was
turned on for
this sample
so yes let's go debug false
and then
let's go and flash it
okay
it's flashing
and let's see
it says connect to ap we know that's the
case that we do have to connect to the
serial
oh wait
we didn't it's actually just working
i never connected to the serial
okay
so yes it is to do with that debug
and uh so i guess the debug has got a
bug in it
oh yeah
not the first time that ever happened
because this is actually working really
well now
if we take a look at the
micro view
you can see it's
querying the tiny go website
it's redirecting to the
secure version
and then since it doesn't have support
for that it just redirects back to the
unsecured version and so on so it just
keeps fetching it
that is really awesome
okay
so let's go and
see if we can maybe
either find the bug
or
at least notify
i guess saga 35 that there's something
not quite working as expected
because it's this rpc wi-fi connect
and this is that function
and so
let's see what it's doing here
so if debug is set on it displays that
message we saw that
what else about debug
doesn't seem like it
should
necessarily be causing such a problem
but
but it is
well i mean this is one thing that we
could probably
make this program a lot smaller by not
using font print line
but yeah i mean that's a minor
that's minor
in the grand scheme
so then it's
creating the packet that it needs to
and then it calls this perform request
let's see what that does
i guess we should say
perform request
funk
r star
rtl
dm
what
no that's not working well let's see
here
there's just so many uses i mean perform
request is used uh
all over
let's see if maybe
go to definition
hey okay
um
so let's see
more stuff done by the debug here
so if if debug then it dump packs what
does that do
because it's not
it only works after you disconnect the
serial port
hmm
not sure
but
i'm running out of time today and i
think i will just report this possibly
to
our erstwhile maintainer of this
particular code
and this way
so let's see
oh
also would be good to these things that
were released
this has been released
in 0 17 1.
maybe we could spell that correctly
and of course thank you
one should always thank
contributors
and anybody who reports a bug is a
contributor
there might be a few more of those but
let's uh no that's it okay
so it's a new issue
and it's with the rtl
what's the name of the board
or chip
program
or let's see
connect
to
ap
does
not proceed
as expected
and so
when using the
examples
for the
rtl8720
the program
does not proceed
with the
connect to ap
until
the
user
disconnects
the ur or the
i guess the serial connection better
said
so let's see here
does not
call
connect to ap
when using the examples
and the debug flag
debug equals true
because it worked fine when we had that
set to false
does not call connect to ap
until
the
serial port
connects
to the board
and then
does not proceed
with the connect to ap call
until the user disconnects the serial
connection
serial port from the computer
this is
very odd
behavior
okay
well
i should say
does not call
connect ap until the show important can
be the connection board
and then does not proceed until the user
disconnects the serial connection all
right now i got it right
got to state this correctly because
otherwise
it's like super confusing
i mean
i could barely write it
all right this is much better now i feel
i feel better about this so let's
label bug
and cool
all right we've done it we entered in
the information about that issue
man
that was a lot of work but
surprisingly
um but of course it was user error on my
part right first oh i thought the
firmware didn't flash correctly
so i flashed it like two three times
nope firmware was fine
oh okay i must have the wrong info for
my ssid or my password what's wrong with
that nope that was fine
oh wait okay hmm it was literally just
because i only noticed this particular
odd behavior
by
disconnecting the serial while the
tiny term was running on the device
itself
right like if i didn't have this output
on the device to know
that it actually was working
i might have thought or continued to
think i should say
that it was actually not working right
so that's uh
kind of misleading
and this very interesting example of how
you know we need
different ways to test software
generally like multiple ways because
sometimes your debug code
causes a problem
or your when your logging code does not
work the way you expect
or even causes a separate problem
you may not even realize
that in fact
the code was kind of working or maybe
where the problem is
actually just so happens just
as a
example of this very thing
in this last version of tiny go's
release
one of the features that was added
i don't know if i'll be able to find it
this way
let me see if i can
um
it's probably in the change log it's
probably the easiest way to find it
maybe that was in the previous release
i thought it was in this release anyway
a recent release one of the features
that was added was
that
when a panic would occur
that it would not
disable all the interrupts on the board
because that was causing the panics to
not being displayed on the
serial port and of course they would
just stop and you wouldn't know why it
was going wrong unless you have a debug
device like a jtag connector or
something like that so
you know you need multiple ways to debug
and you need to be very careful to check
your debug code
okay so
on a totally unrelated note it looks
like we have some very annoying spam
people on our
feed how do i get rid of these folks
let's see
there's a trackball but they don't know
how to use it
oh wait
uh well
anyway
um
i hate spammers
we'll reject them all later
um cool all right so let's see if
there's any other things that we need to
take care of today like work wise
um
so one thing that i think we should do
now that this release is actually
released
is it's time to update
the tiny go version to
0.20.0 dev
and
luckily this
same amazing human being sato 35 has
already got the commit ready to go man
talk about with it wow
i'm very impressive i have to say
very very impressive
yes right click and block i know i will
do that if i could just get this
this computer is a trackball
and for some reason i cannot get the
trackball to appear on the screen where
the
actual device is
i assume it's plugged in
okay
this is why i don't use trackballs
no usually the trackball is actually
really good for things like
missile command and
very
really i'm not that big a fan of the
trackball okay
i don't like trackballs okay i i hate a
man i hate them no
um
well really i actually don't see
on this computer
it should be plugged in
but
well okay
oh wait hold it i saw up there it is
there it is
it was on a different monitor okay
oh wait
okay right click
oh wait
how do i
right click and block
i don't see a right click option to
block
hmm
click on the name
okay
the chatter's name yeah
and then how do i block is it this x
no
it would help if this
ah there we go
ban
all right
goodbye
here's another one to ban oh this is
getting fun
i'm having a good time
banning
goodbye
thanks soy pete you don't know how happy
this is making me
all right
good yeah
goodbye spammers
all right
um thank you thank you very much i
appreciate that
you've taught me how to use twitch a
little bit better today than i did
yesterday which you know i will consider
that personal self-improvement
cool all right so we were going to
um merge the new update for the next
development version which will be
0.20.dev
so not too much to go wrong there
and we have all of our checks that are
passing so
looks good
time to merge
and of course thank you
never forget to say thank you and please
it just seems like good advice that my
mom gave me and i was paying attention
to like two things she ever said and
that was one of them apparently the
other one is time for dinner um
probably
well actually if you know my mom you
know she probably never said that but
um anyway
so cool let's see if there's any other
pull requests that we need to
do anything about
actually there are a few that are quite
interesting
but i'm not ready to merge them yet
so
one of them is from hey swipe at
it's you
um
with this mac implementation
oh yeah we need this
oh we should have merged this before
this most recent release
whoops
um
okay
uh well
yeah too late maybe
um
let's see
where do we do we have anywhere where we
can test this well someone's testing it
because it looks like um
federico needs this
looks good
okay well if it looks good to the two of
you it looks good to me as well
go to me too
thanks
this is so cool
because i think that we actually have a
duplicate
a duplicate implementation of this mac
desk mac address implementation for
getting out of speak here
in the drivers
package doing i think pretty much the
exact same thing
so that would mean that we could
actually remove that
that would be really really cool
let's actually go take a quick look and
see if that's true
because i believe it is in there
in the net sub package
of the drivers
maybe that's not here let's take a look
and see
i think it's in here somewhere though
we'll just search here
for mac
yeah here it is
ah
that's a little different though because
that's actually the mac address that's
coming from
the wi-fi neenah chip itself
so
um not exactly the same
let's see
yeah because i think the mac address
that comes back from the
wi-fi nina adapter is just a string it's
not like an actual mac mac address
so
there's no overlap in that functionality
i would gather that
probably this mac address implementation
would probably be to support this work
that's going on for the um
for the ethernet adapter am i right
let's go take a look
this is actually super interesting
if it's what i think it is yes ether
switch
so this looks super neat
basically a
there's a bunch of boards
well i should say chips
mostly like stm32s
that are like a little bit you know more
serious
and they have support for
physical ethernet connections if you
have the right wiring right
so um
i have a couple of boards like this
myself i just have never had a chance to
be able to use them with tiny go
because i did not have anything like
this which would be
you know basically a low level stack
which would let me plug in
you know the
some actual higher level you know ip
type protocol
which
when you're usually using go right this
is just happening for you like you pay
no attention it just works everything's
good it's the operating system with no
operating system we have to do all this
work ourselves kind of like what i was
talking about earlier with the file
system
so
in this case it would be
all right i would like to have this
microcontroller that is probably plugged
into something that's
you know
relatively important if it has an actual
physical ethernet connection you know
some type of industrial controller maybe
it's getting power over ethernet that
way it doesn't have to have a separate
power connection you can just get
networking and power from the single set
of cables
so
um again
for any type of like industrial or
commercial
type of application
um or you just
don't want to run a lot of extra cables
home networking or home automation
so uh lots of people have ethernet
cables that they've run through their
house you know if you've done any kind
of remodeling job you know you've
probably put in ethernet cables you've
got power over ethernet potentially
so
this is actually a super super
cool tiny go project and i'm really
looking forward to hopefully helping out
um i have to drag
one of those boards out and see if
i can get anything to see if at least i
can test you know
but okay cool we got um
that pull request merged
and i think that that pretty much covers
all of the open prs that
don't require at least a little bit more
um
attention being paid
yeah here's an example of that exact um
driver
for an ethernet board probably using
that same
package or maybe that package came from
that i think that package came from that
actually
anyway
so
you know got a lot of stuff done on tiny
go got the chance to review a bunch of
the things that are in this new release
we got to check out
my main man toby thiel's new book which
i'm going to start digging into
maybe next week we will
go through
a chapter and see if we can try out
you know the stuff that's actually in
there
and
also some of the stuff that's upcoming
opencv has got a new release that's just
about to come out which means we need to
have a new go cv release in order to
support
the not even necessarily new features
but at least just work with the latest
version so we're gonna have to work on
that
and a couple of other cool things that
are coming up
so
i think that's about it for this week go
for bot and i will wish you an excellent
weekend
and if you're in the usa have a great
fourth of july if you're in the rest of
the world have a great weekend you're
probably starting summer vacation if
you're here in europe
um but we're still going to be on doing
some more shows this summer so don't go
away we're going to have some more fun
coming up for you so on that note
farewell adivadarchi sayonada adios and
live long and prosper
farewell
[Music]
oh
[Music]
foreign
