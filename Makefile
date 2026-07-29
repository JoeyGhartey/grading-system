CC = gcc
CFLAGS = -g -O0
TARGET = grading_system.exe
SRC = grading_system.s

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

clean:
	rm -f $(TARGET) *.o *.dat *.csv

run: $(TARGET)
	./$(TARGET)

.PHONY: all clean run
