# Embedded GNSS
Buildroot project for an embedded software-defined GNSS receiver.

## Making

Choose a board to build for and make that board's defconfig. Currently supported boards are:

  - **Raspberry Pi**: `make rpi_defconfig`

Now `make` (and maybe go make a coffee). Once this has finished building, you will have an image ready to load onto your board. See the documentation for the board to learn how to do this.

## Contact

Anthony Arnold

University of Queensland

`anthony.arnold at uqconnect dot edu dot au`

----
This file is part of egnss.

    egnss is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    egnss is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with egnss.  If not, see <http://www.gnu.org/licenses/>.