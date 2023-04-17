import serial
import argparse
import os
import time
 
parser = argparse.ArgumentParser(description='C0 SoC\'ye program yukle')

parser.add_argument('--port' , '-p', default='/dev/ttyUSB1' , help='serial port\'un ismi')

args = parser.parse_args()

serial_port = args.port 

ser = serial.Serial(serial_port, 115200)

message = "e" * 100

ser.write(bytes(message, encoding="ASCII"))