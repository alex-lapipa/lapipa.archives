---
document_id: "LP-MEDIA-YOUTUBE-VIDEO-XTR07R8FSIU-DOC"
source_id: "LP-MEDIA-YOUTUBE-VIDEO-XTR07R8FSIU"
title: "Ron Evans - Go Developers Network at LA PIPA Hackspace"
language: "en"
document_type: "youtube_video"
origin_uri: "https://www.youtube.com/watch?v=xtR07r8fsiU"
verification_status: "provider_metadata_captured"
access_scope: "public"
content_sha256: "638090c57374d4c9d6c61deb5751dd7531a71e8792132ed378c253ca24e634d8"
---

# Ron Evans - Go Developers Network at LA PIPA Hackspace

Archive source LP-MEDIA-YOUTUBE-VIDEO-XTR07R8FSIU. Ron Evans - Go Developers Network at LA PIPA Hackspace.

YOUTUBE video accession record.

Canonical provider URL: https://www.youtube.com/watch?v=xtR07r8fsiU

Provider identifier: xtR07r8fsiU

Creator/channel: GoDevNet

Go programmers now have access to an entire world of Bluetooth devices, the most popular Wireless Personal Area Network (WPAN) standard ever created, thanks to the aptly named "Go Bluetooth" (https://tinygo.org/bluetooth).

Developers can write code to control Bluetooth Low Energy devices from Go programs running on desktop operating systems. You can also write bare-metal code for chips made by Nordic Semiconductor by using "Go Bluetooth" with TinyGo.

This means you can write the code for both sides of your Bluetooth Low Energy wireless application all using Go. In this talk I will explain the concepts and show code by programming several live objects.

Provider metadata captured successfully.

Transcript (en-orig; automatic_captions):

Kind: captions
Language: en
thank you thank you very much hello
everybody
uh before i get started i just want to
say thank you so much
to angelina and to wilken for all the
great work putting this together
and i want to say thank you to tobias to
david and to vladimir for the fantastic
presentations really great work make
sure that you check them out if you
didn't see them because a lot of amazing
demonstrations and cool stuff
anyway hello i am dead program
i am here with gopherbot which is my
programmable robot plushie
entirely coated with tiny go and
i am here at la pipa in beautiful
northern spain where i do my stream
every week
uh check it out at twitch.tv forward
slash lapis.tv
so without further ado this is
go without wires i am dead program
technologist friar you know that at the
hybrid group
where we are all technologists for hire
well aren't we all
technologists for hire really but uh
yeah but specifically
and uh clients most interestingly
the company north volt where we are
helping this wonderful swedish company
create the future of energy
check them out so but also
a lot of open source projects that we've
over the last years gobot which was
one of the first hardware control
software written in the go programming
language
go cv which is a very popular wrapper
around opencv in the go language that's
used in a bunch of cool projects very
active project
and of course tinygo which uh you
must about from some of our other
speakers a really
amazing project that we're happy to
participate in
but this is a talk about wireless
networking
and of course when we mean wireless
we mean this time it's personal
yes we're talking about wireless
personal area networking
of course bluetooth i mean what other
wireless personal networks are there
actually there are a few but bluetooth
is the most popular
and so earlier this year we released
go bluetooth which is a package written
in go that is specifically to let you
use
this very powerful most popular
wireless standard ever created by
a sheer number of devices on linux
of course you need linux i mean linux is
very important
mac os for all the hipsters and people
who are cool
windows 10 we only have minimal support
still but
there is some it needs more work if
you're a windows person
and then of course bare metal which is
where we run on microcontrollers such as
the one built into gopherbot
using the nordic semiconductor soft
device which is not open source but
is a free license so uh very cool
software
so but what's so good about bluetooth
anyway i mean
why use bluetooth as opposed to zigbee
or one of these other
you know wireless personal area
networking standards well
first of all low power use
we don't want to use our precious
batteries to stay connected
another is high speed you can do video
you can do audio you can do lots of
other things over bluetooth
and then most importantly it is already
everywhere
i mean don't you want to program for
hardware that everyone already has
it's kind of a classic example of
increasing returns
so but which bluetooth is for you
you've heard all these different
bluetooth this and bluetooth that
bluetooth low energy perhaps or maybe
you want to use bluetooth smart
well haha fooled you there's actually
only one bluetooth
they all have these different names
along the way but bluetooth is bluetooth
no matter what kind it is today so it's
very good to know very important
so how bluetooth works so bluetooth i'm
going to put gopherbot down here
so bluetooth we're going to go over this
entire diagram here that shows
all of the bluetooth lower energy stack
huh no just kidding we're not going to
go over all these details
instead if you want to know more about
the very low level details
of the bluetooth low energy stack
check out sparkfun as a great
introduction along with some others
but let's just talk about the roles of
bluetooth that you would use
as a developer when you want to write
some code that
uses this bluetooth interface well first
of all we have peripherals
peripherals like your mindfulness
headset
or your heart monitor and then we have
centrals centrals like your cell phone
or your car and so this is a cool
diagram created by adafruit
and it shows in the middle our centrals
like our mobile phone
tablet computer and then around it
surrounded by this
embarrassment of riches of peripheral
devices out in the world all supporting
bluetooth so in order to
get started we have to use the generic
access protocol
so what does that mean well when
peripherals want to be found
of course they advertise so we're going
to start with a demonstration
that uses the adafruit itsy bitsy mlf
which is a nordic semiconductor nrf
52840 chip
with a 32-bit processor it's a 64
megahertz
arm cortex m4 and it has
about a 1024k of flash memory so let's
take a quick look
at our here is the itsy bitsy
it's very small you can see it i mean it
really is small
it's a very very cool board and uh i use
it for a lot of interesting things
so let's take a look at some code that
we're going to use to program the itsy
bitsy
so the code for the hello world
of bluetooth is advertising so we can
see package main just like we would in a
normal go program
we're going to import the time package
and we're going to import the
tiny go.org forward slash
x forward slash bluetooth package and
that's the package we're going to use to
actually communicate
with the device so the first thing is
that we have our bluetooth
default adapter since most devices only
have one
bluetooth adapter built in we have this
shorthand for you
and so we're going to put that into our
adapter and so our main program
first we're going to enable the adapter
we're going to call this must
function so we don't have to check for
the error repeatedly
in this code to make it a little bit
shorter so first we enable the adapter
turn it on so we can use bluetooth then
we're going to create our default
advertisement
which is whatever we're going to say out
to the world
and then we're going to configure our
advertisement
so that it's handler function is going
to
be able to provide this information that
the local name is globe
go bluetooth then we start advertising
and that's it we're done from that point
on all we have to do is just sleep for
an hour and let the advertising take
place
so let's go over to actually flash the
code
so if i say make advertising and i'm
going to
go ahead and plug in my itsy bitsy
and i'm going to plug it in here to my
computer
and then from there we can
go ahead and flash it by running this
make command that i've created
so it's going to the program is 9k
in size which includes the entire
bluetooth
access code and everything else and so
now if we take a look at our micro
then we can see that in fact nothing is
happening
right of course because we need to
actually listen to this
so let's go and unplug our
um device here the itsy bitsy and let's
plug it into a battery
and that way with this battery it will
start advertising again
and now let's put it aside for the
moment
and we'll go on to the rest of our
talking which is what about when
centrals
are looking for peripherals we have a
peripheral that wants to be found
but we do not yet
actually have anything that is looking
for it so when centrals want to find
peripherals
they scan and so
when they scan we're going to take a
look at the code here real quick
of our scanning code so let's see
get out of zen mode whoops
there we go and we'll go to our scanner
so the scanner here is actually very
very similar
to the uh to the code that we wrote
before
for advertising we have our main package
we import the bluetooth package then we
have our adapter a default adapter
in this case on my computer and then we
have to enable that adapter and our main
function turn it on and then we start
scanning
so when we turn on our scanning
we have our scan handler here wait
something's missing there we go
so once we start scanning by calling the
adapter.scan
we pass it our scan handler which is the
function that's going to be called
whenever a device that we find
is located and that scan handler here
gets past
the adapter and then it also
gets past the scan result for each time
i think we can turn off the speaker
loss altogether um so then
the device has got a string which
corresponds to its address
and then also the relative signal
strength of it
since you've probably seen this before
devices that are closer or further
and then the name of the device so let's
go ahead and run this
by saying make scan
and you can see here go bluetooth is
showing up that is our actual
device that we flashed before so if i
unplug it
it'll stop showing up and if i plug it
back in
it should if i could plug it back in
correctly there we go
you'll see that it will appear again you
see how fast a microcontroller boots
it's very very fast all right so now
that's our scanning
so and then what happens well
once our central has found our
peripheral
they connect oh isn't that cute
um by the way there is no actual contact
between central's and peripherals that
was a metaphor
all right so but let's keep the metaphor
going
a little bit longer since we're in the
mood
connections are exclusive once they're
made i mean for the lifetime of the
connection
so if you disconnect then your new
connection will be exclusive
and of course once you're connected
that's when we ask the big question
what data do you have so for that we're
going to need
the generic attribute protocol or gat
which is the other main category of
protocols
when using bluetooth so we have services
and each of those services has a unique
identifier
so that it's unique in all the world for
that one service
and then it has a list of the
characteristics for each of those
characteristics
it also has a universal unique
identifier
and then the actual data so if we look
at this cool diagram that was created by
adafruit
we can see here that we've got a service
and a bunch of characteristics under it
and then the different service and a
couple of characteristics under that
and so this defines pretty much the
whole high level standard of what we
care about
when we're using bluetooth low energy
the process of figuring out what that
data is is actually called discovery
and we don't have time um right this
instant but
what i thought i would show you since we
don't have time to look at the code i
brought another toy with me
so we could go back to some scanning
this is an adafruit clue board
which has another nrf52840
semiconductor nordic semiconductor
microcontroller
and then we're going to plug into it
with just a battery i flashed this code
earlier
and i could plug it in here real quick
then you will see
that as it boots up
we can actually it's a little out of
focus but you can see it's scanning
and you can see go bluetooth appearing
on the display of this device so a
microcontroller can be
a peripheral or it could be a central
right so we'll just leave that running
and
uh so there are well-known
services and characteristics that are
out there defined
by of course the bluetooth special
interest group
of which northern semiconductor and a
number of other countries
are companies i should say they're all
members
so these well-known
include for example the battery service
if you've ever been in your car and you
wondered how does your car
know that your phone is on low battery
it's because of the battery service
there's the location of the navigation
service which would be the opposite how
your
phone knows that the car's gps is
working
and then the heart rate service which is
if you were going to connect
a heart rate sensor this is how you
would be able to do it so
let's actually take a quick look at the
heart rate sensor
we're going to use the adafruit circuit
playground
bluefruit which is another board from
adafruit awesome company
and it just so happens that's the board
that's built into gopherbot
so what i'm trying to say here is we're
going to use gopherbot now
gopherbot do you have a heart
well gopherbot does not have a heart
however
gopherbot can have a heartbeat
so let's take a real quick look at that
code
um so the
heart beat what we're going to do here
is same pattern as what we saw before
right um let's see ctrl k
z for zen um so we have our package
main we have the standard packages from
go
rand and time we're using the bluetooth
package
once again the default adapter and this
time we're going we have a
characteristic which is the heart rate
measurement
so we enable our adapter same as the
other demonstration
we create a default advertisement same
as the other demonstration
the advertiser but this time our
advertisement options include
the local name and which one of the
service uuids that we're going to
actually advertise that we support
in this case we're going to say we
support the standard
service uuid for heart rate rate which
is a previously well-defined
well-known uuid that's any heart rate
monitor will support
so we start advertising and then we're
going to add our services
the bluetooth service has the bluetooth
characteristic
for the heart rate measurement so this
is the actual data itself
and we're going to start with a heart
rate of zero
and we're going to set this permission
which says
we can receive notifications from the
device
this is how bluetooth lower energy is so
efficient instead of continuously asking
a device do you have new data
instead it receives a notification from
the peripheral device saying
here's your new information and then
we're going to start the heartbeat
so the heartbeat it's going to check the
time and then
we're going to show the pulse somehow
by flashing some lights we're going to
sleep for however long our heartbeat is
supposed to wait for
and then we're going to vary it between
65 and 85
beats per minute which i've heard for a
gopher bot is relatively normal
and then last we're going to write this
to
the characteristic which is going to
send the information from the peripheral
to whatever centrals are listening okay
so let's go and let's take a look and
let's actually run this code so we're
going to say
make heart rate
circuit play and so i'm gonna plug in
go for bot don't worry go for about i'll
put you back normal um afterwards
but right now we need to program you so
you've got a heartbeat
so let's plug in and then we'll flash
the board
it's this is only a 13k program a lot
smaller
and now we can see actually
that gopherbots
heart is rotating at approximately every
second
depending on how fast or how slow so
let's unplug
from the computer and let's plug in the
battery
that way we you believe me that in fact
i'm not faking this it's all real
so we're going to plug in gopherbot and
oh yeah let's take a look and see
if we spot in our scanner yeah we could
see that we've got
go bluetooth still and then we've also
got go
hrs which is our heart monitoring
service
so just to prove to you though that in
fact
this is completely standard what we're
going to see
is we're going to demonstrate this using
um if we go back to it here
use the heart rate monitor that we're
going to show is using android
so i'm going to plug in my telephone
here and let's go over to linux
i'm going to plug in my phone and then
what i'm going to do is i'm going to run
a program that's called
screen copy whoops um
oh yes i have to i have to permit
and then let's try running it again
okay so now you can see my android phone
has appeared now
on the screen so if i go to this
application from nordic semiconductor
called the nrf toolbox it supports a
bunch of very well-known
services and one of them is the heart
rate monitor
so if i connect here we see go
hrs is listed under the devices so if i
connect to it
and we can see here's my heart rate
coming through
actually it's not my heart rate it's
actually gopherbot's heart rate
that's coming through at the same time
so gopherbot has a heart
that is so awesome right who knew that
robotic plushies
could have a heartbeat okay
let's keep going because we have little
to do and lots of time
no wait strike that reverse it
so there are also custom services
and characteristics not just the
well-defined ones
but that usually big companies get
together in their consortium but
there's lots of other devices in the
world and for all these other devices
for example like drones
so i of course love flying drones and
i've never found a drone i didn't want
to fly programmatically
so we're going to build a tiny go flight
controller
so the first thing is that it uses we're
going to use a parrot
mambo mini drone which if you've
maybe seen a couple of my talks you see
that i love these little parrot drones
they're very inexpensive they're very
cool
kind of hard to see um in that angle but
so this
is also got a 3d printed enclosure with
a first person video camera so let's go
ahead and
turn this on and you can see that the
eyes are going to start flashing red
because it's waiting for something to
connect to it
okay so what are we going to connect to
it well for that we're going to use
once again the same chip that we used
initially the itsy bitsy
nrf52840 so this is
a very very cool little board and i used
it in order to make
this which is a small
flight controller with only one joystick
so it's hard to fly a drone with two
joysticks but i'm going to do with only
one
because that's the most minimal possible
flight controller i could think of
so let's take a quick look at the code
so there's actually two pieces of code
here
the first one is that we're going to go
take a look at the drone client code
now keep in mind here that
the drone is a separate bluetooth device
with its own firmware and we're not
reprogramming that firmware
this is actually the client that we're
going to use so it's a client wrapper
from the flight controller
as a proxy for the drone itself
and we can see here it's got um
a main oh sorry wrong code here wrong
code
um let's go back to the mini drone it's
in the other one
my bad there we go
okay so this is the mini drone code
and it's got a few different services
and characteristics that it defines
based on the not well known but having
these uuids which are defined by parrot
and so it's going to be a wrapper
around the bluetooth functionality so
when we say
new mini drone in our code we're going
to pass it the actual bluetooth
device that we found and then
based on that when it starts it's going
to discover the services
which ones the services we use to fly
the drone of course
and then once it's found those it's
going to discover the characteristics
for each of those services
first for the command characteristic
which is what we use to send commands to
the drone like take off and land
and then the flight status
characteristic which is how we determine
is it flying has it crashed etc
and so if we go take a look at the other
code that i was trying to show you a
minute ago
which was the actual flight controller
the flight controller is what's running
on the
itsy bitsy board itself and for that
it looks a lot like the code that we've
seen previously
a few differences because this
particular board
now that we have as i showed you before
we have a display
it's an i square c ssd 1306 display
so it's just a very very small little
led
oled display an analog joystick and of
course the buttons
right so if we go back to our code here
we can see we
are initializing the i square c
interface just so we can
look at the display and then the
important part is that we're doing
the same thing as what we did in our
other bluetooth code
right we're enabling our default adapter
we're scanning in this case we're going
to scan for
the drone's mac address since every
bluetooth device has
its own mac address so we can find it by
that
we're gonna ron welcome back
i don't know what happened there um from
our side everything looked fine
that's a bummer sorry where was i so
right now we should be connected uh
when uh if i flash the code here
it should flash the board
with the uh the right code
am i still coming through okay hopefully
yeah so
um so i've just flashed the flight
controller
with this latest code and so if we go
over to the micro camera
we can see that it's actually displaying
the
the joystick and so
theoretically i am connected to the
drone
so now if we go over to the drones
camera
you can see that actually this is the
drone's eye
view and here's my flight crew
so let's uh let's try to take off and
see if it works so i'm going to press
the take off button
it's not the best connection maybe
it's a little interference but we'll be
i think we'll be all right so i'm going
to press the take off button and let's
see what happens
[Music]
okay and we're flying
so we're actually sending the bluetooth
commands
from the drone if i press this other
button i can
hopefully get some height so you can
see that in fact i am here we'll flip
around
the video's a little odd quality but
yeah there i am
hello people of the internets
all right so this is the drone that
we're flying entirely through bluetooth
and it's actually almost on the battery
that's why it's eyes are flashing at me
so i guess we'd better land
oh just in time we've lost video we've
lost contact with the probe
what does that mean well it means that
our demonstration is over of the drone
all right well i hope that worked
so um in conclusion
no contact with other physical objects
or living beings
well no problem of course all you need
to do
is go without wires so please
check out tinygoat.org forward slash
bluetooth that's where you'll find the
information
about go bluetooth runs on mac
runs on linux some very initial
rudimentary
windows support and runs bare metal on
microcontrollers
and with that i will say thank you so
very much
and are there any questions
