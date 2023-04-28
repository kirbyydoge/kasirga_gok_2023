import serial
import argparse
import os
import pygame, sys, random
from pygame.locals import *
import time
import keyboard
import traceback
 
parser = argparse.ArgumentParser(description='')
parser.add_argument('--view' , '-v', default='/dev/ttyUSB2')

args = parser.parse_args()

view_port = args.view

view = serial.Serial(view_port, 460800, timeout=None, write_timeout=None)

screen_dims = (40, 40)
screen_size = screen_dims[0] * screen_dims[1]
SCALE = 10

screen = pygame.display.set_mode((screen_dims[1] * SCALE, screen_dims[0] * SCALE))
square = pygame.Surface((SCALE, SCALE))

def from8bit(val):
    r = (val & 0xe0) >> 5
    g = (val & 0x1c) >> 2
    b = val & 0x03
    return (r * 255 // 7, g * 255 // 7, b * 255 // 3)

W_MASK = int(0x01)
A_MASK = int(0x02)
S_MASK = int(0x04)
D_MASK = int(0x08)
S_BYTE = int(0x01)

print("Starting")
frames = 0
screen_buf = []
key_state = 0
last_update = 0
while True:
    try:
        if (time.time() - last_update) > 2:
            print(f"FPS: {frames/2}")
            frames = 0
            last_update = time.time()
        if keyboard.is_pressed('w'):
            key_state |= W_MASK
        if keyboard.is_pressed('a'):
            key_state |= A_MASK
        if keyboard.is_pressed('s'):
            key_state |= S_MASK
        if keyboard.is_pressed('d'):
            key_state |= D_MASK
        read = view.read(1)
        val = int.from_bytes(read, 'little')
        if val != S_BYTE:
            screen_buf.append(val)
            continue
        try:
            status = key_state.to_bytes(2, 'little')
            view.write(bytes([status[0]]))
        except:
            pass
        finally:
            key_state = 0
        view.flushOutput()
        if len(screen_buf) < screen_size:
            screen_buf = []
            continue
        frames += 1
        pygame.event.get()
        for i in range(screen_dims[0]):
            for j in range(screen_dims[1]):
                pixel = screen_buf[i * screen_dims[1] + j]
                color = from8bit(pixel)
                square.fill(color)
                screen.blit(square, pygame.Rect(j*SCALE, i*SCALE, SCALE, SCALE))
        pygame.display.flip()
        screen_buf = []
    except KeyboardInterrupt:
        break
    except Exception as e:
        print(e)
        screen_buf = []
