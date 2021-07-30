import sys

lines = sys.stdin.readlines()
cur_line = -1

def input():
    global lines, cur_line
    cur_line += 1
    return lines[cur_line][:-1]



