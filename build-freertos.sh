#! /usr/bin/env bash

#################build a freertos from official repository######################

PATH_HOME=/home/shylock/Workspace/freertos

PATH_MIDDLEWARE=Middlewares

FREERTOS_COMPILER=GCC
FREERTOS_ARCH=ARM_CM7
FREERTOS_HEAP=heap_3.c

# create freertos directory
mkdir -p $PATH_MIDDLEWARE
mkdir -p $PATH_MIDDLEWARE/FreeRTOS
mkdir -p $PATH_MIDDLEWARE/Inc

# hyper source
rsync -av --exclude=portable $PATH_HOME/FreeRTOS/Source $PATH_MIDDLEWARE/FreeRTOS/

# portable
cp -r $PATH_HOME/FreeRTOS/Source/portable/$FREERTOS_COMPILER/$FREERTOS_ARCH/r0p1/ $PATH_MIDDLEWARE/FreeRTOS/Port
cp $PATH_HOME/FreeRTOS/Source/portable/MemMang/$FREERTOS_HEAP $PATH_MIDDLEWARE/FreeRTOS/Port

# FreeRTOSConfig.h
cp $PATH_HOME/FreeRTOS/Demo/CORTEX_M7_STM32F7_STM32756G-EVAL_IAR_Keil/FreeRTOSConfig.h Inc/



