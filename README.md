# Base Boxes
Useful Base Box creation capabilities using Packer for Fraedom contributors

## Software Dependencies

The following dependencies need to be installed on the machine used to build the base boxes. At this time VirtualBox does not support nested virtualization so the recommended way to build boxes is to have these installed on bare metal. The versions in brackets below are those that have been tested at this time. That is not to say other versions will not work, but at this time we are not supporting other versions.

* [Packer](https://www.packer.io/)  (0.8.6)
* [VirtualBox](https://www.virtualbox.org/) (5.0.10-104061)
* [Vagrant](https://www.vagrantup.com/) (1.7.4)

These dependencies can be installed using [Chocolatey](https://chocolatey.org/). The [init.bat](init.bat) script will install the latest version if none is found on the machine it is run on.

## Quick Start

### Install Software Dependencies
The quickest way to install the dependencies is to run the [init.bat](init.bat) script. This will use [Chocolatey](https://chocolatey.org/) to install the Software Dependencies. It will install the following versions of the Software Dependencies at this time using Chocolatey.

* [Packer](https://www.packer.io/)  (0.8.6)
* [VirtualBox](https://www.virtualbox.org/) (5.0.10-104061)
* [Vagrant](https://www.vagrantup.com/) (1.7.4)

If you have any of these installed at this time and don't want to install these versions then you should edit the [init.bat](init.bat) script before running it.

### Download An Appropriate ISO

Details of ISO requirements can be found [here](iso/README.md) including download instructions. For this Quick Start download the Windows 8.1 Enterprise with Updates (x64) ISO using the direct download link.

### Build Your First Base Box

Once you have an appropriate ISO downloaded to the [iso](iso) folder you are ready to build your first box.

    PACKER_LOG=1 packer build -force -machine-readable win81x86-enterprise.json

This will start the build of your base box. Once this is complete a box file will appear in your box folder.

### Import your Box into Vagrant

To use your box you need to import it into [Vagrant](https://www.vagrantup.com/). In the test folder is a [metadata.json](test/metadata.json) file that should be used for this purpose. It has a link to the box and appropriate checksum. It also supplies a version of the box so that updates can be implemented in a Vagrant native way. To import the box issue the following command from within the test folder:

    vagrant box add --force metadata.json
    
Once the box is imported if you issue the command `vagrant box list -i` you should see the following box listed

    fraedom/dev-box  (virtualbox, 0.1.0)
    
### Start your Box

Now you have a box ready for use by vagrant. In the directory you would like to initialise your box (not usually in the repository!) run the following command:

    vagrant init fraedom/dev-box
    
This will provide a Vagrantfile that will delegate all control to the Vagrantfile baked into the box at build time. Now to run the machine:

    vagrant up

### TO-DO
* Provide a pipeline template for automated build, import and initialization of boxes
* Document how to change the Chocolatey version checked for and installed
* Document how to change the init.bat script to install different versions of the Software Dependencies
* Provide an internal ISO storage for simpler ISO discovery and download
* Update box build scripts to install from internal repository (at this time external downloads)