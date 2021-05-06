NAME = sustoraged
BIN = bin
OBJ = obj

SOURCES = $(wildcard src/*.c)
OBJECTS = $(patsubst src/%.c,$(OBJ)/%.o,$(SOURCES))

FLAGS   = -Wall -Wextra -std=c99
LFLAGS  = -pthread

$(OBJ)/%.o: src/%.c
	@echo "\e[1mBuilding \e[4m$@\e[0m"
	@mkdir -p $(@D)
	@$(CC) $(FLAGS) $(CFLAGS) -c -o $@ $<

$(BIN)/$(NAME): $(OBJECTS)
	@echo "\e[1mLinking \e[4m$@\e[0m"
	@mkdir -p $(@D)
	@$(CC) $(LFLAGS) $(LDFLAGS) -o $@ $^

cleanobj:
	@echo "Cleaning objects"
	@rm -fv $(OBJECTS)

clean: cleanobj
	@echo "Cleaning executables"
	@rm -fv $(BIN)/$(NAME)

# vim: filetype=make tabstop=2 shiftwidth=2
