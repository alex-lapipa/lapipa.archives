---
document_id: "LP-MEDIA-YOUTUBE-VIDEO-TF8YRYJW7ZE-DOC"
source_id: "LP-MEDIA-YOUTUBE-VIDEO-TF8YRYJW7ZE"
title: "S2_03_DEADPROGRAM@LA PIPA"
language: "en"
document_type: "youtube_video"
origin_uri: "https://www.youtube.com/watch?v=tF8YrYJW7zE"
verification_status: "provider_metadata_captured"
access_scope: "public"
content_sha256: "b44bbcc4241b77eaa7f3331f7375a45ecb6a6babfcec4275adf733be27202e21"
---

# S2_03_DEADPROGRAM@LA PIPA

Archive source LP-MEDIA-YOUTUBE-VIDEO-TF8YRYJW7ZE. S2_03_DEADPROGRAM@LA PIPA.

YOUTUBE video accession record.

Canonical provider URL: https://www.youtube.com/watch?v=tF8YrYJW7zE

Provider identifier: tF8YrYJW7zE

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
um
so i was showing the
kitty hawk heavyside which is an air
taxi
that is electrically powered
that old chum chris anderson has
recently
joined that company as ceo when they
purchased 3d robotics which you remember
me
probably from quite a few years ago
using go
as it just so happens to fly a 3d
robotics iris drone
so
anyway very cool stuff that is happening
uh in electric vehicles of the sky
i just think that is so
so cool
all right so um
this is the um
the video if we can see it of
there we go this is the heavy side which
is the kitty hawk air taxi
and uh it's a pretty interesting looking
vehicle you can tell that they've got
some different design concepts and some
of the specs that they have been sharing
are just outrageous so i'm pretty
excited about that
so last tuesday
if you were on the internets uh i was
fortunate enough to be interviewed by my
friends at microsoft on their awesome
weekly stream hello world which is
on microsoft learn tv so you can check
out the recording
that is right now already up on channel
nine
and if you want to get information about
some of the things we talked about
you can go to
aka dot ms forward slash hello dash oss
and awesome human being and
go friend
airing whistling has been doing a great
job with this show and i was really
lucky to be invited on for the season
finale
so does that mean i'll be coming back as
a recording character next season or i
don't know anyway though it was really
fun they have a lot of cool stuff that
they're doing
and it was really great to share with
them some of the things that we've been
up to with tinygo
so
on the other side of the world
in chicago which just happens to be uh
my old hometown
there was at the chicago gophers meet up
at right i think around around the no no
actually some hours later um
i think probably midnight in european
time anyway tobias thiel gave a remote
talk about tiny go
showcasing some of the cool demos that
are in
his book that just came out the first go
tiny go book
and uh so i didn't get to see this video
yet because i couldn't figure out where
it actually was online supposedly the
video of the talk was there but
i haven't gotten to see it yet
anyway really looking forward to
checking that out and super cool stuff
happening all around the world of tiny
go
so um
i brought some toys with me but we'll
kind of get into that but i thought
before we did that we should try to
finish up a couple of the loose ends
some of the long story arcs in our own
extended first season
and so
um i think maybe we'll start with um
approximately the demo
okay
so we'll start with um manuel who's been
working on the
project cow detection
using machine learning tensorflow
opencv and go cv so i'm going to put my
mask on because
we got to see some really cool demos
last time showing some of the training
systems and apparently
this time we've got some actual code oh
let's find out let's see if the
homework's been worked on your final
grade depends on this hey how you doing
thank you roman
so um i still have um
this computer plugged in i think if we
just unplug it and plug it back in
it won't be too bad yes
no problem no worries um do you have
hdmi yes but i think it's on the other
side of course it's on the other side
it's always from the left side
that's one of the great rules of life
the input you need is on the other side
all right
cool
so yeah tell me tell me what you've been
up to
well if you remember and last time we
talked about how the model didn't really
detect that rate in video source let's
say using the webcam so just to re just
just to recap
so last week
you showed your trained machine learning
model
which you had retrained
using some source images of cows yes and
you were able to actually execute the
model
on your computer
using the remote server of what was the
company whose training services you're
using no i didn't use their training
services i used their labeling system oh
okay just to save some time
but i executed in ocv
we got to see that it didn't really
detect
much okay because
it's not really a final model let's say
it had only 300 images so that's a very
small number of images yes okay so then
what did you do next since the last time
yes so what i did next is i wrote some
code in gocv
to intake still images instead of a
video source just to check if while in
still images as we saw previously in
tensorflow we could actually detect cows
so
maybe this can also also detect cows in
wcv right well in all my exams yes makes
sense so let me walk you through the
code i basically took the code from the
dnn detection module and i changed some
things i also took some code from the
show image module just to see how to
actually
well it's actually a wrapper of opencv
but how to actually read the image and
show it in the frame instead of just in
a for loop i forgot to show you that
yeah no my bad but i found it but you
found it that's good that's good yes so
well i changed um how this model works
so
main changes were yes set in a test
directory so the first um if you
remember
on the first argument of the dnn
detection model was the device right so
you said that which camera to use yes
which camera to use
so i change that to intake the image
that you want to run the predictions on
but the rest of the arguments stay the
same the model to use the configuration
files basically and then
if we had some hardware acceleration set
up yes well we'll do that in a few
the next time okay well i guess that
depends on how good your performance is
with the cpu yes
not great
but let's see um yeah so the first
change is setting up this object with
the i am read to read that image
with the i am read color so you're
reading a color image from a file on
disk yes i have the files right here so
this is the image detection module that
i created and i just input well some
images just to test that it works sure
so we create this object we test that
it's not empty
then we we create a window and we that
way we can see the results yes and we
read the net this is all basically the
same as in the dna detection module
just if you recall um
well after all of these
setups for either cafe model or
tensorflow models and all of these
variables if you remember when we
perform the detection we actually have a
for loop and then it is always running a
blob detection for each frame of the
webcam right so we don't need that here
because we only have one image
so so we only have to do it once but yes
basically so
but it's the same thing so we have a
blob from an image which is 300 by 200
this is important because this is the
resolution where we should have trained
our model
just to make sure that
the predictions when we run them on the
image make sense so if we train the
model on 300 by 300 images and we input
an image with uh builder resolution
maybe then the model may not predict
that well
so we have to make sure that that's
right
then we just set the input um forward
through the net
and then we have the perform detection
function which is basically the same
and if you see here i have the for loop
where basically i'm doing the same thing
and that is in the dnn detection model
except now i'm using i am show for the
image
so it's just showing the image that's
already been processed but it's not
reprocessing it each time yes it's just
showing it because if you don't input
this for loop then it shows it for one
frame and then it disappears
makes sense
but the perform detection part is still
the same i'm just printing the
confidence and then my threshold is 0.3
just because i want it a bit lower just
in case
well because the model is not that great
so we can run that and then this code
here is drawing a rectangle around what
it thinks it recognized yes it's the
same code and i added something here at
the end we using the put text um
function from opencv
and just to write well i'm writing cow
just because i know it's a cow but if we
had
several classes we could input them any
other way which is more efficient but
it's basically um printing the
confidence uh
besides cow
and
in one of the
corners of the detection
just to see okay this is a cow and it
predicts with 90 accuracy let's say
so useful useful yes i mean
in python and in tensorflow a lot of
these models do have this and i thought
that it was weird that this one didn't
have it but it's not a problem you can
just do it like this
so for example we can run this pretty
easily we just input instead of zero
which was our welcome we just input
a path to an image i have them right
here so i can just call them because i'm
in the right directory
and then i input the inference graph and
the configuration file which are the
ones we need for prediction and those
are the ones that you downloaded after
you've trained them yes exactly and i
actually have to change this because
spoilers i trained a new model and it's
not that one nice
so this is the old model and let's see
how it performs oh why did it
crash it crashed maybe because it didn't
find them
it was not able to open the uh yes
because i may move the path
yes oh no i know why why it is it's
because it's not called config for this
one i think it's called test yes
without auto completes i couldn't do any
work yes tab auto completion is the best
invention
yes
oh wait it's a cow yes and it doesn't
detect right
maybe if or the confidence even more
maybe this will work so the model is
rubbish let's say
oh well
the whole thing is one giant cow well
there's at least one cow here right i
mean we can agree on that there's at
least one cow
so
with a confidence of zero point zero
point two really really bad
this is one of the things that
has been free because
well as you saw in this image we have a
0.2
percent detection
precision but when i run this test if
you remember in tensorflow
the predictions had a higher value
so i thought okay this is really weird
why are the predictions with the same
model different
well basically i
i
read a lot of documentation about this
and
my final conclusion let's say
is that um
the way tensorflow works
not just with the object detection but
the way the inference works with
tensorflow
and the way opencv does its interference
probably has some changes in the maybe
the output layers or something of these
models that i couldn't control or maybe
i could control if i had more time
but
i think that's the reason why these
changes are
but anyway i think it's even better if
we run inference on opencv just because
it's a lot faster than influence on
tensorflow
so tensorflow is really slow
and
for our purposes opencv is the way to
out for offline processing
i've used things like tensorflow server
yes but not generally for real-time type
processing yes for real-time opencv is a
lot better
so
okay
but you know one thing i was thinking
yeah
was
i had to bug in some code that used this
same pattern before
and it turned out that the problem was
is the uh
the code that current turns the image
into a blob yes so the function is a
little
um this one yes yes that's the one
so it has a number of different
parameters to modify
the different values as it's
constructing the matrix with the blobs
and swap rgb because i think um
opencv uses
b
brg i think or that's correct it uses
another channel it's the same
you know red green and blue but it's in
the order blue green and red yes for
historical reasons having to do with a
thing called television oh
i know what what's television yes
it's a it's a you know a thing that's
sometimes on in bars when you walk
through uh but
um but the bug was actually i believe
the last parameter is to crop or not
yes
yes i think so
what i was doing
was i was accidentally stretching out
the image
because the aspect ratio of my source
image was not perfectly square
like the trained images in what i was
trying to use for the object detection
and so
when i realized that and i fixed it so
that it was the correct aspect ratio
the recognition improved dramatically
yes that does make sense and it was just
a very
easy
like
the mistake was very like rudimentary
mistake and i looked at this code so
many times and i didn't realize it until
just
i think maybe it was you know
in the output just finally one day it
occurred to me to look at this parameter
and i realized i've been doing it wrong
the entire time i changed it and
suddenly the recognition
improved a lot as you might imagine yes
anyway i just was thinking that you you
probably don't make those mistakes
because you're a trained professional
and you know i'm i'm just a programming
guy but uh
but yeah so but anyway it was just a
thing that i was thinking about so tell
me so tell me more about what you did
next yes so i also created a
a program with
opencv
in python let's say so well maybe i can
open the folder and then i can show you
to compare the results to see if you're
getting the same thing yes makes sense
um
so
but this one uses the webcam
it's using opencv but it's using the
webcam but in python instead instead of
go or anything which actually should
output the same you can see it should do
the same thing because it's going right
there if not then it's a bug somewhere
yes
um well
it actually worked i think but
now i have to remember um how to
actually call it so controller which is
really useful oh yes
and yeah so it's here
we don't have it so
this is python for the webcam detection
of the opencv which is the name of the
python script then we input the model
which is in the 50k model folder so
that's the same model yes it's the same
model as before
the config file and then we can even um
input the confidence that we want
and it didn't work because for the same
reason i don't know why this because the
file was moved
it was the same error
but with a different message
probably no it it's not because it's
because when i read this is trying to do
it in the
with the new files from the new model
that i trained
and i changed the name of the config
file to test
well the name wasn't wasn't the same so
this is why it doesn't work but
okay
and well it doesn't detect anything
because we because we're neither you nor
i or cows only model is rubbish so all
things that's true problems yes
but even if the model was great we're
still not cows
yes that's true i mean i hope it doesn't
detect that i'm a crowd
that wouldn't sound fine i've been
trying to work out so
um so this is um what i did um regarding
scripts
and then as i said before i retrained
the model i uploaded
a lot of more images more than 300 yes i
think i have about 900 now which is a
lot more reasonable and you've labeled
them all as cows yes amazing that's a
lot of work yes it took a long time and
i think i
may need even more i don't really know
but
that was the new model so we can test
that as well i just have to move from my
directory
and so
this is
in this direct yes but that won't work
because i have to go to the actual
detection module which is here
i have a lot of folders so i got lost
pretty easily
that's why i have so many tabs
if i have to restart my computer i had
to restart my computer last night and i
don't know what i'm doing now
yeah or well that was it couldn't have
been that important or somebody would
ask me to do it again
yeah okay so this makes sense this will
run inference on images to the jpeg
which is one of the images i have
using the no this is not the 50k model
why
no because this is
the 40k model actually because it took a
lot longer to train instead of
let's say um i think it was about 20
seconds every 100 steps
and this model took about 40. so
double the time
so
this and now it's called config so it
should work
and
error opening ah yes that's because i'm
not using the correct module i'm using
the
dnn detection one which is the webcam
one and i'm trying to use it as the
image detection detection one
so i have to move here and now it should
run
on an image oh
well it's a lot better
it's very certain last time yes um but
in similar fashion it knows that there
is a cow like image within there but
it's not necessarily
trying to track each one
probably it doesn't have enough visual
information
yeah
[Music]
or maybe it's something to do with the
color of it
no i don't think so because in the
validation part of the training it
works reasonably well
it may have to do with what you said
about cropping the images correctly
maybe the resolution or even maybe the
training parameters maybe i have to look
at them
better maybe i have to train
and
evaluate at the same time and have a
cutoff point or something just so it
doesn't overfit
because i think i haven't tried it i was
just noticing the color palette of that
image is there's not a lot of contrast
between the colors of the sky and the
colors of the cows are not such a high
contrast yeah in that one it's
it's difficult but um do you have some
other sample images yeah i do um i want
to well let's say let's
try that first
um
so if we go here
i think i have well i have a lot of
images but maybe one of them is which is
five i think
so yeah
well basically the same thing
but but even just to the
untrained eye um it looks like there's
more color contrast
yeah
but it's still doing i mean it's a small
image and maybe it's not trained to
recognize features of a cow but just
entire cows
yeah i mean it's obviously
so do you have a negative example of an
image with no cow that we can try with
this model
i don't but that's one of the things i
wanted to show you is that maybe this
model is overfitting a lot
because when i tried
well we made that joke before i hope the
model doesn't detect me as a cow and i
think it will just because when i run it
with
the vnn detection one
so i have to basically change
this parameter from the jpeg to
zero just so it takes the camera
oh i'm a crowd
everything is a cow i see the image but
it doesn't but i don't see cow
yeah so maybe it's uh maybe one of the
other classes that it's able to identify
it's because um
i was really lazy
sorry about that but when i
um
had the oh no this is the dnn detection
one so this one doesn't have a label oh
i haven't tried it with labels yet
but i believe you though that things
were cows no in the other one what i
wanted to say was that in the image
detection one i cheated a bit and i said
okay
and move three pixels to the right and
three presets down and then put the
label there
so
if the label is big then it may show out
correctly but if if it didn't were
smaller or something maybe it would be
outside of the box or something
there's definitely a better way to do it
but just for testing purposes
and so yeah this model is also rubbish
and it's faster yeah
so do you think that it can now keep up
with
a frame rate that's
you know what frame rate would you
estimate that you think you could keep
up with i mean i think
maybe 24 fps or something maybe yeah i
think that's where the ssd mobile models
move around so
i think it should i mean
it's all about training more and more
and more and having even more images
because i have a demo that i've shown
that takes a type of drone a dji uh
tello drone
and then i would use it for facial
tracking once you've got it so it's not
too over fitted we could try that
with some video that we maybe capture
if we have some video flying through
some cows yeah yeah
actually
that
would be great just to test if the model
works or not exactly so we just need by
next week we just need a video
yeah and it doesn't even have to be
flying it could just be like walking
through i'm sure we could find some
video on youtube
yeah there are there are some videos of
cows or we could even get you know lucia
or somebody who actually someone who
actually knows cows
yeah and because we could test it
outside or something well with a video
first well let's get the video and then
only then will we take the drone out to
try the real time track the cars i guess
that'll be the finale yeah once we have
it it seems like it's working
out finale exactly
the big cliffhanger is like will the
ground crash or not
and will it detect cows well yes of
course not well
well cool it looks like you made some
really great progress yeah so what's the
next step
so i think the next step would be um
just looking at the training parameters
and trying to
train a better model yes
i don't know if 50k steps is the right
amount i should think so but maybe the
learning rate needs it needs to be
lowered or something
also you need some other animals
to make sure that there's no false
positives
yeah well i mean i mean right now it's
obviously recognizing us because it's
overfitting yeah but um
it shouldn't really need that many um
let's say background images or negative
images just because
there's a part of the tensorflow um
workaround that you do when you train
which is a hard negative minor where it
basically takes the image and okay this
is the actual cow so from the parts that
are not cows
they take those as negatives just so it
lowers the false positive rate so it
shouldn't in theory but
we have to see that works pretty well
for some other types of technology too
like anomaly detection for example yeah
interesting stuff well very cool so yeah
i look forward to seeing the next
version and let's see if we can get a
video and actually
you know test the frame rate
yeah and we you know the um
one of the demos in there you can
increase the delay
of the weight
so that it doesn't feed too many images
or frames to the model if it turns out
that it can't keep up yeah now there's a
couple ways to adjust that frame rate so
we can figure out you know what's the
maximum okay great
cool well great work man thank you ron
you're doing awesome it's a pleasure
this is really fun
cow vision
21st century the future yes the future
is the same as the past it's all about
the cows
that is awesome well that's really cool
i'm really i mean
computer vision
and
let's see go back to the main
yeah computer vision with
all of the trimmings
is something that is a lot more
interesting when you have some machine
learning technology to apply
this kind of recognition suddenly it
could become very interesting
uh cow avoidance like you don't want to
crash into them or cow recognition whose
cow is that
yeah very very cool i love it
all right
so
now let's go to the final
step
in the amazing story arc of lorenzo
learning to tiny go
with and actually substantially
improving upon the whole experience um
by like putting the hardware together
properly and helping identify all the
bugs hey how's it going i'm fine thank
you good to see you man good to see you
too yeah so i last week i was just
totally amazed at let's see if we can
jump over to the we cleaned up a little
bit maybe on that camera
oh you cleaned it up even more oh well
let's go let's go to the micro
because
is there enough light
i don't know
not too much no do we have to plug it in
to
light it up a little bit
i know it's okay
do you prefer a red light or maybe a
green light for a nice atmosphere
it looks like a jungle
yeah blue light
oh thank you
yeah so you did an amazing uh job
reorganizing all of the cables yes it's
much better you can easily troubleshoot
and um
yeah also see a pin layout to find out
where to plug in without having to
oh look at this we're on the wrong
camera no wonder
i thought that looked a little odd there
we go
i think you bought
gopher
yeah that's really cool
so just to reiterate for anybody who
maybe wasn't around for the whole story
arc and you're just tuning in here for
the final episode
so what this is about is
taking the information that was used for
the workshop
at gophercon 2019
and then revamping it all which is a
multiple step
series of lessons to take an arduino
nano 33
iot microcontroller and turn it into
this cool
sensor device
that adds more and more sensors
and then the final step which is step
seven
is the part where we actually connect it
we take the thing
and we turn it into an internet thing
and the way we do that is by connecting
it of course to the internet
i mean otherwise you know not much
happens
so let's see if we can you need the uh
we're sorry we unplugged that for uh
manuel's
laptop died oh you need any batteries
let's see if oh no no it's okay
just
fell asleep
hold on this oh yes i mean let me move
this yes
now it's
we're having the dial working as
promised
so i there is
and the led as well
no no not the other one so maybe we have
to reset the connection
so we're just taking no we i think
let me see
okay now we change the software so
we only have now the working display
so if i press the button you can see
in real time the
maybe it's over here
i think there's a little delay possibly
and uh there we go yes
so we can see this one is working and
the numbers that show up on the display
are actually
representing
the status of the potentiometer going
between zero and six five five three
five which is the highest value for the
16-bit
analog to digital converter
so we just jump over real quick again to
the uh to the code so we can
see what we're looking at so the um
step seven
which is this final step here
is uh
we can do it on your computer that's
that's good i'll jump over there
so step seven if we if we go to the
actual code
okay let me
okay
i am having some issues
okay sorry about this
you know every time i use windows i'm
like oh how do i copy and paste oh yeah
ctrl c
and then it's under exactly arduino or
sensor arduino actually
and it's set number seven if i'm okay
step
seven
dot go ah it's it's the right that's on
the directory sorry well no worries
so i'm surprised you haven't tried to
install a slightly better editor
no i have it but it's i usually use the
python for python and i have also the
other one which is very
i use a vs code successfully on windows
i have to switch to it
yes
it looks very nice
ah it's called main right
okay
all right
so let's take a look and see what this
is doing
so
it looks like it's doing all the same
exact things
it brings in all the same packages as
the step six did
right so we've got our
different drivers for the buzzer
and then um
so yeah actually um hmm
i'm looking at this and i'm realizing
that there's actually a fairly sizable
change that's taken place from when this
was done
and that is that this example is using
the s-pat driver which stands for the
esp82 command set
and i believe that this board has been
flashed
if i'm not mistaken
with the wi-fi neenah firmware
which requires a different driver
so we're going to have to change that
but i believe that that should be okay
because um
let's see what was the name of the event
we actually did a revised version of
this for
a google event
let me think of where the uh
it was uh
let's see where will i find that
probably in the same
location
um let's see
so much code
so little time
uh
let's see
trying to remember the name of it
um maybe we can run it on your machine
oh yeah gdg 2019
so it was the google developer groups
2019 conference
which took place in portugal
it's a really fantastic event
and um
let's see if we're still using s path at
the time um yes
so we're gonna have to make a few
changes to actually get this to work
um
only because the actual
firmware that's on your
esp32 compatible board
is different firmware than was used for
this example
which the api is a little bit different
but i bet we can figure it out
so
let's see the easiest way will be
probably
so if we were to look at the
drivers repo
for tiny go
the driver that we need to actually use
here to connect is called
wi-fi neenah
and if we looked at the sample code
under examples for wifi nina
there is an example for mqtt
client
which is
really really similar to the code that
we need to change
in
the example for the gophercon
code
so
one difference is you'll see that we're
using the wifi nina driver
instead of the s-pat driver
and then the other one is is that we're
use but we're still using the
driver's net mqtt package
so we
this might not be too difficult of a
change but let's see if we can figure it
out
so if we go to take a look at um
i don't know if i should try to do this
probably
yes it seems like it might be a little
easier
so i'm gonna go and i'm going to use
gvm
to choose go 1.163
and then
i believe
i think it's under development
yep that's where it is
and this is the gdg 19 code that's
that's not what i want though i want the
gophercon code
all right so
um
if we bring up visual studio vs code
i trust the authors the authors of tiny
go i trust them implicitly they're like
my best friends i feel like i know i
feel like it's myself
i know them better than i know myself
or do i okay so um anyway what we're
saying oh yes back to reality
so
instead of using the s-pat driver
we want to use the wi-fi nema driver
no it doesn't doesn't want me because
you'll notice my editor
remove that line
it's because
go
foot
go fmt
which is the automatic formatting
is already installed and every time i
save the file it runs it so it will
automatically reformat my file for me
but that isn't always what i want right
like in this case
i need to say wi-fi neenah device i
believe
and let's go and take a look at the
sample code we were just looking at to
make sure we get it right
so it uses the spy interface
instead of using the uart
so that's one really important
difference right there right so we're
not going to need this uart anymore
instead we're going to use the wi-fi
neenah
which uses the spy interface
and so we're going to define that pen
and the adapter is still
is the wi-fi neenah device instead of
the s-pat device we have that
that's good
so that's okay so we don't need to
configure the uart anymore now we need
to configure the spy interface
and so we can do that
so instead of configuring the uart we
can figure this by
and then
we want to configure the adapter for the
wi-fi neenah board and it's very similar
to what we would have been doing for the
s-pad because they have a pretty similar
api but
they're just different enough
that we don't want to just
um
so if we just compare them to make sure
that we're doing it right
so this is saying
so we used the spy configuration to
configure the serial peripheral
interface
and then
we
all the other code is the same as the
previous example we turn on the i square
c interface by configuring it so we can
use the display
the analog to digital converter
the pwm so that we can make the beeping
sound
so the only difference here is that
we're going to use the wi-fi neenah
adapter
and then we have to configure it just
like any of the drivers we say the name
of the driver.configure and it will set
it up so it's ready for use
and then i have this function i wrote
called connect ap
which is um
a little different than what we're doing
here
right we call this connect to esp
instead of connect to ap but it probably
does the same thing which is connecting
to the access point right
so let's go take a look at what
connected esp does
versus what connect ap in this function
which is in let's just in the same file
we don't even need to
so connect ap
what it's doing here is it's almost
doing exactly the same thing right if we
we could actually
we are going to connect to this network
and
we're going to sell our passphrase
which we do differently with the s-pat
interface it calls this connect to ap
instead of set passphrase so
we need to actually unify the api
between
the s-pat driver
the wi-fi nina driver and another wi-fi
driver whose pull request is actually
waiting in
this repository right now
which was just contributed about a week
over just over a week ago by saga 35
which is support for the rtl
8720 dn wi-fi chip yet another wi-fi
chip and this is going to have yet a
different api so we need to make at
least so that all the apis are the same
because right now it's really really
hard
to just switch between them yeah and the
idea is that we want to be able to
switch between them so
anyway let's let us continue so
so those are some differences right
there
and um
so that's
can it's going to connect for us and
then give us a message when we're
connected and then display the ip
address and then return
and this the purpose of this is just to
connect to the access point that we have
here
um in the studio
so let's go back to the original code
again
or the modified code rather
so we're going to connect to the access
point and then after that i think most
of this is going to be the same
if we go and we take a look at what the
actual mqtt part is doing
once we've connected to the
we can just call this connect to ap
just to
keep it the same
and connect to esp32
connect esp32
to access point
it's not an access point it is on a
client so it needs to connect to the
access point
i think it was called connect to ap
oh
that's right actually i already added
this other function
so we can just remove this
wait
am i doing this right
oh it's supposed to return a true or
false depending on whether it succeeded
that's what the problem is
so
if it fails
it'll always succeed
so we'll just say return true
and we have to
return the value a bool
all right now this should actually
have a better chance of working
okay good
so if it connects the blue light will
turn on
and it should
otherwise it will
oh
and we've actually removed the
should we let's see
at one point i had it so that it would
display that message on the screen
and in fact you'll notice we're not
actually using oh no we aren't using the
display we're reducing the display
okay so no i didn't remove it okay
that's good i just want to make sure i
didn't totally remove it
all right
so we've almost got this done
so
now the part where we actually connect
to the mqtt server
to do that
what we have to do
is
uh here we go
so first we
this is using the same interface
as a very commonly used package
which is actually created by the ellip
eclipse foundation
called pajo
mqtt
but for go
yeah i hadn't used the one for python on
the client side yeah i mean everybody
these are uh the official
libraries from the eclipse foundation
uh they're also the maintainers of
mosquito which is the embedded one the
mqtt broker that a lot of people use
so um
so because this package requires
some operating system
and because tinygo has no operating
system when it executes on a
microcontroller
we couldn't just use this package by
itself
however
we're able to use the important part of
it which is
the actual definition of the mqtt
packets that are used for the protocol
it's a tcp
based protocol to communicate and so we
could just use this we're actually using
the real package
in the driver
but
we're not able to use the entire package
and the reason for that is because it
has some expectations
about
the way that
the
operating system should be providing
some of the networking capabilities and
in our case we're using that other chip
that's actually built in
right to when we're communicating it
with either
with the s pat driver a serial protocol
and with the
um wi-fi nina a spy-based protocol so
it's not using like operating system
networking calls at all
and that's what the normal pajo package
expects
so that's the reason we couldn't just
use it by itself but we could take
pieces from it
especially the most important ones
and then use those
in order to
um
put everything together or as far as
what we need to communicate
so it's still the same basic principle
which is
we're going to create
an option structure
whose purpose is just to hold whatever
if we had some specialized options
that have to do with the
mqtt quality of service or keep alive
times this is where we would set those
but
i don't need to change any from the
default
so then we add a broker to it which is
whatever server we're going to talk to
and we set our client id
to tiny go dash client and then some
random string
this is because most mqtt servers will
if they get
a client connecting with the exact same
id as one that was previously connected
they'll disconnect the old one
and only allow the new one to connect
that way they don't get duplicates so
this is what this creates a random
string and that way if
you and i both at the same time try to
connect to an mqtt server it doesn't
kick one of us off
we found this out when doing the
workshops that if we didn't have a
random string
everybody was stepping all over
its own their own connections and the
mosquito web mqtt server would say oh
kicking you off because there's a new
one
we couldn't figure out why what was
going on at first so
anyway
so we set that client id
we'll turn the blue light off
display a message
then we'll try to connect to the mqtt
server
and
then we'll go on to if that works we'll
initialize the display
handle display the same as our code from
before
now the only difference between the code
that we previously had
and this code is
after we get the value of the dial
and the button
and the touch sensor
we're going to take and we're going to
publish a message to the mqtt server
that publishes this
fake json
it's not real json it's just text that
looks like json
and then it publishes it
and then it'll do this every 100
milliseconds the same as what we were
doing before
so the only difference between this and
what we did previously was that
in addition
to us
reading the sensors we're also
publishing an mqtt message but otherwise
it's exactly the same
so let's find out if this actually
compiles
and we need to and then we'll plug it in
and see uh if this works
but we i need to see if it even compiles
first because uh i have not actually
tested it
so if we say tiny go
we can make this a little bigger
tiny go build
and we'll output to just test.hex
and the target
is the arduino
nano 33
hey i see a question on the internets
about go cv should it run on the apple
silicon m1
that is a really good question
the answer is i don't know
um i don't have an m1 myself well my
wife does but if i take her computer and
i try to do this on it i'm you may not
see me again for a few weeks
because i'll be uh in hiding
um
i think that it should
and that's something we need to find out
actually um that's a very good question
and i'd like to know the answer myself
i think that it should be able to
but it may require a few tweaks because
we're going to have to
you need to compile opencv
with the arm
parameters
on your mac
and so i'm not 100 sure if the
version that's in homebrew
for mac uh we could look at that
actually after this i'll take a look
because that's a very good question
thank you live hacknet for that question
because that's super interesting
all right um anyway let's finish this so
we were just gonna try to see if we
could build this target arduino nano
and it is step seven i believe yes
yes it is
all right
so
um has no field or method echo
yes of course not echo
um
i don't know what that was supposed to
do
but we can just remove it
that looks like a clever feature that
even i forgot what it was supposed to do
all right it does compile
does that mean it works
well we don't know there is one other
thing though that we're going to have to
do
exactly we need so um
the
let's see
where is
it um
so there is in fact
a file
in this directory
that should have the
ssid and password
that we used
from uh
so i'll just kind of go back over to a
different window that way i can look
just preserve our highly secretive
information
now that's definitely not it right
so uh
luckily though i have a file that should
do the same thing
i believe
i guess we'll find out here in a minute
let's go back to my computer
all right
so i believe i have a file
in a mysterious location called my
desktop
and so if i copy
desktop i believe it's access
to sure
to
step seven
access go
and that should replace it let's make
sure it still is able to compile
no of course not
um
ssid and pat oh i see
ssid
pass all right so
of course it wasn't going to be quite
that easy
while maintaining a high secrecy
let's see if we can fix this here
make it easier
let me just do this
other cons set them as environment
variables
that's one way to do it but probably not
necessary here
we could just replace those with the
right values
okay very good
now we can go back to our main window
make sure that our code compiles
no uh let's see oh it's because it
should be named password
probably the name of the variable
okay so now it compiles
so will it flash
so we can just flash this from my
machine
since
and
put any other different cable luckily i
have one
right here a vehicle so the problem you
will
well at least we can flash it with that
and then power it up if that doesn't
work
okay
so
yeah i had to actually downgrade my
linux kernel last night because i ran
into a problem where
um
it turned out the an upgraded come in
which caused my serial
my usb uh compute cdc to no longer
function that was really annoying
all right so we'll flash it
and
it's thinking
it's flashing yet
okay
well we have to reset the buffer of the
well you'll notice it's not actually
doing anything
and that's because
we use too much power
and the thing will freeze up
because my usb port doesn't provide
enough power for both the display and
for the wi-fi but luckily
i brought with me
a separate usb
5 volt power supply
so if we just
plug that
so one of in here
[Music]
and we plug this in
well i guess we'll find out if it works
so we configure this as a client no for
that's what should happen
um
[Music]
and do we have to set up the broker to
get those
what broker did we actually
um
what broker do we think we're using
i believe that we're using the broker
that's just on
ah
so maybe we need to not use the ssl
version but instead just use the regular
mqtt protocol
which i believe is tcp
and make that i believe it's 1883.
we can verify that
quite easily
yes
it is tcp
test.mosquito.org port 1883.
so this is actually the mosquito test
server
yeah thank you
all right
so this is actually the mosquito test
server so we'll have to plug it back in
again to flash it okay
try this again
flashing now
okay
so what should we expect from
well the first thing it should do is
turn the um
it should be trying to connect to the
wi-fi and do we get any i'm not sure if
we actually will see any notification
because it might take a while well but
we probably better plug it again well
hang on but let's wait and see if we can
let's just see if we even get anything
to happen here with um
okay it's trying to connect
okay maybe we don't have the right
uh ssid and password
or maybe we just didn't wait long enough
because um takes a while i guess yeah it
can it could take a little while
depending on uh
but that's what it says while it's
waiting to try to connect usually
okay let's try it should we
um
let's see here
so let's take a look real fast just
to make sure i didn't mess up something
with the
code values because i believe i've got
the right info for the
ssid and password
which is what we're passing in here to
this connect to ap
and it should be
using this code from
here
connect to ap
which um
sets the passphrase
checks the connection status that's what
just displaying that idle message as it
continues to try to connect
and then
it uh
okay
what's happening here
get ip
prints the string
and wait a second here
return true
so yeah it seems like it should have
been working
so one thing we can figure out real fast
is um
so if we
just
unplug it and plug it back in and we
see if we can connect real quick well
but we weren't fast enough before it
displayed that first message
yeah we said maybe no no leave it leave
it be for a second let's see if it let's
give it a minute to see if it's gonna
it's gonna keep trying here
sometimes it takes a little while and we
do have the right
um oh wait a minute another problem
i believe
i'm pretty sure
that
is this the old info no no that's the
right info
nope what is it
okay
so um
it certainly could be
similar to the symptom that i had seen
when we were doing the workshop which
was
to
remove the um
ss
the
oled display because you just couldn't
take it
but we're not seeing any feedback
like i believe that this code when we
looked at it before
that what should be happening here
when it first goes to it should turn on
the blue led when it if it connects
and we're not seeing the blue led come
on maybe we want to move that before
that so it turns on the led
um
oh wait a second hold on here
we actually are doing this wrong we're
calling it twice
this is clearly wrong we don't want to
call that twice
we want to check to see if we're
connected
only once
not twice
let's go back to so people can see what
we're doing
that's just like a bug in the code or
whatever
because connect ap here
should only be calling we should only be
calling once and it should
would do this connection
and yeah if we um
we're calling it twice then that would
be a bit of a problem because
but let's also change the leds let's
turn on the led
initially the blue one if we connect
we'll turn it off
otherwise we'll just leave it on
sounds good yes makes sense so now let's
go back and plug it in and flash it
again
you thought that was going to be really
easy like oh yeah just in another thing
it should be like no problem
that's one of the hardest parts is just
getting things to connect
all right so
give it a flash
it's thinking
okay now it's on
well let's see
will it turn off
or will it just sit there
attempting forever
predictions don't steal the same
this is doing the same thing
but let's be a little more patient and
give it
a little bit longer to connect
20 seconds because it does take um
when you restart the
arduino nano 33
there's two microcontrollers starting up
there's the main one which is the at sam
d21
and there's this separate coprocessor
and it needs a chance to start up as
well but i mean it's it would have
already done so
i don't think that's it
but now that we have the code right
maybe we should yeah let's try that
let's try powering
i had some issues with
a bad cable no not so well we're not
supplying enough power
and so these kind of problems are
sometimes are very difficult to
understand
because i believe that we should be
getting enough power out of the
just the usb i don't think we need to
plug into the separate power inputs
but
that was how
i did it because it should be using the
regulator
of the
board of the arduino
it should be using its onboard regulator
to take however many amps it can out of
the usb
but maybe it's not maybe to get the
amount of power we need
we actually have to have a separate
adapter
to plug this in to the
we can plug it from the
the input
but we don't have anything to do with
right now i have a jumper cable but what
do you want to try no with an external
power source from the
voltage in
i think i was powering mine not from the
usb but from the
input pins
well we can do it probably i can try
from home to see
if we with another source
we can fix this because i mean let's
just look at the code and make sure
there's no
like obvious error
is there some information we can capture
in between
connections let's see
well it wasn't giving any error it was
just simply not actually connecting it
was saying connection status
and then
repeating this idle message
you know over and over basically okay
that was what it was doing
and the ssid is correct
and the password
i know because i copied those over
you know we would see the um
if it's able to connect to the access
point
let's just increase the length of time a
little
so we can try to catch that first
message
just to be and let's
flash it again so yeah we'll flash it
again
and
plug in
give it a little flash
it should tell us connecting the ssid
hack
space
yep yes
but it's not successfully connecting
let me we have to leave it for a while
let's see
no usually it just means that um
it would have not given that message if
it wasn't able to communicate with the
okay
so
it's just um
it just makes me wonder is there
something
else plugged in wrong somewhere
normally
we would
it wouldn't even get this far
but we're not seeing any actual error
well no i mean not um
just to make sure that we're not
accidentally using
a pin that's reserved for the spy
interface
as opposed to
um
you know accidentally basically
what i mean is some of the pins on there
could be used either as the spy
interface
or it could be used for
but i think those pins are just plugged
in directly
what power are you taking out
are you taking the one from 3.3 volts
from d
yes
that would be correct because that's a
3.3 volt and that's what we want to use
to power the other one
this vusb would be the 5 volt and we
don't want to use that
yeah we are thinking
this is going to i think that what in
order to get maybe we needed to plug
into the
voltage in
and the ground
from
an adapter
because no maybe it's not so one way we
can find out if that's the case
is we can just go and disable the ssd
that's what i did originally that was
the reason for that
was um let's see
where's the ssd
uh
oh yes handle display that was it
if we don't handle display
a net display
and you want to
exclude it
and maybe even
it shouldn't if it doesn't get turned on
it shouldn't draw any power
so if we just remove those and we try to
flash it again
if that has something to do with it then
it might work this time
in which case i don't have the power
problem fixed
says idle
i'm gonna have like a loose ground or
anything that might cause it to complain
because it's giving us this idle message
that means that the esp32
is uh
so while we're waiting for this to
so live hack net uh
cool
you tried the installation
um yes please do send if if you don't
mind um we sure appreciate if you went
to the go cv repository
and entered a github issue
that gave the error message that you ran
into
when you tried to install
yeah um i think if you just use homebrew
from your m1
it will automatically install the arm
versions of whatever you're trying to
install
and
you can actually take a look at that if
we go to homebrew
opencv
we can look at the formula
on the github repo that they have
uh
let's see where's the formula code on
github there we go
and we can see if there's anything so
yeah arm64
is there so that should have worked
potentially
so if
opencv has correctly installed
then it should be possible to
get
go cv to also install
but it may require
a few different settings than they're
currently in there
so um
live hacknet yeah if you don't mind
entering into the
go cv repository which is on
github.com forward slash
hybrid group forward slash go cv
and if you don't mind entering an issue
for
maybe this is you right here right now
now this is for somebody else who had
run into some problems which looks like
they did not actually install home
opencv through homebrew
whereas i see obviously you have
livehack.net
but
i would suspect that we would need to
make some changes possibly to go cv the
way that it is
hmm it should still work because if it
uses package config
which is the way that it normally works
on
um
on linux and on the mac then it should
have picked up those settings but i
don't know um
you know i
i'll have to wait till my wife goes to
sleep sneak in
walk off with the computer quietly
realize i don't have her password
and then like what do i do then what do
i do then like then i'm caught i have to
go back put it back
and uh
yeah well but we'll see if we can figure
that out because that would be obviously
a good thing to have
in the meantime
with all that time we were waiting and
it did not connect so it's clearly not
working
the way we expected
but it's not acting
interestingly it's not acting the way i
would have thought
let's go back and let's take a quick
look again at the
make sure we have all these
um
let's see
the mqtt
examples is what i'm looking for not the
so if we get down there
under
wi-fi nina
mqtt client
and
so let's just take a quick look to make
sure that there's nothing
completely obvious
so still using the
spy configure
which we're doing here
and this code is just copied
um do we need to define the spy
interface somewhere
spy equals
machine
oh well hmm
that doesn't look right at all
i think just looking
that would
be pen not an actual
interface that doesn't look right
something looks off there to me
let's go take a look at one of these
other examples here
mqtt sub
well that must be right
this must be a uh
this must be the actual spy interface
and not what it looks like
i closed my window but we can actually
check that out pretty easily
just by going and taking a look and oh
wait
b zero there we go
to the tiny go
and if we just take a look in the code
for time ago
and we look at the board files
that are used for
all the different boards which are under
the machine package
and we look for the board for the
arduino
there's a lot of boards well so many
boards supported it's pretty incredible
so yeah the um
so yeah this is not right oh no that is
right it is
nina spy is a constant which is set
equal to spy one
which should be
um
and yeah that should be a um
it certainly should have worked
but
um
something worth trying
perhaps
would be if we go back to the
just other curiosity
if we
say that this spy is going to be a
pointer to it instead of a
but he's saying
using the ampersand and getting the
address of and let's just see if that
maybe i don't think that's it though
think there's something else wrong
but i'm not sure what yet
we'll flash again
and it is trying to connect again
it's not actually getting an error
usually if there's something wrong it
won't say connection status idle it'll
so this is what happens when it thinks
it's sent the request but it just hasn't
been able to actually get through
and that's this um
access point here
and there's no like interference or
anything maybe from
just make sure everything's
nice and tight
and that hopefully the
we haven't done any damage to the
antenna or anything
[Music]
which is not too likely
but it has happened
if this one got squished
do we have another one i have another
one but we could maybe test it with just
one of these other programs
i think i brought it with me
i didn't bring it today
i brought all my stuff except for that
no i i took the other one back because
it was broken
hmm
well let's just take one last quick look
to see if there's something that
stands out here
because
so data out day the end clock
frequency
that certainly should be correct
and that's what we're doing here which
is basically setting it to um
and then we are
defining the adapter we're configuring
it
connect to ap
let's make sure we're doing the right
things we set the passphrase we
check the connection status we wait
and only if it fails
hmm
well one thing that's a little different
i don't know if that's meaningful
is we'll just um
we just call the function
without worrying whether it succeeded or
not
even though it should have displayed a
it would have displayed that fail
message
one seven yeah
what's in step six
doesn't matter all right
um
that should have displayed this fail
message if it wasn't able to connect but
if it never times out
so connect to ap
it's going to
[Music]
keep trying until it gets through
and if it does it should display the ip
address otherwise it just keeps trying
all right
we just remove some of the extra error
checking which
just to be sure
we can also try
removing the actual call which
initializes the
i square c interface to see if that's
drawing too much power just from turning
it on
i don't think so but
okay
but certainly worth a try
which is not configure the i square c
interface
since we're not even
since we're not even using it actually
um
so we'll flash it one last time
i don't think so
something is not working
so one thing to try is actually just try
to flash it with one of those sample
programs
so if we go to the drivers
use go 1.163
and we'll change to the directory with
the tiny go
drivers in them
and if we
let's see
probably need to
probably need to look at the code here
real quick just to make sure we're not
doing something completely off
um
going back to our examples for wi-fi
nina
let's just go to the
connect example which is what i used
previously
and it looks like it's all pretty much
the same
yep well that should have been it
okay
and i think i have to remove these
so i believe if we just flash the
connect so if we say tiny go
flash
target
arduino
nano 33
and we use the examples from the wi-fi
unit that connect
and then we go back to our
um
oh yes
good to note which
it's doing the same thing
hmm
something's
off could be
some problem with the board
that's what makes me wonder
maybe this board got damaged and uh
unfortunately i do not have another
one of these exact boards with me so we
can't test that right now
[Music]
all right
well we're going to try so we're not
finished today we still have one more
thing to finish which is this to get it
to work because we need to connect to
the internet
yes for us to say we have an internet
thing
so i'll bring another board with me and
i will test that as well
and just make sure that there's not
something that's gotten off somewhere
and then
we'll try this again next week for
so it's a two-part cliffhanger
[Laughter]
okay
we're cool man i mean uh you did uh i
mean everything looks like it's good
it's got to be something that i've done
something wrong while trying to hack
that code together at the last minute if
we work next time
not realizing that in fact i had um
because i know we flashed this with the
wi-fi nina
because otherwise it wouldn't even get
to that yeah it would it would actually
just give a terrible fail
um of a different kind entirely yeah
okay all right well next time that was
interesting
all right
all right thanks ciao
hmm
all right well that wasn't quite what i
wanted but uh
you know what can we do
um
well there's one other thing that i
wanted to play with today
um it's a new toy
that actually i just got
from the awesome people at pine pine64
so if you haven't heard of pine64
let's bring up their website
so pine64 is a really cool company
they have been making open source
hardware for a while
if you've ever been to fosdam
which is the fantastic open source
conference that is located in belgium
it is a chance to drink trappist ales
and eat fried foods with your open
source friends
and they have
um
last year was the first online only
hopefully next year we'll be back in the
world of these wonderful dark bears and
open source glorious madness
anyway pine64 tl who is the founder
um has been physically at fast
for years
in a
little hall which is or
hallway i should say set up with a
number of different hardware hackers and
open source hardware people
really cool stuff always happening so um
the paring phone
if you've heard of that is from them
it's an open source mobile phone the
pine time which is a really cool smart
watch
and
so the pine
sole
like pencil but pine sole
um
what happened to the what happened on
the uh
well i'll just do it
wait for it to show up
pine sol
what
not the pine cube
the pine sole
so the pencil
is an open source
soldering iron
which is programmable thanks to its
built-in 32-bit risk 5 processor
so yeah obviously you need a open source
processor
that is running open source firmware to
do all your soldering i mean clearly you
need that well i needed it and so
i was really really excited
when yesterday
lo and behold but what should appear at
my door
but
a pine sole
so i
i looked at it in the box and i didn't
even try to plug it in because i thought
i would share it with all of you
wonderful people
and uh so this is the pine sol itself
so let's go ahead and open it up see
what's in here
so this is the let's see if we can get a
little better focus
uh
other way there we go
so you can see it's very small
this is the
just the soldering device itself i feel
like i need a little more light
a little too dark
there we go
all right so
it's very small
it's got a
two jacks or two ports on the bottom one
is a usb c
and the other one is a barrel connector
you can power it with apparently either
one of those
and then up here in the front you've got
a little set screw
and then where the
actual soldering tip gets inserted which
this is the soldering tip that it comes
with
and you know it's not too skinny and not
too fat just kind of a
generally
you know fairly decent looking size
so let's go and um see if we can screw
this in
which i believe i'm going to have to
unscrew this or
alright fit but i think i need to screw
it down a little let me see if i have a
screwdriver
which i should
generally carry many many small
screwdrivers with me for obvious reasons
okay
so let's
tighten it down a little bit
that way it doesn't just fall out okay
looks good looks good
all right so far so good
so
in order to power the pine sole
it does not have a battery i know you
thought it was but you can't fit a
battery that's actually strong enough
to
be able to
do anything at all that involves heating
up a soldering iron
so you need some type of external power
supply and that's what those two jacks
there for
so you could use like a high
oh
not a high voltage but a higher
amperage 5 volt battery like one of
those big
heavy ones that you use to charge your
modern telephone
that's one option
the other one is you can use an external
power supply of some kind let's go back
to the other
camera because that way we can see this
a little bit better
because i'd like to solder something
i don't actually need the soldering
anything but
i just want to
because i mean when you get a brand new
soldering iron you have to solder
something right
so here's the pine sole
i mean the first thing we got to do is
power it up and just even see what it
does right
so i brought with me
one of my many power supplies
this particular one is a
12 volt i believe it's 7.5 amp
i use it for powering
led lights that are really really bright
on
some occasions when i have called to do
so which is to say
i don't even need a reason
i just will do it
so let's plug in the power supply
and then
let's plug it into
the soldering iron and see what happens
okay oh something came on
there's some lights
so it claims that okay that looks like
there's two options one is to turn on
the heat
i haven't read any of the documentation
i have no idea what i'm doing but this
is awesome
so it looks like the top button turns up
the heat and the bottom one goes to
like a menu option let's see what that
does first okay
so it says power source
dc
i don't know if you can see that in the
camera
on this little cool built-in oled
display
and it says that it is
[Music]
disabled
the power limit is disabled
power source dc
qc voltage 9 volt
soldering setting
sleep mode
user interface what does that do
temperature unit celsius yes of course
i don't want fahrenheit i want celsius
display orientation right or left i'll
leave it on right
a automatic
l left
alright good enough display orientation
cool down blink
so
the
risk 5
microcontroller's firmware
apparently will automatically cool it
down if you put it down
so that's good that way it doesn't burn
anything down
scrolling speed i think that's good
enough
and reversing the plus and the minus
keys
i don't i don't think i need to do that
all right so let's go back to
oh there's advanced options but
let's just
get out a couple of more accessories
first and see if we can actually use it
to solder something
so i
got a
little tiny
portable
soldering iron holder
didn't really need it probably but it
just looks so cool i mean
you need something to
all those lights yeah you can see good
enough um well enough i should say so
you need something to rest it on uh
while with the hot tip or else it's
definitely gonna burn something down
right
so let's get some solder
which of course i have always lots of
solder
and
let's get something to solver
what should we saw there today
well actually um i did have something to
do which is i have one of my raspberry
pies here
uh one of the raspberry pi pico boards
and
i have i have a bunch of them not a
bunch but a few
so i wanted to solder some more pins on
it
so that i could plug it into a
breadboard and use it for some things
so yeah let's go ahead and do that
so i'm gonna
put in my heather here
break it off in just the right spot
and we'll have to put some headers on
the other side that way it stays even
which it happens to be exactly the right
number of pins
on both sides very good
so let's
can we see this
it's not the brightest but
it's probably
oh here
i know
it's a little bit brighter over here
yes that'll work
all right so let's
move the cables out of the way so we
don't light them on fire
the minute we turn on the soldering iron
and
so we've got the solder
and i've got the board that i want to
solder right here
and
i'm going to get a chair so that i can
get a little bit closer
otherwise
i won't do a good job and that's kind of
important right
i mean this is not soldering for
soldering's sake i'm taking one of my
precious supply
one of my oh so precious supply
of raspberry pie pico boards and
soldering it together
one thing that is sometimes helpful is
to use a breadboard
but if you heat it up too much then it
will melt
and then you have one less breadboard
all right let's see what happens when we
turn on the heat
oh
it's heating up wow it really is heating
up
it's got a little display in here and
it's already about over 150 degrees
celsius
to about
225 celsius so that's probably quite
warm enough for us to solder let's
melt a little solder on the tip to see
if it in fact is hot enough it's over
oh yeah this is cool oh this is working
great look at it
can you see that smoke
it's real alright so
let's go and whoops
this is why you need a stand
because you can't just put this down
right now or it will burn things up
and that would be very bad
so let's
put it down and let's see if the
automatic
is trying to get away let's see if the
automatic
no it's not turning off
i thought when i put it down it would
cool down
maybe that's a user setting
we definitely want to be able to turn
that on
all right so let's get the pins at least
more or less adjusted
good enough
we'll take the
tilt the connector over a little
and
[Music]
oh yeah this is actually really nice
i have to say
i've used quite a few soldering irons
and this one is pretty slick
i mean for how small it is
i mean that first other joint is nice
let's get the other one on there so that
the headers for that don't fall off
so we'll just
i felt like it moved a little
yeah we have to align it better now
if the pins are not correctly aligned
you will
not be able to plug it in
okay
that was a little too much
i don't have the best lighting here but
for this i'll give another a light next
time so that you can get a little bit
better view
but
let's just straighten the other pin this
out as well
all right so let's go ahead and turn
this off now
which
how do you do that
i see if i turn this down to
hmm
well
what how do we turn it off hmm
that's kind of key
soldering settings let's see what those
settings are boost temperature there's a
boost
ooh i don't want to boost it
auto start
temperature change short
i'm not sure what that does
temperature change long oh i see if you
want to like give a
boost for a period of time like a quick
boost or a long one allow locking
buttons
i can't really tell
what any of those do
i assume it's still quite hot though
you'll see this definitely hot you can
see the smoke coming off
hmm
all right i might have to read the
manual
at least a little
so let's unplug it
which will of course turn it off
and let's let it cool down a bit
and while we do that let's take a quick
peek over here
at the
documentation page for this thing
which has
quite a lot of information on it
so
probably i could read the manual on here
somewhere
oh let's see
go to store no oh there's a wiki
excellent ah yes the wiki page
so
it's got instructions here on how to use
those soldering settings like the boost
temperature and the auto start
excellent
the user interface advanced options
here's some of the prototypes
well this is really cool
so let's go take a quick look at some of
the other accessories that i got
which um
i did not want to take it apart
and
before i had a chance to at least try it
and make sure it worked right i mean
if it didn't work and i had already
taken it apart i mean i'm sure it worked
out of the box right
but
this way we can be certain
so here is the pine soil itself which
i don't know how hot it is
it cools off quite nicely
yeah it's really totally cool
wow that's really good so it's got this
tip
that it came with
and then i also got
a kit here that includes
a series of other tips
in case not kind of generic size is too
you know fat for you
you've got this
really really skinny micro tip
there's a chisel i got the tips that
were the
fine tips as opposed to the
thicker ones i'm not going to use
something like this to solve something
that's too thick probably so i got my
replacement or substitute tips
i've got the breakout board so since
this is in fact a programmable device
and we can
perhaps at some point figure out how to
get tiny guy the run on it
so that's what this is for
is this breakout board here is that way
you've got pins for the debug connector
and the
ota update so i suppose this will
probably be something you just plug into
that back port
and then
if we connect jumpers we'll be able to
program it using something like a jtag
connector
which is what oh
is used to program some of the other
boards
it's a very commonly used device
so that's really cool we got this
this is just a breakout board the actual
processor is inside
and that brings up the third thing that
i got
which is
a transparent case
so i mean obviously i need to have not
just i mean transparency is very
important to those of us who work in
open source ha ha he he
and
naturally we want to be transparent and
everything we do with electronics like
even the case itself
so yes what i will do
not right now because i don't have time
but
and i didn't want to do this before
because i'd like to do it together with
all of you so we can actually check out
how awesome this is going to look
is
take the case off that it comes with
this it's a cool looking black case
don't get me wrong this is really cool
looking but
a transparent case where we can actually
see all the electronics inside
is just so much cooler so that's what
we'll do
is we will switch over to this
transparent case and i promise i will
actually read the documentation so i
know a little bit better how it is
supposed to work
and then we can combine that information
together
to
complete some of the soldering jobs for
building some of the awesome stuff that
we need to work on
so that pretty much wraps it up um
it's been a really fun time we've gotten
to play with some toys we got to do some
machine learning
with
friend manuel who has been doing some
really interesting stuff with cow vision
really looking forward to seeing that in
full
um
splendor if you will
and then
lavenzo was here and we struggled a bit
to try to get the wi-fi
which is part of the example step 7
in the arduino nano 33 workshop
so it didn't quite work as expected got
to do a little research into that to
figure out why
and then had a chance to play with my
new toy
from our awesome friends at pine64
the pencil which is a risk five
completely programmable open source
soldering iron
the ultimate in hacker chic
so on that
i will say farewell and the dew
it has been fantastic and we will see
you again next week for more fun at
lapepa hacking hardware with dead
program myself and gopherbot
farewell farewell farewell farewell
[Music]
oh
[Music]
thank you
