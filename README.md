# Commodore 64 User Port Midi Input Device
> Simple Midi Input via the Commodore 64 User Port Interface<br />
> Created by D Cooper Dalrymple 2021 - [dcdalrymple.com](https://dcdalrymple.com/)<br />
> Licensed under GNU GPL V3.0<br />

I found myself in possession of a Commodore SX-64 and a desire to make music with it. After quickly finding [Cynthcart](https://www.qotile.net/cynthcart.html), I wasn't too happy about the idea of plugging both the Cynthcart cartridge and a separate Datel midi cartridge into in a [Mini X-Pander+](http://www.arkanixlabs.com/minixpander/) all sticking out of the hood of my SX-64. I had assumed that the User Port would have been a great interface for transmitting the necessary midi input data to whatever SID program you're jamming with. That's where this project comes in.

![First development unit of C64UserPortMidi with 3d-printed case](assets/case.jpg)

## Functionality
The concept is fairly simple: as soon as any data comes in via UART from a midi device, it is piped over to the shift register which is connected to the 8 data pins of the user port and the user port's flag interrupt pin is triggered. The compatible Commodore software that has an interrupt registered for the user port's flag pin then adds that 8-bit data register to a data buffer. The midi information would then need to be processed by the main loop of the software. Easy peasy!

I am aware that there are serial lines available on the user port that have been used for RS-232 communication and such, but I wanted to use the least amount of resources when transferring data from the bus to the Commodore software. A simple `lda $DD01` is all that is necessary to get the full byte during a flag interrupt.

## Components
I mostly used the components I had sitting around to design this which is why I picked the very limited ATtiny13A microcontroller to handle UART communication (without a UART hardware controller). That being said, the simple discrete components required make this an inexpensive option compared to other options out there. The [BOM I've compiled](https://www.digikey.com/BOM/Create/CreateSharedBom?bomId=8564682) makes this roughly $10 for all the parts (not including the PCB).

For future revisions, I might upgrade the tiny13 to an ATtiny2313 which has hardware UART support and enough IO pins to supply all 8 bits to the user port data bus. This (along with the jump to SMD components) would significantly decrease the size and maybe even the cost. _[Thanks mitxela for the advice!](https://mitxela.com/)_

![Schematic of C64UserPortMidi](assets/schematic.png)

## Development Status
I am currently working on fine-tuning the AVR firmware and the corresponding C64 testing cartridge software. After the first run of PCBs, there have been a few revisions to the hardware which have not been reflected in the current design. I advise from producing your own units until the hardware and software have been fully developed.

<p float="left">
<img src="assets/ports.jpg" width="32%" alt="View of ports on development unit of C64UserPortMidi device" />
<img src="assets/edge.jpg" width="32%" alt="View of edge connector on development unit of C64UserPortMidi device" />
<img src="assets/back.jpg" width="32%" alt="The back of the C64UserPortMidi development unit pcb" />
</p>

## Software
A testing cartridge for the C64 is in development and mostly complete. This easily fits on a small 4kb/8kb lo-rom cart and could be compiled for floppy if needed. It can be run in emulation, but it's very useful unless the debugging data is enabled.

I plan to fork the Cynthcart repo once testing is completed to include full compatibility with this device.

## Midi Thru
I know this device is limited in that it doesn't include a midi thru port, but I recommend using an external midi thru box (such as those offered by [MIDI Solutions](http://midisolutions.com/)) if desired. Future revisions might include both midi thru and out if there is a need for it.
