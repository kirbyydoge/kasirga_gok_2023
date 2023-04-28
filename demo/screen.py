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
parser.add_argument('--type' , '-t', default='color')

args = parser.parse_args()

view_port = args.view
type = args.type

view = serial.Serial(view_port, 2000000, timeout=None, write_timeout=None)

screen_dims = (20, 20)
screen_size = screen_dims[0] * screen_dims[1]
SCALE = 15

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

COLOR = type == "color"

pygame.init()
screen = pygame.display.set_mode((screen_dims[1] * SCALE, screen_dims[0] * SCALE))
square = pygame.Surface((SCALE, SCALE))
# font = pygame.font.Font(None, SCALE)
font = pygame.font.SysFont('consolas', SCALE + 2)

from queue import Queue
from threading import Thread

def read_worker(frames:Queue):
    screen_buffer = []
    while True:
        try:
            read = view.read(1)
            ord_val = int.from_bytes(read, 'little')
            if COLOR:
                val = ord_val
            else:
                val = read.decode('ascii')
            if ord_val != S_BYTE:
                screen_buffer.append(val)
                continue
            if len(screen_buffer) == screen_size:
                frames.put(screen_buffer)
            screen_buffer = []
        except KeyboardInterrupt:
            return
        except:
            screen_buffer = []


render_queue = Queue()
read_thread = Thread(target=read_worker, args=(render_queue,))
read_thread.start()

print("Starting")
frames = 0
screen_buf = []
key_state = 0
last_update = 0

while True:
    try:
        pygame.event.get()
        if (time.time() - last_update) > 2:
            print(f"FPS: {frames/2}")
            frames = 0
            last_update = time.time()
        frame = render_queue.get()
        if keyboard.is_pressed('w'):
            key_state |= W_MASK
        if keyboard.is_pressed('a'):
            key_state |= A_MASK
        if keyboard.is_pressed('s'):
            key_state |= S_MASK
        if keyboard.is_pressed('d'):
            key_state |= D_MASK
        try:
            status = key_state.to_bytes(2, 'little')
            view.write(bytes([status[0]]))
        except:
            pass
        finally:
            key_state = 0
        frames += 1
        if COLOR:
            for i in range(screen_dims[0]):
                for j in range(screen_dims[1]):
                    pixel = frame[i * screen_dims[1] + j]
                    color = from8bit(pixel)
                    square.fill(color)
                    screen.blit(square, pygame.Rect(j*SCALE, i*SCALE, SCALE, SCALE))
        else:
            square.fill((0, 0, 0))
            for i in range(screen_dims[0]):
                for j in range(screen_dims[1]):
                    char = frame[i * screen_dims[1] + j]
                    disp = font.render(char, False, (255, 255, 255))
                    screen.blit(square, pygame.Rect(j*SCALE, i*SCALE, SCALE, SCALE))
                    screen.blit(disp, pygame.Rect(j*SCALE, i*SCALE, SCALE, SCALE))
        pygame.display.flip()
    except KeyboardInterrupt:
        break
    except Exception as e:
        print(e)
        screen_buf = []

pygame.quit()
sys.exit()