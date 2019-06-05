## Android Application Analyzer

<p style="text-align: right">
Prepared by:</p>


<p style="text-align: right">
Kostiantyn Bykhkalo</p>


<p style="text-align: right">
Wojtek Bomba</p>


<p style="text-align: right">
Łukasz Kozieł </p>

## 


## Introduction

The task involves the development of a tool (module for the Android system) that will analyze the behavior of running applications. The analysis method checks calls to the “sys_call_table” of Android kernel. The goal is to build a profile of calls that will allow you to identify potentially dangerous applications (e.g. malware).

This is a simple Android rootkit, particularly by hooking the "__NR_openat" syscall, you can monitor the programs that access at the following files and check these call profile statuses.

We are listening on the next files list (if you want you can add more):



*   /data/data/com.android.providers.contacts/databases/contacts2.db
*   /data/data/com.android.providers.telephony/databases/telephony.db
*   /data/data/com.android.providers.telephony/databases/mmssms.db
*   /data/data/com.facebook.katana/databases
*   /data/data/com.facebook.orca/databases
*   /data/data/com.skype.raider/files/shared.xml
*   /data/data/com.whatsapp/shared_prefs
*   /data/data/com.whatsapp/shared_prefs/RegisterPhone.xml
*   /data/data/com.viber.voip/files 


## Environment

An important part of this task was using MacOS. Believe us - it isn’t a good decision and solution. Finally, we advise to use Docker - it’s easier than installing Ubuntu 16.04. Plus after all, you will have reusable Docker configuration for using in future.

All system was built on the macOS Mojave 10.14.5 (18F132). Based on the Google AOSP documentation, we have an ability to build AOSP and Linux Kernel for android on macOS. But actually, it isn't true. We can solve all problems which happen with AOSP building (but believe us it’s a lot), but not with Kernel. After a lot of tests, cases, builds, and configurations we have found a complete solution for implementations.  


## Android Modules

For creating this module we have inspired by the next sources:



*   CopperDroid – http://s2lab.isg.rhul.ac.uk/papers/files/ndss2015.pdf
    *   A very old example. There are no cases of using in the web anymore. Previously, it was available as a service for validating applications. But, the useful, interesting document describing the operation of the system behavior helped a lot.
*   DroidBox – https://github.com/pjlantz/droidbox
    *   Dynamic analysis of applications for Android. The problem is that the DroidBox has not been updated for 4 years and therefore does not work on Android over 4.4 (at the moment available Android 9). But analysis scripts is very interesting for us.
*   Cuckoo Droid –  https://github.com/idanr1986/cuckoo-droid
    *   It is an extension of the Cuckoo Sandbox Open Source software for automating the analysis of suspicious files, CuckooDroid brings Cuckoo the ability to perform and analyze applications on Android. The problem is that the system is very large and heavy for a proper startup.
