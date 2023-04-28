import serial
import argparse
import os
import time
 
parser = argparse.ArgumentParser()

parser.add_argument('hex', help='')
parser.add_argument('--port' , '-p', default='COM6' , help='serial port\'un ismi')

args = parser.parse_args()

serial_port = args.port 
hex = args.hex

ser = serial.Serial(serial_port, 9600)

hex_f = open(hex)

hex_arr = hex_f.readlines()

hex_bytes = (len(hex_arr))

hex_data = hex_bytes.to_bytes(4, 'big')

ser.write(bytes("TEKNOFEST", encoding="ASCII"))

for i in range(4):
    ser.write(bytes([hex_data[i]]))

print("Buyruk bellegini gonderiyorum... [" + str(hex_bytes) + " bayt]")

byte_counter = 0
for line in hex_arr:
    hex_str = line[:8].lstrip().strip()
    hex_data = bytearray.fromhex(hex_str)
    for i in range(4):
        print('{:02x}'.format(hex_data[3-i]), end="")
        ser.write(bytes([hex_data[i]]))
    byte_counter += 1
    print("                                                          ", end = "\r")
    print("%" + "{:.2f}".format((byte_counter/hex_bytes) * 100) + " bitti", end = "\r", flush = True)

print("Programladimmm")