*   Android Syscall Monitor - [https://github.com/invictus1306/Android-syscall-monitor](https://github.com/invictus1306/Android-syscall-monitor)
    *   Awesome example of creating Android Module for Linux system. Module part of work based on its module.


## AOSP

A lot of investigations, documentation, tutorials, articles, and forums. After all we have decided to start from the most reliable source – Google Android Source. Let`s visit [https://source.android.com/setup/build/requirements](https://source.android.com/setup/build/requirements) for our start.


### Advices:

* Configure python2.7 as default on your mac. Repo solution require it.

* Install Xcode CLI. Even you iOS Developer. 

* Install Android Studio and configure all instruments (it would be easier and more reliable than custom installing NDK, LLVM, JDK, etc).

* You need at least 200 gb. You can use external HDD/SSD (but anyway compiling will take long time, really long).


### Short Guide:

Creating a case-sensitive disk image. Might take long time.
```
hdiutil create -type SPARSE -fs 'Case-sensitive Journaled HFS+' -size 200g ~/android.dmg
```
Install the Xcode command line tools:
```
xcode-select --install
```
Install either [MacPorts](http://www.macports.org/install.php) or [Homebrew](https://brew.sh/) for package management.

Set limit to ~/.bash_profile
```
ulimit -S -n 1024
```
Download source. Visit [this page](https://source.android.com/setup/build/downloading) Please choose the master branch, based on [Google Forum's](https://groups.google.com/forum/#!topic/android-building/rwf1jQMhW_s) advice it would be the correct choice. We tried to compile AOSP for android-9.0.0_r36 but we got unsolved bugs and problems on MacOS.

Building. After repo sync just run the next commands in your terminal:

Attention! Mac does not support ARM processors! Don’t use ARM. Believe us.

```
source build/envsetup.sh
lunch 
# choose aosp_x86_64-eng
aosp_x86_64-eng
make -j8
emulator
```
If everything was correct before you should get working AOSP.


## Android Kernel

By start Android does not support loadable kernel modules, these are the steps to perform, for the kernel compiling and for the emulation of the Loadable Kernel Module. Also how we know now, we can’t compile Linux Kernel on the Mac operating system. The one stable and useful solution was using Docker on the board.


## Docker

For installing docker on your machine we advise checking the original Docker documentation.

[https://docs.docker.com/docker-for-mac/](https://docs.docker.com/docker-for-mac/)


## Android Kernel - Source

Based on the AOSP version and mac os using we decided to compile the next version:

[https://android.googlesource.com/kernel/common/+/android-4.14-p-release](https://android.googlesource.com/kernel/common/+/android-4.14-p-release)

For compiling this kernel we have to use Android GCC NDK tools. In our case it’s x86_64-linux-android-4.9 prebuilt gcc:

[https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9/](https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9/)

Just download all these sources and put it to the “android-4.14-p-release” and “android-ndk” accordingly.


## Run Step by Step

For the easiest implementations we create special 5 scripts and the one instruction for the last step. So it’s mean, that all is maximum automatically.


### Step 1 - Create the Docker

Create Docker container and configure it.

Docker file:

```
#Base image
FROM ubuntu:16.04
#Labels and Credits
 LABEL \
    name="docker-android-kernel" \
    author="Konstantyn Byhkalo <byhkalo.konstantyn@gmail.com>" \
    maintainer="Konstantyn Byhkalo <byhkalo.konstantyn@gmail.com>" \
    contributor_1="Konstantyn Byhkalo <byhkalo.konstantyn@gmail.com>" \ 
        description="Docker image for building Android common 4.14 kernel." 
    RUN apt-get update && \ 
      apt-get install -y bc build-essential make python-lunch qt4-default gcc-multilib distcc ccache 
    RUN apt install libelf-dev
    RUN apt install libelf-devel
```
Command line:
```
    docker build -t goldfish_android_kernel .
```
Or just run the first script:
```
    sh 1.first-run-docker.sh
```

### Step 2 - Into the Docker

Enter to the docker image:
```
    docker run -v $PWD/android-4.14-p-release/:/opt/kernel \ 
        -v $PWD/android-ndk:/opt/android-ndk \
        -v $PWD/androidLKM:/opt/androidLKM \
        -v $PWD/3.third-run-docker.sh:/3.third-run-docker.sh \
        -v $PWD/4.fourth-run-docker.sh:/opt/4.fourth-run-docker.sh \ 
        -it goldfish_android_kernel bash
```
Or just run the next script:

``` 
    sh 2.second-run-docker.sh
```

### Step 3.1 - Configure Kernel environment

In the Docker environment run next commands:

```
    cd opt/kernel
    echo $PWD
    
    export ARCH=x86_64
    echo "ARCH Configured \n"
    
    export CROSS_COMPILE=x86_64-linux-android-
    echo "CROSS_COMPILE Configured \n"
    
    export PATH=$PATH:/opt/android-ndk/bin
    echo "PATH Configured \n"
    
    echo "Run defconfig file. WAIT PLEASE ...\n"
    make x86_64_ranchu_defconfig 
    echo "Config finished \n"
```
Or just run the next script:

``` 
    source 3.third-run-docker.sh
```

### Step 3.2 - Build

Check and update .config file:

```
    CONFIG_MODULES=y 
    CONFIG_MODULE_UNLOAD=y
```
Start kernel build:
 
```
    make -j4
```

### Step 4 - Compile module file

```
    export SYSCALL_TABLE=$(grep sys_call_table $PWD/android-4.14-p-release/System.map | awk '{print $1}') 
    echo "SYSCALL_TABLE = " 
    echo SYSCALL_TABLE
    sed -i s/SYSCALL_TABLE/$SYSCALL_TABLE/g $PWD/androidLKM/lkm_android.c
    echo "Sed completed"
    cd androidLKM
    echo $PWD 
    make
```
Or just run the next script: 
```
    sh 4.fourth-run-docker.sh
```

### Step 5.1 - Start an emulator with Kernel:

Run in the AOSP Folder:

```
    source ~/.bash_profile
    source build/envsetup.sh
    lunch aosp_arm_x86_64-eng 
    emulator -debug init -kernel ~/android-4.14-p-release/arch/arm/boot/zImage -show_kernel
```

### Step 5.2 - Connect module:

You should have the $ANDROID_HOME path in your .bash_profile file. Next in the console:

```
    adb push $PWD/androidLKM/lkm_android.ko /data/lkm_android.ko
    ./adb shell
```
Or just run the next script:

``` 
    sh 5.fifth-run-adb.sh
```

### Step 6 - Check applications:

It your adb shell:

```
    cd /data
    insmod lkm_android.ko
    lsmod 
    lkm_android 450 - - Live 0x00000000 (PO)
```
All this commands available in the 6.sixth-run-instruction.txt file.


### Final - View the results:

```
    Task sh [PID:1738] make use of this file: /data/data/com.android.providers.contacts/databases/contacts2.db 
    Task sh [PID:1738] make use of this file: /data/data/com.facebook.katana/databases

```

<!-- Docs to Markdown version 1.0β17 -->
